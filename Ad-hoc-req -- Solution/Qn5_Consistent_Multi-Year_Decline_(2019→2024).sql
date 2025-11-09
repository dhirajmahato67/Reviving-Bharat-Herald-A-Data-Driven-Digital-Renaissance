WITH city_year_data AS (
    SELECT
        d.city AS city_name,
        ar.year,
        p.net_circulation AS yearly_net_circulation,
        ar.ad_revenue AS yearly_ad_revenue
    FROM dim_city d
    INNER JOIN fact_ad_revenue ar 
        ON d.city_id = ar.city_id
    LEFT JOIN fact_print_sales_csv p
        ON d.city_id = p.city_id
       AND YEAR(STR_TO_DATE(p.month, '%m/%d/%Y')) = ar.year
    WHERE ar.year BETWEEN 2019 AND 2024
),
decline_flags AS (
    SELECT
        city_name,
        MIN(yearly_net_circulation) AS min_net,
        MAX(yearly_net_circulation) AS max_net,
        MIN(yearly_ad_revenue) AS min_ad,
        MAX(yearly_ad_revenue) AS max_ad,
        SUM(yearly_net_circulation) AS total_net_circulation,
        SUM(yearly_ad_revenue) AS total_ad_revenue
    FROM city_year_data
    GROUP BY city_name
),
final AS (
    SELECT
        city_name,
        total_net_circulation,
        ROUND(total_ad_revenue, 2) AS total_ad_revenue,  -- rounded to 2 decimal places
        CASE WHEN min_net < max_net THEN 'Yes' ELSE 'No' END AS is_declining_print,
        CASE WHEN min_ad < max_ad THEN 'Yes' ELSE 'No' END AS is_declining_ad_revenue,
        CASE 
            WHEN min_net < max_net AND min_ad < max_ad THEN 'Yes'
            ELSE 'No'
        END AS is_declining_both
    FROM decline_flags
)
SELECT *
FROM final
ORDER BY city_name;
