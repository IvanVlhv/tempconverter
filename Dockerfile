FROM python:3.12-slim

LABEL org.opencontainers.image.title="tempconverter" \
      org.opencontainers.image.authors="Ivan, Algebra Bernays University"

# Task 1a) Update ALL OS packages as part of the image build process
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Task 1c) Install all required requirements
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

# Run the process as a non-root user inside the container (security best practice)
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser

# Task 1b) Expose port 5000 TCP
EXPOSE 5000/tcp

# Task 1d) Correct command to start the flask application
# (app.py itself calls app.run(host=0.0.0.0, port=5000))
CMD ["python", "app.py"]
