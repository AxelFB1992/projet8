{{ config(
    materialized='table',
    indexes=[
        {'columns': ['station_id'], 'unique': true, 'type': 'btree'},
        {'columns': ['network'], 'type': 'btree'}
    ],
    pre_hook=[
        "ALTER TABLE IF EXISTS {{ this }} DROP CONSTRAINT IF EXISTS pk_dim_weather_stations"
        ],
    post_hook=[
        
        "ALTER TABLE {{ this }} ADD CONSTRAINT pk_dim_weather_stations PRIMARY KEY (station_id)"
    ]
) }}

with infoclimat_stations as (
    select
        '00052'             as station_id,
        'Armentières'       as station_name,
        'infoclimat'        as network,
        50.689              as latitude,
        2.877               as longitude,
        16                  as elevation_m,
        'Armentières'       as city,
        'France'            as country,
        'static'            as station_type,
        null::varchar       as hardware,
        null::varchar       as software
    union all
    select
        '000R5',
        'Bergues',
        'infoclimat',
        50.968,
        2.441,
        17,
        'Bergues',
        'France',
        'static',
        null::varchar,
        null::varchar
    union all
    select
        '07015',
        'Lille-Lesquin',
        'infoclimat',
        50.575,
        3.092,
        47,
        'Lille-Lesquin',
        'France',
        'synop',
        null::varchar,
        null::varchar
    union all
    select
        'STATIC0010',
        'Hazebrouck',
        'infoclimat',
        50.734,
        2.545,
        31,
        'Hazebrouck',
        'France',
        'static',
        null::varchar,
        null::varchar
),

wunderground_stations as (
    select
        'ILAMAD25'              as station_id,
        'La Madeleine'          as station_name,
        'weather_underground'   as network,
        50.659                  as latitude,
        3.070                   as longitude,
        23                      as elevation_m,
        'La Madeleine'          as city,
        'France'                as country,
        'amateur'               as station_type,
        'other'                 as hardware,
        'EasyWeatherPro_V5.1.6' as software
    union all
    select
        'IICHTE19',
        'WeerstationBS',
        'weather_underground',
        51.092,
        2.999,
        15,
        'Ichtegem',
        'Belgique',
        'amateur',
        'other',
        'EasyWeatherV1.6.6'
),

all_stations as (
    select * from infoclimat_stations
    union all
    select * from wunderground_stations
)

select * from all_stations
