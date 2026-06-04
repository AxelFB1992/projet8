FROM python:3.12-slim

WORKDIR /app

RUN pip install --no-cache-dir \
    pandas \
    requests \
    sqlalchemy \
    psycopg2-binary \
    openpyxl

COPY ingest_pyairbyte.py .

CMD ["python", "ingest_pyairbyte.py"]
