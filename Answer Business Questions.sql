Use magist;


/* 3.1. In relation to the products: */

/*1 What categories of tech products does Magist have?*/
SELECT 
    product_category_name_english AS tech_prod,
    product_category_name
FROM
    product_category_name_translation
WHERE
    product_category_name_english IN ('audio' , 'books_technical',
        'computers',
        'computers_accessories',
        'consoles_games',
        'electronics',
        'home_appliances',
        'home_appliances_2',
        'pc_gamer',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony')
GROUP BY product_category_name
ORDER BY tech_prod ASC;


SELECT DISTINCT
    p.product_category_name, t.product_category_name_english
FROM
    products p
        JOIN
    product_category_name_translation t ON p.product_category_name = t.product_category_name;

SELECT * FROM sellers;


/*2 How many products of these tech categories have been sold (within the time window of the database snapshot)? 
What percentage does that represent from the overall number of products sold?  */

SELECT COUNT(DISTINCT order_id)
AS total_sells
FROM order_items as oi;

SELECT t.product_category_name_english, ROUND((COUNT(oi.order_id) / 98666) * 100, 2)
AS percentage_sold_count
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name =
t.product_category_name
WHERE t.product_category_name_english IN ('audio', 'books_technical', 'computers',
'computers_accessories', 'consoles_games', 'electronics', 'home_appliances',
'home_appliances_2', 'pc_gamer', 'signaling_and_security', 'tablets_printing_image',
'telephony')
GROUP BY t.product_category_name_english
ORDER BY percentage_sold_count DESC;

/*3 What’s the average price of the products being sold? */
SELECT DISTINCT AVG(price) AS average_price, t.product_category_name_english
FROM products p
JOIN product_category_name_translation t ON p.product_category_name =
t.product_category_name
join order_items as oi ON p.product_id = oi. product_id
WHERE t.product_category_name_english IN ('audio', 'books_technical', 'computers',
'computers_accessories',
'consoles_games','electronics','home_appliances','home_appliances_2','pc_gamer','signaling_and_securi
ty','tablets_printing_image','telephony')
GROUP BY t.product_category_name_english
order by average_price ASC;

/*4 Are expensive tech products popular? */

SELECT COUNT(oi.product_id)as product_count, 
	CASE 
		WHEN price > 1000 THEN "Expensive"
		WHEN price > 100 THEN "Mid-range"
		ELSE "Cheap"
	END AS "price_range"
FROM order_items oi
LEFT JOIN products p
	ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pt
	USING (product_category_name)
WHERE pt.product_category_name_english IN ('audio', 'books_technical', 'computers', 'computers_accessories',                       
 'consoles_games', 'electronics', 'home_appliances', 'home_appliances_2',                                      
 'pc_gamer', 'signaling_and_security', 'tablets_printing_image', 'telephony')
GROUP BY price_range
ORDER BY 1 DESC;



/*3.2. In relation to the sellers:
1. How many months of data are included in the magist database?*/

SELECT
    (SELECT MIN(order_purchase_timestamp) FROM orders) AS 'first order',
    (SELECT MAX(order_purchase_timestamp) FROM orders) AS 'last order',
    TIMESTAMPDIFF(MONTH,
                  (SELECT MIN(order_purchase_timestamp) FROM orders),
                  (SELECT MAX(order_purchase_timestamp) FROM orders)) AS 'timespan'
FROM magist.orders;

/* 2. How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers? */
-- 2.1 How many sellers are there?

SELECT COUNT(DISTINCT seller_id) as total_sellers FROM magist.sellers; -- 3095 
-- since seller_id only holds unique values, DISTINCT is not required but doesn't harm.


-- 2.2 How many Tech sellers are there? -- 594 (distinct)

SELECT count(distinct i.seller_id) as 'Tech Sellers' -- , p.product_id, c.product_category_name_english -- add distinct?
FROM order_items i 
JOIN products p USING(product_id)
JOIN product_category_name_translation c USING(product_category_name)
WHERE c.product_category_name_english IN
('audio',
'books_technical',
'computers',
'computers_accessories',
'consoles_games',
'electronics',
'home_appliances',
'home_appliances_2',
'pc_gamer',
'signaling_and_security',
'tablets_printing_image',
'telephony');

-- 2.3 What percentage of overall sellers are Tech sellers? -- 19,19 %

SELECT 
ROUND(100 *
( 
-- start subquery
SELECT count(distinct i.seller_id) as 'Tech Sellers'
FROM order_items i 
JOIN products p USING(product_id)
JOIN product_category_name_translation c USING(product_category_name)
WHERE c.product_category_name_english IN
	('audio',
	'books_technical',
	'computers',
	'computers_accessories',
	'consoles_games',
	'electronics',
	'home_appliances',
	'home_appliances_2',
	'pc_gamer',
	'signaling_and_security',
	'tablets_printing_image',
	'telephony'
	)
) -- end subquery
/
COUNT(DISTINCT s.seller_id), 2) as "Percent of Tech Sellers"
FROM sellers s;



-- What is the total amount earned by all sellers? -- 13_221_498.11 €

select ROUND(SUM(i.price), 2) as "Total Sales by all Sellers"
from order_items i
left join orders o USING(order_id)
where o.order_status IN("delivered");

-- What is the total amount earned by all Tech sellers? -- 2_006_525.95 €
select ROUND(SUM(i.price), 2) as "Total Sales by Tech Sellers"
from order_items i
left join orders o USING(order_id)
left join products p USING(product_id)
left join product_category_name_translation c USING(product_category_name)
WHERE 
o.order_status = "delivered"
AND 
c.product_category_name_english IN
('audio',
'books_technical',
'computers',
'computers_accessories',
'consoles_games',
'electronics',
'home_appliances',
'home_appliances_2',
'pc_gamer',
'signaling_and_security',
'tablets_printing_image',
'telephony');

 /*-- average monthly income of all sellers -- 528859.92 */
select
round(
( -- subquery total income of all sellers
select ROUND(SUM(i.price), 2) 
from order_items i
left join orders o USING(order_id)
where o.order_status IN("delivered")
) -- end subquery
/
( -- subquery timespan in months
SELECT
    TIMESTAMPDIFF(MONTH,
                  (SELECT MIN(order_purchase_timestamp) FROM orders),
                  (SELECT MAX(order_purchase_timestamp) FROM orders)) AS 'timespan'
FROM magist.orders
LIMIT 1
) -- end subquery
, 2); -- end round



-- average monthly income of Tech sellers? -- 80261.04
select
round(
( -- subquery total income of all sellers
select ROUND(SUM(i.price), 2) 
from order_items i
left join orders o USING(order_id)
left join products p USING(product_id)
left join product_category_name_translation c USING(product_category_name)
where o.order_status IN("delivered")
AND 
c.product_category_name_english IN
('audio',
'books_technical',
'computers',
'computers_accessories',
'consoles_games',
'electronics',
'home_appliances',
'home_appliances_2',
'pc_gamer',
'signaling_and_security',
'tablets_printing_image',
'telephony')
) -- end subquery
/
( -- subquery timespan in months
SELECT
    TIMESTAMPDIFF(MONTH,
                  (SELECT MIN(order_purchase_timestamp) FROM orders),
                  (SELECT MAX(order_purchase_timestamp) FROM orders)) AS 'timespan'
FROM magist.orders
LIMIT 1
) -- end subquery
, 2); -- end round
SELECT count(i.seller_id) as 'Tech Sellers'
FROM order_items i
JOIN products p USING(product_id)
JOIN product_category_name_translation c USING(product_category_name)
WHERE c.product_category_name_english IN
('audio' , 'books_technical',
        'computers',
        'computers_accessories',
        'consoles_games',
        'electronics',
        'home_appliances',
        'home_appliances_2',
        'pc_gamer',
        'signaling_and_security',
        'tablets_printing_image',
        'telephony');

