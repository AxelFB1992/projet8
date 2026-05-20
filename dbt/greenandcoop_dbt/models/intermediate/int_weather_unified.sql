with infoclimat as (
    select
        station_id,
        measured_at,
        -- Conversions : valeurs déjà en unités métriques
        NULLIF(temperature_raw, '')::numeric                                        as temperature_c,
        NULLIF(humidity_raw, '')::numeric                                           as humidity_pct,
        NULLIF(pressure_raw, '')::numeric                                           as pressure_hpa,
        NULLIF(dew_point_raw, '')::numeric                                          as dew_point_c,
        wind_direction,
        NULLIF(wind_speed_raw, '')::numeric                                         as wind_speed_kmh,
        NULLIF(wind_gust_raw, '')::numeric                                          as wind_gust_kmh,
        NULLIF(visibility_raw, '')::numeric                                         as visibility_m,
        NULLIF(precip_rate_raw, '')::numeric                                        as precip_rate_mm,
        NULLIF(precip_accum_raw, '')::numeric                                       as precip_accum_mm,
        NULLIF(snow_depth_raw, '')::numeric                                         as snow_depth_cm,
        NULLIF(cloud_cover_raw, '')::numeric                                        as cloud_cover_oktas,
        weather_code,
        null::numeric                                                               as solar_radiation,
        null::numeric                                                               as uv_index,
        'infoclimat'                                                                as source
    from {{ ref('stg_infoclimat') }}
),

wunderground_lamadeleine as (
    select
        station_id,
        measured_at,
        -- Conversions : °F → °C
        round(((regexp_replace(temperature_raw, '[^0-9.]', '', 'g')::numeric - 32) * 5/9)::numeric, 2)   as temperature_c,
        -- Humidité : extraire le nombre
        regexp_replace(humidity_raw, '[^0-9.]', '', 'g')::numeric                  as humidity_pct,
        -- Pression : pouces → hPa
        round((regexp_replace(pressure_raw, '[^0-9.]', '', 'g')::numeric * 33.8639)::numeric, 2)         as pressure_hpa,
        -- Point de rosée : °F → °C
        round(((regexp_replace(dew_point_raw, '[^0-9.]', '', 'g')::numeric - 32) * 5/9)::numeric, 2)    as dew_point_c,
        wind_direction,
        -- Vitesse : mph → km/h
        round((regexp_replace(wind_speed_raw, '[^0-9.]', '', 'g')::numeric * 1.60934)::numeric, 2)       as wind_speed_kmh,
        -- Rafales : mph → km/h
        round((regexp_replace(wind_gust_raw, '[^0-9.]', '', 'g')::numeric * 1.60934)::numeric, 2)        as wind_gust_kmh,
        null::numeric                                                               as visibility_m,
        -- Précipitations : pouces → mm
        round((regexp_replace(precip_rate_raw, '[^0-9.]', '', 'g')::numeric * 25.4)::numeric, 2)         as precip_rate_mm,
        round((regexp_replace(precip_accum_raw, '[^0-9.]', '', 'g')::numeric * 25.4)::numeric, 2)        as precip_accum_mm,
        null::numeric                                                               as snow_depth_cm,
        null::numeric                                                               as cloud_cover_oktas,
        null::varchar                                                               as weather_code,
        regexp_replace(solar_radiation_raw, '[^0-9.]', '', 'g')::numeric           as solar_radiation,
        uv_index_raw::numeric                                                       as uv_index,
        'weather_underground'                                                       as source
    from {{ ref('stg_wunderground_lamadeleine') }}
),

wunderground_ichtegem as (
    select
        station_id,
        measured_at,
        round(((regexp_replace(temperature_raw, '[^0-9.]', '', 'g')::numeric - 32) * 5/9)::numeric, 2)   as temperature_c,
        regexp_replace(humidity_raw, '[^0-9.]', '', 'g')::numeric                  as humidity_pct,
        round((regexp_replace(pressure_raw, '[^0-9.]', '', 'g')::numeric * 33.8639)::numeric, 2)         as pressure_hpa,
        round(((regexp_replace(dew_point_raw, '[^0-9.]', '', 'g')::numeric - 32) * 5/9)::numeric, 2)    as dew_point_c,
        wind_direction,
        round((regexp_replace(wind_speed_raw, '[^0-9.]', '', 'g')::numeric * 1.60934)::numeric, 2)       as wind_speed_kmh,
        round((regexp_replace(wind_gust_raw, '[^0-9.]', '', 'g')::numeric * 1.60934)::numeric, 2)        as wind_gust_kmh,
        null::numeric                                                               as visibility_m,
        round((regexp_replace(precip_rate_raw, '[^0-9.]', '', 'g')::numeric * 25.4)::numeric, 2)         as precip_rate_mm,
        round((regexp_replace(precip_accum_raw, '[^0-9.]', '', 'g')::numeric * 25.4)::numeric, 2)        as precip_accum_mm,
        null::numeric                                                               as snow_depth_cm,
        null::numeric                                                               as cloud_cover_oktas,
        null::varchar                                                               as weather_code,
        regexp_replace(solar_radiation_raw, '[^0-9.]', '', 'g')::numeric           as solar_radiation,
        uv_index_raw::numeric                                                       as uv_index,
        'weather_underground'                                                       as source
    from {{ ref('stg_wunderground_ichtegem') }}
),

unified as (
    select * from infoclimat
    union all
    select * from wunderground_lamadeleine
    union all
    select * from wunderground_ichtegem
)

select * from unified
