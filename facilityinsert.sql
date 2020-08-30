INSERT INTO CSE532.facility (
FacilityID,
FacilityName,
Description,
Address1,
Address2,
City,
State,
ZipCode,
CountyCode,
County,
Geolocation)
SELECT FacilityID,
FacilityName,
Description,
Address1,
Address2,
City,
State,
ZipCode,
CountyCode,
County,
db2gse.ST_Point(Longitude, Latitude, 1)
FROM CSE532.facilityoriginal;
