{{ config(
    materialized='table',
    indexes=[
        {'columns': ['date_id'], 'unique': true, 'type': 'btree'},
        {'columns': ['date'], 'type': 'btree'},
        {'columns': ['year', 'month'], 'type': 'btree'}
    ],
    post_hook=[
    	"ALTER TABLE {{ this }} DROP CONSTRAINT IF EXISTS pk_dim_date",
    	"ALTER TABLE {{ this }} ADD CONSTRAINT pk_dim_date PRIMARY KEY (date_id)"
    ]
) }}

with date_spine as (
    select
        generate_series(
            '2024-10-01'::date,
            '2024-10-31'::date,
            '1 hour'::interval
        ) as date_hour
),

renamed as (
    select
        to_char(date_hour, 'YYYYMMDDHH24')::bigint  as date_id,
        date_hour                                    as datetime,
        date_hour::date                              as date,
        extract(year from date_hour)::int            as year,
        extract(month from date_hour)::int           as month,
        extract(day from date_hour)::int             as day,
        extract(hour from date_hour)::int            as hour,
        extract(dow from date_hour)::int             as day_of_week,
        to_char(date_hour, 'Day')                    as day_name,
        to_char(date_hour, 'Month')                  as month_name,
        case
            when extract(dow from date_hour) in (0, 6) then true
            else false
        end                                          as is_weekend
    from date_spine
)

select * from renamed
