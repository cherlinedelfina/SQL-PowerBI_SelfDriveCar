-- FIT3003 MAJOR ASSIGNMENT 2022
-- TASK C.3 (REPORT 5 - 8)
-- STUDENT NAME: AMY WANG JUNE KOH, CHERLINE DELFINA TANDRA
-- STUDENT ID: 29796601, 31864767
-- DATE MODIFIED: 12/10/2022

-- REPORT 5: Produce one booking-related report that is useful for management that uses rollup.
SELECT DECODE(GROUPING(BOOKINGMONTH),1,'All Months', BOOKINGMONTH) AS "Months",
DECODE(GROUPING(FACULTYID),1,'All Faculties', FACULTYID) AS "Faculties",
TO_CHAR(SUM(NO_OF_BOOKING),'9,999,999,999') AS "Total Bookings"
FROM BOOKING_FACT1
GROUP BY ROLLUP(BOOKINGMONTH, FACULTYID)
ORDER BY TO_DATE(BOOKINGMONTH, 'MONTH'), "Total Bookings" DESC, "Faculties";

-- REPORT 6: Produce one booking-related report that is useful for management that uses partial rollup.
SELECT DECODE(GROUPING(AGEGROUP),1,'ALL AGE', AGEGROUP) AS "Age Group",
FACULTYID AS "Faculties",
TO_CHAR(SUM(NO_OF_BOOKING),'9,999,999,999') AS "Total Bookings"
FROM BOOKING_FACT1
GROUP BY ROLLUP(AGEGROUP), FACULTYID
ORDER BY AGEGROUP, "Total Bookings" DESC, "Faculties";

-- REPORT 7: Produce one moving aggregate report that relates to the Booking
-- information. The report must contain or use the month information and number of Bookings in the
-- output.
SELECT BOOKINGMONTH AS "Months", C.CARBODYTYPE AS "Car body type", ROUND(SUM(NO_OF_BOOKING)) AS  "Total bookings",
ROUND(AVG(SUM(NO_OF_BOOKING)) OVER (ORDER BY C.CARBODYTYPE, BOOKINGMONTH ROWS 2 PRECEDING)) AS "Moving 3 Months Average" 
FROM BOOKING_FACT1 B, CAR_BODY_DIM1 C
WHERE B.CARBODYTYPE = C.CARBODYTYPE
GROUP BY BOOKINGMONTH, C.CARBODYTYPE
ORDER BY TO_DATE(BOOKINGMONTH, 'MONTH');

-- REPORT 8: Produce one cumulative aggregate report that relates to the maintenance
-- information. The report must contain or use the number of maintenance records or the total
-- maintenance cost in the output.
SELECT C.CARBODYTYPE AS "Car body type", M.MAINTENANCETYPE AS "Maintenance type",
SUM(TOTAL_MAINTENANCE_COST) AS "Total maintenance cost",
SUM(SUM(TOTAL_MAINTENANCE_COST)) OVER (ORDER BY C.CARBODYTYPE, M.MAINTENANCETYPE) AS "Cumulative number of maintenance cost"
FROM MAINTENANCE_FACT1 M, CAR_BODY_DIM1 C
WHERE M.CARBODYTYPE = C.CARBODYTYPE
GROUP BY C.CARBODYTYPE, M.MAINTENANCETYPE
ORDER BY C.CARBODYTYPE, M.MAINTENANCETYPE;



