DROP TABLE RECIPE;
DROP TABLE PRODUCT;

CREATE TABLE PRODUCT
       (PRODUCT_ID NUMBER(2) PRIMARY KEY,
	    NAME VARCHAR2(50) NOT NULL,  
	    AMOUNT NUMBER(6) NOT NULL,
        MANUFACTURER NUMBER(2) REFERENCES MANUFACTURER(MANUFACTURER_ID),
        SALES_POINT NUMBER(2) REFERENCES SALES_POINT(SALES_POINT_ID),
        PRICE NUMBER(6) NOT NULL,
        PACKAGE_TYPE NUMBER(2) REFERENCES PRODUCT_PACKAGE(PACKAGE_ID)
       );
COMMIT;

CREATE TABLE PRODUCT_PACKAGE
       (PACKAGE_ID NUMBER(2) PRIMARY KEY,
	    NAME VARCHAR2(50) NOT NULL);
COMMIT;

INSERT INTO PRODUCT_PACKAGE VALUES (1, 'банка');
INSERT INTO PRODUCT_PACKAGE VALUES (2, 'пакет');	
COMMIT;

INSERT INTO PRODUCT VALUES (1, 'product 1', 20, 1, 1, 12, 1);	
INSERT INTO PRODUCT VALUES (2, 'product 2', 500, 1, 1, 5, 2);	
INSERT INTO PRODUCT VALUES (3, 'product 3', 200, 1, 2, 7, 1);	
INSERT INTO PRODUCT VALUES (4, 'product 4', 150, 2, 2, 22, 2);	
COMMIT;

CREATE TABLE RECIPE
       (RECIPE_ID NUMBER(2) PRIMARY KEY,
	    NAME VARCHAR2(50) NOT NULL,  
	    PREPARE_TIME NUMBER(6),
        PRODUCT_ID NUMBER(2) REFERENCES PRODUCT(PRODUCT_ID),
        AMOUNT NUMBER(6) NOT NULL);
COMMIT;

CREATE TABLE MANUFACTURER
       (MANUFACTURER_ID NUMBER(2) PRIMARY KEY,
	    NAME VARCHAR2(50) NOT NULL);
COMMIT;

INSERT INTO MANUFACTURER VALUES (1, 'Савушкин продукт');
INSERT INTO MANUFACTURER VALUES (2, 'ABC');	
COMMIT;

CREATE TABLE SALES_POINT
       (SALES_POINT_ID NUMBER(2) PRIMARY KEY,
	    NAME VARCHAR2(50) NOT NULL,
       ADDRESS VARCHAR2(50) NOT NULL
       );
COMMIT;

INSERT INTO SALES_POINT VALUES (1, 'Евроопт', 'address 1');
INSERT INTO SALES_POINT VALUES (2, 'Рублёвский', 'address 2');	
COMMIT;

INSERT INTO RECIPE VALUES (1, 'recipe 1', 20, 1, 1);
INSERT INTO RECIPE VALUES (2, 'recipe 1', 20, 2, 3);
INSERT INTO RECIPE VALUES (3, 'recipe 1', 20, 3, 2);

INSERT INTO RECIPE VALUES (4, 'recipe 2', 35, 3, 1);
INSERT INTO RECIPE VALUES (5, 'recipe 2', 35, 4, 2);
INSERT INTO RECIPE VALUES (6, 'recipe 2', 35, 1, 1);
INSERT INTO RECIPE VALUES (7, 'recipe 2', 35, 2, 2);

INSERT INTO RECIPE VALUES (8, 'recipe 3', 40, 1, 1);
INSERT INTO RECIPE VALUES (9, 'recipe 3', 40, 2, 2);
INSERT INTO RECIPE VALUES (10, 'recipe 3', 40, 3, 1);

INSERT INTO RECIPE VALUES (11, 'recipe 4', 20, 1, 1);
INSERT INTO RECIPE VALUES (12, 'recipe 4', 20, 3, 1);
INSERT INTO RECIPE VALUES (13, 'recipe 4', 20, 4, 1);	
COMMIT;

-- 1. List of ingredients according to the list of selected dishes.
select RECIPE.NAME, PRODUCT.NAME from RECIPE left join PRODUCT;
select RECIPE.NAME, PRODUCT.NAME from RECIPE left join PRODUCT where RECIPE.NAME in ('recipe 2', 'recipe 4');

-- 2. The total cost of all products according to the list of dishes (including packaging).
select recipeName, sum(PRODUCT_PRICE) as TOTAL_PRICE from(
    select RECIPE.NAME as recipeName, PRODUCT.PRICE*RECIPE.AMOUNT as PRODUCT_PRICE from RECIPE left join PRODUCT) group by recipeName order by recipeName;

-- 3. List of the most popular manufacturers.
select MANUFACTURER, count(MANUFACTURER) as MANUFACTURER_COUNT from PRODUCT group by MANUFACTURER order by MANUFACTURER_COUNT desc;
select MANUFACTURER from (select MANUFACTURER, count(MANUFACTURER) as MANUFACTURER_COUNT from PRODUCT group by MANUFACTURER) s
    where MANUFACTURER_COUNT in (select max(MANUFACTURER_COUNT) from s);

-- 4. Number of purchases for each outlet.
select SALES_POINT, count(SALES_POINT) as SALES_POINT_COUNT from PRODUCT group by SALES_POINT order by SALES_POINT;

-- 5. The number of necessary products for the preparation of each dish (excluding packaging).
select NAME, count(*) as INGREDIENT_COUNT from RECIPE group by NAME order by NAME;


------------------- task 4 ----------------------------
--1. Add information about the new product, for the new product, determine the most popular manufacturer and the most common type of packaging.

INSERT INTO PRODUCT VALUES (5, 'product 5', 50, 2, 1, 8, 1);	
select MANUFACTURER, package_type from (select MANUFACTURER, count(MANUFACTURER) as MANUFACTURER_COUNT from PRODUCT group by MANUFACTURER where NAME in 'ABC' join 
                                       select package_type, count(package_type) as package_type_COUNT from PRODUCT group by package_type where NAME in 'ABC') s
    where MANUFACTURER_COUNT in (select max(MANUFACTURER_COUNT) from s) and package_type_COUNT in (select max(package_type_COUNT) from s);
    
--2. In connection with the closure of a certain outlet, reschedule the purchase of products at a neighboring outlet (by the value of the primary key).

UPDATE PRODUCT SET sales_point = 1 WHERE sales_point = 2;
    
--3. Delete information about products from a specific vendor. Ensure the purchase of these products from other suppliers.
delete from sales_point where name in 'Евроопт';
UPDATE PRODUCT SET sales_point = (select sales_point_id from sales_point where name in 'Рублёвский') 
    WHERE sales_point in (select sales_point_id from sales_point where name in 'Евроопт');

