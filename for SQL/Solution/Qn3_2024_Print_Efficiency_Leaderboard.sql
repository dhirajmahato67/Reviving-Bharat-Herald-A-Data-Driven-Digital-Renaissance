WITH city_efficiency AS (
    SELECT 
        d.city,
        SUM(p.copies_sold) AS copies_sold_2024,
        SUM(p.copies_returned) AS copies_returned_2024,
        SUM(p.net_circulation) AS net_circulation_2024,
        SUM(p.copies_sold + p.copies_returned) AS copies_printed_2024
    FROM dim_city d
    JOIN fact_print_sales_csv p 
        ON d.city_id = p.city_id
    WHERE YEAR(STR_TO_DATE(p.month, '%m/%d/%Y')) = 2024
    GROUP BY d.city
)
SELECT 
    city,
    copies_printed_2024,
    net_circulation_2024,
    CONCAT(ROUND(net_circulation_2024 * 100.0 / NULLIF(copies_printed_2024,0), 2), '%') AS efficiency_percentage,
    RANK() OVER (
        ORDER BY net_circulation_2024 * 1.0 / NULLIF(copies_printed_2024,0) DESC
    ) AS efficiency_rank_2024
FROM city_efficiency
ORDER BY efficiency_rank_2024
LIMIT 5;
