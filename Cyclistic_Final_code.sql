




use Cyclistic
go
select * from bikedata1

/*PREPARE STAGE */

INSERT INTO bikedata1
SELECT *
FROM bikedata12;

/* PROCESS */
/* Verify row count */

SELECT *
FROM bikedata1;--- 5,667,717 rows

SELECT COUNT(*)
FROM bikedata1;---5667717 rows. Same as above

/* To check if there are no duplicates in the first row, which is supposed to be the primary key*/

SELECT DISTINCT(COUNT(ride_id)) /* 5667717, which is same number o rows as above, which confirms no duplicates */
FROM bikedata1;

/*This gives us how many null values are there per variable */

SELECT 
  COUNT(*) - COUNT(ride_id) AS count_ride_id,
  COUNT(*) - COUNT(rideable_type) AS count_rideable_type,
  COUNT(*) - COUNT(started_at) AS count_started_at,
  COUNT(*) - COUNT(ended_at) AS count_ended_at,
  COUNT(*) - COUNT(start_lat) AS count_start_lat,
  COUNT(*) - COUNT(start_lng) AS count_start_lng,
  COUNT(*) - COUNT(end_lat) AS count_end_lat, /*5858*/
  COUNT(*) - COUNT(start_station_name) AS count_start_station_name, /*833064*/
  COUNT(*) - COUNT(start_station_id) AS count_start_station_id, /*833064*/
  COUNT(*) - COUNT(end_station_name) AS count_end_station_name, /*892742*/
  COUNT(*) - COUNT(end_station_id) AS count_end_station_id, /*892742*/
  COUNT(*) - COUNT(member_casual) AS count_member_casual,
  COUNT(*) - COUNT(end_lng) AS count_end_lng /*5866*/
  
  FROM
bikedata1;

/* member_casual count per member type */

SELECT member_casual, COUNT(member_casual) AS count
FROM bikedata1
GROUP BY member_casual /* member=334568, casual=2322032 */

/* bike count */

SELECT rideable_type, COUNT(rideable_type) AS COUNT
FROM bikedata1
GROUP BY rideable_type /* docked_bike=177474, classic=2601214, electric_bike=2889029 */

/* How many station do we have, counted by start stations?*/

SELECT DISTINCT( start_station_name) AS start_station /*1675 stations*/
FROM bikedata1


/* Station count by end station count?*/

SELECT DISTINCT(end_station_name) AS end_station /*1693*/
FROM bikedata1;

/* member type verification */

SELECT DISTINCT(member_casual) AS membership /*verified that there are only two membership types; member and casual */
FROM bikedata1;

/* date conversions*/

SELECT
  ride_id,rideable_type,start_station_name, end_station_name, start_lat, start_lng,end_lat, end_lng, member_casual AS member_type,started_at,
  CASE 
    WHEN DATEPART(w,started_at) = 1 THEN 'SUN'
    WHEN DATEPART(w,started_at) = 2 THEN 'MON'
    WHEN DATEPART(w,started_at) = 3 THEN 'TUE'
    WHEN DATEPART(w,started_at) = 4 THEN 'WED'
    WHEN DATEPART(w,started_at) = 5 THEN 'THU'
    WHEN DATEPART(w,started_at) = 6 THEN 'FRI'
	WHEN DATEPART(w,started_at) = 7 THEN 'SAT'
   END AS day_of_week
  FROM
  bikedata1;

  /* Final code to upload data to power bi */

  SELECT
  ride_id,rideable_type,start_station_name, end_station_name, start_lat, start_lng,end_lat, end_lng, member_casual AS member_type,started_at,ended_at,start_station_id,end_station_id,
  CASE 
    WHEN DATEPART(w,started_at) = 1 THEN 'SUN'
    WHEN DATEPART(w,started_at) = 2 THEN 'MON'
    WHEN DATEPART(w,started_at) = 3 THEN 'TUE'
    WHEN DATEPART(w,started_at) = 4 THEN 'WED'
    WHEN DATEPART(w,started_at) = 5 THEN 'THU'
    WHEN DATEPART(w,started_at) = 6 THEN 'FRI'
	WHEN DATEPART(w,started_at) = 7 THEN 'SAT'
   END AS week_day,

  CASE
    WHEN MONTH (started_at) = 1 THEN 'JAN'
    WHEN MONTH (started_at) = 2 THEN 'FEB'
    WHEN MONTH (started_at) = 3 THEN 'MAR'
    WHEN MONTH (started_at) = 4 THEN 'APR'
	WHEN MONTH (started_at) = 5 THEN 'MAY'
	WHEN MONTH (started_at) = 6 THEN 'JUN'
	WHEN MONTH (started_at) = 7 THEN 'JUL'
	WHEN MONTH (started_at) = 8 THEN 'AUG'
	WHEN MONTH (started_at) = 9 THEN 'SEP'
	WHEN MONTH (started_at) = 10 THEN 'OCT'
	WHEN MONTH (started_at) = 11 THEN 'NOV'
	WHEN MONTH (started_at) = 12 THEN 'DEC'
 END AS month,
  DATEPART(dd, started_at) AS day,
  DATEPART(yy,started_at) AS year,
  DATEDIFF (minute,started_at,ended_at) AS ride_length
  
