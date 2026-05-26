-- Test métier : l'humidité doit être entre 0 et 100%
SELECT *
FROM {{ ref('fact_weather_measures') }}
WHERE humidity_pct IS NOT NULL
AND (humidity_pct < 0 OR humidity_pct > 100)
