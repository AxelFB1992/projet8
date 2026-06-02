FROM python:3.12-slim

WORKDIR /app

# Installation de dbt-postgres avec version fixée
RUN pip install --no-cache-dir \
    "dbt-core>=1.8.0,<2.0.0" \
    "dbt-postgres>=1.8.0,<2.0.0"
    
# Installation de dbt-postgres
RUN pip install --no-cache-dir dbt-postgres==1.10.0

# Copie du projet DBT
COPY greenandcoop_dbt/ ./greenandcoop_dbt/

# Copie du profiles.yml
COPY profiles.yml /root/.dbt/profiles.yml

# Script d'exécution
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
