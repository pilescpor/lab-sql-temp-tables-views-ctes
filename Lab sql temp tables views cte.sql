USE sakila;

/*## Challenge

**Creating a Customer Summary Report**

In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

- Step 1: Create a View

First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).*/

CREATE VIEW rental_information AS
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS full_name, email, COUNT(rental_id) AS rental_count
FROM customer
JOIN rental USING (customer_id)
GROUP BY customer_id, full_name, email
;

DROP VIEW IF EXISTS rental_information;

/*- Step 2: Create a Temporary Table

Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.*/

CREATE TEMPORARY TABLE total_paid AS
SELECT customer_id, full_name, email, rental_count, SUM(amount) AS total_paid
FROM rental_information
JOIN payment USING (customer_id)
GROUP BY customer_id, full_name, email, rental_count
; 

/*- Step 3: Create a CTE and the Customer Summary Report

Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid. 

Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.*/

WITH summary AS ( 
	SELECT customer_id, full_name, email, rental_count, total_paid
    FROM total_paid
)
SELECT full_name, email, rental_count, total_paid, 
CASE 
	WHEN rental_count > 0 THEN total_paid/rental_count
    ELSE 0
END AS average_payment_per_rental
FROM summary;