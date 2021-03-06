CREATE PROCEDURE SPMERGEZIP
LANGUAGE SQL
BEGIN
  DECLARE SQLSTATE CHAR(5) DEFAULT '00000';
  DECLARE V_ZIP_PARENT DECFLOAT;
  DECLARE V_ZIP_PARENT_POP DECFLOAT;
  DECLARE V_ZIP_CHILD DECFLOAT;
  DECLARE V_CUMULATIVE_SUM DECFLOAT;
  DECLARE V_AVERAGE_ZIP DECFLOAT;
  DECLARE SUM DECFLOAT;
  DECLARE FLAG DECFLOAT;
  DECLARE C_ZIP_PARENT CURSOR FOR SELECT ZIP_PARENT FROM CSE532.NEIGHBORS;
  DECLARE C_ZIP_PARENT_POP CURSOR FOR SELECT ZIP_PARENT_POP FROM CSE532.NEIGHBORS;
  DECLARE C_ZIP_CHILD CURSOR FOR SELECT ZIP_CHILD FROM CSE532.NEIGHBORS;
  DECLARE C_CUMULATIVE_SUM CURSOR FOR SELECT CUMULATIVE_SUM FROM CSE532.NEIGHBORS;
  DECLARE C_AVERAGE_ZIP CURSOR FOR SELECT AVERAGE_ZIP FROM CSE532.NEIGHBORS;
  SET SUM = 0;
  SET FLAG = 0;
  OPEN C_ZIP_PARENT;
  OPEN C_ZIP_PARENT_POP;
  OPEN C_ZIP_CHILD;
  OPEN C_CUMULATIVE_SUM;
  OPEN C_AVERAGE_ZIP;
    FETCH FROM C_ZIP_PARENT INTO V_ZIP_PARENT;
    FETCH FROM C_ZIP_PARENT_POP INTO V_ZIP_PARENT_POP;
    FETCH FROM C_ZIP_CHILD INTO V_ZIP_CHILD;
    FETCH FROM C_CUMULATIVE_SUM INTO V_CUMULATIVE_SUM;
    FETCH FROM C_AVERAGE_ZIP INTO V_AVERAGE_ZIP;
    WHILE(SQLSTATE = '00000') DO
      SET SUM = V_ZIP_PARENT_POP + V_CUMULATIVE_SUM;
      IF SUM <= V_AVERAGE_ZIP THEN
        UPDATE CSE532.NEIGHBORS
          SET MERGED = 1
        WHERE ZIP_PARENT = V_ZIP_PARENT AND ZIP_CHILD = V_ZIP_CHILD AND CUMULATIVE_SUM = V_CUMULATIVE_SUM;
        SET FLAG = 0;
      DELETE FROM CSE532.NEIGHBORS WHERE ZIP_PARENT = V_ZIP_CHILD AND ZIP_CHILD = V_ZIP_PARENT;
      ELSEIF SUM > V_AVERAGE_ZIP AND FLAG = 0 THEN
        UPDATE CSE532.NEIGHBORS
          SET MERGED = 1
        WHERE ZIP_PARENT = V_ZIP_PARENT AND ZIP_CHILD = V_ZIP_CHILD AND CUMULATIVE_SUM = V_CUMULATIVE_SUM;
        SET FLAG = 1;
        DELETE FROM CSE532.NEIGHBORS WHERE ZIP_PARENT = V_ZIP_CHILD AND ZIP_CHILD = V_ZIP_PARENT;
        DELETE FROM CSE532.NEIGHBORS WHERE (ZIP_CHILD = V_ZIP_PARENT OR ZIP_PARENT = V_ZIP_CHILD) AND (MERGED = -1);
       ELSE
        UPDATE CSE532.NEIGHBORS
          SET MERGED = 0
        WHERE ZIP_PARENT = V_ZIP_PARENT AND ZIP_CHILD = V_ZIP_CHILD AND CUMULATIVE_SUM = V_CUMULATIVE_SUM;
      END IF;
    SET SUM = 0;
    FETCH FROM C_ZIP_PARENT INTO V_ZIP_PARENT;
    FETCH FROM C_ZIP_PARENT_POP INTO V_ZIP_PARENT_POP;
    FETCH FROM C_ZIP_CHILD INTO V_ZIP_CHILD;
    FETCH FROM C_CUMULATIVE_SUM INTO V_CUMULATIVE_SUM;
    FETCH FROM C_AVERAGE_ZIP INTO V_AVERAGE_ZIP;
   END WHILE;
   CLOSE C_ZIP_PARENT_POP;
   CLOSE C_CUMULATIVE_SUM;
   CLOSE C_AVERAGE_ZIP;
END
@

CALL SPMERGEZIP
@
DROP procedure SPMERGEZIP
@
