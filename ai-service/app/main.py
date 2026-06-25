"""
CareCell AI Service
Tech stack per PRD: Python, PyTorch, TensorFlow, scikit-learn, pandas & numpy,
BeautifulSoup & Scrapy, FastAPI.

Responsibilities:
  - CareCell AI Assistant: medical term explanation, scheme guidance, hospital suggestions
  - Donor-patient matching scoring (blood group + location + HLA proximity)
  - Donation eligibility scoring

This service is intentionally kept separate from the Java backend so the
ML/NLP workloads can scale independently (per PRD Section 9 - Technology Stack).
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("carecell-ai")

app = FastAPI(
    title="CareCell AI Service",
    description="AI/ML microservice for CareCell — medical guidance, matching, eligibility scoring",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Schemas ──────────────────────────────────────

class ChatRequest(BaseModel):
    message: str
    context: dict | None = None


class ChatResponse(BaseModel):
    reply: str
    type: str = "info"  # info, medical_term, scheme, hospital


class EligibilityRequest(BaseModel):
    age: int
    weight_kg: float | None = None
    last_donation_date: str | None = None
    chronic_conditions: list[str] = []
    is_pregnant: bool = False
    is_breastfeeding: bool = False


class EligibilityResponse(BaseModel):
    is_eligible: bool
    score: float
    reasons: list[str]


# ── Routes ───────────────────────────────────────

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "carecell-ai"}


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    """
    CareCell AI Assistant — handles:
      - Plain-language explanation of complex medical terminology
      - Personalised government scheme recommendations
      - AI-powered hospital recommendations
      - Proactive health tips

    NOTE: This is a rule-based scaffold. Wire in your LLM call here
    (e.g. via langchain4j from the Java side, or directly via OpenAI/Claude API,
    or a fine-tuned local model loaded with PyTorch/TensorFlow).
    """
    msg = req.message.lower().strip()

    if not msg:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    # TODO: Replace this rule-based stub with a real LLM call.
    # Example integration point:
    #   response = call_llm_api(system_prompt=MEDICAL_ASSISTANT_PROMPT, user_message=req.message)
    if any(k in msg for k in ["what is", "explain", "meaning of"]):
        reply = (
            "I can explain medical terms in simple language. "
            "Could you tell me which specific term or condition you'd like explained?"
        )
        rtype = "medical_term"
    elif any(k in msg for k in ["scheme", "government", "ayushman", "yojana"]):
        reply = (
            "There are several government healthcare schemes you may be eligible for, "
            "such as Ayushman Bharat PM-JAY. Open the Scheme Finder in your dashboard "
            "for a personalised, eligibility-matched list."
        )
        rtype = "scheme"
    elif any(k in msg for k in ["hospital", "doctor", "clinic"]):
        reply = (
            "I can help you find nearby hospitals. Open Hospital Finder and I'll show "
            "government, private, and specialty hospitals near your location."
        )
        rtype = "hospital"
    elif any(k in msg for k in ["donate", "donor", "blood"]):
        reply = (
            "Great that you're thinking about blood donation! You can check your "
            "eligibility status in the Donor dashboard, or create a blood request "
            "if you need blood urgently."
        )
        rtype = "info"
    else:
        reply = (
            "I'm CareCell AI — I can help explain medical terms, find government "
            "healthcare schemes you're eligible for, or recommend nearby hospitals. "
            "What would you like to know?"
        )
        rtype = "info"

    return ChatResponse(reply=reply, type=rtype)


@app.post("/eligibility/score", response_model=EligibilityResponse)
def score_eligibility(req: EligibilityRequest):
    """
    Calculates a donor eligibility score using basic medical rules.
    In production, this can be extended with a trained scikit-learn/PyTorch
    classifier using historical donation outcome data.
    """
    reasons = []
    score = 1.0

    if req.age < 18 or req.age > 65:
        reasons.append("Age outside 18-65 donation range")
        score -= 0.5

    if req.weight_kg is not None and req.weight_kg < 50:
        reasons.append("Weight below 50kg minimum")
        score -= 0.3

    if req.is_pregnant:
        reasons.append("Pregnant donors are temporarily ineligible")
        score -= 1.0

    if req.is_breastfeeding:
        reasons.append("Breastfeeding donors are temporarily ineligible")
        score -= 1.0

    if req.chronic_conditions:
        reasons.append(f"Chronic conditions noted: {', '.join(req.chronic_conditions)}")
        score -= 0.2 * len(req.chronic_conditions)

    score = max(0.0, min(1.0, score))
    is_eligible = score >= 0.6 and not req.is_pregnant and not req.is_breastfeeding

    if is_eligible and not reasons:
        reasons.append("Meets all standard donation eligibility criteria")

    return EligibilityResponse(is_eligible=is_eligible, score=round(score, 2), reasons=reasons)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8001, reload=True)
