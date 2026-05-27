{{ config(
    materialized='table',
    indexes=[
        {'columns': ['station_id'], 'type': 'btree'},
        {'columns': ['measured_at'], 'type': 'btree'},
        {'columns': ['source'], 'type': 'btree'},
        {'columns': ['station_id', 'measured_at'], 'type': 'btree'}
    ],
    pre_hook=[
        "ALTER TABLE IF EXISTS {{ this }} DROP CONSTRAINT IF EXISTS pk_fact_weather_measures",
        "ALTER TABLE IF EXISTS {{ this }} DROP CONSTRAINT IF EXISTS fk_fact_station"
        ],
	post_hook=[
	    "ALTER TABLE {{ this }} ADD CONSTRAINT pk_fact_weather_measures PRIMARY KEY (measure_id)",
	    "ALTER TABLE {{ this }} ADD CONSTRAINT fk_fact_station FOREIGN KEY (station_id) REFERENCES public_marts.dim_weather_stations(station_id)"
	])
	}}

with unified as (
    select * from {{ ref('int_weather_unified') }}
),

dim_stations as (
    select * from {{ ref('dim_weather_stations') }}
),

final as (
    select
        -- Clés
		{{ dbt_utils.generate_surrogate_key(['u.station_id', 'u.measured_at']) }} as measure_id,
		u.station_id,
        u.measured_at,
        u.source,
        -- Mesures météo
        u.temperature_c,
        u.humidity_pct,
        u.pressure_hpa,
        u.dew_point_c,
        u.wind_direction,
        u.wind_speed_kmh,
        u.wind_gust_kmh,
        u.visibility_m,
        u.precip_rate_mm,
        u.precip_accum_mm,
        u.snow_depth_cm,
        u.cloud_cover_oktas,
        u.weather_code,
        u.solar_radiation,
        u.uv_index
    from unified u
    left join dim_stations s on u.station_id = s.station_id
)

select * from final
