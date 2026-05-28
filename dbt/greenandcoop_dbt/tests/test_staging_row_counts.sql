-- Test : chaque source doit avoir au moins 100 relevés
SELECT 'stg_infoclimat' as model, COUNT(*) as row_count
FROM {{ ref('stg_infoclimat') }}
HAVING COUNT(*) < 100
UNION ALL
SELECT 'stg_wunderground_lamadeleine', COUNT(*)
FROM {{ ref('stg_wunderground_lamadeleine') }}
HAVING COUNT(*) < 100
UNION ALL
SELECT 'stg_wunderground_ichtegem', COUNT(*)
FROM {{ ref('stg_wunderground_ichtegem') }}
HAVING COUNT(*) < 100
