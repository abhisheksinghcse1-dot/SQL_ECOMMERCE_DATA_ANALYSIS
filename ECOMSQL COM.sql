---FUNNEL ANALYSIS OF A WEBSITE
SELECT * FROM WEBSITE_SESSIONS
SELECT * FROM orders
SELECT * FROM website_pageviews
SELECT * FROM order_items
SELECT * FROM order_item_refunds
SELECT * FROM products


1---CONVERSION RATE COUNT
SELECT COALESCE (w.utm_source,'Direct')AS traffic_source,
COUNT(w.website_session_id) AS total_sessions,
COUNT(o.order_id) AS total_orders,
ROUND(COUNT(o.order_id)*100.00/COUNT(w.website_session_id),2)AS conversion_rate
FROM website_sessions w 
LEFT JOIN orders o
ON w.website_session_id=o.website_session_id
GROUP BY traffic_source ;



-------------------SECTION 1-----------------------------------------------------------


-------------TRAFFIC & ACQUISITION (MARKETING FUNNEL)----------------------------------
---NULL=DIRECT UNTRACKED SALES
1---HOW MANY SESSIONS CAME FROM EACH TRAFFIC SOURCE OVER TIME (Monthly_trend)
SELECT
COALESCE(w.utm_source,'Direct') AS traffic_source,
COUNT(w.website_session_id) AS total_sessions,
COUNT(o.order_id) AS total_orders,
ROUND(
COUNT(o.order_id)*100.0/COUNT(w.website_session_id),2) AS conversion_rate
FROM website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
GROUP BY COALESCE(w.utm_source,'Direct')
ORDER BY conversion_rate DESC;



2---WHICH TRAFFIC CAMPAIGN PERFORM BEST (Conversion rate by utm_camapign)
SELECT COALESCE (w.utm_campaign,'No_campaign')AS utm_campaign,
COUNT(w.website_session_id)AS total_session,
COUNT(o.order_id) AS total_orders,
ROUND(COUNT(o.order_id)*100.00/COUNT(w.website_session_id),2)AS conversion_rate
FROM website_sessions w
LEFT JOIN orders o
ON w.website_session_id=o.website_session_id
GROUP BY COALESCE (w.utm_campaign,'No_campaign')
ORDER BY conversion_rate desc;





3---WHICH AD VERSION PERFORMS BETTER (utm_content A/B testing)?
---PURPOSE:CAMPAIGN EFFCIENCY COMPARISION
SELECT 	COALESCE(w.utm_content,'Direct')AS all_utm_content,
COUNT (w.website_session_id)AS sessions_id,
COUNT (o.order_id)AS Total_orders_recived,
ROUND(COUNT(o.order_id)*100.00/COUNT(w.website_session_id),2)AS Conversion_rate
FROM website_sessions w
LEFT JOIN orders o
ON w.website_session_id=o.website_session_id
GROUP BY COALESCE(w.utm_content,'Direct')
ORDER BY Conversion_rate DESC ;



---------------------------------SECTION 2------------------------------------------
-------------------------LANDING PAGE PERFORMANCE--------------------------------------

4---WHICH LANDING PAGE RECIVES THE MOST SESSIONS
--PURPOSE:TRAFFIC ENTRY OPTIMIZATION
SELECT
pageview_url AS landing_page,
COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_pageviews
GROUP BY pageview_url
ORDER BY total_sessions DESC;




5---WHICH LANDING PAGE HAS A HIGHEST CONVERSION RATE
SELECT website_session_id,
MIN(created_at) AS first_page_time
FROM website_pageviews
GROUP BY website_session_id

WITH first_pageviews AS
(SELECT website_session_id,
MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
GROUP BY website_session_id)
SELECT
wp.pageview_url AS landing_page,
COUNT(DISTINCT wp.website_session_id) AS total_sessions,
COUNT(o.order_id) AS total_orders,
ROUND(COUNT(o.order_id)*100.0/COUNT(DISTINCT wp.website_session_id),2) AS conversion_rat
FROM first_pageviews fp
JOIN website_pageviews wp
ON fp.first_pageview_id = wp.website_pageview_id
LEFT JOIN orders o
ON wp.website_session_id = o.website_session_id
GROUP BY landing_page



--------------------------SECTION 3----------------------------------------------------

--------------------------DEVICE BEHAVIOUS ANALYSIS------------------------------------


