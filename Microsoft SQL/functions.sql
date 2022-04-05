--1. Compose per data sample using reflective join for table

select a.name, b.name from recipe a join recipe b on a.product_id = b.product_id;


--2. A simple CASE() statement;
select product.name, 
	case product_package.package_id 
		when 1 then 'банка'
		when 2 then 'пакет'
	end "package"
from product join product_package using(package_id);


--3. Search operator CASE();
select name, 
	case prepare_time > 30 then 'long prepare'
	else 'quick prepare' end preparing
from recipe;


--4. WITH statement
with tbl as (select manufacturer, price from product where manufacturer = 1) 
select manufacturer, price from tbl where price = (select max(price) from tbl);


--5. Embedded View
create materialized view view1 as
select manufacturer.name, product.name, amount from manufacturer 
join products on product.manufacturer = manufacturer.manufacturer_id
where manufacturer.name = 'Савушкин продукт';
select * from view1 where amount > 100;


--6. Uncorrelated query
select manufacturer.name, product.name, amount from manufacturer 
join products on product.manufacturer = manufacturer.manufacturer_id
where amount = (select min(amount) from manufacturer 
join products on product.manufacturer = manufacturer.manufacturer_id);


--7. Correlated query
select product_package.name, product_name, price from product_package join product
on product.packade_type = product_package.id
where price = (select max(price) from product_package join product
on product.packade_type = product_package.id);


--8. NULLIF 
select product.name, product.amount, recipe.amount, case when nullif(length(recipe.amount),length(product.amount)) IS NULL THEN 'Равны' else 'Не равны' end comp from recipe join product on product_id = recipe.product_id;


--9. NVL2 
select product.name, nvl2(nullif(length(recipe.amount),length(product.amount),'Равны','Не Равны') part from recipe join product on product_id = recipe.product_id;


--10. TOP-N analysis
select product.name from
(Select product.name,rank() over(partition by manufacturer_id order by price) as most_popular_by_prod from product)
where most_popular_by_prod = 1;


--11. ROLLUP
select decode(grouping(manufacturer.name), 1, 'all producers', manufacturer.name) manufacturer.name, decode(grouping(product.name), 1, 'all products', product.name) product.name, sum(price) from product join manufacturer on product.manufacturer = manufacturer.manufacturer_ID
group by rollup(manufacturer.name, product.name);


--12. Write a query to use the data manipulation language MERGE statement.
create table new_product(
	PRODUCT_ID NUMBER(2) PRIMARY KEY,
	NAME VARCHAR2(50) NOT NULL,  
	AMOUNT NUMBER(6) NOT NULL,
        MANUFACTURER NUMBER(2) REFERENCES MANUFACTURER(MANUFACTURER_ID),
        SALES_POINT NUMBER(2) REFERENCES SALES_POINT(SALES_POINT_ID),
        PRICE NUMBER(6) NOT NULL,
        PACKAGE_TYPE NUMBER(2) REFERENCES PRODUCT_PACKAGE(PACKAGE_ID));

merge into product
using new_product on(product.name = new_product.name) 
	when matched then update set product.price = new_product.price 
	when not matched then insert (product.product_id, product.name, product.amount, product.manufacturer, product.sales_point, proproduct.price, products.package_type)
value (new_product.product_id, new_product.name, new_product.amount, new_product.manufacturer, new_product.sales_point, new_proproduct.price, new_products.package_type);