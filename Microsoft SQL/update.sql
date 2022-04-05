update JOB set MINSALARY=1000;

update JOB set MINSALARY = (MINSALARY*1.1) where JOBNAME != 'FINANCIAL DIRECTOR';

UPDATE job SET MINSALARY = (case when JOBNAME = 'CLERK' then MINSALARY*1.1 when JOBNAME = 'FINANCIAL DIRECTOR' then MINSALARY*1.2 end) where JOBNAME = 'CLERK' or JOBNAME = 'FINANCIAL DIRECTOR';

update JOB set MINSALARY = (select MINSALARY from JOB where JOBNAME = 'EXECUTIVE DIRECTOR')*0.9 where JOBNAME = 'FINANCIAL DIRECTOR';

update EMP set EMPNAME = lower(EMPNAME) where EMPNAME like 'J%';

update EMP set EMPNAME = INITCAP(EMPNAME) where INSTR(EMPNAME, ' ') != 0;

update EMP set EMPNAME = UPPER(EMPNAME);

update DEPT set DEPTADDR = (select DEPTADDR from DEPT where DEPTNAME = 'SALES') where DEPTNAME = 'RESEARCH';

insert into EMP values((select MAX(EMPNO)+1 from EMP), 'ALEXANDR ANTONENKO', to_date('20.01.1999', 'dd.mm.yyyy'), NULL);

insert into CAREER values(1004, (select MAX(EMPNO) from EMP where EMPNAME = 'ALEXANDR ANTONENKO'), 10, sysdate , NULL);

DROP TABLE TMP_EMP;
CREATE TABLE TMP_EMP (EMPNOq NUMBER(4) PRIMARY KEY, EMPNAMEq VARCHAR2(30) NOT NULL, BIRTHDATEq DATE);

DROP TABLE JOB_;
CREATE TABLE JOB_ (JOBNOq NUMBER(4) PRIMARY KEY, JOBNAMEq VARCHAR2(30) NOT NULL, MINSALARYq NUMBER(6));

delete from TMP_EMP;


insert into TMP_EMP values
(select E.EMPNO, E.EMPNAME, E.BIRTHDATE from EMP E
JOIN CAREER C on E.EMPNO = C.EMPNO
JOIN JOBNO J on C.JOBNO = J.JOBNO where J.JOBNAME = 'CLERCK' and C.ENDDATE is NULL);


insert into TMP_EMP (select * from EMP where EMPNO in (select EMPNO from CAREER where EMPNO in (select EMPNO from (select DISTINCT JOBNO, EMPNO from CAREER) T 
group by EMPNO
HAVING COUNT(EMPNO) = 1) AND ENDDATE IS NOT NULL AND ENDDATE < sysdate));


delete from SALARY where YEAR = 2018;

delete from CAREER where ENDDATE <= sysdate AND ENDDATE IS NOT NULL;

delete from SALARY where EMPNO IN (select EMPNO FROM EMP);

delete from EMP E1 where E1.EMPNO = (select EMPNO FROM CAREER where CAREER.STARTDATE IS NULL);