FROM bikedata1

WHERE DATEDIFF (minute,started_at,ended_at) > 0 AND DATEDIFF (minute,started_at,ended_at) < 1440 AND
end_lat IS NOT NULL AND
start_station_name IS NOT NULL AND
start_station_id IS NOT NULL AND
end_station_name IS NOT NULL AND
end_station_id IS NOT NULL AND
end_lng IS NOT NULL
ORDER BY ride_length DESC


/* ANALYSE STAGE */
/* perform EDA by firing the queries as below */

/* total trips for all by membership and bike type*/

SELECT member_casual, rideable_type, COUNT(*) AS trip_total
FROM bikedata1
GROUP BY member_casual, rideable_type
ORDER BY member_casual, trip_total;

/* total ride_length */

SELECT SUM(DATEDIFF(minute, started_at, ended_at)) AS total_ride_length
FROM bikedata1 

/*  average ride length */

SELECT
ROUND(AVG(DATEDIFF (minute,started_at,ended_at)),2) AS avg_ride_length /* 19 minutes */
FROM bikedata1;

/* Average trip length per member type */

SELECT
ROUND(AVG(DATEDIFF (minute,started_at,ended_at)),2) AS avg_ride_length, member_casual, rideable_type
FROM bikedata1
GROUP BY 
member_casual, rideable_type
ORDER BY avg_ride_length DESC

/* max trip time per member class */

SELECT
ROUND(MAX(DATEDIFF (minute,started_at,ended_at)),2) AS max_ride_length , member_casual, rideable_type
FROM bikedata1
GROUP BY member_casual, rideable_type 
ORDER BY max_ride_length DESC

/* min trip per member type */

SELECT
ROUND(MIN(DATEDIFF (minute,started_at,ended_at)),2) AS min_ride_length , member_casual, rideable_type
FROM bikedata1
WHERE DATEDIFF (minute,started_at,ended_at) > 1 /* this was neccessary to remove -ve values */
GROUP BY member_casual, rideable_type
ORDER BY min_ride_length



/* trips analysed on a daily basis for all users */

SELECT
   member_casual AS member_type, DATEDIFF(minute,started_at,ended_at) AS ride_length, rideable_type,
  CASE 
    WHEN DATEPART(w,started_at) = 1 THEN 'SUN'
    WHEN DATEPART(w,started_at) = 2 THEN 'MON'
    WHEN DATEPART(w,started_at) = 3 THEN 'TUE'
    WHEN DATEPART(w,started_at) = 4 THEN 'WED'
    WHEN DATEPART(w,started_at) = 5 THEN 'THU'
    WHEN DATEPART(w,started_at) = 6 THEN 'FRI'
	WHEN DATEPART(w,started_at) = 7 THEN 'SAT'
   END AS week_day
FROM bikedata1
WHERE 
DATEDIFF(minute,started_at,ended_at)  >= 0 AND
end_lat IS NOT NULL AND
start_station_name IS NOT NULL AND
start_station_id IS NOT NULL AND
end_station_name IS NOT NULL AND
end_station_id IS NOT NULL AND
end_lng IS NOT NULL 
GROUP BY  rideable_type, member_casual, started_at, ended_at, CASE 
    WHEN DATEPART(w,started_at) = 1 THEN 'SUN'
    WHEN DATEPART(w,started_at) = 2 THEN 'MON'
    WHEN DATEPART(w,started_at) = 3 THEN 'TUE'
    WHEN DATEPART(w,started_at) = 4 THEN 'WED'
    WHEN DATEPART(w,started_at) = 5 THEN 'THU'
    WHEN DATEPART(w,started_at) = 6 THEN 'FRI'
	WHEN DATEPART(w,started_at) = 7 THEN 'SAT'
   END
ORDER BY ride_length, member_type, week_day, rideable_type desc

/* trips/rides as per start station */

SELECT start_station_name, member_casual,
  AVG(start_lat) AS avg_start_lat, AVG(start_lng) AS avg_start_lng,
  COUNT(ride_id) AS trip_count
FROM bikedata1
GROUP BY start_station_name, member_casual
ORDER BY trip_count DESC

/* trips/rides by end station */

SELECT end_station_name, member_casual,
  AVG(end_lat) AS avg_start_lat, AVG(end_lng) AS avg_end_lng,
  COUNT(ride_id) AS trip_count
FROM bikedata1
GROUP BY end_station_name, member_casual
ORDER BY trip_count DESC



