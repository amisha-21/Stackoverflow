with stg_comments as (select * from {{ source("stackoverflow", "comments") }})
select {{ dbt_utils.generate_surrogate_key(["stg_comments.id"]) }} as commentskey,*
from stg_comments
