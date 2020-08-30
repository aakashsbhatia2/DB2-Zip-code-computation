-- ==================================

-- FACILITY_ER_CTE:
-- Obtain list of facilities with an Emergency Department

-- FACILITY_INFO_CTE:
-- For all facilities which have ER, obtaining the closest one from
-- "2799 Horseblock Road Medford, NY 11763"(40.824369, -72.993983)

-- Main Query:
-- Obtain the facility name and geolocation from facility table

-- ==================================

WITH FACILITY_ER_CTE (facility_name)
AS
(
	SELECT
		FACILITYNAME
	FROM
		CSE532.FACILITYCERTIFICATION
	WHERE
		ATTRIBUTEVALUE = 'Emergency Department'
),
FACILITY_INFO_CTE (facility_name2, Location)
AS
(
	SELECT
		FACILITYNAME,
 		GEOLOCATION
	FROM
		CSE532.FACILITY
)
SELECT
	FACILITY_NAME,
	DECIMAL(DB2GSE.ST_Distance(LOCATION, DB2GSE.ST_Point(-72.993983, 40.824369, 1), 'STATUTE MILE'), 8, 2) AS DISTANCE,
	CAST(DB2GSE.ST_ASTEXT(LOCATION) AS VARCHAR(64)) AS LOCATION
FROM
	FACILITY_ER_CTE, FACILITY_INFO_CTE
WHERE
	FACILITY_NAME = FACILITY_NAME2
	AND
	DB2GSE.ST_Intersects(LOCATION, DB2GSE.ST_Buffer(DB2GSE.ST_Point(-72.993983, 40.824369, 1), 4.0, 'STATUTE MILE')) = 1
  	SELECTIVITY 0.0001
;
