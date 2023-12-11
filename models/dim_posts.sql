with stg_posts as (select * from {{ source("stackoverflow", "posts") }})
select {{ dbt_utils.generate_surrogate_key(["stg_posts.id"]) }} as postkey,*
from stg_posts
