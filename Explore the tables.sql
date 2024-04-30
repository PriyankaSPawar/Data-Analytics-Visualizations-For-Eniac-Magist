Use magist;

SELECT * FROM orders;

/*1.How many orders are there in the dataset? */
SELECT 
	COUNT(*) AS total_count
FROM 
	orders;
    
SELECT * 
FROM order_items
ORDER BY order_id ASC, order_item_id DESC;

/*2. Are orders actually delivered?*/

SELECT 
	order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status;

SELECT 
    order_status, count(order_id), ROUND(count(order_id)/99441*100, 3) AS Percentage_From_Total
FROM
    orders
GROUP BY order_status
ORDER BY count(order_id) DESC;

/*3. Is Magist having user growth? */

SELECT 
	YEAR(order_purchase_timestamp) AS year_pur,
    MONTH(order_purchase_timestamp) AS month_pur,
    COUNT(customer_id)
    FROM
		orders
	GROUP BY year_pur,month_pur
    ORDER BY year_pur,month_pur DESC;
    
    /*OR*/
    
select year(order_purchase_timestamp) as "year", month(order_purchase_timestamp) as "month", count(order_id) as "total orders"
from orders
group by 1, 2
order by 1, 2 asc;
    
/*4. How many products are there on the products table?*/

SELECT * FROM products;

SELECT 
	COUNT(DISTINCT product_id) AS product 
FROM
	products;

/*5. Which are the categories with the most products? */

SELECT 
	product_category_name, COUNT(DISTINCT product_id) AS product
FROM
	products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;

/*OR*/
SELECT 
    COUNT(product_id) AS Number_of_Products,
    ROUND(COUNT(product_id) / 32951 * 100, 2) AS Percentage_From_Total,
    product_category_name_english
FROM
    products
        JOIN
    product_category_name_translation USING (product_category_name)
GROUP BY product_category_name , product_category_name_english
ORDER BY COUNT(product_id) DESC;

/*6. How many of those products were present in actual transactions? */
SELECT * FROM order_items;

SELECT 
	COUNT(DISTINCT product_id) 
FROM order_items;

/*7 What’s the price for the most expensive and cheapest products? */

SELECT * FROM order_items;
SELECT 
	MIN(price) AS cheapest,
	MAX(price)AS expensive
FROM
	order_items;
    
/*8 What are the highest and lowest payment values? */
SELECT * FROM order_payments;
SELECT
	MAX(payment_value) AS highest,
    MIN(payment_value) AS lowest
FROM
	order_payments;
    

SELECT ROUND(SUM(payment_value))AS highest_value
FROM
	order_payments
GROUP BY order_id
ORDER BY highest_value DESC
LIMIT 1;

/*OR*/
SELECT 
    MAX(payment_value),
    MIN(payment_value),
    ROUND(AVG(payment_value), 2)
FROM
    order_payments;