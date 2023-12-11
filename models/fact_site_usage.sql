with user_signups as (
    select
        cast(CreationDate as date) as signup_date,
        count(*) as new_signups
    from {{ source('stackoverflow', 'users_info') }}  -- Adjusted to 'users' assuming 'users_info' was incorrect
    group by signup_date
),
daily_activity as (
    select
        activity_date,
        count(distinct user_id) as daily_active_users
    from (
        select
            CreationDate::date as activity_date,
            OwnerUserId as user_id  -- Using OwnerUserId for the posts table
        from {{ source('stackoverflow', 'posts') }}
        union all
        select
            CreationDate::date as activity_date,
            UserId as user_id  -- Using UserId for the votes table
        from {{ source('stackoverflow', 'votes') }}
    ) as activity_data
    group by activity_date
),
monthly_activity as (
    select
        date_trunc('month', activity_date) as activity_month,
        count(distinct daily_active_users) as monthly_active_users
    from daily_activity
    group by activity_month
),
activity_heatmap as (
    select
        cast(CreationDate as date) as activity_date,
        date_part('hour', cast(CreationDate as timestamp)) as activity_hour,
        date_part('dayofweek', cast(CreationDate as timestamp)) as activity_day_of_week,
        count(*) as activity_count
    from {{ source('stackoverflow', 'posts') }}
    group by activity_date, activity_hour, activity_day_of_week
)
select
    us.signup_date,
    us.new_signups,
    da.activity_date,
    da.daily_active_users,
    ma.activity_month,
    ma.monthly_active_users,
    ah.activity_hour,
    ah.activity_day_of_week,
    ah.activity_count
from user_signups us
full outer join daily_activity da on us.signup_date = da.activity_date
full outer join monthly_activity ma on date_trunc('month', da.activity_date) = ma.activity_month
left join activity_heatmap ah on da.activity_date = cast(ah.activity_date as date)
