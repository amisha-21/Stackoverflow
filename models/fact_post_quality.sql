WITH post_scores as (
    SELECT
        p.Id as post_id,
        DATE(p.CreationDate) as post_date,
        p.Score as post_score,
        p.ViewCount as post_views,
        LENGTH(p.Body) as post_length -- Using LENGTH for Snowflake
    FROM {{ source('stackoverflow', 'posts') }} p
),

comment_counts as (
    SELECT
        c.PostId as post_id,
        COUNT(*) as comment_count
    FROM {{ source('stackoverflow', 'comments') }} c
    GROUP BY c.PostId
),

post_engagement as (
    SELECT
        ps.post_id,
        ps.post_date,
        ps.post_score,
        ps.post_views,
        ps.post_length,
        COALESCE(cc.comment_count, 0) as comment_count
    FROM post_scores ps
    LEFT JOIN comment_counts cc ON ps.post_id = cc.post_id
),

score_stats as (
    SELECT
        post_date,
        AVG(post_score) as average_score,
        MAX(post_score) as max_score
    FROM post_engagement
    GROUP BY post_date
),

view_stats as (
    SELECT
        post_id,
        post_views
    FROM post_engagement
    ORDER BY post_views DESC
    LIMIT 10 -- Top 10 posts by views
),

length_engagement as (
    SELECT
        post_length,
        AVG(post_score) as average_score,
        SUM(post_views) as total_views,
        SUM(comment_count) as total_comments
    FROM post_engagement
    GROUP BY post_length
)

SELECT
    ss.post_date,
    ss.average_score,
    ss.max_score,
    vs.post_id as top_viewed_post_id,
    vs.post_views as top_viewed_post_views,
    le.post_length,
    le.average_score as length_average_score,
    le.total_views as length_total_views,
    le.total_comments as length_total_comments
FROM score_stats ss
CROSS JOIN (
    SELECT * FROM view_stats
) vs -- This subquery is used to apply the LIMIT clause in a CTE (if required)
LEFT JOIN length_engagement le ON true-- Assuming you want to join on post_date
