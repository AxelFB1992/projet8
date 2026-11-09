# Projet 8 — Construisez et testez une infrastructure de données

> OpenClassrooms · Parcours Data Engineer
> GreenAndCoop Forecast 2.0 : pipeline ELT de données météorologiques, de l'ingestion au déploiement sur AWS.

---

## Contexte

GreenAndCoop, coopérative de fourniture d'électricité, souhaite améliorer ses prévisions de consommation en y intégrant des **données météorologiques**. Ces données proviennent de plusieurs stations, dans des formats différents (JSON, fichiers Excel).

L'objectif est de construire une **infrastructure de données complète** : ingestion des sources, transformation en un modèle analytique unifié, tests de qualité, puis déploiement automatisé et supervisé dans le cloud.

## Architecture

```
Sources météo (JSON, Excel)
        │
        ▼
Ingestion : Airbyte (local) / script PyAirbyte conteneurisé (AWS)
        │
        ▼
PostgreSQL — schéma raw
        │
        ▼
dbt : staging → intermediate → marts (schéma en étoile) + tests de qualité
        │
        ▼
PostgreSQL — schéma analytique
```

Sur AWS, le pipeline est **planifié et orchestré** (EventBridge, Step Functions), exécuté dans des conteneurs (ECR, ECS Fargate), et **supervisé** (CloudWatch, SNS).

## Outils

| Domaine | Outils |
|---|---|
| Ingestion | Airbyte, PyAirbyte, Python, pandas, SQLAlchemy |
| Stockage | PostgreSQL (Docker en local, Amazon RDS sur AWS) |
| Transformation et tests | dbt |
| Conteneurisation | Docker, Amazon ECR, Amazon ECS Fargate |
| Orchestration | Amazon EventBridge, AWS Step Functions |
| Sécurité et supervision | AWS Secrets Manager, IAM, Amazon CloudWatch, Amazon SNS |

## Structure du dépôt

```
projet8/
├── GreenAndCoop_Forecast2_Notebook_v2.ipynb   # Notebook principal : démarche complète et démonstrations
├── Scripts_complementaires_pyairbyte.ipynb    # Scripts complémentaires d'ingestion
├── postgres/
│   └── docker-compose.yml                     # PostgreSQL local
├── python/
│   ├── ingest_pyairbyte.py                    # Script d'ingestion des sources vers le schéma raw
│   ├── Dockerfile
│   └── requirements.txt
├── dbt/
│   ├── Dockerfile, entrypoint.sh, profiles.yml
│   └── greenandcoop_dbt/
│       ├── models/staging/        # Nettoyage et standardisation par source
│       ├── models/intermediate/   # Unification des stations
│       ├── models/marts/          # Dimension stations et table de faits des mesures
│       └── tests/                 # Tests de qualité personnalisés
└── requirements.txt
```

## Démarche

1. **Environnement de travail** : environnement virtuel Python, PostgreSQL dans Docker, installation d'Airbyte et de dbt.
2. **Ingestion avec Airbyte** des différentes sources ; une limitation d'Airbyte sur les fichiers Weather Underground est contournée par un script Python.
3. **Transformation avec dbt** en trois couches :
   - **staging** : nettoyage et standardisation de chaque source (unités, formats de date) ;
   - **intermediate** : unification des stations dans un modèle commun ;
   - **marts** : schéma en étoile, avec une dimension des stations et une table de faits des mesures.
4. **Optimisation et sécurisation du schéma** : contraintes et index PostgreSQL.
5. **Qualité et documentation** : tests dbt génériques et personnalisés (plages de température et d'humidité, présence de données pour chaque station, volumes) ; documentation dbt générée.
6. **Déploiement sur AWS** :
   - base PostgreSQL sur **Amazon RDS** ;
   - identifiants protégés dans **Secrets Manager** ;
   - script d'ingestion et dbt **conteneurisés** (ECR) et exécutés en tâches **ECS Fargate** ;
   - planification avec **EventBridge** et enchaînement ingestion puis transformation avec **Step Functions** ;
   - journaux dans **CloudWatch** et alertes par e-mail avec **SNS**.
7. **Bilan** : reporting sur la qualité, la complétude et l'accessibilité des données, et sur les performances du pipeline.

## Lancer le pipeline en local

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# PostgreSQL (variables POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB dans un fichier .env)
cd postgres && docker compose up -d && cd ..

# Ingestion : via l'interface Airbyte (http://localhost:8000)

# Transformation et tests
cd dbt/greenandcoop_dbt
dbt run
dbt test
```

## Lancer le script d'ingestion Python

Le script `python/ingest_pyairbyte.py` télécharge les trois sources météo et les charge dans le schéma `raw`. Il est conçu pour la base **Amazon RDS** : il se connecte sur le port 5432 avec une connexion chiffrée (SSL) obligatoire, et lit ses identifiants dans des variables d'environnement.

**Directement avec Python**

```bash
pip install -r python/requirements.txt

export DB_HOST=<point de terminaison RDS>
export DB_USER=<utilisateur>
export DB_PASSWORD=<mot de passe>
export DB_NAME=<nom de la base>

python python/ingest_pyairbyte.py
```

**Dans son conteneur Docker**

```bash
cd python
docker build -t greenandcoop-python .
docker run --rm \
  -e DB_HOST=<point de terminaison RDS> \
  -e DB_USER=<utilisateur> \
  -e DB_PASSWORD=<mot de passe> \
  -e DB_NAME=<nom de la base> \
  greenandcoop-python
```

Sur AWS, ce même conteneur est exécuté en tâche ECS Fargate, avec les identifiants fournis par Secrets Manager.

Les démonstrations détaillées, en local et sur AWS, figurent à la fin du notebook principal.

## Compétences mises en œuvre

- Installer et paramétrer un SGBD et un outil d'extraction
- Structurer l'architecture des données et concevoir une base analytique
- Établir et exécuter un processus de test des données
- Déployer, orchestrer et superviser une infrastructure de données dans le cloud
