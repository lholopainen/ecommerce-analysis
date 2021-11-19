# WEBSITE PERFORMANCE ANALYSIS IN 2013 Q2

-- top website pages 
SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pageviews
FROM
    website_pageviews
WHERE
    created_at between '2013-04-01' and '2013-06-30'
GROUP BY pageview_url
ORDER BY pageviews DESC;


-- entry page trends
CREATE TEMPORARY TABLE first_page_in_session
SELECT 
    website_session_id,
    min(website_pageview_id) as first_page
FROM
    website_pageviews
WHERE
    created_at between '2013-04-01' and '2013-06-30'
GROUP BY website_session_id;

SELECT 
    wp.pageview_url AS landing_page_url,
    COUNT(DISTINCT fp.website_session_id) as sessions_hitting_page
FROM
    first_page_in_session fp
    LEFT JOIN website_pageviews wp
    ON fp.first_page = wp.website_pageview_id
    GROUP BY wp.pageview_url;

    
-- bounce rates for home and lander2 and landing page trend analysis
-- CREATE TEMPORARY TABLE first_pageviews
SELECT
website_session_id,
MIN(website_pageview_id) as min_pageview_id
FROM
    website_pageviews
WHERE created_at between '2013-04-01' and '2013-06-30'
GROUP BY website_session_id;

-- CREATE TEMPORARY TABLE sessions_home
SELECT 
    COUNT(DISTINCT fp.website_session_id),
    wp.pageview_url AS landing_page
FROM
    first_pageviews fp
    LEFT JOIN website_pageviews wp
    ON wp.website_pageview_id = fp.min_pageview_id
    WHERE wp.pageview_url = '/home';

-- CREATE TEMPORARY TABLE sessions_lander2
SELECT 
    COUNT(DISTINCT fp.website_session_id),
    wp.pageview_url AS landing_page
FROM
    first_pageviews fp
    LEFT JOIN website_pageviews wp
    ON  fp.min_pageview_id = wp.website_pageview_id
    WHERE wp.pageview_url = '/lander-2';

-- CREATE TEMPORARY TABLE bounced_sessions_home
SELECT 
    sh.website_session_id,
    sh.landing_page,
    COUNT(wp.website_pageview_id) AS pageviews
FROM
    sessions_home sh
        LEFT JOIN
    website_pageviews wp ON sh.website_session_id = wp.website_session_id
GROUP BY sh.website_session_id , sh.landing_page
HAVING COUNT(wp.website_pageview_id) = 1;

-- CREATE TEMPORARY TABLE bounced_sessions_lander2
SELECT 
    sl.website_session_id,
    sl.landing_page,
    COUNT(wp.website_pageview_id) AS pageviews
FROM
    sessions_lander2 sl
        LEFT JOIN
    website_pageviews wp ON sl.website_session_id = wp.website_session_id
GROUP BY sl.website_session_id , sl.landing_page
HAVING COUNT(wp.website_pageview_id) = 1;

-- CREATE TEMPORARY TABLE home_br
SELECT 
    COUNT(DISTINCT sh.website_session_id) AS total_sessions,
    COUNT(DISTINCT bsh.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bsh.website_session_id) / COUNT(DISTINCT sh.website_session_id) AS bounce_rate
FROM
    sessions_home sh
LEFT JOIN bounced_sessions_home bsh
ON sh.website_session_id = bsh.website_session_id;

-- CREATE TEMPORARY TABLE lander2_br
SELECT 
    COUNT(DISTINCT sl.website_session_id) AS total_sessions,
    COUNT(DISTINCT bsl.website_session_id) AS bounced_sessions,
	COUNT(DISTINCT bsl.website_session_id) / COUNT(DISTINCT sl.website_session_id) AS bounce_rate
FROM
    sessions_lander2 sl
LEFT JOIN bounced_sessions_lander2 bsl
ON sl.website_session_id = bsl.website_session_id;

SELECT 
    CASE
        WHEN total_sessions = 5026 THEN 'home'
        ELSE NULL
    END AS 'page',
    total_sessions,
    bounced_sessions,
    bounce_rate
FROM
    home_br 
UNION SELECT 
    CASE
        WHEN total_sessions = 19568 THEN 'lander-2'
        ELSE NULL
    END AS 'page',
    total_sessions,
    bounced_sessions,
    bounce_rate
FROM
    lander2_br;
    
-- conversion funnel
SELECT 
    DISTINCT pageview_url
FROM
    website_pageviews
WHERE
    created_at between '2013-04-01' and '2013-06-30';

SELECT 
   ws.website_session_id,
   wp.pageview_url,
   CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0
   END AS products_page,
   CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' OR wp.pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0
   END AS product,
   CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0
   END AS cart,
   CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0
   END AS shipping,
   CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0
   END AS billing,
   CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0
   END AS thank_you
FROM
    website_sessions ws
    LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at between '2013-04-01' and '2013-06-30'
ORDER BY ws.website_session_id, wp.created_at;

-- CREATE TEMPORARY TABLE session_level_made_it
SELECT
website_session_id,
MAX(products_page) AS products_page_made_it,
    MAX(product) AS product_made_it,
    MAX(cart) AS cart_made_it,
    MAX(shipping) AS shipping_made_it,
    MAX(billing) AS billing_made_it,
    MAX(thank_you) AS thank_you_made_it
FROM
(SELECT 
   ws.website_session_id,
   wp.pageview_url,
   CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0
   END AS products_page,
   CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' OR wp.pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0
   END AS product,
   CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0
   END AS cart,
   CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0
   END AS shipping,
   CASE WHEN wp.pageview_url = '/billing-2' THEN 1 ELSE 0
   END AS billing,
   CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0
   END AS thank_you
FROM
    website_sessions ws
    LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at between '2013-04-01' and '2013-06-30'
ORDER BY ws.website_session_id, wp.created_at) AS pageview_level
GROUP BY website_session_id;

SELECT 
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE
            WHEN products_page_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_products_page,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_product,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_cart,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_shipping,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_billing,
    COUNT(DISTINCT CASE
            WHEN thank_you_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS to_thank_you
FROM session_level_made_it;

SELECT 
    COUNT(DISTINCT CASE
            WHEN products_page_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS products_page_click_rt,
    COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN products_page_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS product_click_rt,
    COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN product_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS cart_click_rt,
    COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN cart_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS shipping_click_rt,
    COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN shipping_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS billing_click_rt,
    COUNT(DISTINCT CASE
            WHEN thank_you_made_it = 1 THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN billing_made_it = 1 THEN website_session_id
            ELSE NULL
        END) AS thank_you_click_rt
FROM session_level_made_it;

