WITH internet_by_quarter AS (
    SELECT
        d.city AS city_name,
        -- Internet penetration in Q1-2021
        MAX(CASE 
                WHEN cr.quarter = 'Q1' AND ar.year = 2021 
                THEN cr.internet_penetration 
            END) AS internet_rate_q1_2021,
        -- Internet penetration in Q4-2021
        MAX(CASE 
                WHEN cr.quarter = 'Q4' AND ar.year = 2021 
                THEN cr.internet_penetration 
            END) AS internet_rate_q4_2021
    FROM dim_city d
    INNER JOIN fact_city_readiness cr
        ON d.city_id = cr.city_id
    INNER JOIN fact_ad_revenue ar
        ON d.city_id = ar.city_id 
       AND cr.quarter = ar.quarter 
       AND cr.year = ar.year
    WHERE ar.year = 2021 AND ar.quarter IN ('Q1','Q4')
    GROUP BY d.city
),
internet_delta AS (
    SELECT *,
        ROUND(internet_rate_q4_2021 - internet_rate_q1_2021, 2) AS delta_internet_rate
    FROM internet_by_quarter
)
SELECT *
FROM internet_delta
ORDER BY delta_internet_rate DESC
LIMIT 6;
