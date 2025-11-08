WITH circulation_change AS (
    SELECT 
        d.city AS city_name,
        DATE_FORMAT(STR_TO_DATE(p.month, '%m/%d/%Y'), '%Y-%m') AS month,
        p.net_circulation,
        p.net_circulation - LAG(p.net_circulation) 
            OVER (PARTITION BY d.city ORDER BY STR_TO_DATE(p.month, '%m/%d/%Y')) AS mom_change
    FROM dim_city d
    JOIN fact_print_sales_csv p 
        ON d.city_id = p.city_id
    WHERE STR_TO_DATE(p.month, '%m/%d/%Y') BETWEEN '2019-01-01' AND '2024-12-31'
)
SELECT 
    city_name,
    month,
    net_circulation,
    mom_change
FROM circulation_change
WHERE mom_change IS NOT NULL
  AND mom_change < 0
ORDER BY mom_change ASC
LIMIT 3;
