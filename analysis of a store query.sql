# SQL_analysis_of_store
This is my MSSQL basic to advance project

--Q1: Who is the senior based employee based on the job title?
 select * from employee
 
 select top 1 levels,employee_id,first_name,last_name
 from employee order by levels desc

 --Q2 :Which countries have the most invoices ?
  select * from invoice

  select count(*) most_invoice,billing_country
  from invoice group by
  billing_country order by most_invoice desc

  --Q3: what are the top 3 values of total invoice 

select top 3 total from invoice 
order by total desc

--Q4:which city has the best customers? we would like to through a promotional music festival in the city we made the most money.
--Write a query to return one city that has highest sum of invoice totals.Return both the city name & sum of all invoice totals 
 
 select * from invoice
  select sum(total) as invoice_total ,billing_city
  from invoice group by billing_city 
  order by billing_city desc

  --Q5:Who is the best coustomer? 
  --The customer who has spent the most money will be declared the best coustomer 
  --Write a query that returns the person who has spent the most money.
  
  select top 1  c.customer_id,c.first_name,c.last_name, sum(i.total)as total 
  from customer as c
  inner join invoice as i
  on c.customer_id=i.customer_id
  group by c.customer_id,c.first_name,c.last_name
  order by total desc
  
 --Q1:Write query to return email,first name,
 --last name & genre of all rock music listeners
 -- Return your list ordered alphabetically by email starting with A

 select distinct email,first_name,last_name
 from customer
  inner join invoice 
  on customer.customer_id=invoice.customer_id
  inner join invoice_line
  on invoice_line.invoice_id=invoice.invoice_id
  where track_id in(
  select track_id from track
  join genre on track.genre_id= genre.genre_id
  where genre.name like 'rock')
  order by email

--Q2: let's invite the artist who have written the most 
--rock music in our dataset. Write aquery that returns 
--the artist name and total track count of the top 10 rock bands.

select top 10 artist.artist_id,artist.name, count(artist.artist_id)as no_of_songs
from track 
join album on album.album_id=track.album_id
join artist on album.album_id=track.album_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'rock'
group by artist.artist_id,artist.name
order by no_of_songs desc 

--Q3: Return all the track names that have a song length 
--longer then the average song lenfth. Return the name and 
--milliseconds for each track. order by the song length 
--with the longest song listen first.

select name ,milliseconds
from track 
where milliseconds> (select avg (milliseconds) as 
avg_track_length from track)
order by milliseconds desc

--Q1:Find  how much amount spend by each customer on artists?
--Write a query to return customer name ,artist name and total spent 

with best_selling_artist as (
select top 1 artist.artist_id as artist_id,artist.name as artist_name,
sum (invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line 
join track on track.track_id=invoice_line.track_id
join album on album.artist_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.artist_id,artist.name
order by total_sales desc
)
select c.customer_id,c.first_name,c.last_name, best_selling_artist.artist_name,
sum (il.unit_price*il.quantity)as amount_spent 
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id =il.track_id 
join album alb on alb.album_id=t.album_id
join best_selling_artist on best_selling_artist.artist_id=alb.artist_id
group by c.customer_id,c.first_name,c.last_name,best_selling_artist.artist_name
order by amount_spent desc 

--Q2: We want find out the most popular genre for each country.
-- We  determine the most popular genere as the genere with the highest amount of purchases.
--Write a query that returns each country along with the top genere. For countries where the 
-- maximum number of purchases is shared return all genres.

with popular_genre as(
select count (invoice_line.quantity)as purchase,customer.country,
genre.name,genre.genre_id, ROW_NUMBER ()over (partition by customer.country 
order by count (invoice_line,quantity) desc) as Rowno
From invoice_line 
join invoice on invoice.invoice_id=invoice_line.invoice_id
join customer on customer.customer_id=invoice.customer_id
join track on track.track_id=invoice_line.track_id
join genre on genre.genre_id =track.track_id
group by 2,3,4
order by 2 ,1 desc 
)
select * from popular_genre where Rowno<=1
