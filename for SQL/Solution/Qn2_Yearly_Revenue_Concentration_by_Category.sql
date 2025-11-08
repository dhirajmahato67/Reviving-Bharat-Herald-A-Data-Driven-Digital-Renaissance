WITH yearly_category AS (
    SELECT 
        year,
        ad_category,
        SUM(ad_revenue) AS category_revenue
    FROM fact_ad_revenue
    GROUP BY year, ad_category
),
yearly_total AS (
    SELECT 
        year,
        SUM(ad_revenue) AS total_revenue_year
    FROM fact_ad_revenue
    GROUP BY year
),
category_pct AS (
    SELECT 
        yc.year,
        yc.ad_category AS category_name,
        yc.category_revenue,
        yt.total_revenue_year,
        ROUND((yc.category_revenue / yt.total_revenue_year) * 100, 2) AS pct_of_year_total,
        ROW_NUMBER() OVER (PARTITION BY yc.year ORDER BY yc.category_revenue DESC) AS rank_no,
        CASE 
            WHEN (yc.category_revenue / yt.total_revenue_year) > 0.5 THEN 'High (>50%)'
            ELSE 'Normal'
        END AS contribution_flag
    FROM yearly_category yc
    JOIN yearly_total yt
        ON yc.year = yt.year
)
SELECT *
FROM category_pct
WHERE rank_no <= 5   -- top 5 categories per year
ORDER BY year, pct_of_year_total DESC;
