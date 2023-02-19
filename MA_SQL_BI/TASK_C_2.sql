-- FIT3003 MAJOR ASSIGNMENT 2022
-- TASK C.2 (STAR SCHEMA)
-- STUDENT NAME: AMY WANG JUNE KOH, CHERLINE DELFINA TANDRA
-- STUDENT ID: 29796601, 31864767
-- DATE MODIFIED: 12/10/2022


/**********************
STAR SCHEMA VERSION 1
**********************/
-- CAR_DIM1
DROP TABLE CAR_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE CAR_DIM1 AS SELECT DISTINCT REGISTRATIONNO
FROM MONCITY.CAR;

-- CARACCIDENT_BRIDGE
DROP TABLE CARACCIDENT_BRIDGE CASCADE CONSTRAINTS PURGE;
CREATE TABLE CARACCIDENT_BRIDGE AS SELECT DISTINCT REGISTRATIONNO, ACCIDENTID
FROM MONCITY.CARACCIDENT;

-- ACCIDENTINFO_DIM1
DROP TABLE ACCIDENTINFO_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE ACCIDENTINFO_DIM1 AS SELECT DISTINCT A.ACCIDENTID,
1.0/COUNT(*) AS WEIGHTFACTOR,
LISTAGG (CA.REGISTRATIONNO, '_') WITHIN GROUP
(ORDER BY CA.REGISTRATIONNO) AS REGISTRATIONGROUPLIST
FROM ACCIDENTINFO A, MONCITY.CARACCIDENT CA
WHERE A.ACCIDENTID = CA.ACCIDENTID
GROUP BY A.ACCIDENTID;

-- ERROR_DIM1
DROP TABLE ERROR_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE ERROR_DIM1 AS 
SELECT ERRORCODE, ERRORMESSAGE FROM MONCITY.ERROR;

-- ACCIDENT_FACT1
DROP TABLE ACCIDENT_FACT1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE ACCIDENT_FACT1 
AS SELECT DISTINCT A.ACCIDENTID, A.ACCIDENTZONE, E.ERRORCODE, C.CARBODYTYPE, A.CAR_DAMAGE_SEVERITY, COUNT(*) AS NO_OF_ACCIDENTS
FROM MONCITY.CAR C, ACCIDENTINFO A,  MONCITY.ERROR E, MONCITY.CARACCIDENT CA
WHERE A.ACCIDENTID = CA.ACCIDENTID 
AND c.REGISTRATIONNO = CA.REGISTRATIONNO
AND E.ERRORCODE = A.ERRORCODE
GROUP BY A.ACCIDENTZONE, A.ACCIDENTID, E.ERRORCODE, A.CAR_DAMAGE_SEVERITY, C.CARBODYTYPE
ORDER BY A.ACCIDENTID;

-- ZONE_DIM1
DROP TABLE ZONE_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE ZONE_DIM1 AS SELECT DISTINCT ACCIDENTZONE
FROM ACCIDENTINFO;

-- CAR_DAMAGE_DIM1
DROP TABLE CAR_DAMAGE_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE CAR_DAMAGE_DIM1 AS SELECT DISTINCT CAR_DAMAGE_SEVERITY
FROM ACCIDENTINFO;

-- CAR_BODY_DIM1
DROP TABLE CAR_BODY_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE CAR_BODY_DIM1 AS SELECT DISTINCT CARBODYTYPE, NUMSEATS
FROM MONCITY.CAR;

-- TEMPFACT
DROP TABLE TEMPFACT1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE TEMPFACT1
AS SELECT TO_CHAR(B.BOOKINGDATE, 'Month') AS BOOKINGMONTH, F.FACULTYID, P.PASSENGERAGE AS AGE, C.REGISTRATIONNO, C.CARBODYTYPE
FROM PASSENGER P, BOOKING B,  MONCITY.FACULTY F, MONCITY.CAR C
WHERE F.FACULTYID = P.FACULTYID
AND P.PASSENGERID = B.PASSENGERID
AND C.REGISTRATIONNO = B.REGISTRATIONNO
GROUP BY B.BOOKINGDATE, F.FACULTYID, P.PASSENGERAGE, C.CARBODYTYPE, C.REGISTRATIONNO;

