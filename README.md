# CareCell — AI-Powered Healthcare Assistance Platform

Production-ready scaffold for the CareCell MVP described in the PRD: a
two-role (Patient / Donor) healthcare platform with emergency SOS, blood
donation matching, hospital & scheme finders, an AI assistant, and encrypted
health record storage.

This repository contains three independently deployable services:

```
carecell/
├── backend/        Java 21 + Spring Boot 3.2 — REST API, auth, business logic
├── frontend/        Flutter — Android + iOS app (Patient & Donor flows)
├── ai-service/       Python + FastAPI — CareCell AI assistant, eligibility scoring
├── docker-compose.yml  Runs all three + MongoDB + Redis locally with one command
└── .env.example        Every secret/config value you need to fill in
```

---

## 1. Run It Locally (fastest path)

```bash
cp .env.example .env
```

Open `.env` and fill in **at minimum**: `JWT_SECRET` (generate with
`openssl rand -base64 32`). Everything else has a working local default via
Docker Compose, except features that call external paid APIs (AWS, Google
Maps) — those will simply no-op gracefully until you add real keys.

```bash
docker compose up --build
```

This starts: MongoDB, Redis, the Spring Boot backend (`:8080`), the FastAPI
AI service (`:8001`), and a Mongo admin UI (`:8081`). Swagger docs are at
`http://localhost:8080/swagger-ui.html`.

Then, separately, run the Flutter app:
```bash
cd frontend
flutter pub get
flutter run
```

---

## 2. What Is Genuinely Done

Reading this honestly matters more than a long checkmark list, so here's
what's real:

- **Full backend domain model** matching every entity in the PRD: User
  (role-differentiated Patient/Donor), HealthProfile, DonorProfile,
  BloodRequest, HealthRecord, Treatment, AuditLog — with proper MongoDB
  indexes, geo-queries for donor proximity matching, and blood-type
  compatibility logic.
- **Full auth flow**: registration with age-based guardian-consent branching
  (PRD Section 6.2), donor under-18 hard block (PRD Section 7.2), OTP via AWS
  SNS cached in Redis with attempt-limiting, JWT access+refresh tokens,
  BCrypt password hashing, role-based endpoint authorization.
- **Every MVP module from PRD Section 12** has a working controller +
  service: Digital Health Card with QR, SOS with emergency-contact SMS
  alerts + audit logging, Blood Donation Network with geo-radius donor
  matching and automatic state-wide fallback, Hospital Finder (Google
  Places proxy), Scheme Finder, an AI Assistant proxy, encrypted S3 health
  record storage with pre-signed URLs, Treatment Tracker.
- **Full Flutter app**: both onboarding flows (Patient + Donor) faithfully
  reproducing the PRD's age-verification and guardian-consent screens, both
  dashboards with all listed feature tiles, and a working screen behind
  every tile — wired to real API calls via Dio with automatic token refresh
  on 401.
- **Production scaffolding**: multi-stage Dockerfiles for both backend and
  AI service, docker-compose for the full local stack, GitHub Actions CI for
  both backend and frontend, Android manifest with every permission the app
  actually uses, iOS Info.plist with App-Store-required usage descriptions.

## 3. What Is Stubbed and Needs Your Decision

Being equally honest about the other half:

- **CareCell AI** (`ai-service/app/main.py`) is currently **rule-based
  keyword matching**, not a real LLM. It's structured so you can drop in a
  call to Claude/OpenAI/a fine-tuned local model in one place
  (`chat()` function). The PRD's tech stack lists PyTorch/TensorFlow,
  suggesting you may intend to train or fine-tune your own model — that
  training pipeline does not exist here and is a substantial project in
  itself.
- **Government schemes** (`PublicController.findSchemes()`) returns a static
  hardcoded list of 6 well-known schemes. The PRD says "search across
  hundreds of government schemes" — that requires either a licensed data
  source/API or a scraping pipeline (the `beautifulsoup4`/`scrapy`
  dependencies are in `ai-service/requirements.txt` for exactly this, but no
  scraper is implemented).
