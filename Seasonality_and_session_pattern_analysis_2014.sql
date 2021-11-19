# SEASONALITY AND SESSION PATTERN ANALYSIS IN 2014

-- seasonality in 2014
SELECT 
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mth,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM
    website_sessions ws
        LEFT JOIN
    orders o ON ws.website_session_id = o.website_session_id
WHERE
    ws.created_at BETWEEN '2014-01-01' AND '2014-12-31'
GROUP BY YEAR(ws.created_at) , MONTH(ws.created_at);


-- daily and hourly session pattern analysis in 2014 Q2
SELECT 
	hr,
    ROUND(avg(website_sessions) ,0) as avg_sessions,
    ROUND(AVG(case when week_day = 0 THEN website_sessions ELSE NULL END) ,0) as monday,
	ROUND(AVG(case when week_day = 1 THEN website_sessions ELSE NULL END) ,0) as tuesday,
	ROUND(AVG(case when week_day = 2 THEN website_sessions ELSE NULL END) ,0) as wednesday,
	ROUND(AVG(case when week_day = 3 THEN website_sessions ELSE NULL END) ,0) as thursday,
	ROUND(AVG(case when week_day = 4 THEN website_sessions ELSE NULL END) ,0) as friday,
	ROUND(AVG(case when week_day = 5 THEN website_sessions ELSE NULL END) ,0) as saturday,
	ROUND(AVG(case when week_day = 6 THEN website_sessions ELSE NULL END) ,0) as sunday
FROM (
SELECT 
    DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS week_day,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS website_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2014-01-01' AND '2014-03-31'
GROUP BY DATE(created_at),
    WEEKDAY(created_at),
    HOUR(created_at)
) hourly_sessions
GROUP BY hr;