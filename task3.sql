WITH t1 AS (
SELECT start_date_time, 
	end_date_time,
	lag(start_date_time) OVER win1 - start_date_time AS if_neg_start1,
	lag(end_date_time) OVER win1 - start_date_time AS if_neg_start2,
	lag(end_date_time) OVER win1 - end_date_time AS if_neg_end,
	lag(start_date_time) OVER win2 - end_date_time AS if_pos_end
FROM intervals
WINDOW win1 AS (ORDER BY start_date_time), win2 AS (ORDER BY end_date_time DESC)
ORDER BY start_date_time),

t2 AS (
SELECT t1.start_date_time AS start_date_time,
	row_number() OVER() AS id
FROM t1
WHERE t1.if_neg_start1 < '00:00:00' AND t1.if_neg_start2 < '00:00:00' OR t1.if_neg_start2 IS NULL
ORDER BY 1),

t3 AS (
SELECT t1.end_date_time AS end_date_time,
	row_number() OVER() AS id
FROM t1
WHERE t1.if_neg_end < '00:00:00' AND t1.if_pos_end > '00:00:00' OR t1.if_pos_end IS NULL
ORDER BY 1)

SELECT t2.start_date_time AS StartDateTime, t3.end_date_time AS EndDateTime
FROM t2
JOIN t3 ON t2.id = t3.id