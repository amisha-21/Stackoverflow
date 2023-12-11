WITH user_posts AS (
    SELECT
        OWNERUSERID AS user_id,
        DATE(CreationDate) AS post_date,
        COUNT(*) AS post_count
    FROM {{ source('stackoverflow', 'posts') }}
    GROUP BY OWNERUSERID, DATE(CreationDate)  -- Ensure this matches the column names exactly
),
user_comments AS (
    SELECT
        UserId AS user_id,
        DATE(CreationDate) AS comment_date,
        COUNT(*) AS comment_count
    FROM {{ source('stackoverflow', 'comments') }}
    GROUP BY UserId, DATE(CreationDate)
),

user_votes AS (
    SELECT
        UserId AS user_id,
        DATE(CreationDate) AS vote_date,
        COUNT(*) AS vote_count
    FROM {{ source('stackoverflow', 'votes') }}
    GROUP BY UserId, DATE(CreationDate)
),

user_badges AS (
    SELECT
        UserId AS user_id,
        DATE("DATE") AS badge_date,
        COUNT(*) AS badge_count
    FROM {{ source('stackoverflow', 'badges') }}
    GROUP BY UserId, DATE("DATE")
),
user_activity AS (
    SELECT
        u.Id AS user_id,
        CAST(u.CreationDate AS DATE) AS account_creation_date,
        DATE_TRUNC('month', CAST(u.CreationDate AS DATE)) AS retention_cohort,
        p.post_count,
        c.comment_count,
        v.vote_count,
        b.badge_count
    FROM {{ source('stackoverflow', 'users_info') }} u
    LEFT JOIN user_posts p ON u.Id = p.user_id AND DATE(u.CreationDate) = p.post_date
    LEFT JOIN user_comments c ON u.Id = c.user_id AND DATE(u.CreationDate) = c.comment_date
    LEFT JOIN user_votes v ON u.Id = v.user_id AND DATE(u.CreationDate) = v.vote_date
    LEFT JOIN user_badges b ON u.Id = b.user_id AND DATE(u.CreationDate) = b.badge_date
)
SELECT
    user_id,
    account_creation_date,
    retention_cohort,
    SUM(COALESCE(post_count, 0)) AS total_posts,
    SUM(COALESCE(comment_count, 0)) AS total_comments,
    SUM(COALESCE(vote_count, 0)) AS total_votes,
    SUM(COALESCE(badge_count, 0)) AS total_badges
FROM user_activity
GROUP BY user_id, account_creation_date, retention_cohort
