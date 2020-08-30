CREATE TABLE cse532.NEIGHBORS(
ZIP_PARENT DECFLOAT,
ZIP_PARENT_POP DECFLOAT,
ZIP_CHILD DECFLOAT,
ZIP_CHILD_POP DECFLOAT,
CUMULATIVE_SUM DECFLOAT,
AVERAGE_ZIP DECFLOAT,
MERGED INTEGER
);


INSERT INTO
        CSE532.NEIGHBORS
        (
                ZIP_PARENT,
                ZIP_PARENT_POP,
                ZIP_CHILD,
                ZIP_CHILD_POP,
                CUMULATIVE_SUM,
                AVERAGE_ZIP,
                MERGED
        )
        WITH USZIP_CTE AS
        (
                SELECT GEOID10 AS ZIP, SHAPE AS SHAPE FROM CSE532.USZIP u
        ),
        GET_DISTINCT_ZIPPOP AS
        (
                SELECT DISTINCT ZIP, ZPOP FROM CSE532.ZIPPOP
        ),
        ZIPPOP_CTE AS
        (
                SELECT u.ZIP, u.SHAPE, z.ZPOP FROM USZIP_CTE u, GET_DISTINCT_ZIPPOP z
                WHERE u.ZIP = z.ZIP AND
                z.ZPOP <> 0
                FETCH FIRST 1000 ROWS ONLY
        ),
        CREATE_COMBINATION_TABLE AS
        (
                SELECT
                        A.ZIP AS ZIP1, A.ZPOP AS ZPOP1, A.SHAPE AS SHAPE1,
                        B.ZIP AS ZIP2, B.ZPOP AS ZPOP2, B.SHAPE AS SHAPE2
                FROM
                        ZIPPOP_CTE A, ZIPPOP_CTE B
                WHERE
                        DB2GSE.ST_TOUCHES(A.SHAPE, B.SHAPE) = 1
                ORDER BY A.ZIP, B.ZPOP
        ),
        GET_AVG AS
        (
                SELECT AVG(ZPOP) AS AVG_ZIPS FROM ZIPPOP_CTE
        ),
        GET_SUM (ZIP_PARENT, ZIP_PARENT_POP, ZIP_CHILD, ZIP_CHILD_POP, CUMULATIVE_SUM, AVERAGE_ZIP) AS
        (
        SELECT ZIP1, ZPOP1, ZIP2, ZPOP2, SUM(ZPOP2) over (PARTITION BY ZIP1 order by ZIP1, ZPOP2), AVG_ZIPS
        FROM CREATE_COMBINATION_TABLE, GET_AVG
        GROUP BY ZIP1, ZPOP1, ZIP2, ZPOP2, AVG_ZIPS
        )
        SELECT ZIP_PARENT, ZIP_PARENT_POP, ZIP_CHILD, ZIP_CHILD_POP, CUMULATIVE_SUM, AVERAGE_ZIP, -1 FROM GET_SUM;

!db2 connect to CSE532;

!db2 -td@ -f spmergezip_test.sql;

SELECT * FROM CSE532.NEIGHBORS;

DROP TABLE CSE532.NEIGHBORS;
