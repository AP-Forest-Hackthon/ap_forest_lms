"""
services/pdf_extractor.py
PDF text extraction using PyMuPDF (primary) and pdfplumber (fallback).
Handles text cleaning and chunking for large PDFs.
"""

import io
import re
import logging
from typing import Optional

logger = logging.getLogger(__name__)

# Maximum characters to send to AI (to avoid token limits)
MAX_CONTENT_CHARS = 12000

class PdfExtractor:
    """Extracts and cleans text from PDF bytes."""

    def extract_text(self, pdf_bytes: bytes) -> str:
        """
        Try PyMuPDF first, fall back to pdfplumber.
        Returns cleaned, chunked text ready for AI.
        """
        text = None

        # Primary: PyMuPDF (fitz) — fast and handles most PDFs well
        try:
            import fitz  # PyMuPDF
            text = self._extract_with_pymupdf(pdf_bytes)
            logger.info("Text extracted with PyMuPDF")
        except ImportError:
            logger.warning("PyMuPDF not available, trying pdfplumber")
        except Exception as e:
            logger.warning(f"PyMuPDF extraction failed: {e}")

        # Fallback: pdfplumber
        if not text or len(text.strip()) < 100:
            try:
                import pdfplumber
                text = self._extract_with_pdfplumber(pdf_bytes)
                logger.info("Text extracted with pdfplumber")
            except ImportError:
                logger.error("pdfplumber not available either")
            except Exception as e:
                logger.warning(f"pdfplumber extraction failed: {e}")

        if not text:
            raise ValueError("Could not extract text from PDF. The file may be image-only or corrupted.")

        # Clean and limit
        cleaned = self._clean_text(text)
        chunked = self._smart_chunk(cleaned, MAX_CONTENT_CHARS)
        return chunked

    def _extract_with_pymupdf(self, pdf_bytes: bytes) -> str:
        import fitz
        doc = fitz.open(stream=pdf_bytes, filetype="pdf")
        texts = []
        for page in doc:
            texts.append(page.get_text("text"))
        doc.close()
        return "\n".join(texts)

    def _extract_with_pdfplumber(self, pdf_bytes: bytes) -> str:
        import pdfplumber
        with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
            texts = []
            for page in pdf.pages:
                page_text = page.extract_text()
                if page_text:
                    texts.append(page_text)
        return "\n".join(texts)

    def _clean_text(self, text: str) -> str:
        """Remove noise, normalize whitespace, remove non-educational content."""
        # Remove excessive whitespace
        text = re.sub(r'\n{3,}', '\n\n', text)
        text = re.sub(r' {2,}', ' ', text)
        # Remove page numbers (common patterns)
        text = re.sub(r'\n\s*\d+\s*\n', '\n', text)
        # Remove common header/footer artifacts
        text = re.sub(r'(Page \d+ of \d+)', '', text, flags=re.IGNORECASE)
        # Remove URLs
        text = re.sub(r'https?://\S+', '', text)
        # Strip leading/trailing
        text = text.strip()
        return text

    def _smart_chunk(self, text: str, max_chars: int) -> str:
        """
        Intelligently truncate text at paragraph boundaries.
        Sends the most content-rich portion to the AI.
        """
        if len(text) <= max_chars:
            return text

        # Try to cut at a paragraph boundary
        truncated = text[:max_chars]
        last_para = truncated.rfind('\n\n')
        if last_para > max_chars * 0.7:
            truncated = truncated[:last_para]

        logger.info(f"Text chunked from {len(text)} to {len(truncated)} chars")
        return truncated
