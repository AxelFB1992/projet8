-- Test métier : toutes les stations doivent avoir au moins un relevé
SELECT s.station_id
FROM {{ ref('dim_weather_stations') }} s
LEFT JOIN {{ ref('fact_weather_measures') }} f ON s.station_id = f.station_id
WHERE f.station_id IS NULL
