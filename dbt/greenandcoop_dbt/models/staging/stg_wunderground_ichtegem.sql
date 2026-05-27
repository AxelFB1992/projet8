with source as (
    select * from {{ source('raw', 'WeatherUnderground_Ichtegem_BE_File') }}
),

renamed as (
    select
        'IICHTE19'                                  as station_id,
        "measured_at"                               as measured_at,
        NULLIF("Temperature", '')                   as temperature_raw,
        NULLIF("Humidity", '')                      as humidity_raw,
        NULLIF("Pressure", '')                      as pressure_raw,
        NULLIF("Dew Point", '')                     as dew_point_raw,
        "Wind"                                      as wind_direction,
        NULLIF("Speed", '')                         as wind_speed_raw,
        NULLIF("Gust", '')                          as wind_gust_raw,
        NULLIF("Solar", '')                         as solar_radiation_raw,
        "UV"                                        as uv_index_raw,
        NULLIF("Precip. Rate.", '')                 as precip_rate_raw,
        NULLIF("Precip. Accum.", '')                as precip_accum_raw
    from source
    where "measured_at" is not null
)

select * from renamed
