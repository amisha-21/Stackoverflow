with
    stg_votes as (
        select * from {{ source("stackoverflow", "votes") }}
    )
select {{ dbt_utils.generate_surrogate_key(["stg_votes.id"]) }} as votekey, *
from stg_votes
