with source as (
    select * from {{ source('raw', 'InfoClimat_Stations_Hauts_de_France_File') }}
),

expanded as (
    select
        jsonb_array_elements(hourly -> station_key) as record,
        station_key
    from source,
    lateral (
        select unnest(array['07015', '00052', '000R5', 'STATIC0010']) as station_key
    ) station_keys
    where hourly is not null
),

renamed as (
    select
        record->>'id_station'                   as station_id,
		(record->>'dh_utc')::timestamp    		as measured_at,       
		record->>'temperature'                  as temperature_raw,
        record->>'humidite'                     as humidity_raw,
        record->>'pression'                     as pressure_raw,
        record->>'point_de_rosee'               as dew_point_raw,
        record->>'vent_direction'               as wind_direction,
        record->>'vent_moyen'                   as wind_speed_raw,
        record->>'vent_rafales'                 as wind_gust_raw,
        record->>'visibilite'                   as visibility_raw,
        record->>'pluie_1h'                     as precip_rate_raw,
        record->>'pluie_3h'                     as precip_accum_raw,
        record->>'neige_au_sol'                 as snow_depth_raw,
        NULLIF(record->>'nebulosite', '')        as cloud_cover_raw,
        record->>'temps_omm'                    as weather_code
    from expanded
    where record->>'id_station' is not null
)

select * from renamed