-- UPDATE TEMPFACT TO TURN AGE INTO AGE GROUP
ALTER TABLE TEMPFACT1
ADD (AGEGROUP VARCHAR2(30));
      
UPDATE TEMPFACT1
SET AGEGROUP = 'GROUP 1'
WHERE AGE >=18 AND AGE <=35;

UPDATE TEMPFACT1
SET AGEGROUP = 'GROUP 2'
WHERE AGE >=36 AND AGE <=59;

UPDATE TEMPFACT1
SET AGEGROUP = 'GROUP 3'
WHERE AGE >=60;

-- BOOKING_FACT1
DROP TABLE BOOKING_FACT1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE BOOKING_FACT1
AS SELECT BOOKINGMONTH, FACULTYID, AGEGROUP, CARBODYTYPE, COUNT(*) as NO_OF_BOOKING
FROM TEMPFACT1
GROUP BY BOOKINGMONTH, FACULTYID, AGEGROUP, CARBODYTYPE;

-- TIME_DIM1
DROP TABLE TIME_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE TIME_DIM1 AS SELECT DISTINCT TO_CHAR(BOOKINGDATE, 'Month') AS BOOKINGMONTH
FROM BOOKING;

-- FACULTY_DIM1
DROP TABLE FACULTY_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE FACULTY_DIM1 AS
SELECT DISTINCT FACULTYID, FACULTYNAME FROM MONCITY.FACULTY;

-- AGE_DIM1
DROP TABLE AGE_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE AGE_DIM1  
(AGEGROUP VARCHAR2(30) NOT NULL,
 AGEDESC VARCHAR2(30),
 PRIMARY KEY(AGEGROUP));

INSERT INTO AGE_DIM1 VALUES ('18-35 YEARS OLD', 'YOUNG ADULTS');
INSERT INTO AGE_DIM1 VALUES ('36-59 YEARS OLD', 'MIDDLE-AGED ADULTS');
INSERT INTO AGE_DIM1 VALUES ('OVER 60 YEARS OLD', 'OLD-AGED ADULTS');

-- MAINTENANCE_FACT1
DROP TABLE MAINTENANCE_FACT1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE MAINTENANCE_FACT1
AS SELECT c.CARBODYTYPE, mt.TEAMID, m.MAINTENANCETYPE, count(*) as NO_OF_MAINTENANCE, sum(m.MAINTENANCECOST) AS TOTAL_MAINTENANCE_COST
FROM MONCITY.CAR c, MONCITY.MAINTENANCETEAM mt, MAINTENANCE m
WHERE c.REGISTRATIONNO = m.REGISTRATIONNO
AND m.TEAMID = mt.TEAMID
GROUP BY c.CARBODYTYPE, mt.TEAMID, m.MAINTENANCETYPE;

-- MAINTENANCE_TYPE_DIM1
DROP TABLE MAINTENANCE_TYPE_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE MAINTENANCE_TYPE_DIM1 AS SELECT DISTINCT MAINTENANCETYPE
FROM MAINTENANCE;

-- MAINTENANCE_TEAM_DIM1
DROP TABLE MAINTENANCE_TEAM_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE MAINTENANCE_TEAM_DIM1 AS SELECT DISTINCT M.TEAMID, M.TEAMLEADER,
1.0/COUNT(*) AS WEIGHTFACTOR,
LISTAGG (B.CENTERID, '_') WITHIN GROUP
(ORDER BY B.CENTERID) AS CENTERGROUPLIST
FROM MONCITY.MAINTENANCETEAM M, MONCITY.BELONGTO B
WHERE M.TEAMID = B.TEAMID
GROUP BY M.TEAMID, M.TEAMLEADER;

-- BELONG_TO_BRIDGE
DROP TABLE BELONG_TO_BRIDGE CASCADE CONSTRAINTS PURGE;
CREATE TABLE BELONG_TO_BRIDGE AS
SELECT DISTINCT * FROM MONCITY.BELONGTO;

