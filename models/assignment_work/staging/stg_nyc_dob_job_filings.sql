-- Clean and standardize NYC DOB NOW job application filings
-- Grain: one row per job filing

WITH source AS (

    SELECT *
    FROM {{ source('raw', 'source_nyc_dob_job_apps') }}

),

cleaned AS (

    SELECT
        -- Identifier
        CAST(job_filing_number AS STRING) AS job_filing_number,

        -- Filing information
        CAST(filing_status AS STRING) AS filing_status,
        CAST(filing_date AS TIMESTAMP) AS filing_date,
        CAST(current_status_date AS TIMESTAMP) AS current_status_date,
        CAST(first_permit_date AS TIMESTAMP) AS first_permit_date,
        CAST(approved_date AS TIMESTAMP) AS approved_date,
        CAST(signoff_date AS TIMESTAMP) AS signoff_date,

        -- Location
        CAST(house_no AS STRING) AS house_no,
        CAST(street_name AS STRING) AS street_name,

        CASE
            WHEN UPPER(TRIM(borough)) IN ('MANHATTAN', 'NEW YORK COUNTY') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough)) IN ('BRONX', 'THE BRONX') THEN 'Bronx'
            WHEN UPPER(TRIM(borough)) IN ('BROOKLYN', 'KINGS COUNTY') THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough)) IN ('QUEENS', 'QUEEN', 'QUEENS COUNTY') THEN 'Queens'
            WHEN UPPER(TRIM(borough)) IN ('STATEN ISLAND', 'RICHMOND COUNTY') THEN 'Staten Island'
            ELSE 'UNKNOWN or CITYWIDE'
        END AS borough,

        CAST(commmunity_board AS STRING) AS community_board,
        CAST(postcode AS STRING) AS zip,
        CAST(council_district AS STRING) AS council_district,
        CAST(bbl AS STRING) AS bbl,
        CAST(block AS STRING) AS block,
        CAST(lot AS STRING) AS lot,
        CAST(bin AS STRING) AS bin,

        -- Job information
        CAST(job_type AS STRING) AS job_type,
        CAST(building_type AS STRING) AS building_type,
        CAST(job_description AS STRING) AS job_description,

        -- Coordinates
        CAST(latitude AS DECIMAL) AS latitude,
        CAST(longitude AS DECIMAL) AS longitude,

        -- Filing representative
        CAST(filing_representative_first_name AS STRING)
            AS filing_representative_first_name,
        CAST(filing_representative_middle_initial AS STRING)
            AS filing_representative_middle_initial,
        CAST(filing_representative_last_name AS STRING)
            AS filing_representative_last_name,
        CAST(filing_representative_business_name AS STRING)
            AS filing_representative_business_name,
        CAST(filing_representative_street_name AS STRING)
            AS filing_representative_street_name,
        CAST(filing_representative_city AS STRING)
            AS filing_representative_city,
        CAST(filing_representative_state AS STRING)
            AS filing_representative_state,
        CAST(filing_representative_zip AS STRING)
            AS filing_representative_zip,

        -- Metadata
        CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source

    -- Basic cleaning
    WHERE job_filing_number IS NOT NULL
      AND filing_date IS NOT NULL

    -- Deduplicate
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY job_filing_number
        ORDER BY filing_date DESC
    ) = 1

)

SELECT * FROM cleaned