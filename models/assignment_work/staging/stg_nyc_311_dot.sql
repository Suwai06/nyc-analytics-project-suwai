with source as (

    select *
    from {{ source('raw', 'source_service_requests_homework') }}

),

renamed as (

    select
        unique_key,
        created_date,
        closed_date,
        agency,
        agency_name,
        complaint_type,
        descriptor,
        location_type,
        incident_zip,
        incident_address,
        borough,
        latitude,
        longitude
    from source

)

select * from renamed