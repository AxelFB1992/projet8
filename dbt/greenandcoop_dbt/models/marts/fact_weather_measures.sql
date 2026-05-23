with unified as (
    select * from {{ ref('int_weather_unified') }}
),

dim_stations as (
    select * from {{ ref('dim_weather_stations') }}
),

final as (
    select
        -- Clés
        {{ dbt_utils.generate_surrogate_key(['u.station_id', 'u.measured_at']) }}   as measure_id,
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
