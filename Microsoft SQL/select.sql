SELECT DEPTADDR
FROM DEPT
WHERE DEPTNAME='SALES';


SELECT DEPTNO,
       DEPTNAME
FROM DEPT
WHERE DEPTADDR = 'CHICAGO'
  OR DEPTADDR = 'NEW YORK';


SELECT MIN(SALVALUE) AS min_sal
FROM SALARY
WHERE YEAR = 2009;


SELECT EMPNO,
       EMPNAME,
       BIRTHDATE
FROM EMP
WHERE BIRTHDATE <= to_date('01-01-1960', 'dd-mm-yyyy');


SELECT COUNT(*) AS count_raws
FROM EMP;


SELECT regexp_replace(lower(EMPNAME), 't$', '')
FROM EMP
WHERE instr(EMPNAME, ' ') = 0;


SELECT EMPNO,
       EMPNAME,
       TO_CHAR(BIRTHDATE, 'DD, MONTH, YEAR')
FROM EMP;


SELECT EMPNO,
       EMPNAME,
       TO_CHAR(BIRTHDATE, 'DD, Month, YYYY', 'nls_date_language=Russian')
FROM EMP;


SELECT regexp_replace(JOBNAME, 'CLERK|DRIVER', 'WORKER')
FROM JOB;


SELECT ROUND(AVG(SALVALUE)),
       YEAR
FROM SALARY
GROUP BY YEAR
HAVING COUNT(MONTH) >= 3;


SELECT EMPNAME,
       SALVALUE,
       YEAR
FROM SALARY,
     EMP
WHERE SALARY.EMPNO = EMP.EMPNO;


SELECT SALVALUE,
       MINSALARY
FROM SALARY,
     JOB,
     CAREER
WHERE SALARY.EMPNO = CAREER.EMPNO
  AND JOB.JOBNO = CAREER.JOBNO
  AND SALARY.SALVALUE > JOB.MINSALARY
  AND SALARY.SALVALUE < JOB.MINSALARY + 500;


SELECT SALVALUE AS SALVALUE_MINSALARY,
       MONTH,
       YEAR,
       JOBNAME
FROM SALARY
JOIN JOB ON SALARY.SALVALUE = JOB.MINSALARY;


SELECT JOBNO,
       EMPNAME,
       DEPTNO,
       STARTDATE,
       ENDDATE
FROM CAREER
NATURAL JOIN EMP;


SELECT JOBNO,
       EMPNAME,
       DEPTNO,
       STARTDATE,
       ENDDATE
FROM CAREER
INNER JOIN EMP ON CAREER.EMPNO = EMP.EMPNO;


SELECT c.*,
       e.EMPNAME,
       j.JOBNAME,
       d.DEPTNAME
FROM CAREER c
JOIN EMP e ON c.EMPNO = e.EMPNO
JOIN JOB j ON c.JOBNO = j.JOBNO
JOIN DEPT d ON c.DEPTNO = d.DEPTNO;


SELECT e.EMPNAME,
       c.*
FROM EMP e
LEFT OUTER JOIN CAREER c ON e.EMPNO = c.EMPNO;


SELECT EMPNAME
FROM SALARY,
     JOB,
     CAREER,
     EMP
WHERE SALARY.EMPNO = CAREER.EMPNO
  AND JOB.JOBNO = CAREER.JOBNO
  AND SALARY.SALVALUE = JOB.MINSALARY
  AND EMP.EMPNO = SALARY.EMPNO;


SELECT EMPNAME
FROM CAREER,
     EMP
WHERE CAREER.DEPTNO IN
    (SELECT DEPTNO
     FROM CAREER c
     WHERE c.EMPNO =
         (SELECT EMPNO
          FROM EMP
          WHERE EMP.EMPNAME = 'RICHARD MARTIN'))
  AND CAREER.EMPNO = EMP.EMPNO;


SELECT EMPNAME
FROM CAREER,
     EMP
WHERE CAREER.DEPTNO IN
    (SELECT DEPTNO
     FROM CAREER c
     WHERE c.EMPNO =
         (SELECT EMPNO
          FROM EMP
          WHERE EMP.EMPNAME = 'RICHARD MARTIN'))
  AND CAREER.EMPNO = EMP.EMPNO
  AND CAREER.JOBNO IN
    (SELECT JOBNO
     FROM CAREER c
     WHERE c.EMPNO =
         (SELECT EMPNO
          FROM EMP
          WHERE EMP.EMPNAME = 'RICHARD MARTIN'));


SELECT EMPNO
FROM SALARY
WHERE SALARY.SALVALUE > ANY
    (SELECT AVG(SALVALUE)
     FROM SALARY
     WHERE YEAR = ANY('2007', '2008')
     GROUP BY YEAR);


SELECT EMPNO
FROM SALARY
WHERE SALARY.SALVALUE > ALL
    (SELECT AVG(SALVALUE)
     FROM SALARY
     GROUP BY YEAR);


SELECT YEAR
FROM SALARY
GROUP BY YEAR
HAVING AVG(SALVALUE) >
  (SELECT AVG(SALVALUE)
   FROM SALARY);


SELECT DEPTNO
FROM CAREER c
WHERE c.EMPNO IN
    (SELECT EMPNO
     FROM SALARY);


SELECT DEPTNO
FROM CAREER c
WHERE EXISTS
    (SELECT *
     FROM salary
     WHERE c.empno = salary.empno);


SELECT DEPTNO
FROM CAREER
WHERE EXISTS
    (SELECT *
     FROM SALARY s
     RIGHT JOIN EMP e ON s.EMPNO = e.EMPNO);


SELECT TRUNC(AVG(SALVALUE)),
       YEAR
FROM SALARY
GROUP BY YEAR;


SELECT d.DEPTNAME,
       d.DEPTADDR,
       c.JOBNO,
       c.EMPNO,
       c.STARTDATE,
       c.ENDDATE
FROM CAREER c
INNER JOIN DEPT d ON c.DEPTNO = d.DEPTNO;

TRUNC(months_between(to_date('22-10-2019', 'dd-mm-yyyy'), e.BIRTHDATE)/12)
SELECT k.*,
       CASE
           WHEN k.birth >= 20
                AND k.birth <= 30 THEN '20-30'
           WHEN k.birth >= 31
                AND k.birth <= 40 THEN '31-40'
           WHEN k.birth >= 41
                AND k.birth <= 50 THEN '41-50'
           WHEN k.birth >= 51
                AND k.birth <= 60 THEN '51-60'
           ELSE 'not found'
       END AS lalal
FROM
  (SELECT e.*,
          TRUNC(months_between(to_date('22-10-2019', 'dd-mm-yyyy'), e.BIRTHDATE)/12) AS birth
   FROM EMP e) k;


SELECT CASE
           WHEN d.DEPTNO <= 20 THEN regexp_replace(d.DEPTNO, '^', 'BI')
           WHEN d.DEPTNO >= 30 THEN regexp_replace(d.DEPTNO, '^', 'LN')
       END
FROM DEPT d;


SELECT e.EMPNO,
       e.EMPNAME,
       COALESCE(BIRTHDATE, to_date('1-1-1000', 'dd-mm-yyyy')) AS birthday
FROM EMP e;