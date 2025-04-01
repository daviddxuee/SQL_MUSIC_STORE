--Q1: Who is the senior most employee based on job title? 

SELECT * FROM employee
ORDER BY birthdate ASC 
LIMIT 1

--Q2: Which countries have the most Invoices? 

SELECT COUNT(*) AS Invoices , billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY Invoices DESC 
LIMIT 10

--Q3: List the top 3 invoices with the highest dollar amount

SELECT *
FROM invoice
ORDER BY total DESC 
LIMIT 3

--Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money in. 
--Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name & sum of all invoice totals. 

SELECT SUM(TOTAL) as invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC 
LIMIT 1

--Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.

SELECT customer.first_name, customer.last_name, customer.customer_id, SUM(invoice.total) as Total
FROM customer JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1


--Q6: Write a query to return the email, first name, last name, and Genre of all Rock Music Listeners. 
--Return the list ordered alphabetically by email starting with A

SELECT DISTINCT email, first_name, last_name, genre.name
FROM customer JOIN invoice ON customer.customer_id = invoice.customer_id 
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id 
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email ASC

--Q7: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the artist name and total track 
--count of the top 10 rock bands

SELECT artist.name, COUNT(*) as total_songs
FROM track JOIN album ON track.album_ID = album.album_id
	JOIN artist ON album.artist_id = artist.artist_id 
	JOIN genre ON genre.genre_id = track.genre_id 
WHERE genre.name LIKE 'Rock'
GROUP BY artist.name
ORDER BY total_songs DESC 
LIMIT 10 

--Q8: Return all the track names that have a song length longer than the average song length.
-- Return the name and milliseconds for each track. Order by song length with the longest songs listed first 

SELECT name, milliseconds
FROM track
WHERE milliseconds > ( SELECT AVG(milliseconds) AS avg_length
					 FROM track)
ORDER BY milliseconds DESC

--Q9: Find how much each customer has spent on artists. Write a query to return customer name, artist name and total spent per artist. 

SELECT DISTINCT customer.customer_id, customer.first_name, customer.last_name, artist.name AS artist, SUM(invoice.Total) as amount_spent
FROM customer JOIN invoice ON customer.customer_id = invoice.customer_id
	JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id 
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id 
GROUP BY customer.customer_id, artist
ORDER BY customer.customer_id ASC

--Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
--For countries with the maximum number of purchases is shared return all Genres

WITH popular_genre AS 
(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rowno
	FROM invoice_line
	JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY customer.country, genre.name, genre.genre_id
	ORDER BY customer.country ASC, purchases DESC
)
SELECT * 
FROM popular_genre 
WHERE rowno <= 1

--Q11 Write a query that determines the customer that has spent the most on music for each country. Write a query that returns
-- the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide
--all customers who spent this amount

WITH customer_country AS (
	SELECT customer.customer_id, first_name, last_name, billing_country, SUM(total) AS total_spent,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS rowno
	FROM invoice
	JOIN customer ON invoice.customer_id = customer.customer_id 
	GROUP BY customer.customer_id, first_name, last_name, billing_country
	ORDER BY billing_country ASC, total_spent DESC)
SELECT * FROM customer_country WHERE rowno <= 1
	 
		  
		  