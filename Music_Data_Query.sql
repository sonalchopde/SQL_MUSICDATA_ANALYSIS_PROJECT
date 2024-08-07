
/* EASY */

/* Q.1 who is the senior most employee based on job title ?*/
SELECT first_name,last_name,title
FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q.2 Which countries have the most invoices ? */
SELECT COUNT(*) AS c , billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c DESC

/* Q.3 what are the top 3 values of total invoice ? */
SELECT total
FROM invoice
ORDER BY total DESC 
LIMIT 3

/* Q.4 Which city has the best customer ? we would like to throw a promotion party in the city we made the most money
write a query that returns  one city that has  the highest sum of invoice totals
Return both the city name and sum of all invoice totals */
SELECT billing_city,SUM(total) as INVOICETOTAL
FROM invoice
GROUP BY billing_city
ORDER BY INVOICETOTAL DESC
LIMIT 1 ;

/*Q.5  who is the best coustomer ?the customer who spent the most money will be declared the best customer
write a query that returns the person who spent the most money? */
SELECT customer.customer_id,customer.first_name,customer.last_name ,SUM(invoice.total) as TOTAL_SPENT
FROM customer
JOIN invoice ON customer.customer_id =invoice.customer_id
GROUP BY customer.customer_id,customer.first_name , customer.last_name
ORDER BY TOTAL_SPENT DESC
LIMIT 1;

/* MODERATE */

/*  Q.1 write a query to return the email,firstname, lastname and genre of all rock music listeners.
return your list ordered alphabetically by email starting with A   ? */
SELECT DISTINCT email,first_name,last_name
FROM customer
JOIN invoice ON customer.customer_id=invoice.customer_id
JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN(
SELECT track_id FROM track
JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name LIKE "ROCK"
)
ORDER BY email;

/* Q.2 lets invite the artists who have written the most rock music in our dataset . write a query that returns the artist
 name and total track count of thr top 10 rock bands */
 SELECT artist.artist_id,artist.name,COUNT(track.track_id) AS no_of_songs
 FROM track
 JOIN album2 ON album2.album_id=track.album_id
 JOIN artist ON artist.artist_id=album2.artist_id
 JOIN genre ON genre.genre_id=track.genre_id
 WHERE genre.name LIKE "ROCK"
 GROUP BY artist.artist_id,artist.name
 ORDER BY no_of_songs DESC 
 LIMIT 10;
 
 /* Q.3 return all thetrack names that have a song length longer than the average song length.
  return the name and milliseconds for each track. order by the song length with the longest song listed first */
  SELECT name,milliseconds FROM track
  WHERE milliseconds >(
  SELECT AVG (milliseconds) AS avg_milli
  FROM track
  )
  ORDER BY milliseconds DESC;
  
  /* ADVANCE */

  /* Q.1 find how  much amount spent by each customer on artists ? write a query to return customer name ,artist name and total spent */
  WITH best_selling_artist AS (
    SELECT artist.artist_id AS artist_id , artist.name AS artist_name , SUM(invoice_line.unit_price*invoice_line.quantity) AS  total_sales
    FROM invoice_line 
    JOIN track ON  track.track_id=invoice_line.track_id
    JOIN album2 ON album2.artist_id = track.album_id
    JOIN artist ON artist.artist_id = album2.artist_id
    GROUP BY artist.artist_id
    ORDER BY total_sales DESC
    LIMIT 1
  )
  SELECT c.customer_id , c.first_name ,c.last_name , bsa.artist_name , SUM (invoice_line.unit_price*invoice_line.quantity) AS amt_spent
  FROM invoice_line
  JOIN customer c ON c.customer_id=invoice.customer_id
  JOIN invoice_ line ON invoice_line.invoice_id=invoice.invoice_id
  JOIN track t ON t.track_id=invoice_line.track_id
  JOIN album2 alb ON alb.album_id=t.album_id
  JOIN best_selling_artist bsa ON bsa.artist_id =alb.artist_id
  GROUP BY c.first_name,c.last_name,bsa.artist_name
  ORDER BY  amt_spent  DESC ;
  
  /* Q.2 we want to find out the most popular music genre for each country we determine the most popular genre as the genre with the
  highest amount of purchases write a query that returns each country along with the top genre. for countries where the max. no
  of purchases is share return all genres */
    WITH popular_genre AS (
     SELECT COUNT(invoice_line.quantity) AS purchases ,customer.country ,genre.name ,genre.genre_id,
     ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC ) AS RowNO
     FROM invoice_line
       JOIN  invoice ON invoice.invoice_id = invoice_line.invoice_id
       JOIN  customer ON customer.customer_id=invoice.customer_id
       JOIN track ON track.track_id=invoice_line.track_id
       JOIN genre ON genre.genre_id = track.genre_id
	   GROUP BY customer.country , genre.name , genre.genre_id
       ORDER BY customer.country ASC , purchases DESC
  )
  SELECT * FROM popular_genre WHERE RowNo <=1
  
  
  /* Q.3 write a query that determines the customer that has spent the most on music for each country.
  write a query that returns that country along with the top customer and how much they spent.
  for countries where the top amount spent is shared , provide all customers who spent this amount . */
  WITH Customer_with_country AS (
    SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC ) AS RowNO
    FROM invoice
    JOIN  customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id,first_name,last_name,billing_country
    ORDER BY total_spending ASC , total_spending DESC
  )
  SELECT * FROM Customer_with_country WHERE RowNo <=1
