@echo off
echo =============================================
echo  Forest Academy E-Center — Python Backend
echo =============================================
echo.
echo Setting up Python virtual environment...

cd /d "%~dp0"

if not exist "venv" (
    python -m venv venv
    echo Virtual environment created.
)

call venv\Scripts\activate.bat

echo Installing dependencies...
pip install -r requirements.txt --quiet

echo.
echo Starting FastAPI server on http://localhost:8000
echo.
echo API Docs: http://localhost:8000/docs
echo Health:   http://localhost:8000/health
echo.
echo Press Ctrl+C to stop.
echo.

uvicorn main:app --host 0.0.0.0 --port 8000 --reload

pause
