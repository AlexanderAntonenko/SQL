 CREATE VIEW pensioner AS 
SELECT * FROM emp 
WHERE MONTHS_BETWEEN(SYSDATE, birthdate) / 12 >= 60; 

SELECT * FROM pensioner; 

CREATE VIEW dismissed (empname, enddate, deptname, jobname, empno) AS 
SELECT e.empname, c.enddate, d.deptname, j.jobname, e.empno 
FROM emp e 
INNER JOIN career c ON e.empno = c.empno 
INNER JOIN dept d ON d.deptno = c.deptno 
INNER JOIN job j ON j.jobno = c.jobno 
WHERE c.enddate IS NOT NULL; 

SELECT * FROM dismissed; 

CREATE VIEW kvartal (sotrudnik, dolzhnost, itogo_3_kv) AS 
SELECT e.empname, j.jobname, SUM(s.salvalue) 
FROM job j 
INNER JOIN career c ON j.jobno = c.jobno 
INNER JOIN emp e ON e.empno = c.empno 
INNER JOIN salary s ON s.empno = e.empno 
WHERE s.year = 2010 
AND s.month BETWEEN 7 AND 9 
AND c.enddate IS NULL 
GROUP BY e.empname, j.jobname; 

SELECT * FROM kvartal; 


CREATE VIEW salary_dismissed AS 
SELECT d.*, s.month || ', ' || s.salvalue AS month_and_sum 
FROM dismissed d INNER JOIN salary s ON s.empno = d.empno 
WHERE s.empno IN ( 
SELECT empno 
FROM dismissed NATURAL JOIN salary 
GROUP BY empno 
HAVING COUNT(salvalue) > 2 
); 

SELECT * FROM salary_dismissed; 