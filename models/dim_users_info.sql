-- models/dim_users_info.sql
with stg_users as (
    select * from {{ source('stackoverflow','users_info')}}
)
select
{{ dbt_utils.generate_surrogate_key(['stg_users.id']) }}
as userkey,
    stg_users.*
from stg_users
