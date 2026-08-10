"""
services/groq_service.py
Groq LLM integration for quiz generation and AI assistant.
Uses groq Python SDK with llama-3.3-70b-versatile model.
API key loaded from .env — NEVER hardcoded.
"""

import os
import json
import logging
import asyncio
from typing import Optional

logger = logging.getLogger(__name__)

# Forestry MCQ generation prompt — carefully engineered for quality
QUIZ_GENERATION_PROMPT = """You are an expert forestry education assessment specialist for the A.P. State Forest Academy, India.

Your task: Generate multiple-choice questions (MCQs) from the provided educational material for forest officer trainees.

STRICT RULES:
1. Questions must be ONLY based on the provided text. Do not invent facts.
2. Generate exactly {max_questions} MCQs (or fewer if content is insufficient).
3. Each question must have EXACTLY 4 options (A, B, C, D).
4. EXACTLY one option must be the correct answer.
5. Questions must be factual, clear, and unambiguous.
6. Language must be professional and suitable for forest officer trainees.
7. Avoid duplicate or very similar questions.
8. Provide a short explanation (1-2 sentences) for the correct answer.
9. Return ONLY valid JSON. No markdown, no explanation text, ONLY the JSON object.

REQUIRED JSON FORMAT (return exactly this structure):
{{
  "title": "{quiz_title}",
  "questions": [
    {{
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": "Option A",
      "explanation": "Brief explanation of why this is correct."
    }}
  ]
}}

EDUCATIONAL MATERIAL:
---
{text}
---

Generate the quiz JSON now:"""

ASSISTANT_PROMPT = """You are the Forest Learning Assistant for the A.P. State Forest Academy, Rajamahendravaram, Andhra Pradesh.

You help forest officer trainees understand forestry concepts. Your responses are:
- Factual and educational
- Based on established forestry science
- Concise and clear
- Professional in tone

Always add this disclaimer at the end: "⚠️ Please verify with your faculty and official training material."

Question: {question}

Answer:"""


class GroqService:
    """Handles all Groq LLM API calls."""

    def __init__(self):
        self.api_key = os.getenv("GROQ_API_KEY")
        if not self.api_key:
            logger.warning("GROQ_API_KEY not set. AI features will not work.")
        self.model = os.getenv("GROQ_MODEL", "llama-3.3-70b-versatile")
        self._client = None

    def _get_client(self):
        """Lazy init Groq client."""
        if self._client is None:
            try:
                from groq import Groq
                self._client = Groq(api_key=self.api_key)
            except ImportError:
                raise RuntimeError("groq package not installed. Run: pip install groq")
        return self._client

    async def generate_quiz(self, text: str, title: str, max_questions: int = 8) -> str:
        """
        Call Groq to generate quiz questions from PDF text.
        Returns raw JSON string from LLM.
        """
        if not self.api_key:
            raise ValueError("GROQ_API_KEY not configured in backend .env file")

        prompt = QUIZ_GENERATION_PROMPT.format(
            max_questions=max_questions,
            quiz_title=title,
            text=text,
        )

        client = self._get_client()

        # Run synchronous Groq call in thread pool to not block event loop
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a forestry education expert. Return ONLY valid JSON, no other text.",
                    },
                    {"role": "user", "content": prompt},
                ],
                max_tokens=4096,
                temperature=0.3,  # Low temperature for factual accuracy
                top_p=0.9,
            ),
        )

        raw = response.choices[0].message.content
        logger.info(f"Groq response length: {len(raw)} chars")
        return raw

    async def answer_question(self, question: str, domain: str = "forestry") -> str:
        """Answer a trainee's learning question."""
        if not self.api_key:
            return "AI assistant is not available at this time. Please contact your faculty."

        prompt = ASSISTANT_PROMPT.format(question=question)
        client = self._get_client()

        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            None,
            lambda: client.chat.completions.create(
                model=self.model,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a helpful forestry education assistant for Indian forest officers.",
                    },
                    {"role": "user", "content": prompt},
                ],
                max_tokens=800,
                temperature=0.5,
            ),
        )

        return response.choices[0].message.content
