"""
Forest Academy E-Center — Python FastAPI Backend
=================================================
PDF Text Extraction (PyMuPDF/pdfplumber) + Groq LLM Quiz Generation

Endpoints:
  GET  /health              — Health check
  POST /generate-quiz       — PDF URL → extracted text → Groq → MCQ JSON
  POST /ai-assistant        — Trainee question → Groq → Answer

Groq API Key stored in .env — NEVER exposed to Flutter.
"""

import os
import re
import json
import logging
import requests
import tempfile
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, HttpUrl
from dotenv import load_dotenv

from services.pdf_extractor import PdfExtractor
from services.groq_service import GroqService
from services.quiz_validator import QuizValidator

# ── Setup ─────────────────────────────────────────────────────────────────────

load_dotenv()
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Forest Academy AI Backend",
    description="PDF extraction + Groq LLM quiz generation for A.P. State Forest Academy",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict to your Flutter app origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

pdf_extractor = PdfExtractor()
groq_service = GroqService()
quiz_validator = QuizValidator()

# ── Request/Response Models ────────────────────────────────────────────────────

class GenerateQuizRequest(BaseModel):
    pdf_url: str
    quiz_title: str = "Forest Training Quiz"
    max_questions: int = 8

class AiAssistantRequest(BaseModel):
    question: str
    course_id: Optional[str] = None
    domain: str = "forestry education"

class HealthResponse(BaseModel):
    status: str
    groq_configured: bool
    version: str

# ── Routes ────────────────────────────────────────────────────────────────────

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint — Flutter app calls this to verify backend is running."""
    return HealthResponse(
        status="ok",
        groq_configured=bool(os.getenv("GROQ_API_KEY")),
        version="1.0.0",
    )


@app.post("/generate-quiz")
async def generate_quiz(req: GenerateQuizRequest):
    """
    Main endpoint: PDF URL → extract text → Groq → structured MCQ JSON
    
    Flow:
    1. Download PDF from Firebase Storage URL
    2. Extract text using PyMuPDF (primary) or pdfplumber (fallback)
    3. Clean and chunk text
    4. Send to Groq with forestry education prompt
    5. Validate JSON response
    6. Return structured questions
    """
    logger.info(f"Quiz generation request: {req.quiz_title}, max_questions={req.max_questions}")

    # Step 1: Download PDF
    try:
        pdf_content = _download_pdf(req.pdf_url)
    except Exception as e:
        logger.error(f"PDF download failed: {e}")
        raise HTTPException(status_code=422, detail=f"Could not download PDF: {str(e)}")

    # Step 2: Extract text
    try:
        extracted_text = pdf_extractor.extract_text(pdf_content)
    except Exception as e:
        logger.error(f"Text extraction failed: {e}")
        raise HTTPException(status_code=422, detail=f"PDF text extraction failed: {str(e)}")

    if not extracted_text or len(extracted_text.strip()) < 100:
        raise HTTPException(
            status_code=422,
            detail="PDF appears to be empty or image-only. Text-based PDFs required for AI generation."
        )

    logger.info(f"Extracted {len(extracted_text)} characters from PDF")

    # Step 3: Generate quiz via Groq
    try:
        raw_response = await groq_service.generate_quiz(
            text=extracted_text,
            title=req.quiz_title,
            max_questions=req.max_questions,
        )
    except Exception as e:
        logger.error(f"Groq generation failed: {e}")
        raise HTTPException(status_code=500, detail=f"AI generation failed: {str(e)}")

    # Step 4: Validate & parse
    try:
        quiz_data = quiz_validator.parse_and_validate(raw_response, req.quiz_title)
    except Exception as e:
        logger.error(f"Quiz validation failed: {e}\nRaw: {raw_response[:500]}")
        raise HTTPException(
            status_code=500,
            detail=f"AI returned malformed quiz data. Please retry. ({str(e)})"
        )

    logger.info(f"Successfully generated {len(quiz_data['questions'])} questions")
    return quiz_data


@app.post("/ai-assistant")
async def ai_assistant(req: AiAssistantRequest):
    """
    Trainee AI learning assistant.
    Answers questions related to forestry education.
    """
    if not req.question.strip():
        raise HTTPException(status_code=400, detail="Question cannot be empty")

    try:
        answer = await groq_service.answer_question(
            question=req.question,
            domain=req.domain,
        )
        return {"answer": answer, "disclaimer": True}
    except Exception as e:
        logger.error(f"AI assistant error: {e}")
        raise HTTPException(status_code=500, detail=f"Assistant unavailable: {str(e)}")


# ── Helpers ────────────────────────────────────────────────────────────────────

def _download_pdf(url: str) -> bytes:
    """Download PDF from Firebase Storage URL."""
    response = requests.get(url, timeout=30, stream=True)
    response.raise_for_status()

    content_type = response.headers.get("Content-Type", "")
    if "pdf" not in content_type and not url.lower().endswith(".pdf"):
        # Firebase Storage URLs may not have content-type — check first bytes
        content = response.content
        if not content.startswith(b"%PDF"):
            raise ValueError("Downloaded file is not a valid PDF")
        return content

    return response.content


# ── Entry Point ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.getenv("PORT", 8000)),
        reload=True,
    )
