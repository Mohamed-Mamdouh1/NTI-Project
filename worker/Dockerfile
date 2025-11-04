FROM python:3.9-slim
WORKDIR /app
COPY worker.py .
RUN pip install redis psycopg2-binary
CMD ["python", "worker.py"]