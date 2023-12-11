with stg_badges as (select * from {{ source("stackoverflow", "badges") }})
select {{ dbt_utils.generate_surrogate_key(["stg_badges.id"]) }} as badgeskey,*
from stg_badges
