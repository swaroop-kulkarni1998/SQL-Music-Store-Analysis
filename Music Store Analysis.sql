SELECT * FROM music_store_analysis.employee;

/* Q1: Who is the senior most employee based on job title? */
SELECT * 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */
select * from invoice;

SELECT 
    billing_country, COUNT(*) count
FROM
    invoice
GROUP BY billing_country
ORDER BY count DESC;
   
/* Q3: What are top 3 values of total invoice? */

SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */


select billing_city , sum(total) invoice_total from invoice 
group by billing_city 
order by invoice_total desc ;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id , c.first_name ,  c.last_name  , sum(i.total) as invoice_total from customer c
  join invoice i using (customer_id)
  group by c.customer_id , c.first_name ,  c.last_name 
  order by sum(i.total) desc
  limit 1;
 ----------------------------------------------------------------------------------------
 
  /* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct email  , first_name , last_name 
from customer join invoice using (customer_id)
join invoice_line using (invoice_id)
join track using (track_id)
join genre g using (genre_id)
where g.name = 'rock'
order by email asc;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id,  artist.name, COUNT(artist.artist_id) total_songs from artist , album2 , track , genre
where artist.artist_id=album2.artist_id and album2.album_id=track.album_id
and track.genre_id=genre.genre_id and genre.name ='rock'
group by artist.artist_id , artist.name
order by total_songs desc
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name , milliseconds from track 
where milliseconds > (select avg(milliseconds)  avg_length
                          from track )
order by milliseconds  desc ;


----------------------------------###  ADVANCE  ###--------------------------------------------

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
 

with best_selling_artist as
      (select a.artist_id artist_id , a.name artist_name ,   sum(i.unit_price*i.quantity) total_sales from invoice_line i
      join track t  on t.track_id=i.track_id 
      join album2 al on al.album_id=t.album_id
      join artist a on al.artist_id=a.artist_id
      group by 1,2
      order by 3 desc
      limit 1 )
      
      select c.customer_id, c.first_name , c.last_name , bsa.artist_name , sum(il.unit_price*il.quantity) as 'amount spent '
      from invoice i 
      join customer c on c.customer_id=i.customer_id
      join invoice_line il on il.invoice_id =i.invoice_id 
      join track t on t.track_id=il.track_id
      join album2 al on al.album_id=t.album_id
      join best_selling_artist bsa on bsa.artist_id=al.artist_id
      group by 1,2,3,4
      order by 5 desc ;
      
      /* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


with popular_genre as 
    ( select count(il.quantity) as purchase , c.country , g.name , g.genre_id,
    row_number() over(partition by c.country order by count(il.quantity) desc)  as rowno
    from invoice_line il 
          join invoice  i on i.invoice_id=il.invoice_id
          join customer c on c.customer_id=i.customer_id
          join track t on t.track_id=il.track_id
          join genre g on g.genre_id=t.genre_id
    group by 2,3,4
    order by  2 asc , 1 desc )
    
    select * from popular_genre  where rowno = 1 ;
    
   /* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with spent_on_music as (
  select c.customer_id , c.first_name , i.billing_country as'country' , sum(i.total)  total_spent , 
         row_number () over(partition by i.billing_country order by sum(i.total) desc ) as rowrk 
         from customer c join invoice i on i.customer_id=c.customer_id
         group by 3 ,2,1 
         order by  3 asc ,  4  desc )
         
         select * from spent_on_music where rowrk =1 ;
         
         WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
