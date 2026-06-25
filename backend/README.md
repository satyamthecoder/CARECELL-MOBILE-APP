# CareCell Backend

Java 21 · Spring Boot 3.2 · MongoDB Atlas · Redis · AWS (S3 + SNS)

Production REST API for the CareCell healthcare platform, covering both the
Patient flow and the Donor flow described in the PRD.

## Quick Start (Local, with Docker)

From the **repo root** (not this folder):

```bash
cp .env.example .env
# edit .env and fill in MONGODB_URI / JWT_SECRET / AWS keys / Google Maps key
docker compose up --build
```

The API will be live at `http://localhost:8080`. Swagger UI:
`http://localhost:8080/swagger-ui.html`.

## Quick Start (Without Docker)

Requirements: JDK 21, Maven 3.9+, a running MongoDB instance, a running Redis instance.

```bash
cd backend
cp src/main/resources/application.yml src/main/resources/application-local.yml
# edit application-local.yml with your local Mongo/Redis URIs

mvn clean install
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

## Project Layout

```
src/main/java/com/carecell/
├── config/        Security, CORS, Mongo, Redis, AWS, Swagger beans
├── controller/     REST endpoints (Auth, Patient, Donor, Public)
├── dto/            Request/response objects (validation annotations live here)
├── entity/         MongoDB documents (User, HealthProfile, DonorProfile, ...)
├── enums/          UserRole, BloodGroup, DonationType, MatchStatus, ...
├── exception/      Global exception handler + custom exceptions
├── repository/     Spring Data MongoDB repositories
├── security/       JWT provider + filter
├── service/        Business logic (OTP, S3 storage, blood matching, SOS, ...)
└── util/           HealthIdGenerator and other helpers
```

## API Surface (high level)

| Area | Base path | Notes |
|---|---|---|
| Auth | `/api/v1/auth/*` | register, send-otp, verify-otp, login, refresh-token, forgot/reset password |
| Patient | `/api/v1/patient/*` | dashboard, health profile, health card, SOS, blood requests, records, treatments |
| Donor | `/api/v1/donor/*` | dashboard, donor profile, donor card, match requests, eligibility, records |
| Public | `/api/v1/public/*` | hospital finder (Google Places proxy), scheme finder, AI chat proxy |

Full interactive docs at `/swagger-ui.html` once running.

## Authentication Flow

1. `POST /auth/register` — creates the user, sends an OTP via SMS (AWS SNS).
2. `POST /auth/verify-otp` — marks `mobileVerified = true`.
3. `POST /auth/login` — returns `accessToken` (24h) + `refreshToken` (7d).
4. Every protected request needs `Authorization: Bearer <accessToken>`.
5. `POST /auth/refresh-token` when the access token expires.

Role-based access is enforced at the Spring Security layer:
`/api/v1/patient/**` requires `ROLE_PATIENT`, `/api/v1/donor/**` requires `ROLE_DONOR`.

## Running Tests

```bash
mvn test
```

Tests use Testcontainers to spin up a real MongoDB instance (the same `mongo:7`
image used in `docker-compose.yml`) in a Docker container automatically.
**Docker must be running** on the machine executing `mvn test` — Testcontainers
starts and tears down the container itself, but it needs a Docker daemon
available to do so. No manually-managed external database is needed; you do
not need to start MongoDB yourself before running tests, only Docker itself.

## Environment Variables

See `.env.example` in the repo root for the full list. The critical ones to
get a working dev environment:

- `MONGODB_URI`
- `JWT_SECRET` (generate with `openssl rand -base64 32`)
- `AWS_ACCESS_KEY` / `AWS_SECRET_KEY` / `AWS_S3_BUCKET` (for health record uploads + OTP SMS)
- `GOOGLE_MAPS_API_KEY` (for Hospital Finder)

## Troubleshooting

**Logs show repeating `MailHealthIndicator ... 535-5.7.8 BadCredentials` every ~30-90s.**
This is Spring Boot Actuator auto-detecting `spring-boot-starter-mail` on the
classpath and running a live SMTP login test against `MAIL_HOST` on every
`/actuator/health` call — including the Docker `HEALTHCHECK` directive, which
polls every 30s by default. Mail is **not used anywhere in this codebase
yet** and is not required for the app to function (OTP delivery is SMS via
AWS SNS). Fix: leave `MAIL_USERNAME`/`MAIL_PASSWORD` blank in `.env` and keep
`MAIL_HEALTH_ENABLED=false` (the default) — this disables the indicator
entirely. If you later add a real mail feature (e.g. password-reset email),
set `MAIL_HEALTH_ENABLED=true` and note that Gmail requires an
[App Password](https://myaccount.google.com/apppasswords), not your regular
account password — a regular password will always produce this exact error
regardless of whether it's typed correctly.

## Production Notes

- The `HealthIdGenerator` util uses an in-memory `AtomicLong` counter, which is
  **not safe across multiple backend instances**. Before scaling horizontally,
  replace it with a Redis `INCR`-based or MongoDB sequence-collection approach.
- Rate limiting (Bucket4j dependency is already in `pom.xml`) is referenced in
  config but the filter itself needs to be wired up — see the requirements
  checklist in the root `README.md`.
- `BloodMatchingService` is stubbed to call `NotificationService`; the FCM
  push-notification call is a `TODO` — currently only SMS is wired.