-- RESEARCH_DIM1
DROP TABLE RESEARCH_DIM1 CASCADE CONSTRAINTS PURGE;
CREATE TABLE RESEARCH_DIM1 AS
SELECT DISTINCT CENTERID, CENTERNAME FROM MONCITY.RESEARCHCENTER;


COMMIT;



/**********************
STAR SCHEMA VERSION 2
**********************/
-- TIME_DIM2
DROP TABLE TIME_DIM2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE TIME_DIM2 AS SELECT DISTINCT BOOKINGDATE
FROM BOOKING;

-- AGE_DIM2
DROP TABLE AGE_DIM2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE AGE_DIM2 AS SELECT DISTINCT PASSENGERAGE AS AGE
FROM PASSENGER;

--ACCIDENTINFO_DIM2
DROP TABLE ACCIDENTINFO_DIM2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE ACCIDENTINFO_DIM2 AS SELECT DISTINCT A.ACCIDENTID, A.ACCIDENTZONE, A.CAR_DAMAGE_SEVERITY
FROM ACCIDENTINFO A, MONCITY.CARACCIDENT CA
WHERE A.ACCIDENTID = CA.ACCIDENTID
GROUP BY A.ACCIDENTID, A.ACCIDENTZONE, A.CAR_DAMAGE_SEVERITY;

-- MAINTENANCE_TYPE_DIM2
DROP TABLE MAINTENANCE_TYPE_DIM2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE MAINTENANCE_TYPE_DIM2 AS SELECT DISTINCT MAINTENANCEID, MAINTENANCEDATE, MAINTENANCETYPE
FROM MAINTENANCE;

-- ACCIDENT_FACT2
DROP TABLE ACCIDENT_FACT2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE ACCIDENT_FACT2 
AS SELECT A.ACCIDENTID, E.ERRORCODE, CA.REGISTRATIONNO, COUNT(*) AS NO_OF_ACCIDENTS
FROM ACCIDENTINFO A, MONCITY.ERROR E, MONCITY.CARACCIDENT CA
WHERE E.ERRORCODE = A.ERRORCODE
AND A.ACCIDENTID = CA.ACCIDENTID
GROUP BY A.ACCIDENTID, E.ERRORCODE, CA.REGISTRATIONNO;

-- CAR_BODY_DIM2
DROP TABLE CAR_BODY_DIM2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE CAR_BODY_DIM2 AS SELECT DISTINCT REGISTRATIONNO, CARBODYTYPE, NUMSEATS
FROM MONCITY.CAR;

-- BOOKING_FACT2
DROP TABLE BOOKING_FACT2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE BOOKING_FACT2 
AS SELECT B.BOOKINGDATE, F.FACULTYID, P.PASSENGERAGE AS AGE, C.REGISTRATIONNO, COUNT(*) AS NO_OF_BOOKING
FROM PASSENGER P, BOOKING B,  MONCITY.FACULTY F, MONCITY.CAR C
WHERE F.FACULTYID = P.FACULTYID
AND P.PASSENGERID = B.PASSENGERID
AND C.REGISTRATIONNO = B.REGISTRATIONNO
GROUP BY B.BOOKINGDATE, F.FACULTYID, P.PASSENGERAGE, C.REGISTRATIONNO;

-- MAINTENANCE_FACT2
DROP TABLE MAINTENANCE_FACT2 CASCADE CONSTRAINTS PURGE;
CREATE TABLE MAINTENANCE_FACT2 
AS SELECT C.REGISTRATIONNO, MT.TEAMID, M.MAINTENANCEID, COUNT(*) AS NO_OF_MAINTENANCE, SUM(M.MAINTENANCECOST) AS TOTAL_MAINTENANCE_COST
FROM MONCITY.CAR C, MONCITY.MAINTENANCETEAM MT, MAINTENANCE M
WHERE C.REGISTRATIONNO = M.REGISTRATIONNO
AND M.TEAMID = MT.TEAMID
GROUP BY C.REGISTRATIONNO, MT.TEAMID, M.MAINTENANCEID;

COMMIT;
