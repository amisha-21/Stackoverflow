WITH stg_posttypes AS (
    SELECT * FROM {{ source('stackoverflow','posttypes') }}
)
SELECT
    {{ dbt_utils.generate_surrogate_key(['stg_posttypes.ID']) }} 
    AS posttypekey,
    stg_posttypes.*
FROM stg_posttypes
