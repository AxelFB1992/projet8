-- Test métier : la température doit être entre -30°C et 50°C
SELECT *
FROM {{ ref('fact_weather_measures') }}
WHERE temperature_c IS NOT NULL
AND (temperature_c < -30 OR temperature_c > 50)
