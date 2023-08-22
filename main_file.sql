create database music_project;
use music_project;
-- who is seniour most employee based on job title

select * from employee order by levels desc limit 1;

-- which country has most invosices

select billing_country,count(*) from invoice group by billing_country order by count(*) desc limit 1;

-- what are the top three values of total invoice
select  total from( select *, dense_rank() over(order by total desc) as r from invoice)as t where t.r<=3;

-- which city has best customer?write a query that returns one city that has a highest sum of invoice totals. return both the city name and invoice total
select billing_city,my_total from(select billing_city,e.s as my_total,dense_rank() over(order by e.s desc) as d from (select billing_city,sum(total) as s from invoice group by billing_city ) as e ) l where l.d=1

-- who is the best customer? The customer who has spent the most money will be declared the best customer

select final_table.first_name,final_table.last_name,final_table.s from (select *,dense_rank() over(order by t.s desc) as d from (select c.first_name,c.last_name,sum(i.total) s from customer c inner join invoice i on c.customer_id=i.customer_id group by 1,2) as t) as final_table where final_table.d=1;

/* Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A.*/

select distinct c.first_name,c.last_name, c.email from customer c 
inner join invoice i on c.customer_id=i.customer_id
inner join invoice_line l on l.invoice_id=i.invoice_id
where l.track_id in (select t.track_id from track t inner join genre g on g.genre_id=t.genre_id where g.name="Rock")order by c.email;


/*Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands.*/

select dence_final.name,dence_final.co from (select *, dense_rank() over(order by main_t.co desc) d from(select a.name,count(*) co  from artist a inner join album2 al on al.artist_id=a.artist_id
inner join track t on t.album_id= al.album_id 
where al.album_id in(
select t.album_id from track t inner join genre g on g.genre_id=t.genre_id where g.name="Rock") group by 1) main_t) dence_final where dence_final.d<=10;

-- Return all the track names that have a song length longer than the average song length
-- Return the name and milliseconds for each track . order by the song length with the longest songs listed first

select name,milliseconds from track where milliseconds > (select avg(milliseconds) average from track ) order by 2 desc;

select * from  (select  name,milliseconds ,avg(milliseconds) over() average from track) as t where milliseconds>t.average order by milliseconds desc;



-- find how much amount spent by each customer on artists? write a query to return customer_id,customer name,artist name and total spent

with best_selling_artist as (
select artist.artist_id as artist_id ,artist.name as artist_name,sum(invoice_line.unit_price*invoice_line.quantity) as total_sales from invoice_line 
join track on invoice_line.track_id= track.track_id
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id= album2.artist_id group by 1,2 order by 3 desc)

select c.customer_id,c.first_name,c.last_name, bsa.artist_name,sum(l.unit_price*l.quantity) as total_spent from customer c inner join invoice i on c.customer_id= i.customer_id
inner join invoice_line l on l.invoice_id= i.invoice_id inner join 
track t on t.track_id = l.track_id inner join album2 al on al.album_id=t.album_id inner join best_selling_artist  bsa on bsa.artist_id=al.artist_id group by 1,2,3,4 order by 5 desc

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

select ttt.country,ttt.name,ttt.co from (select *,rank() over(partition by country order by co desc) as r from 
(select c.country,g.name,count(l.quantity) as co from customer c inner join invoice i on c.customer_id= i.customer_id 
inner join invoice_line l on i.invoice_id= l.invoice_id inner join track t on l.track_id=t.track_id inner join 
genre g on g.genre_id= t.genre_id group by 1,2) as tt) as ttt where ttt.r=1 order by co desc; 



WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


