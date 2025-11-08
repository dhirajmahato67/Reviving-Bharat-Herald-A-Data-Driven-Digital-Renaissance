WITH readiness_2021 AS (
    SELECT
        d.city AS city_name,
        ROUND(
            (c.smartphone_penetration + c.internet_penetration + c.literacy_rate) / 3,
            2
        ) AS readiness_score_2021
    FROM dim_city d
    INNER JOIN fact_city_readiness c
        ON d.city_id = c.city_id
    WHERE c.year = 2021
),
engagement_2021 AS (
    SELECT
        d.city AS city_name,
        ROUND(
            AVG(
                (e.downloads_or_accesses * 1.0 / NULLIF(e.users_reached,0))
                * (1 - e.avg_bounce_rate / 100)
            ),
            4
        ) AS engagement_metric_2021
    FROM dim_city d
    INNER JOIN fact_digital_pilot e
        ON d.city_id = e.city_id
    WHERE e.launch_month LIKE '%2021%'
    GROUP BY d.city
),
combined AS (
    SELECT
        r.city_name,
        r.readiness_score_2021,
        e.engagement_metric_2021
    FROM readiness_2021 r
    INNER JOIN engagement_2021 e
        ON r.city_name = e.city_name
),
ranked AS (
    SELECT
        city_name,
        readiness_score_2021,
        engagement_metric_2021,
        RANK() OVER (ORDER BY readiness_score_2021 DESC) AS readiness_rank_desc,
        RANK() OVER (ORDER BY engagement_metric_2021 ASC) AS engagement_rank_asc
    FROM combined
),
bottom3_engagement AS (
    SELECT *
    FROM ranked
    WHERE engagement_rank_asc <= 3
)
SELECT
    city_name,
    readiness_score_2021,
    engagement_metric_2021,
    readiness_rank_desc,
    engagement_rank_asc,
    'Yes' AS is_outlier
FROM bottom3_engagement
ORDER BY readiness_score_2021 DESC
LIMIT 1;
