CREATE TABLE public.album2
(
    album_id int8 PRIMARY KEY,
    title character varying,
    artist_id int8
);


create table public.artist
(
  artist_id int8 primary key,
  name varchar
)

CREATE TABLE public.customer (
    customer_id SERIAL PRIMARY KEY, 
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    company VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(25),
    fax VARCHAR(25),
    email VARCHAR(100) UNIQUE,
    support_rep_id INT
)
    
CREATE TABLE public.employee (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    title VARCHAR(100),
    reports_to INT,
    levels VARCHAR(20),
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(25),
    fax VARCHAR(25),
    email VARCHAR(100) UNIQUE,
);

create table public.genre
(
   genre_id int8 primary key,
   name varchar
)

select * from genre

create table public.invoice
(
invoice_id int8 primary key,
customer_id int8,
invoice_date date,
billing_address varchar(50),
billing_city varchar(50),
billing_state varchar(50),
billing_country varchar (50),
billing_postal_code varchar(30),
total float
)
create table public.invoice_line(
invoice_line_id int8,
invoice_id int8,
track_id int8,
unit_price float,
quantity int8
)

create table public.media_type
(
media_type_id int8 primary key,
name varchar(50)
)

create table public.playlist
(
playlist_id int8 primary key,
name varchar(50)
)

create table public.playlist_track(
playlist_id int8,
track_id int8

)

create table public.track(
track_id int8 primary key,
name varchar(200),
album_id int8,
media_type_id int8,
genre_id int8,
composer varchar(200),
milliseconds int,
bytes int,
unit_price float
)

CREATE TABLE public.employee (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    title VARCHAR(100),
    reports_to INT8,
    levels VARCHAR(20),
    birthdate TIMESTAMP,
    hire_date TIMESTAMP,
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(20),
    phone VARCHAR(25),
    fax VARCHAR(25),
    email VARCHAR(100) UNIQUE
);



 

-- Q1 who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1

-- Q2 which country has the most invoices?


select count(*) as number,billing_country from invoice
group by billing_country
order by number desc
limit 1

-- Q3 what are the top 3 value of total invoice?

select total from invoice
order by total desc
limit 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select * from invoice
select billing_city,sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select * from invoice
select customer.customer_id,
       customer.first_name,customer.last_name, 
       sum(invoice.total) as total 
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select email,first_name,last_name
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in(
                select track_id from track 
				join genre on track.genre_id = genre.genre_id
				where genre.name  = 'Rock'
) order by email

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.name,count(artist.artist_id) as number_of_songs
from artist
join album2 on album2.artist_id = artist.artist_id
join track on track.album_id = album2.album_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.name
order by number_of_songs desc
limit 10

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds 
from track 
where milliseconds > (
                       select avg(milliseconds) as average_length
					   from track)
order by milliseconds desc


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */


with best_selling_artist as(
select artist.artist_id,artist.name,sum(invoice_line.unit_price*invoice_line.quantity)as total_price
from artist
join album2 on album2.artist_id = artist.artist_id
join track on track.album_id = album2.album_id
join invoice_line on invoice_line.track_id = track.track_id
group by artist.name,artist.artist_id
order by total_price desc
limit 1)

select c.first_name,c.last_name,bsa.name as artist_name,sum(il.unit_price*il.quantity) as total_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album2 a on a.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = a.artist_id
group by 1,2,3
order by total_spent desc


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.*/

with popular_genre as(
select count(il.quantity) as purchases,c.country,g.genre_id,g.name,
  row_number() over(partition by c.country order by count(il.quantity) desc ) as rowno
from invoice_line il
join invoice i on i.invoice_id = il.invoice_id
join customer c on c.customer_id = i.customer_id
join track t on t.track_id = il.track_id
join genre g on g.genre_id = t.genre_id
group by 2,3,4
order by 2 asc,1 desc)
select * from popular_genre 
where rowno <=1

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with customer_with_country as(
select c.country,c.first_name,c.last_name,sum(total),
row_number() over(partition by c.country order by sum(total) desc)as rowno
from customer c
join invoice i on c.customer_id = i.customer_id
group by 1,2,3
order by 1 asc,4 desc)
select * from customer_with_country where rowno <=1
