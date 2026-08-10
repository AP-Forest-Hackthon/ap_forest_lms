"""
services/quiz_validator.py
Validates and normalizes AI-generated quiz JSON.
Handles common LLM output issues like markdown fences, trailing commas, etc.
"""

import json
import re
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)


class QuizValidator:
    """Parses and validates raw LLM quiz output."""

    def parse_and_validate(self, raw: str, fallback_title: str = "Quiz") -> Dict[str, Any]:
        """
        Parse LLM output to structured quiz dict.
        Raises ValueError if quiz is invalid after cleanup attempts.
        """
        # Step 1: Extract JSON from raw output
        json_str = self._extract_json(raw)

        # Step 2: Parse JSON
        try:
            data = json.loads(json_str)
        except json.JSONDecodeError as e:
            # Try to fix common issues
            fixed = self._fix_common_json_issues(json_str)
            try:
                data = json.loads(fixed)
            except json.JSONDecodeError:
                raise ValueError(f"Could not parse AI response as JSON: {e}")

        # Step 3: Validate structure
        return self._validate_structure(data, fallback_title)

    def _extract_json(self, raw: str) -> str:
        """Extract JSON from LLM output that may contain markdown or extra text."""
        raw = raw.strip()

        # Remove markdown code fences
        raw = re.sub(r'^```(?:json)?\s*', '', raw, flags=re.MULTILINE)
        raw = re.sub(r'\s*```$', '', raw, flags=re.MULTILINE)

        # Find first { and last }
        start = raw.find('{')
        end = raw.rfind('}')
        if start == -1 or end == -1:
            raise ValueError("No JSON object found in AI response")

        return raw[start:end + 1]

    def _fix_common_json_issues(self, json_str: str) -> str:
        """Fix common LLM JSON mistakes."""
        # Remove trailing commas before } or ]
        json_str = re.sub(r',\s*([}\]])', r'\1', json_str)
        # Fix single quotes → double quotes (sometimes LLMs use single quotes)
        # This is risky, so only attempt if double-quote parse failed
        return json_str

    def _validate_structure(self, data: dict, fallback_title: str) -> dict:
        """Validate and normalize quiz structure."""
        if not isinstance(data, dict):
            raise ValueError("AI response is not a JSON object")

        title = data.get("title", fallback_title) or fallback_title
        questions_raw = data.get("questions", [])

        if not isinstance(questions_raw, list):
            raise ValueError("'questions' field must be a list")

        questions = []
        seen_questions = set()

        for i, q in enumerate(questions_raw):
            if not isinstance(q, dict):
                continue

            question_text = str(q.get("question", "")).strip()
            options_raw = q.get("options", [])
            correct_answer = str(q.get("correctAnswer", "")).strip()
            explanation = str(q.get("explanation", "")).strip()

            # Skip malformed
            if not question_text or not options_raw or not correct_answer:
                logger.warning(f"Skipping malformed question {i}: missing required fields")
                continue

            # Skip duplicates
            q_lower = question_text.lower()
            if q_lower in seen_questions:
                continue
            seen_questions.add(q_lower)

            options = [str(o).strip() for o in options_raw if str(o).strip()]
            if len(options) < 2:
                continue

            # Ensure correct answer is in options
            if correct_answer not in options:
                # Try case-insensitive match
                match = next((o for o in options if o.lower() == correct_answer.lower()), None)
                if match:
                    correct_answer = match
                else:
                    # Use first option as fallback
                    logger.warning(f"Correct answer not in options for Q{i}, using first option")
                    correct_answer = options[0]

            questions.append({
                "question": question_text,
                "options": options,
                "correctAnswer": correct_answer,
                "explanation": explanation or "Based on the training material.",
                "order": len(questions),
                "source": "ai",
            })

        if not questions:
            raise ValueError("No valid questions could be parsed from AI response")

        return {"title": title, "questions": questions}
