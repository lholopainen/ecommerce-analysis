# PRODUCT ANALYSIS IN 2014


-- product level sales analysis in 2014 Q1
SELECT DISTINCT
    pageview_url
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2014-01-01' AND '2014-03-31';
    
SELECT 
wp.pageview_url,
COUNT(DISTINCT wp.website_session_id) as sessions,
COUNT(DISTINCT o.order_id) as orders,
COUNT(DISTINCT o.order_id) / COUNT(DISTINCT wp.website_session_id) as viewed_product_to_order_rate
FROM
    website_pageviews wp
    LEFT JOIN orders o ON o.website_session_id = wp.website_session_id
WHERE
    wp.created_at BETWEEN '2014-01-01' AND '2014-03-31'
    AND wp.pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/the-birthday-sugar-panda')
GROUP BY 1;


-- product launch analysis in December 2014
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mth,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS cvr,
    SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 1 THEN order_id
            ELSE NULL
        END) AS product_1_orders,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 2 THEN order_id
            ELSE NULL
        END) AS product_2_orders,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 3 THEN order_id
            ELSE NULL
        END) AS product_3_orders,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 4 THEN order_id
            ELSE NULL
        END) AS product_4_orders
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at BETWEEN '2014-12-05' AND '2014-12-31'
GROUP BY 1 , 2;
