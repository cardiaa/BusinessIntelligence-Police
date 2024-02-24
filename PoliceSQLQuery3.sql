/* For each month, compute the total gravity in percentage
with respect to the annual total. */

WITH TotalGravityMonth AS (
	SELECT
		d.year,
		d.month,
		SUM(c.crime_gravity) AS TotCG_per_month
	FROM 
		Custody c,
		Date d
	WHERE 
		c.date_id = d.date_id 
	GROUP BY
		d.year,
		d.month
),

TotalGravityYear AS (
	SELECT
		d.year,
		SUM(c.crime_gravity) AS TotCG_per_year
	FROM 
		Custody c,
		Date d
	WHERE 
		c.date_id = d.date_id 
	GROUP BY
		d.year
)

SELECT 
	TGM.month,
	ROUND(CAST(TGM.TotCG_per_month AS FLOAT) / TGY.TotCG_per_year * 100, 2) AS TotalGravityPercentage
FROM 
	TotalGravityMonth TGM,
	TotalGravityYear TGY
WHERE
	TGM.year = TGY.year;

/* -------------- VERSION 2 ---------------- */
/* For each month, compute the total gravity in percentage
with respect to the annual total. */

SELECT
    d.month,
    CAST(
        ROUND(SUM(c.crime_gravity) * 100.0 / (
            SELECT 
				SUM(c2.crime_gravity)
            FROM 
				Custody c2
				JOIN Date d2 ON c2.date_id = d2.date_id
            WHERE 
				d2.year = d.year
        ), 2
	) AS DECIMAL(10,2)) AS TotalGravityPercentage
FROM 
    Custody c
	JOIN Date d ON c.date_id = d.date_id
GROUP BY
    d.year,
    d.month;

/* ------ VERSION 3 (using PARTITION BY) -------- */
/* For each month, compute the total gravity in percentage
with respect to the annual total. */

WITH MonthlyGravity AS (
    SELECT
        d.year,
        d.month,
        SUM(c.crime_gravity) AS MonthlyTotalGravity,
        SUM(SUM(c.crime_gravity)) OVER (PARTITION BY d.year) AS AnnualTotalGravity
    FROM 
        Custody c
        JOIN Date d ON c.date_id = d.date_id
    GROUP BY
        d.year,
        d.month
) 

SELECT
    month,
    CAST(
        ROUND(MonthlyTotalGravity * 100.0 / AnnualTotalGravity, 2) AS DECIMAL(10,2)
    ) AS TotalGravityPercentage
FROM 
    MonthlyGravity;