- **WhatsApp Assistant** has UI placeholders only. Per PRD 8.8 this needs a
  Meta WhatsApp Business Cloud API (or Twilio) integration, a verified
  business phone number, and webhook handling for inbound messages — none of
  which can be scaffolded without your business account details.
- **File upload from the Flutter app** — the bottom-sheet UI exists in
  `health_records_screen.dart` and `donor_records_screen.dart`, but the
  actual `image_picker`/`file_picker` → multipart POST wiring is a TODO.
  The backend endpoint (`POST /patient/records`) is fully functional and
  tested via Swagger; it just isn't called from the UI yet.
- **Push notifications**: Firebase dependencies are included,
  `Firebase.initializeApp()` is commented out in `main.dart` pending your
  `google-services.json`. The backend's `NotificationService` sends SMS via
  SNS but has a `TODO` where the FCM push call belongs.
- **HealthIdGenerator** uses an in-process counter — fine for a single
  instance, **not safe once you run multiple backend replicas**. Needs a
  Redis `INCR` or DB-sequence swap before horizontal scaling.
- **Rate limiting**: Bucket4j is a dependency but the actual filter isn't
  wired into the security chain yet — currently nothing stops a single
  client from hammering `/auth/send-otp`.
- **LifeMatch (PRD Section 14)** is explicitly out of scope per the PRD
  itself ("a SEPARATE future platform — not part of the current MVP") and
  is correctly **not** built here.

---

## 4. Complete Checklist — Things Only You Can Do

This is the real "what's left" list. Nothing on it is code I can write for
you without your accounts, business decisions, or legal review.

### Accounts & Keys (do these first — almost nothing works without them)
- [ ] **MongoDB Atlas** — create a cluster, get the connection string, put it
      in `MONGODB_URI`. (Local Docker Mongo works for dev without this.)
- [ ] **AWS account** — create an S3 bucket (for encrypted health records)
      and enable SNS (for OTP SMS). Note: AWS SNS SMS to Indian numbers
      requires moving your AWS account out of the SNS "sandbox" — this is a
      support-ticket process with AWS, budget a few days.
- [ ] **Google Cloud / Maps Platform** — enable the Places API and Maps SDK,
      get an API key, restrict it to your app's package name / bundle ID,
      set a billing alert (Places API is pay-per-call).
- [ ] **Firebase project** — for push notifications. Download
      `google-services.json` (Android) and `GoogleService-Info.plist` (iOS),
      drop them into the paths noted in `frontend/README.md`.
- [ ] **WhatsApp Business** — Meta Cloud API access (requires Facebook
      Business verification) or a Twilio WhatsApp sender, if you want
      Section 8.8 to actually work.
- [ ] **A real LLM provider key** (Anthropic/OpenAI/etc.) if you don't plan
      to train your own model for CareCell AI.

### Legal / Compliance (this is a healthcare app — do not skip)
- [ ] **Privacy Policy & Terms of Service** — required by both app stores
      and, more importantly, because you're storing health data. Consult an
      actual lawyer familiar with Indian health-data regulation (DPDP Act
      2023) — this is not optional for a real launch.
- [ ] **Data retention & deletion policy** — what happens to a user's health
      records when they delete their account? The schema supports
      soft-delete (`active` flag) but no automated purge job exists.
- [ ] **Medical disclaimer review** — the AI assistant already includes a
      disclaimer string per PRD 8.7, but have it reviewed by counsel/a
      medical advisor before launch, not just engineering.
- [ ] **Guardian consent legal sufficiency** — the app captures a typed
      name as "signature" for minors (`guardianSignature` field in the
      entity). Confirm with counsel whether this meets the bar you need, or
      whether you need actual e-signature capture (DocuSign-style) or
      OTP-verified guardian consent instead.