7---CONVERSION RATE BY DEVICE_TYPE
SELECT w.device_type AS device_category,
COUNT (w.website_session_id) AS total_sessions,
COUNT(o.order_id) AS total_orders,
ROUND(COUNT(o.order_id)*100/COUNT(w.website_session_id),2)AS Conversion_rate
FROM website_sessions w
LEFT JOIN orders o
ON w.website_session_id=o.website_session_id
GROUP BY w.device_type; 


8--- WHICH TRAFFIC SOURCE PERFORM THE BEST ON MOBILE VS DESKTOP
SELECT
COALESCE(w.utm_source,'Direct') AS traffic_source,w.device_type,
COUNT(w.website_session_id) AS total_sessions,
COUNT(o.order_id) AS total_orders,
ROUND(COUNT(o.order_id)*100.0/COUNT(w.website_session_id),2) AS conversion_rate
FROM website_sessions w
LEFT JOIN orders o
ON w.website_session_id = o.website_session_id
GROUP BY traffic_source, w.device_type
ORDER BY conversion_rate DESC;



---------------------------SECTION 4----------------------------------------------------- 
--------------------SALES AND REVENUE ANALYSIS------------------------------------------

9---MONTHLY REVENUE TREND
SELECT
DATE_PART('year',created_at) AS year,
DATE_PART('month',created_at) AS month,
COUNT(order_id) AS total_orders,
ROUND(SUM(price_usd),2) AS revenue
FROM orders
GROUP BY year,month
ORDER BY year,month;


10---REVENUE CONTRIBUTION BY PRODUCT
SELECT o.product_id,product_name,
SUM(o.price_usd) AS Revenue_contribution_by_Product
FROM order_items o
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY o.product_id,product_name




11---PROFIT ANALYSIS BY PRODUCT
SELECT o.product_id,product_name,
SUM(o.cogs_usd) AS Total_cost_price,
SUM(o.price_usd) AS Total_selling_ptice,
ROUND(SUM(o.price_usd)-SUM(o.cogs_usd),2) AS Total_profit,
ROUND((SUM(o.price_usd)-SUM(o.cogs_usd))*100.00/SUM(o.price_usd),2) AS profit_percent
FROM order_items o
LEFT JOIN products p
ON o.product_id = p.product_id
GROUP BY o.product_id,product_name




-----------------------SECTION 5-------------------------------------------------------
--------------CUSTOMER BEHAVIOUR ANALYSIS----------------------------------------------

12---REPET VS NEW VISITOR CONVERSION COMPARISION
SELECT 
CASE 
WHEN is_repeat_session = 1 THEN 'Repeat_customer'
ELSE 'New_customer'
END AS repet_vs_new,
COUNT(w.website_session_id)AS visitors_count,
COUNT(o.order_id) AS total_orders,
ROUND(COUNT(o.order_id)*100.00/COUNT(w.website_session_id),2) AS conversion_rate
FROM website_sessions w
LEFT JOIN orders o
ON w.website_session_id=o.website_session_id
GROUP BY repet_vs_new;




13---AVERAGE NUMBER OF ITEMS PER ORDER
--PURPOSE:BASKET SIZE INSIGHTS
SELECT SUM(items_purchased)AS total_items,
COUNT(order_id) AS total_orders,
ROUND(SUM(items_purchased)*1.00/COUNT(order_id),3)AS conversion_rate
FROM orders;

--------------------------SECTION 6---------------------------------------------------
------------------------REFUND ANALYSIS------------------------------------------------

14---REFUND RATE BY PRODUCT
SELECT * FROM orders
SELECT * FROM order_items
SELECT * FROM order_item_refunds
SELECT * FROM products


SELECT p.product_name,
COUNT(oi.order_id)AS total_orders,
COUNT(r.order_item_refund_id)AS total_refunds_orders,
ROUND(COUNT(r.order_item_refund_id)*100.00/COUNT(oi.order_id),2)AS refund_rate
FROM order_items oi
LEFT JOIN order_item_refunds r
ON oi.order_id=r.order_id
LEFT JOIN products p
ON oi.product_id=p.product_id
GROUP BY p.product_name
ORDER BY refund_rate DESC;


15---REVENUE LOST DUE TO REFUND
--PURPOSE: PROFIT LEKAGE DETECTION
SELECT ROUND(SUM(refund_amount_usd),2)AS total_revenue_lost_due_to_refunds
FROM order_item_refunds;







