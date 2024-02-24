/* For each state, compute the stolen gravity index 
defined as the ratio between the total gravity of custodies
involving stolen guns divided by 
the overall gravity of custodies. */

WITH TotalCG_Per_State AS (
	SELECT
		ge.state,
		SUM(c.crime_gravity) AS TotalCG
	FROM 
		Geography ge,
		Custody c,
		Gun gu
	WHERE 
		ge.geo_id = c.geo_id AND
		gu.gun_id = c.gun_id 
	GROUP BY
		ge.state
),

TotalStolenGravity AS (
	SELECT
		ge.state,
		sum(c.crime_gravity) AS TotalCG
	FROM 
		Geography ge,
		Custody c,
		Gun gu
	WHERE 
		ge.geo_id = c.geo_id AND
		gu.gun_id = c.gun_id AND
		gu.is_stolen = 'Stolen' 
	GROUP BY
		ge.state
)

SELECT
	t1.state,
	ROUND(CAST(t2.TotalCG  AS FLOAT) / t1.TotalCG, 2) AS StolenGravityIndex
FROM 
	TotalCG_Per_State t1,
	TotalStolenGravity t2 
WHERE
	t1.state = t2.state
ORDER BY
	StolenGravityIndex;
	
/* -------------- VERSION 2 ---------------- */
/* For each state, compute the stolen gravity index 
defined as the ratio between the total gravity of custodies
involving stolen guns divided by 
the overall gravity of custodies. */

SELECT
	ge.state,
	ROUND(SUM(CASE WHEN gu.is_stolen = 'Stolen' THEN CAST(c.crime_gravity AS FLOAT) ELSE 0 END)
	/ SUM(c.crime_gravity), 5)
	AS StolenGravityIndex
FROM
	Custody c
	INNER JOIN Geography ge ON c.geo_id = ge.geo_id
	INNER JOIN Gun gu ON c.gun_id = gu.gun_id
GROUP BY
	ge.state
ORDER BY 
	StolenGravityIndex;