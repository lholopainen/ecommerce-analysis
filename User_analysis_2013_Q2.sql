# USER AMALYSIS IN 2013 Q2
 
-- identifying visitors coming back
-- CREATE TEMPORARY TABLE sessions_with_repeats
SELECT 
new_sessions.user_id,
new_sessions.website_session_id AS new_sessions,
ws.website_session_id AS repeat_sessions
FROM
(
SELECT
	user_id,
    website_session_id
FROM website_sessions
WHERE created_at BETWEEN '2013-01-01' AND '2014-03-31'
AND is_repeat_session = 0
) AS new_sessions
LEFT JOIN website_sessions ws
ON ws.user_id = new_sessions.user_id
AND ws.is_repeat_session = 1
AND ws.website_session_id > new_sessions.website_session_id
AND ws.created_at BETWEEN '2013-01-01' AND '2013-03-31'
;

SELECT 
    repeat_sessions, 
    COUNT(DISTINCT user_id) AS users
FROM
    (SELECT 
        user_id,
            COUNT(DISTINCT new_sessions) AS new_sessions,
            COUNT(DISTINCT repeat_sessions) AS repeat_sessions
    FROM
        sessions_with_repeats
    GROUP BY user_id
    ORDER BY COUNT(DISTINCT repeat_sessions) DESC) AS user_level
GROUP BY repeat_sessions;


-- repeat behavior analysis
-- CREATE TEMPORARY TABLE repeat_sessions_time_difference
SELECT 
    new_sessions.user_id,
    new_sessions.website_session_id AS new_sessions,
    new_sessions.created_at AS new_session_created_at,
    ws.website_session_id AS repeat_sessions,
    ws.created_at AS repeat_session_created_at
FROM
    (SELECT 
        user_id, website_session_id, created_at
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-03'
            AND is_repeat_session = 0) AS new_sessions
        LEFT JOIN
    website_sessions ws ON ws.user_id = new_sessions.user_id
        AND ws.is_repeat_session = 1
        AND ws.website_session_id > new_sessions.website_session_id
        AND ws.created_at BETWEEN '2013-01-01' AND '2014-03-31';
        
-- CREATE TEMPORARY TABLE first_to_second
SELECT 
    user_id,
    DATEDIFF(second_session_created_at,
            new_session_created_at) AS first_to_second_days
FROM
    (SELECT 
        user_id,
            new_sessions,
            new_session_created_at,
            MIN(repeat_sessions) AS second_sessions,
            MIN(repeat_session_created_at) AS second_session_created_at
    FROM
        repeat_sessions_time_difference
    WHERE
        repeat_sessions IS NOT NULL
    GROUP BY user_id ,new_sessions ,new_session_created_at) AS first_second;

SELECT
	AVG(first_to_second_days) AS avg_first_to_second_session,
    MIN(first_to_second_days) AS min_first_to_second_session,
    MAX(first_to_second_days) AS max_first_to_second_session
FROM first_to_second;


-- new vs repeat channel patterns
SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(CASE
        WHEN is_repeat_session = 0 THEN website_session_id
        ELSE NULL
    END) AS new_sessions,
    COUNT(CASE
        WHEN is_repeat_session = 1 THEN website_session_id
        ELSE NULL
    END) AS repeat_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2013-01-01' AND '2013-03-31'
GROUP BY utm_source , utm_campaign , http_referer
ORDER BY repeat_sessions DESC;

SELECT 
    CASE
        WHEN
            utm_source IS NULL
                AND http_referer IN ('https://www.gsearch.com' , 'https://www.bsearch.com')
        THEN
            'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN
            utm_source IS NULL
                AND http_referer IS NULL
        THEN
            'direct_type_in'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
    END AS channel_group,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
    FROM website_sessions
    WHERE created_at BETWEEN '2013-01-01' AND '2014-03-31'
    GROUP BY channel_group
    ORDER BY repeat_sessions DESC;
    
-- new and repeated cvr
SELECT
	is_repeat_session,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS cvr,
    SUM(price_usd) / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions ws
	LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2013-01-01' AND '2014-03-31'
GROUP BY is_repeat_session;