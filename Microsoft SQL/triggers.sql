-- 01.Add a tax column to the salary table to calculate the monthly
-- Income tax on wages on a progressive scale.

 ALTER TABLE salary ADD (tax NUMBER(15));

-- 02-a.using a simple loop with a cursor and an if statement;

 CREATE OR REPLACE PROCEDURE tax_simple_loop_if AS
     sumal NUMBER(16);
 BEGIN
     FOR r IN (SELECT * FROM salary)
     LOOP
         SELECT SUM(salvalue) INTO sumal FROM salary s
             WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

         IF sumal < 20000 THEN
             UPDATE salary SET tax = r.salvalue * 0.09
                 WHERE empno = r.empno AND month = r.month AND year = r.year;
         ELSIF sumal < 30000 THEN
             UPDATE salary SET tax = r.salvalue * 0.12
                 WHERE empno = r.empno AND month = r.month AND year = r.year;
         ELSE
             UPDATE salary SET tax = r.salvalue * 0.15
                 WHERE empno = r.empno AND month = r.month AND year = r.year;
         END IF;
     END LOOP;
     COMMIT;
 END;
 /

  -- 02-b. using a simple loop with a cursor and a case statement;

 CREATE OR REPLACE PROCEDURE tax_loop_cur_case AS
     sumal NUMBER(16);
     CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary FOR UPDATE OF tax;
     r cur%ROWTYPE;
 BEGIN
     OPEN cur;
     LOOP
         FETCH cur INTO r;
         EXIT WHEN cur%NOTFOUND;
         SELECT SUM(salvalue) INTO sumal FROM salary s
             WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

         UPDATE salary SET tax =
             CASE
                 WHEN sumal < 20000 THEN r.salvalue * 0.09
                 WHEN sumal < 30000 THEN r.salvalue * 0.12
                 ELSE r.salvalue * 0.15
             END

             WHERE empno = r.empno AND month = r.month AND year = r.year;
     END LOOP;
     CLOSE cur;
     COMMIT;
 END tax_loop_cur_case;
 /

 -- 02-c.using a cursor FOR loop;

 CREATE OR REPLACE PROCEDURE tax_cur_loop_case AS
     sumal NUMBER;
     CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary FOR UPDATE OF tax;
 BEGIN
    FOR r IN cur LOOP
          SELECT SUM(salvalue) INTO sumal FROM salary S
             WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

         UPDATE salary SET tax =
             CASE
                 WHEN sumal < 20000 THEN r.salvalue * 0.09
                 WHEN sumal < 30000 THEN r.salvalue * 0.12
                 ELSE r.salvalue * 0.15
             END

             WHERE empno = r.empno AND month = r.month AND year = r.year;
     END LOOP;
     COMMIT;
 END tax_cur_loop_case;
 /

 -- 02-d.using the cursor with a parameter, passing the number of the employee for whom
 -- you need to calculate the tax.

 CREATE  OR  REPLACE  PROCEDURE  tax_param (empid  NUMBER)  AS
     CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary
         WHERE empno = empid
         FOR UPDATE OF tax;
     sumal NUMBER(16);
 BEGIN
     FOR r IN cur LOOP
         SELECT SUM(salvalue) INTO sumal FROM salary s
             WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

         UPDATE salary SET tax =
             CASE
                 WHEN sumal < 20000 THEN r.salvalue * 0.09
                 WHEN sumal < 30000 THEN r.salvalue * 0.12
                 ELSE r.salvalue * 0.15
             END

             WHERE empno = r.empno AND month = r.month AND year = r.year;
     END LOOP;
     COMMIT;
 END  tax_param;
 /

  -- 04.Create a function that calculates the payroll tax for the entire accrual time for
  -- specific employee.

 CREATE  OR  REPLACE  PROCEDURE  tax_param_less (empid  NUMBER, UNDER_20k NUMBER,
     OVER_20k NUMBER,
     OVER_30k NUMBER)  AS
     CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary
         WHERE empno = empid
         FOR UPDATE OF tax;
     sumal NUMBER(16);
 BEGIN
     FOR r IN cur LOOP
         SELECT SUM(salvalue) INTO sumal FROM salary s
             WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

         UPDATE salary SET tax =
             CASE
                 WHEN sumal < 20000 THEN r.salvalue * UNDER_20k
                 WHEN sumal < 30000 THEN r.salvalue * OVER_20k
                 ELSE r.salvalue * OVER_30k
             END

             WHERE empno = r.empno AND month = r.month AND year = r.year;
     END LOOP;
     COMMIT;
 END  tax_param_less;
 /

  -- 05.Create a procedure that calculates the total tax on an employee's salary for
  -- all the time accruals.

 CREATE  OR  REPLACE  FUNCTION  ftax_param_less (
     empid  NUMBER,
     UNDER_20k NUMBER,
     OVER_20k NUMBER,
     OVER_30k NUMBER) RETURN NUMBER  AS

     CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary
         WHERE empno = empid;
     sumal NUMBER(16);
     RESULT NUMBER(16);
 BEGIN
     RESULT := 0;
     FOR r IN cur LOOP
         SELECT SUM(salvalue) INTO sumal FROM salary s
             WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

         RESULT := RESULT +
             CASE
                 WHEN sumal < 20000 THEN r.salvalue * UNDER_20k
                 WHEN sumal < 30000 THEN r.salvalue * OVER_20k
                 ELSE r.salvalue * OVER_30k
             END;

     END LOOP;
     RETURN RESULT;
 END  ftax_param_less;
 /
 SELECT ftax_param_less(empno, 1, 2, 3) FROM salary
 /

 -- 06.Create a package that includes the tax calculation procedure for all
 -- employees

 CREATE OR REPLACE PACKAGE tax_eval AS
     PROCEDURE tax_simple_loop_if;
     PROCEDURE tax_param (empid NUMBER);
     PROCEDURE tax_param_less (
         UNDER_20k NUMBER,
         OVER_20k NUMBER,
         OVER_30k NUMBER,
         empid  NUMBER
     );
 END tax_eval;
 /
 CREATE OR REPLACE PACKAGE BODY tax_eval AS
     PROCEDURE tax_simple_loop_if AS
         sumal NUMBER(16);
     BEGIN
         FOR r IN (SELECT * FROM salary)
         LOOP
             SELECT SUM(salvalue) INTO sumal FROM salary s
                 WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

             IF sumal < 20000 THEN
                 UPDATE salary SET tax = r.salvalue * 0.09
                     WHERE empno = r.empno AND month = r.month AND year = r.year;
             ELSIF sumal < 30000 THEN
                 UPDATE salary SET tax = r.salvalue * 0.12
                     WHERE empno = r.empno AND month = r.month AND year = r.year;
             ELSE
                 UPDATE salary SET tax = r.salvalue * 0.15
                     WHERE empno = r.empno AND month = r.month AND year = r.year;
             END IF;
         END LOOP;
         COMMIT;
     END;

     PROCEDURE  tax_param (empid  NUMBER)  AS
         CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary
             WHERE empno = empid
             FOR UPDATE OF tax;
         sumal NUMBER(16);
     BEGIN
         FOR r IN cur LOOP
             SELECT SUM(salvalue) INTO sumal FROM salary s
                 WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

             UPDATE salary SET tax =
                 CASE
                     WHEN sumal < 20000 THEN r.salvalue * 0.09
                     WHEN sumal < 30000 THEN r.salvalue * 0.12
                     ELSE r.salvalue * 0.15
                 END

                 WHERE empno = r.empno AND month = r.month AND year = r.year;
         END LOOP;
         COMMIT;
     END  tax_param;

     PROCEDURE  tax_param_less (
     UNDER_20k NUMBER,
     OVER_20k NUMBER,
     OVER_30k NUMBER,
     empid  NUMBER)  AS
         CURSOR cur IS SELECT empno, salvalue, tax, year, month FROM salary
             WHERE empno = empid;
         sumal NUMBER(16);
     BEGIN
         FOR r IN cur LOOP
             SELECT SUM(salvalue) INTO sumal FROM salary s
                 WHERE s.empno = r.empno AND s.month < r.month AND s.year = r.year;

             UPDATE salary SET tax =
                 CASE
                     WHEN sumal < 20000 THEN r.salvalue * UNDER_20k
                     WHEN sumal < 30000 THEN r.salvalue * OVER_20k
                     ELSE r.salvalue * OVER_30k
                 END

                 WHERE empno = r.empno AND month = r.month AND year = r.year;
         END LOOP;
         COMMIT;
     END  tax_param_less;
 END tax_eval;
 /

 -- 07.Create a trigger that fires when the data in the salary table is updated.

 CREATE OR REPLACE TRIGGER check_salary
     BEFORE UPDATE OF salvalue ON salary FOR EACH ROW
 DECLARE
     CURSOR CUR(empid career.empno%TYPE) IS
         SELECT minsalary FROM job
             WHERE jobno = (SELECT jobno FROM career WHERE empid = empno AND enddate IS NULL);
     r job.minsalary%TYPE;
 BEGIN
     OPEN CUR(:NEW.empno);
     FETCH cur INTO r;
     IF :NEW.salvalue < r THEN
         :NEW.salvalue := :OLD.salvalue;
     END IF;
     CLOSE CUR;
 END check_salary;
 /

 -- 08.Create a trigger that takes effect when an entry is deleted from the career table.

 CREATE OR REPLACE TRIGGER check_not_null
     BEFORE DELETE ON career
     FOR EACH ROW
 BEGIN
     IF :OLD.enddate IS NULL
         THEN INSERT INTO career VALUES (:OLD.jobno, :OLD.empno, :OLD.deptno, :OLD.startdate, :OLD.enddate);
     END IF;
 END check_not_null;
 /

 -- 09.Create a trigger that acts on adding or changing data in the EMP table

 CREATE OR REPLACE TRIGGER on_emp_insert_update
     BEFORE INSERT OR UPDATE ON emp
     FOR EACH ROW
 BEGIN
     IF :NEW.birthdate IS NULL THEN
         DBMS_OUTPUT.PUT_LINE('BIRTHDATE IS NULL');
     END IF;

     IF :NEW.birthdate < to_date('01-01-1940', 'dd-mm-yyyy') THEN
         DBMS_OUTPUT.PUT_LINE('PENSIONER');
     END IF;

     :NEW.empname := UPPER(:NEW.empname);
 END on_emp_insert_update;
 /

 -- 10.Create a program to change the type of a given variable from a character type
 -- (VARCHAR2) to numeric type (NUMBER).
 
CREATE OR REPLACE FUNCTION str2nr(str in varchar2) return NUMBER AS
     BEGIN
         RETURN CAST(str AS NUMBER);
         EXCEPTION
         WHEN VALUE_ERROR THEN
             DBMS_OUTPUT.PUT_LINE('CLASS CAST EXCEPTION ' || str);
             RETURN NULL;
         WHEN OTHERS THEN
             RAISE_APPLICATION_ERROR(-20103, 'SHOULD NOT GET THERE');
         RETURN NULL;
     END;