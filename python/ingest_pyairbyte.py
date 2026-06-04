import pandas as pd
import requests
import json
from sqlalchemy import create_engine, text
import os
import io
from sqlalchemy.dialects.postgresql import JSONB

# ─── Connexion RDS ───────────────────────────
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

engine = create_engine(
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:5432/{DB_NAME}?sslmode=require"
)

INFOCLIMAT_URL = "https://s3.eu-west-1.amazonaws.com/course.oc-static.com/projects/922_Data+Engineer/922_P8/Data_Source1_011024-071024.json"
WU_LAMADELEINE_URL = "https://s3.eu-west-1.amazonaws.com/course.oc-static.com/projects/922_Data+Engineer/922_P8/Weather+Underground+-+La+Madeleine%2C+FR.xlsx"
WU_ICHTEGEM_URL = "https://s3.eu-west-1.amazonaws.com/course.oc-static.com/projects/922_Data+Engineer/922_P8/Weather+Underground+-+Ichtegem%2C+BE.xlsx"

def create_raw_schema():
    with engine.connect() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw"))
        conn.commit()
    print("✓ Schéma raw vérifié")

def drop_table_cascade(table_name):
    """Supprime la table avec CASCADE pour gérer les vues dépendantes"""
    with engine.connect() as conn:
        conn.execute(text(f'DROP TABLE IF EXISTS raw."{table_name}" CASCADE'))
        conn.commit()

def ingest_infoclimat():
    """Ingère InfoClimat — colonne hourly (jsonb) requise par DBT"""
    print("\n=== InfoClimat ===")
    response = requests.get(INFOCLIMAT_URL)
    data = response.json()
    # DBT utilise uniquement la colonne 'hourly'
    df = pd.DataFrame([{
        "hourly": data.get("hourly", {})
    }])
    drop_table_cascade('InfoClimat_Stations_Hauts_de_France_File')
    df.to_sql(
        'InfoClimat_Stations_Hauts_de_France_File',
        engine,
        schema='raw',
        if_exists='replace',
        index=False,
        dtype={"hourly": JSONB}
    )
    print(f"✓ InfoClimat chargé : 1 ligne avec colonne hourly")

def ingest_wunderground(url, table_name):
    """Ingère Weather Underground — colonnes exactes requises par DBT"""
    print(f"\n=== {table_name} ===")
    response = requests.get(url)
    excel_file = io.BytesIO(response.content)
    xl = pd.ExcelFile(excel_file)

    dfs = []
    for sheet_name in xl.sheet_names:
        try:
            date = pd.to_datetime(sheet_name, format='%d%m%y')
            df = pd.read_excel(xl, sheet_name=sheet_name)
            df = df.dropna(subset=['Time']).copy()
            df['measured_at'] = pd.to_datetime(
                date.strftime('%Y-%m-%d') + ' ' + df['Time'].astype(str),
                format='%Y-%m-%d %H:%M:%S'
            )
            dfs.append(df)
            print(f"  Feuillet {sheet_name} : {len(df)} lignes")
        except Exception as e:
            print(f"  Feuillet {sheet_name} ignoré : {e}")

    df_final = pd.concat(dfs, ignore_index=True)
    # Colonnes exactes utilisées par DBT
    cols = ['Time', 'Temperature', 'Dew Point', 'Humidity', 'Wind',
            'Speed', 'Gust', 'Pressure', 'Precip. Rate.',
            'Precip. Accum.', 'UV', 'Solar', 'measured_at']
    df_final = df_final[cols]
    drop_table_cascade(table_name)
    df_final.to_sql(
        table_name,
        engine,
        schema='raw',
        if_exists='replace',
        index=False
    )
    print(f"✓ {table_name} chargé : {len(df_final)} lignes")

if __name__ == "__main__":
    print("=== Démarrage ingestion pipeline ===")
    create_raw_schema()
    ingest_infoclimat()
    ingest_wunderground(WU_LAMADELEINE_URL, 'WeatherUnderground_LaMadeleine_FR_File')
    ingest_wunderground(WU_ICHTEGEM_URL, 'WeatherUnderground_Ichtegem_BE_File')
    print("\n=== Ingestion terminée avec succès ===")
