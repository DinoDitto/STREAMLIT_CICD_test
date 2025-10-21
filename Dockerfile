# Minimal Streamlit container for Cloud Run
FROM python:3.11-slim

# System deps (optional but useful)
RUN apt-get update && apt-get install -y --no-install-recommends             curl tini && rm -rf /var/lib/apt/lists/*

ENV PYTHONDONTWRITEBYTECODE=1             PYTHONUNBUFFERED=1

WORKDIR /app

# Install Python deps first for better layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app
COPY . .

# Cloud Run will inject PORT; default to 8080 for local
ENV PORT=8080

EXPOSE 8080

# Use tini for proper signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]

# Run Streamlit
CMD ["sh", "-c", "streamlit run app/streamlit_app.py --server.port=${PORT} --server.address=0.0.0.0 --browser.gatherUsageStats=false"]
