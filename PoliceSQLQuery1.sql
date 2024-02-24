/* For every year, the participant ordered by 
the total number of custodies. */

SELECT
    d.year,
	c.participant_id,
    COUNT(*) AS TotalCustodies
FROM
    Custody c
	INNER JOIN Date d ON c.date_id = d.date_id
GROUP BY
    d.year, 
	c.participant_id
ORDER BY
    d.year, 
	TotalCustodies, 
	c.participant_id;