### Infrastructure & Deployment
- [ ] Pick a hosting target for the backend + AI service (AWS ECS/Fargate,
      Railway, Render, etc. — `docker-compose.yml` runs anywhere that
      supports Docker Compose, but production usually wants a managed
      container service with auto-scaling).
- [ ] Generate a **real production `JWT_SECRET`** — never reuse the example
      or any value that's been in this conversation.
- [ ] Set up a release Android **keystore** and configure
      `android/app/build.gradle` properly — it currently signs release
      builds with the debug key, which Google Play will reject.
- [ ] Set up Apple Developer Program enrollment + App Store Connect listing
      for iOS distribution.
- [ ] Configure a real domain + TLS cert for the backend (`api.carecell.in`
      is used as a placeholder throughout — search-replace it).
- [ ] Decide on and wire up the **rate-limiting filter** (Bucket4j dependency
      is present but unconnected) before exposing OTP endpoints publicly.

### Product Decisions Needed Before Engineering Can Finish
- [ ] **Scheme data source** — license a government scheme API/dataset, or
      approve a scraping approach (legal review needed for scraping gov.in
      sites — check robots.txt and terms first).
- [ ] **AI model choice** — fine-tune your own (PyTorch/TensorFlow per your
      tech stack doc) vs. call a hosted LLM API. This is a build-vs-buy
      decision with real cost/timeline tradeoffs your team should weigh in
      on.
- [ ] **Blood-cooldown business rules** — current code uses a flat 90-day
      whole-blood cooldown (`DonorServiceImpl.recordDonation`). Confirm this
      matches actual medical guidance for your target donor population
      (platelet/plasma cooldowns are typically shorter — the field exists
      but isn't differentiated by donation type yet).
- [ ] **Notification provider for production SMS volume** — AWS SNS works
      for moderate volume; at real scale you may want a dedicated Indian SMS
      gateway (e.g. one that's DLT-registered per TRAI regulations, which
      AWS SNS is not, by default) for OTP delivery reliability.

### Testing Before Real Users Touch It
- [ ] **Docker must be running locally to execute `mvn test`** — the backend's
      test suite uses Testcontainers, which starts a real `mongo:7` container
      automatically. This is not optional infrastructure to set up separately;
      if Docker isn't running, `mvn test` will fail to start. (GitHub Actions'
      `ubuntu-latest` runners have Docker available by default, so CI needs no
      extra setup — this only matters for running tests on your own machine.)
- [ ] Add Flutter widget/integration tests (none are scaffolded yet beyond
      the backend's Java test suite).
- [ ] Load-test the donor-matching geo-query (`UserRepository
      .findEligibleDonorsNearby`) at your expected donor-pool size. (The
      required `2dsphere` index is now declared via `@GeoSpatialIndexed` on
      `User.location` with `auto-index-creation: true` set in
      `application.yml`, so the index itself will exist — this item is now
      about *performance at scale*, not correctness.)
- [ ] Penetration test / security review before handling real health data —
      this app touches PII and PHI; a professional security audit is
      standard practice for healthtech, not optional polish.

---

## 5. Tech Stack (as implemented)

| Layer | Technology |
|---|---|
| Frontend | Flutter, Dart, Riverpod, GoRouter, Dio |
| Backend | Java 21, Spring Boot 3.2, Spring Security, JWT |
| Database | MongoDB (Atlas-ready), Redis (OTP cache, sessions) |
| Cloud | AWS S3 (health records), AWS SNS (OTP SMS) |
| AI / ML | Python, FastAPI (rule-based scaffold — see Section 3 above) |
| Maps | Google Places API (Hospital Finder) |
| CI/CD | GitHub Actions (backend + frontend pipelines included) |

This matches the tech stack from your PRD's Section 9, with Postman/Appium/
JMeter testing tooling left for your QA team to set up against the live
Swagger-documented API, since those are testing workflows rather than
application code.
