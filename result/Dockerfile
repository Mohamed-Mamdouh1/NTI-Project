FROM python:3.9-slim
WORKDIR /app
COPY . .
RUN pip install flask psycopg2-binary
CMD ["python", "app.py"]