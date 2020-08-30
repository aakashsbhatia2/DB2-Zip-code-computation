CREATE INDEX q1_1idx ON CSE532.FACILITYCERTIFICATION(FACILITYNAME, ATTRIBUTEVALUE);

create index cse532.facilityidx on cse532.facility(geolocation) extend using db2gse.spatial_index(0.01, 0, 0);

CREATE INDEX q2_2idx ON CSE532.FACILITY(FACILITYNAME, ZIPCODE);

CREATE INDEX q2_3idx ON CSE532.USZIP(GEOID10);

create index cse532.zipidx on cse532.uszip(shape) extend using db2gse.spatial_index(0.33, 0.83, 3.7);

runstats on table cse532.facility and indexes all;

runstats on table cse532.uszip and indexes all;
