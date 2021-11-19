# TRAFFIC SOURCE ANALYSIS IN 2013 Q2

-- top traffic sources
SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at between '2013-04-01' and '2013-06-30'
GROUP BY 1 , 2 , 3
ORDER BY sessions DESC;


-- cvr for gsearch nonbrand
SELECT 
    count(distinct ws.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    count(distinct o.order_id) / count(distinct ws.website_session_id) as cvr
FROM
    website_sessions ws
    LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
    WHERE
    ws.created_at between '2013-04-01' and '2013-06-30'
    and ws.utm_source = 'gsearch'
    and ws.utm_campaign = 'nonbrand';


-- trend analysis for gsearch nonbrand
SELECT 
    WEEK(created_at) AS wk,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2013-04-01' AND '2013-06-30'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;


-- bid optimization for gseach nonbrand
SELECT 
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS cvr
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at BETWEEN '2013-04-01' AND '2013-06-30'
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
GROUP BY 1;


-- weekly trends for devices
SELECT 
    WEEK(created_at) as wk,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS desktop_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2013-04-01' AND '2013-06-30'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at);