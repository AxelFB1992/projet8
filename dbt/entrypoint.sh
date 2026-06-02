#!/bin/bash
set -e

echo "=== Démarrage du pipeline DBT ==="

cd /app/greenandcoop_dbt

echo "=== dbt run ==="
dbt run

echo "=== dbt test ==="
dbt test

echo "=== Pipeline DBT terminé avec succès ==="
