/*
    CREATE USER POS_DB
*/
set serveroutput on
set escape on
PROMPT specify password for POS_DB:
DEFINE pass     = &1

PROMPT What is password of SYSTEM user:
DEFINE sysusr   = &2

PROMPT Enter connection_string like @localhost:1521/xe leave empty if not applicable
DEFINE conn_str = &3

conn SYSTEM/&sysusr&conn_str

alter session set "_oracle_script"=true;

DROP USER POS_DB CASCADE;

CREATE USER POS_DB IDENTIFIED BY &pass;

alter session set "_oracle_script"=false;

conn SYSTEM/&sysusr&conn_str

ALTER USER POS_DB DEFAULT TABLESPACE users;

ALTER USER POS_DB TEMPORARY TABLESPACE TEMP;

GRANT CONNECT TO POS_DB;
GRANT CREATE SESSION TO POS_DB;
GRANT CREATE VIEW TO POS_DB;
GRANT ALTER SESSION TO POS_DB;
GRANT CREATE TABLE TO POS_DB;
GRANT CREATE SEQUENCE TO POS_DB;
GRANT CREATE SYNONYM TO POS_DB;
GRANT CREATE DATABASE LINK TO POS_DB;
GRANT RESOURCE TO POS_DB;
GRANT UNLIMITED TABLESPACE TO POS_DB;


conn POS_DB/&pass&conn_str

-- DROPPING TABLES IN CASE USER ALREADY EXISTS...
DROP TABLE "row" CASCADE CONSTRAINTS;
DROP TABLE BRANDS CASCADE CONSTRAINTS;
DROP TABLE person CASCADE CONSTRAINTS;
DROP TABLE supplier CASCADE CONSTRAINTS;
DROP TABLE bank CASCADE CONSTRAINTS;
DROP TABLE bank_account CASCADE CONSTRAINTS;
DROP TABLE job CASCADE CONSTRAINTS;
DROP TABLE staff CASCADE CONSTRAINTS;
DROP TABLE payment_terminal CASCADE CONSTRAINTS;
DROP TABLE rack CASCADE CONSTRAINTS;
DROP TABLE product_detail CASCADE CONSTRAINTS;
DROP TABLE category CASCADE CONSTRAINTS;
DROP TABLE product CASCADE CONSTRAINTS;
DROP TABLE purchases CASCADE CONSTRAINTS;
DROP TABLE customer CASCADE CONSTRAINTS;
DROP TABLE counter CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE purchase_summary CASCADE CONSTRAINTS;
DROP TABLE checkin CASCADE CONSTRAINTS;
DROP TABLE order_summary CASCADE CONSTRAINTS;
DROP TABLE terminal_receipts CASCADE CONSTRAINTS;


-- DROPPING EXISTING SEQUENCES AND CREATING NEW ONES
DROP SEQUENCE seq_person_id;
DROP SEQUENCE seq_staff_id;
DROP SEQUENCE seq_payment_terminal_id;
DROP SEQUENCE seq_product_id;
DROP SEQUENCE seq_purchases_id;
DROP SEQUENCE seq_customer_id;
DROP SEQUENCE seq_order_id;

CREATE SEQUENCE seq_person_id;
CREATE SEQUENCE seq_staff_id;
CREATE SEQUENCE seq_payment_terminal_id;
CREATE SEQUENCE seq_product_id;
CREATE SEQUENCE seq_purchases_id;
CREATE SEQUENCE seq_customer_id;
CREATE SEQUENCE seq_order_id;

CREATE TABLE "row" (
    row_id int generated always as identity NOT NULL,
    row_alias varchar(9) NOT NULL,
    CONSTRAINT pk_row PRIMARY KEY (row_id)
);

CREATE TABLE supplier (
    supplier_id varchar(5) NOT NULL,
    representative varchar(40) NOT NULL,
    company_name varchar(40) NOT NULL,
    CONSTRAINT pk_supplier PRIMARY KEY (supplier_id)
);

CREATE TABLE bank (
    bank_id varchar(40) NOT NULL,
    bank_name varchar(40) NOT NULL,
    bank_address varchar(400) NOT NULL,
    manager_name varchar(40) NOT NULL,
    telephone_no varchar(44) NOT NULL,
    CONSTRAINT pk_bank  PRIMARY KEY (bank_id)
);

CREATE TABLE bank_account (
    account_no varchar(44) NOT NULL,
    bank_id varchar(40) NOT NULL,
    account_alias varchar(30) NOT NULL,
    account_type varchar(40) DEFAULT 'BUSINESS' NOT NULL ,
    CONSTRAINT pk_bank_account  PRIMARY KEY (account_no),
    CONSTRAINT bank_account_account_no_char_bound check ( LENGTH(ACCOUNT_NO) <= 14 )
);

CREATE TABLE job (
    job_id varchar(20) NOT NULL,
    job_name varchar(30) NOT NULL,
    max_salary int not null,
    CONSTRAINT pk_job PRIMARY KEY (job_id)
);

CREATE TABLE brands (
    brand_name varchar(20),
    CONSTRAINT pk_brand_brand_name primary key (brand_name)
);

CREATE TABLE staff (
    staff_id varchar(20) NOT NULL,
    person_id varchar(20) NOT NULL,
    job varchar(20) NOT NULL,
    salary int not null,
    CONSTRAINT uq_staff_person_id unique (person_id),
    CONSTRAINT pk_staff  PRIMARY KEY (staff_id)
);

CREATE TABLE person (
    person_id varchar(20) NOT NULL,
    person_name varchar(20) NOT NULL,
    father_name varchar(20),
    CNIC varchar(43) NOT NULL,
    phone_no varchar(44) ,
    email VARCHAR(50),
    CONSTRAINT unique_cnic unique (CNIC),
    CONSTRAINT pk_person PRIMARY KEY (person_id)
);

CREATE TABLE payment_terminal (
    terminal_id varchar(40) NOT NULL,
    reg_account varchar(44) NOT NULL,
    vendor varchar(20) NOT NULL,
    CONSTRAINT pk_payment_terminal  PRIMARY KEY (terminal_id)
);

CREATE TABLE rack (
    rack_id varchar(40) NOT NULL,
    row_id int NOT NULL,
    CONSTRAINT pk_rack  PRIMARY KEY (rack_id)
);


CREATE TABLE product_detail (
    prod_id varchar(40) NOT NULL,
    rack_id varchar(40) NOT NULL,
    quantity int DEFAULT 0 NOT NULL,
    sale_price int not null,
    CONSTRAINT pk_product_detail PRIMARY KEY (prod_id)
);

CREATE TABLE category (
    category_name varchar(30) NOT NULL,
    GST FLOAT DEFAULT 17 NOT NULL,
    CONSTRAINT pk_category PRIMARY KEY (category_name)
);

CREATE TABLE product (
    category_id varchar(30) NOT NULL,
    prod_id varchar(20) NOT NULL,
    prod_name varchar(50) NOT NULL,
    prod_brand varchar(20) NOT NULL,
    CONSTRAINT pk_product PRIMARY KEY (prod_id),
    CONSTRAINT unique_brand_product unique (prod_name, prod_brand),
    CONSTRAINT fk_brand foreign key (prod_brand) references brands(brand_name)
);

CREATE INDEX index_product_on_brand ON PRODUCT(prod_brand);

CREATE TABLE purchases (
    receipt_id varchar(40) NOT NULL,
    supplier_id varchar(40) NOT NULL,
    payment_type varchar(40) DEFAULT 'CASH' NOT NULL,
    purchase_date varchar(9) DEFAULT CAST(SYSDATE as varchar(9)) NOT NULL,
    CONSTRAINT check_payment_type CHECK ( payment_type in ('CASH', 'CREDIT') ),
    CONSTRAINT pk_purchases PRIMARY KEY (receipt_id)
);

CREATE TABLE customer (
    customer_id varchar(40) NOT NULL,
    person_id varchar(40) NOT NULL,
    registration_date varchar(9) default CAST(SYSDATE as varchar(9)),
    loyalty_points int DEFAULT 0 not null,
    CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

CREATE TABLE counter (
    counter_id varchar(40) NOT NULL,
    counter_login_id varchar(40) NOT NULL,
    counter_pass varchar(45) NOT NULL,
    CONSTRAINT pk_counter PRIMARY KEY (counter_id)
);

CREATE TABLE orders (
    receipt_id varchar(20) NOT NULL,
    customer_id varchar(20) NOT NULL,
    receptionist varchar(20) NOT NULL,
    payment_type varchar(20) DEFAULT 'CASH' NOT NULL,
    net_amount int DEFAULT 0 NOT NULL,
    counter varchar(40) NOT NULL,
    CONSTRAINT check_order_payment_type check ( payment_type in ('CASH', 'SWIPE') ),
    CONSTRAINT pk_order PRIMARY KEY (receipt_id)
);

CREATE TABLE purchase_summary (
    product_id varchar(20) NOT NULL,
    receipt_id varchar(20) NOT NULL,
    quantity varchar(20) NOT NULL,
    unit_price int NOT NULL,
    CONSTRAINT pk_purchase_summary PRIMARY KEY (receipt_id, product_id)
);

CREATE INDEX index_prod_id_on_purchase_summary ON  Purchase_summary (product_id);

CREATE TABLE checkin (
    staff_id varchar(20) NOT NULL,
    checkin_date varchar(9) DEFAULT CAST(SYSDATE as varchar(9)) NOT NULL,
    checkin_time varchar(45) DEFAULT to_char(sysdate,'HH24:MI:SS AM') NOT NULL,
    CONSTRAINT pk_checkin PRIMARY KEY (staff_id, checkin_date)
);

CREATE TABLE order_summary (
    receipt_id varchar(20) NOT NULL,
    product_id varchar(20) NOT NULL,
    quantity varchar(20) NOT NULL,
    CONSTRAINT pk_order_summary  PRIMARY KEY (product_id,receipt_id)
);

CREATE INDEX index_receipt_id_order_summary ON  Order_summary (receipt_id);

CREATE TABLE terminal_receipts (
    terminal_id varchar(20) NOT NULL,
    order_receipt_id varchar(20) NOT NULL,
    payer_name varchar(20) NOT NULL,
    receipt_date  varchar(9) DEFAULT CAST(SYSDATE as varchar(9))NOT NULL,
    CONSTRAINT pk_terminal_receipts PRIMARY KEY (order_receipt_id)
);


ALTER TABLE SUPPLIER ADD CONSTRAINT fk_supplier_representative FOREIGN KEY (REPRESENTATIVE) REFERENCES PERSON(person_id);
ALTER TABLE BANK_ACCOUNT ADD CONSTRAINT fk_bank_account_bank_id FOREIGN KEY (bank_id) REFERENCES bank(bank_id);
ALTER TABLE PAYMENT_TERMINAL ADD CONSTRAINT fk_payment_terminal_reg_account FOREIGN KEY (reg_account) REFERENCES Bank_Account(account_no);
ALTER TABLE PRODUCT_DETAIL ADD CONSTRAINT FK_Product_details_rack_id  FOREIGN KEY (rack_id) REFERENCES Rack(rack_id);
ALTER TABLE RACK ADD CONSTRAINT fk_rack_row_id FOREIGN KEY (row_id)  REFERENCES "row"(row_id);
ALTER TABLE PRODUCT ADD CONSTRAINT fk_product_category_id FOREIGN KEY (category_id) REFERENCES category(category_name);
ALTER TABLE PURCHASES ADD CONSTRAINT fk_purchases_supplier_id FOREIGN KEY (supplier_id)REFERENCES supplier(supplier_id);
ALTER TABLE CUSTOMER ADD CONSTRAINT fk_customer_person_id FOREIGN KEY (person_id) REFERENCES person (person_id);
ALTER TABLE TERMINAL_RECEIPTS ADD CONSTRAINT fk_terminal_receipts_terminal_id FOREIGN KEY (terminal_id) REFERENCES payment_terminal(terminal_id);
ALTER TABLE checkin ADD CONSTRAINT fk_checkin_staff_id FOREIGN KEY (staff_id) REFERENCES staff(staff_id);
ALTER TABLE order_summary
ADD (
    CONSTRAINT FK_Order_summary_receipt_id FOREIGN KEY (receipt_id)  REFERENCES orders(receipt_id),
    CONSTRAINT FK_Order_summary_product_id  FOREIGN KEY (product_id) REFERENCES product(prod_id)
);
ALTER TABLE PURCHASE_SUMMARY
ADD (
    CONSTRAINT fk_purchase_summary_receipt_id FOREIGN KEY (receipt_id) REFERENCES purchases(receipt_id),
    CONSTRAINT fk_purchase_summary_product_id FOREIGN KEY (product_id) REFERENCES product(prod_id)
);
ALTER TABLE orders
ADD (
    CONSTRAINT fk_order_counter FOREIGN KEY (counter) REFERENCES counter(counter_id),
    CONSTRAINT fk_order_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT fk_order_receptionist FOREIGN KEY (receptionist) REFERENCES staff(staff_id)
);
ALTER TABLE STAFF
ADD(
    CONSTRAINT fk_staff_person_id FOREIGN KEY (person_id) REFERENCES person(person_id),
    CONSTRAINT fk_staff_job FOREIGN KEY (job) REFERENCES job(job_id)
);

-- ID TRIGGERS
CREATE OR REPLACE TRIGGER assign_rack_id
    BEFORE INSERT
    ON rack
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select count(*) + 1 INTO id_num from rack where rack.row_id = :new.row_id;
    :new.rack_id := CONCAT(CONCAT('r-', :new.row_id), CONCAT('-' , LPAD(id_num, 2, '0')));
end;
/


CREATE OR REPLACE TRIGGER assign_order_id
    BEFORE INSERT
    ON orders
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_order_id.nextval INTO id_num from dual;
    :new.receipt_id := CONCAT('sr-' , LPAD(id_num, 6, '0'));
end;
/

CREATE OR REPLACE TRIGGER assign_customer_id
    BEFORE INSERT
    ON customer
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_customer_id.nextval INTO id_num from dual;
    :new.customer_id := CONCAT('cst-' , LPAD(id_num, 6, '0'));
end;
/

CREATE OR REPLACE TRIGGER assign_purchase_id
    BEFORE INSERT
    ON purchases
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_purchases_id.nextval INTO id_num from dual;
    :new.receipt_id := CONCAT('pr-' , LPAD(id_num, 6, '0'));
end;
/

CREATE OR REPLACE TRIGGER assign_product_id
    BEFORE INSERT
    ON product
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_product_id.nextval INTO id_num from dual;
    :new.prod_id := CONCAT('prd-' , LPAD(id_num, 6, '0'));
end;
/


CREATE OR REPLACE TRIGGER assign_staff_id
    BEFORE INSERT
    ON staff
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_staff_id.nextval INTO id_num from dual;
    :new.staff_id := CONCAT('stf-' , LPAD(id_num, 6, '0'));
end;
/


CREATE OR REPLACE TRIGGER assign_person_id
    BEFORE INSERT
    ON person
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_person_id.nextval INTO id_num from dual;
    :new.person_id := CONCAT('p-' , LPAD(id_num, 6, '0'));
end;
/

CREATE OR REPLACE TRIGGER assign_payment_terminal_id
    BEFORE INSERT
    ON payment_terminal
    FOR EACH ROW
DECLARE
    id_num int;
BEGIN
    select seq_payment_terminal_id.nextval INTO id_num from dual;
    :new.terminal_id := CONCAT('T-' , LPAD(id_num, 2, '0'));
end;
/

-- THIS TRIGGER WILL ALSO CREATE CUSTOMER PROFILE FOR EVERY PERSON ADDED
CREATE OR REPLACE TRIGGER add_customer_after_person
    AFTER INSERT
    ON person
    FOR EACH ROW
BEGIN
    INSERT INTO CUSTOMER (PERSON_ID) VALUES (:NEW.person_id);
end;
/

-- TRIGGERS TO UPDATE DATA IN RELATED TABLE (ENSURE CONSISTENCY)
CREATE OR REPLACE TRIGGER update_quantity_purchase
    AFTER INSERT
    ON PURCHASE_SUMMARY
    FOR EACH ROW
DECLARE
BEGIN
    UPDATE PRODUCT_DETAIL SET QUANTITY = QUANTITY + :new.quantity where prod_id = :new.product_id;
end;
/

CREATE OR REPLACE TRIGGER update_order_total
    AFTER INSERT ON ORDER_SUMMARY FOR EACH ROW
DECLARE
    p_price int;
    l_points int;
    cust_id CUSTOMER.customer_id%type;
BEGIN
    select sale_price into p_price from product_detail where prod_id = :new.product_id;
    update product_detail set quantity = quantity - :new.quantity where prod_id = :new.product_id;
    UPDATE ORDERS set net_amount = net_amount + (p_price*:new.quantity) where receipt_id = :new.receipt_id;
    select customer_id into cust_id from orders where receipt_id = :new.receipt_id;
    l_points := floor(p_price * 0.05) * :new.quantity;
    UPDATE CUSTOMER set loyalty_points = l_points where customer_id = cust_id;
end;
/


-- DATA GENERATION PROCEDURES
CREATE OR REPLACE PROCEDURE generate_orders(n_orders int)
IS
    ord_counter int :=0;
    cust CUSTOMER.customer_id%type;
    recep_attendant STAFF.staff_id%type;
    counter_ COUNTER.counter_id%type;
    payment_terminal_id payment_terminal.terminal_id%type;
    ord_id orders.receipt_id%type;
    pay_type_rand int;
    name TERMINAL_RECEIPTS.payer_name%type;
    rand_date varchar(9);
    rand_n_prods int;
    pay_type_str varchar(5);
BEGIN
    while(ord_counter <= n_orders)
    LOOP
        pay_type_rand := FLOOR(DBMS_RANDOM.VALUE(0,2));
        pay_type_str := CASE WHEN pay_type_rand = 0 THEN 'CASH' WHEN pay_type_rand = 1 THEN 'SWIPE' END;
        select customer_id into cust from customer order by DBMS_RANDOM.VALUE() fetch first 1 row only;
        select counter_id into counter_ from counter order by DBMS_RANDOM.VALUE() fetch first 1 row only;
        select staff_id into recep_attendant from staff where job = 'cashier' order by DBMS_RANDOM.VALUE() fetch first 1 row only;
        INSERT INTO ORDERS (customer_id, receptionist, counter, payment_type) VALUES (cust, recep_attendant, counter_, pay_type_str);
        select receipt_id into ord_id from orders order by receipt_id desc fetch first 1 row only;
        if(pay_type_rand = 1)
        THEN
            select terminal_id into payment_terminal_id from payment_terminal order by DBMS_RANDOM.VALUE() fetch first 1 row only;
            select CAST(to_date(CONCAT(CONCAT('01',  '/01/'), '2020'), 'DD/MM/YYYY')+ FLOOR(DBMS_RANDOM.VALUE(0, 365)) as varchar(9)) into rand_date from dual;
            select person_name into name from person where person_id in (select person_id from customer where customer_id = cust);
            insert into TERMINAL_RECEIPTS (terminal_id, order_receipt_id, payer_name, receipt_date) VALUES (payment_terminal_id, ord_id, name, rand_date);
        end if;
        rand_n_prods := ceil(DBMS_RANDOM.VALUE(0,30));
        for prd in (select prod_id from product order by DBMS_RANDOM.VALUE() fetch first rand_n_prods rows only)
        loop
            INSERT INTO ORDER_SUMMARY (receipt_id, product_id, quantity) VALUES (ord_id, prd.prod_id, CEIL(DBMS_RANDOM.VALUE(0,10)));
        end loop;
        ord_counter := ord_counter + 1;
    end loop;

end;
/

CREATE OR REPLACE PROCEDURE generate_staff_attendance
IS
    curr_date date;
    target_date date;
    nstaff int;
    random_time varchar(16);
BEGIN
    select count(*) into nstaff from staff;
    select to_date(CONCAT(CONCAT('01',  '/11/'), '2020'), 'DD/MM/YYYY') INTO curr_date from DUAL;
    target_date := curr_date + 365;
    while(curr_date <= target_date)
    LOOP
        for stf in (select staff_id from staff order by DBMS_RANDOM.VALUE() fetch first floor(nstaff*0.8) rows only)
        LOOP
            select
            CONCAT(CONCAT(CONCAT(LPAD(floor(DBMS_RANDOM.VALUE(8,9.99)), 2, '0'), ':'),
            CONCAT(CONCAT(LPAD(floor(DBMS_RANDOM.VALUE(0,60.99)), 2, '0'), ':'), LPAD(floor(DBMS_RANDOM.VALUE(0,60.99)), 2, '0'))), ' AM')
            into random_time from dual;
            INSERT INTO CHECKIN (staff_id, checkin_date, checkin_time) VALUES (stf.staff_id, curr_date, random_time);
        end loop;
        curr_date := curr_date + 1;
    end loop;
end;
/

CREATE OR REPLACE PROCEDURE generate_purchases
IS
    n_suppliers int;
    n_products int;
    prds_per_supplier int;
    product_cost int;
    p_id PURCHASES.RECEIPT_ID%type;
    rand_date varchar(15);
    rand_int int;
BEGIN
    select count(*) into n_suppliers from supplier;
    select count(*) into n_products from product;
    prds_per_supplier := n_products / n_suppliers;
    for sup in (select supplier_id from supplier)
    LOOP
        rand_int := floor(DBMS_RANDOM.VALUE(0,2));
        select CONCAT(CONCAT(lpad(FLOOR(DBMS_RANDOM.VALUE(1,31)), 2, '0'),  '-JAN-'), 20) into rand_date from DUAL;
        INSERT INTO PURCHASES
            (supplier_id, payment_type, purchase_date)
        VALUES
            (sup.supplier_id, CASE WHEN rand_int = 0 THEN 'CASH' WHEN rand_int = 1 THEN 'CREDIT' END, rand_date);
        select receipt_id into p_id from purchases order by receipt_id desc fetch first 1 row only;

        for prd in (select prod_id from product
                                   where prod_id
                                             in (select prod_id from product_detail
                                                                where quantity = 0)
                                   order by DBMS_RANDOM.VALUE()
                                   fetch first prds_per_supplier rows only)
        LOOP
            SELECT sale_price into product_cost FROM PRODUCT_DETAIL WHERE prod_id = prd.prod_id;
            product_cost := floor(product_cost * 0.75);
            INSERT INTO purchase_summary (product_id, receipt_id, quantity, unit_price) VALUES (prd.prod_id, p_id, floor(DBMS_RANDOM.VALUE(200, 500)), product_cost);
        end loop;
    end loop;
END;
/


CREATE OR REPLACE PROCEDURE add_product(
    inp_prd_name PRODUCT.prod_name%type,
    inp_category_name CATEGORY.category_name%type,
    inp_rack_id int,
    inp_sale_price int,
    inp_brand brands.brand_name%type
)
IS
    brand_available int;
    rk_id RACK.rack_id%type;
    r_id int;
    prd_id_seq int;
    prd_id_to_be PRODUCT.prod_id%type;
BEGIN
    select count(*) INTO brand_available from brands where brand_name = inp_brand;
    if (brand_available = 0)
    THEN
        INSERT INTO brands (brand_name) VALUES (inp_brand);
    end if;
    INSERT INTO PRODUCT (category_id, prod_name, prod_brand) VALUES (inp_category_name, inp_prd_name, inp_brand);
    r_id := CASE WHEN inp_category_name = 'Beverages' THEN 1
                 WHEN inp_category_name = 'Snacks and Chocolates' THEN 2
                 WHEN inp_category_name = 'Health and Beauty' THEN 3
                 WHEN inp_category_name = 'Frozen' THEN 4
                 WHEN inp_category_name = 'Cooking Essentials' THEN 5 END;
    rk_id :=  CONCAT(CONCAT('r-', r_id) , CONCAT('-', LPAD(inp_rack_id, 2, '0')));
    select seq_product_id.currval into prd_id_seq from dual;
    prd_id_to_be := CONCAT('prd-' , LPAD(prd_id_seq, 6, '0'));
    INSERT INTO PRODUCT_DETAIL (PROD_ID, RACK_ID, SALE_PRICE, QUANTITY) VALUES (prd_id_to_be, rk_id, inp_sale_price, 0);
end;
/


-- POPULATING TABLES
INSERT INTO BANK (BANK_ID, BANK_NAME, BANK_ADDRESS, MANAGER_NAME, TELEPHONE_NO) VALUES ('UBL', 'United Bank Ltd.', 'UBL HQ Building Jail Road', 'Jaffar Sadiq', '042-3626022');
INSERT INTO BANK_ACCOUNT (ACCOUNT_NO, BANK_ID, ACCOUNT_ALIAS) VALUES ('04095423423454', 'UBL', 'UBL Terminal Associated Acc');
INSERT INTO BANK (BANK_ID, BANK_NAME, BANK_ADDRESS, MANAGER_NAME, TELEPHONE_NO) VALUES ('HBL', 'Habib Bank Ltd.', 'HBL HQ Building Johar Town', 'Anwar Razaq', '042-3905866');
INSERT INTO BANK_ACCOUNT (ACCOUNT_NO, BANK_ID, ACCOUNT_ALIAS) VALUES ('05787689423467', 'HBL', 'HBL Terminal Associated Acc');
INSERT INTO BANK (BANK_ID, BANK_NAME, BANK_ADDRESS, MANAGER_NAME, TELEPHONE_NO) VALUES ('JS', 'JS Bank Ltd.', 'JS HQ Gulberg', 'Asif Malik', '042-2435435');
INSERT INTO BANK_ACCOUNT (ACCOUNT_NO, BANK_ID, ACCOUNT_ALIAS) VALUES ('45044567808534', 'JS', 'JS Terminal Associated Acc');


INSERT INTO payment_terminal (reg_account, vendor) VALUES ('04095423423454', 'Mswipe');
INSERT INTO payment_terminal (reg_account, vendor) VALUES ('05787689423467', 'Swyft');
INSERT INTO payment_terminal (reg_account, vendor) VALUES ('45044567808534', 'Verrency');

INSERT INTO PERSON (person_name, father_name, CNIC, phone_no, email) values ('Joe', 'Biden', '6540798734653', '0335-7856574', 'joebiden@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('James' , 'Tillman' , '03744629025' , '3520294343455' , 'JamesTillman@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Anna' , 'Francis' , '03649250870' , '3520264869027' , 'AnnaFrancis@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Penny' , 'Brandt' , '03693207550' , '3520229560520' , 'PennyBrandt@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Irma' , 'Nedd' , '03786277874' , '3520223295894' , 'IrmaNedd@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Gerald' , 'Szydlowski' , '03608047343' , '3520245803305' , 'GeraldSzydlowski@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Judith' , 'Federico' , '03459845438' , '3520294449976' , 'JudithFederico@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Derrick' , 'Hults' , '03442024306' , '3520242474504' , 'DerrickHults@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Scott' , 'Reid' , '03855284992' , '3520237404454' , 'ScottReid@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Nicola' , 'Hevey' , '03944474634' , '3520264794445' , 'NicolaHevey@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Justin' , 'Rowe' , '03695903907' , '3520283402060' , 'JustinRowe@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Glenn' , 'Jones' , '03246306983' , '3520252268735' , 'GlennJones@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Naomi' , 'Ortega' , '03356064700' , '3520297250847' , 'NaomiOrtega@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('David' , 'Jourdan' , '03840422722' , '3520238424804' , 'DavidJourdan@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Richard' , 'Ramm' , '03404040533' , '3520266648278' , 'RichardRamm@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Floyd' , 'Davis' , '03989263440' , '3520289449557' , 'FloydDavis@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Fabian' , 'Hardison' , '03252444953' , '3520297558445' , 'FabianHardison@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Marjorie' , 'Wheaton' , '03866485468' , '3520240932953' , 'MarjorieWheaton@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Albert' , 'Graham' , '03294428445' , '3520273724328' , 'AlbertGraham@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Tyrone' , 'Hines' , '03834997462' , '3520245040334' , 'TyroneHines@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Priscilla' , 'Choi' , '03782644284' , '3520244805805' , 'PriscillaChoi@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Patricia' , 'Brim' , '03223604684' , '3520223553090' , 'PatriciaBrim@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Rebecca' , 'Bevelacqua' , '03270583356' , '3520287409987' , 'RebeccaBevelacqua@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Erik' , 'Claudio' , '03855032544' , '3520249247944' , 'ErikClaudio@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Larry' , 'Carlone' , '03879038366' , '3520249304473' , 'LarryCarlone@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Sandra' , 'Taylor' , '03240973863' , '3520286086603' , 'SandraTaylor@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Lillie' , 'Prok' , '03243600438' , '3520256274700' , 'LillieProk@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Joyce' , 'Marsella' , '03404895257' , '3520266522857' , 'JoyceMarsella@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Alexander' , 'Findlay' , '03493937564' , '3520264440674' , 'AlexanderFindlay@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Frederick' , 'Gunter' , '03973524474' , '3520290594876' , 'FrederickGunter@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Christina' , 'Pittman' , '03569440863' , '3520234964672' , 'ChristinaPittman@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Daniel' , 'Mendoza' , '03689499695' , '3520298800334' , 'DanielMendoza@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Danny' , 'Allison' , '03692399080' , '3520263604764' , 'DannyAllison@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Crystal' , 'Edwards' , '03444243547' , '3520240704965' , 'CrystalEdwards@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('James' , 'Ruthledge' , '03736474945' , '3520293443929' , 'JamesRuthledge@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Tanya' , 'Higgins' , '03485648506' , '3520264904869' , 'TanyaHiggins@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Erica' , 'Sheppard' , '03306062445' , '3520297540580' , 'EricaSheppard@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Mary' , 'Duell' , '03486494954' , '3520229936843' , 'MaryDuell@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Franklin' , 'Orr' , '03832370962' , '3520282369353' , 'FranklinOrr@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Gertrude' , 'Deegan' , '03783663835' , '3520268846033' , 'GertrudeDeegan@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Robert' , 'Lalk' , '03542962782' , '3520230896947' , 'RobertLalk@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Teresa' , 'Reidy' , '03867907868' , '3520266442840' , 'TeresaReidy@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Megan' , 'Boyd' , '03743287789' , '3520252883934' , 'MeganBoyd@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Lucille' , 'Brown' , '03387868020' , '3520260930295' , 'LucilleBrown@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Anthony' , 'Armenta' , '03499605726' , '3520255574547' , 'AnthonyArmenta@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Thomas' , 'Ellis' , '03480944249' , '3520247488398' , 'ThomasEllis@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Howard' , 'Reasner' , '03225979085' , '3520246242243' , 'HowardReasner@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Hugo' , 'Simmons' , '03783864497' , '3520264209547' , 'HugoSimmons@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Michael' , 'Loredo' , '03259243494' , '3520257724885' , 'MichaelLoredo@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('David' , 'Broadnax' , '03474692740' , '3520254354669' , 'DavidBroadnax@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Phil' , 'Samuel' , '03542724590' , '3520244426693' , 'PhilSamuel@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('James' , 'Hamilton' , '03533574642' , '3520262808402' , 'JamesHamilton@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Dorothy' , 'Deering' , '03897506434' , '3520247367406' , 'DorothyDeering@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Ronnie' , 'Mcburney' , '03443974450' , '3520237789037' , 'RonnieMcburney@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Bradley' , 'Curtis' , '03479066884' , '3520222046474' , 'BradleyCurtis@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Michael' , 'Johnson' , '03954608258' , '3520235642437' , 'MichaelJohnson@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Beth' , 'Daudelin' , '03347707884' , '3520292205445' , 'BethDaudelin@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Michael' , 'Allen' , '03740544904' , '3520244494269' , 'MichaelAllen@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Richard' , 'Quimby' , '03724063044' , '3520237002405' , 'RichardQuimby@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('George' , 'Kennedy' , '03444324273' , '3520247736472' , 'GeorgeKennedy@email.com');
INSERT INTO PERSON (person_name, father_name, phone_no, cnic, email) values ('Barbara' , 'Walsh' , '03782489440' , '3520294004563' , 'BarbaraWalsh@email.com');


insert into supplier (supplier_id, representative, company_name) values ('sp-01', 'p-000054', 'Kamlesh Whole-sellers');
insert into supplier (supplier_id, representative, company_name) values ('sp-02', 'p-000060', 'Jalal Sons');
insert into supplier (supplier_id, representative, company_name) values ('sp-03', 'p-000059', 'Imtiaz Imports');


INSERT INTO JOB (job_id, job_name, max_salary) VALUES ('gate_guard', 'Security Guard', 30000);
INSERT INTO JOB (job_id, job_name, max_salary) VALUES ('cashier', 'Counter Cashier', 50000);
INSERT INTO JOB (job_id, job_name, max_salary) VALUES ('c_helper', 'Counter Helper', 40000);
INSERT INTO JOB (job_id, job_name, max_salary) VALUES ('p_guide', 'Product Guide', 45000);
INSERT INTO JOB (job_id, job_name, max_salary) VALUES ('cro', 'Customer Relation Officer', 60000);

INSERT INTO staff (person_id, job, salary) values ('p-000004', 'cro', 55000);
INSERT INTO staff (person_id, job, salary) values ('p-000002', 'p_guide', 20000);
INSERT INTO staff (person_id, job, salary) values ('p-000003', 'p_guide', 49000);
INSERT INTO staff (person_id, job, salary) values ('p-000001', 'p_guide', 49500);
INSERT INTO staff (person_id, job, salary) values ('p-000005', 'p_guide', 47000);
INSERT INTO staff (person_id, job, salary) values ('p-000006', 'c_helper', 35000);
INSERT INTO staff (person_id, job, salary) values ('p-000007', 'c_helper', 35000);
INSERT INTO staff (person_id, job, salary) values ('p-000008', 'c_helper', 35000);
INSERT INTO staff (person_id, job, salary) values ('p-000009', 'c_helper', 35000);
INSERT INTO staff (person_id, job, salary) values ('p-000040', 'c_helper', 35000);
INSERT INTO staff (person_id, job, salary) values ('p-000044', 'c_helper', 35000);
INSERT INTO staff (person_id, job, salary) values ('p-000042', 'cashier', 45000);
INSERT INTO staff (person_id, job, salary) values ('p-000043', 'cashier', 50000);
INSERT INTO staff (person_id, job, salary) values ('p-000047', 'cashier', 44500);
INSERT INTO staff (person_id, job, salary) values ('p-000046', 'gate_guard', 25500);
INSERT INTO staff (person_id, job, salary) values ('p-000045', 'gate_guard', 29900);

INSERT INTO COUNTER (counter_id, counter_login_id, counter_pass) VALUES ('C-01', 'COUNTER-01', 'admin');
INSERT INTO COUNTER (counter_id, counter_login_id, counter_pass) VALUES ('C-02', 'COUNTER-02', 'admin');
INSERT INTO COUNTER (counter_id, counter_login_id, counter_pass) VALUES ('C-03', 'COUNTER-03', 'admin');

-- THESE LINES WILL ADD TOTAL 5 ROWS (with id 1-5) and 5 racks within each row with rack_id (r-(row_id)-(01 to 05))
INSERT INTO "row" (ROW_ALIAS) values ('ROW 1');
-- THESE LINES WILL ADD 10 racks in row 1 with id r-1-01 to r-1-10
INSERT INTO RACK (ROW_ID) values (1);
INSERT INTO RACK (ROW_ID) values (1);
INSERT INTO RACK (ROW_ID) values (1);
INSERT INTO RACK (ROW_ID) values (1);
INSERT INTO RACK (ROW_ID) values (1);

INSERT INTO "row" (ROW_ALIAS) values ('ROW 2');
INSERT INTO RACK (ROW_ID) values (2);
INSERT INTO RACK (ROW_ID) values (2);
INSERT INTO RACK (ROW_ID) values (2);
INSERT INTO RACK (ROW_ID) values (2);
INSERT INTO RACK (ROW_ID) values (2);

INSERT INTO "row" (ROW_ALIAS) values ('ROW 3');
INSERT INTO RACK (ROW_ID) values (3);
INSERT INTO RACK (ROW_ID) values (3);
INSERT INTO RACK (ROW_ID) values (3);
INSERT INTO RACK (ROW_ID) values (3);
INSERT INTO RACK (ROW_ID) values (3);

INSERT INTO "row" (ROW_ALIAS) values ('ROW 4');
INSERT INTO RACK (ROW_ID) values (4);
INSERT INTO RACK (ROW_ID) values (4);
INSERT INTO RACK (ROW_ID) values (4);
INSERT INTO RACK (ROW_ID) values (4);
INSERT INTO RACK (ROW_ID) values (4);

INSERT INTO "row" (ROW_ALIAS) values ('ROW 5');
INSERT INTO RACK (ROW_ID) values (5);
INSERT INTO RACK (ROW_ID) values (5);
INSERT INTO RACK (ROW_ID) values (5);
INSERT INTO RACK (ROW_ID) values (5);
INSERT INTO RACK (ROW_ID) values (5);

INSERT INTO CATEGORY (category_name) VALUES ('Beverages');
INSERT INTO CATEGORY (category_name) VALUES ('Snacks and Chocolates');
INSERT INTO CATEGORY (category_name) VALUES ('Health and Beauty');
INSERT INTO CATEGORY (category_name) VALUES ('Frozen');
INSERT INTO CATEGORY (category_name) VALUES ('Cooking Essentials');

--Add products... (5 rows, 5 racks)  -> rack_id (r-(row_id)-(01 to 05))


BEGIN
                  --Beverages
     ADD_PRODUCT('Coffee Cappuccino 200gm', 'Beverages', 1, 350,'Nescafe');
     ADD_PRODUCT('Coffee Choco   50gm', 'Beverages', 1, 100,'Nescafe');
     ADD_PRODUCT('Coffee Vanilla 80gm', 'Beverages', 1, 150,'Nescafe');
     ADD_PRODUCT('Coffee Salted  150gm', 'Beverages', 1, 200,'Nescafe');
     ADD_PRODUCT('Coffee Gold Blend 250gm', 'Beverages', 1, 430,'Nescafe');
     ADD_PRODUCT('Coffee Caramel Ice 150gm', 'Beverages', 1, 360,'Nescafe');

     ADD_PRODUCT('Flavoured Tea 95gm', 'Beverages', 2, 1200,'Lipton');
     ADD_PRODUCT('Tea 150gm', 'Beverages', 2, 300,'Supreme');
     ADD_PRODUCT('Lemon Tea 50gm', 'Beverages', 2, 200,'Danedar');
     ADD_PRODUCT('Tea 300gm', 'Beverages', 2, 600,'Tapal');
     ADD_PRODUCT('Green Tea 100gm', 'Beverages', 2, 400,'Casino');
     ADD_PRODUCT('Tea 600gm', 'Beverages', 2, 1200,'Danedar');
     ADD_PRODUCT('Everyday milk powder 600gm', 'Beverages', 2, 1200,'Nestle');

     ADD_PRODUCT('Strawberry yogurt 100gm', 'Beverages', 3, 400,'Casino');
     ADD_PRODUCT('Juices 500ml', 'Beverages', 3, 400,'Nestle');
     ADD_PRODUCT('Raspberry Juices 500ml', 'Beverages', 3, 1000,'Casino');
     ADD_PRODUCT('Zero cola 100ml', 'Beverages', 3, 300,'Casino');
     ADD_PRODUCT('Peach Flavoured Water 500ml', 'Beverages', 3, 400,'Nestle');
     ADD_PRODUCT('Cocoa drink 500ml', 'Beverages', 3, 700,'Casino');

     ADD_PRODUCT('Soft drinks 1.5L', 'Beverages', 4, 120,'Monster');
     ADD_PRODUCT('Clementine drinks 1L', 'Beverages', 4, 1220,'Carrefour');
     ADD_PRODUCT('Apple nectar juice 200ml', 'Beverages', 4, 320,'Monster');
     ADD_PRODUCT('Grape friut juice 300ml', 'Beverages', 4, 430,'Carrefour');
     ADD_PRODUCT('Lemonade juice 1.5L', 'Beverages', 4, 1450,'Monster');
     ADD_PRODUCT('Calcium almond drink 1L', 'Beverages', 4, 1120,'Monster');

     ADD_PRODUCT('Energy drinks 250ml', 'Beverages', 5, 500,'Red Bull');
     ADD_PRODUCT('Soy drinks 150ml', 'Beverages', 5, 300,'Gourmet');
     ADD_PRODUCT('Maxi multi-fruit 500ml', 'Beverages', 5, 870,'Fruite');
     ADD_PRODUCT('Tang Mango 300gm', 'Beverages', 5, 300,'Red Bull');
     ADD_PRODUCT('Milo Active-Go drinks 375gm', 'Beverages', 5, 300,'Nestle');

                       --Snacks and Chocolates

     ADD_PRODUCT('Kurkure 50gm','Snacks and Chocolates',1,60,'Kurkure');
     ADD_PRODUCT('Popcorn 50gm','Snacks and Chocolates',1,50,'Garden');
     ADD_PRODUCT('Cheetos 110gm','Snacks and Chocolates',1,260,'Ritz');
     ADD_PRODUCT('Kurkure sticks 70gm','Snacks and Chocolates',1,80,'Kurkure');

     ADD_PRODUCT('Cheese balls 120gm','Snacks and Chocolates',2,360,'Fritos');
     ADD_PRODUCT('Potato Sticks 90gm','Snacks and Chocolates',2,130,'Wheat Thins');
     ADD_PRODUCT('Salanty 60gm','Snacks and Chocolates',2,80,'Doritos');
     ADD_PRODUCT('Snackers 50gm','Snacks and Chocolates',2,65,'Wheat Thins');

     ADD_PRODUCT('Karneez 70gm','Snacks and Chocolates',3,80,'Kurkure');
     ADD_PRODUCT('Lays 80gm','Snacks and Chocolates',3,90,'Lays');
     ADD_PRODUCT('Wavy 50gm','Snacks and Chocolates',3,60,'Ritz');
     ADD_PRODUCT('Granola bars 45gm','Snacks and Chocolates',3,160,'Doritos');

     ADD_PRODUCT('Spicy jalapeno 110gm','Snacks and Chocolates',4,230,'Kurkure');
     ADD_PRODUCT('potato pringles 90gm','Snacks and Chocolates',4,120,'Ritz');
     ADD_PRODUCT('chatty chins 70gm','Snacks and Chocolates',4,80,'Wheat Thins');
     ADD_PRODUCT('peanuts 120gm','Snacks and Chocolates',4,200,'Doritos');

     ADD_PRODUCT('Nimko Mix 30gm','Snacks and Chocolates',5,40,'Ritz');
     ADD_PRODUCT('Seaweed Snacks 200gm','Snacks and Chocolates',5,340,'Doritos');
     ADD_PRODUCT('Karleez 50gm','Snacks and Chocolates',5,70,'Wheat Thins');

                      -- Health and Beauty

     ADD_PRODUCT('Men face wash 160ml','Health and Beauty',1,499,'WBM');
     ADD_PRODUCT('Men facial cream 50ml','Health and Beauty',1,222,'Clear \& Clean');
     ADD_PRODUCT('Men hair Shampoo 160gm','Health and Beauty',1,890,'Panteen');

     ADD_PRODUCT('Body lotion 150gm','Health and Beauty',2,999,'Dove');
     ADD_PRODUCT('Charcoal 50gm','Health and Beauty',2,170,'Garnier');
     ADD_PRODUCT('Hair dyer 50gm','Health and Beauty',2,340,'Loreal');

     ADD_PRODUCT('face wash 80ml','Health and Beauty',3,370,'Nivea');
     ADD_PRODUCT('Rose water 120ml','Health and Beauty',3,100,'WBM');
     ADD_PRODUCT('Niacinamide Powder 20gm','Health and Beauty',3,1970,'The Ordinary');

     ADD_PRODUCT('Wrinkle Repair Serum 29ml','Health and Beauty',4,4800,'Neutrogena');
     ADD_PRODUCT(' Aloe Vera For Oily Skin 150ml','Health and Beauty',4,1170,'Neutrogena');
     ADD_PRODUCT('Facial Foam 100gm','Health and Beauty',4,710,'Ponds');

     ADD_PRODUCT('Vitamin C Silicone 30ml','Health and Beauty',5,3320,'The Ordinary');
     ADD_PRODUCT('Rose Face Gel 30ml','Health and Beauty',5,340,'Bold');
     ADD_PRODUCT('Men Anti Dullness Face Scrub 100gm','Health and Beauty',5,2570,'WBM');
     ADD_PRODUCT('face wash Serum 50gm','Health and Beauty',5,1770,'WBM');


                      --Frozen

     ADD_PRODUCT('Ice Cream choco 700gm', 'Frozen', 1, 1315, 'Hico');
     ADD_PRODUCT('Ice Cream mango 500gm', 'Frozen', 1, 715, 'Walls');
     ADD_PRODUCT('Ice Cream coconut 400gm', 'Frozen', 1, 455, 'Movenpick');
     ADD_PRODUCT('Ice Cream vanilla 600gm', 'Frozen', 1, 765, 'Gelato');
     ADD_PRODUCT('Ice Cream strawberry 800gm', 'Frozen', 1, 980, 'popcycle');

     ADD_PRODUCT('Sekh Kabab 245gm', 'Frozen', 2, 435, 'Sabroso');
     ADD_PRODUCT('Chicken Kofta 672gm', 'Frozen', 2, 710, 'National');
     ADD_PRODUCT('Chicken Nuggets 1500gm', 'Frozen', 2, 1275, 'National');
     ADD_PRODUCT('Paratha 45gm', 'Frozen', 2, 100, 'Sabroso');
     ADD_PRODUCT('Roti  75gm', 'Frozen', 2, 150, 'Sabroso');
     ADD_PRODUCT('Naan 60gm', 'Frozen', 2, 175, 'Menu');

     ADD_PRODUCT('Samosa 100gm','Frozen',3,400,'National ');
     ADD_PRODUCT('Rolls 120gm ','Frozen',3,500,'Shangrilla ');
     ADD_PRODUCT('Snacks 200gm','Frozen',3,600,'Knoor ');
     ADD_PRODUCT('Meat 700gm','Frozen',3,1400,'Sabroso ');
     ADD_PRODUCT('Chicken Patties 300gm','Frozen',3,1200,'Big Bird ');

     ADD_PRODUCT('Beef Chapli kabab 300gm ','Frozen',4,1200,'National');
     ADD_PRODUCT('French Fries 200gm ','Frozen',4,800,' Shangrilla');
     ADD_PRODUCT('Lahori fried fish 450gm','Frozen',4,1500,'Menu');
     ADD_PRODUCT('Chicken tempora 510gm','Frozen',4,1640,' Sabroso');
     ADD_PRODUCT('Grilled chicken fillet 600gm','Frozen',4,2000,'Big Bird');

     ADD_PRODUCT('Jumbo Prawns 400gm','Frozen',5,400,'Sabroso');
     ADD_PRODUCT('Chicken leg tikka 200gm ','Frozen',5,400,'Menu');
     ADD_PRODUCT('beef gola kabab 500gm ','Frozen',5,400,'National');
     ADD_PRODUCT('Cheese balls gm','Frozen',5,400,'Big Bird');
     ADD_PRODUCT('Chicken shots 300gm ','Frozen',5,400,'Sabroso ');

                          --Cooking Essentials

     ADD_PRODUCT('Olive oil 1L','Cooking Essentials',1,1500,'Dalda');
     ADD_PRODUCT('Nihari receipe mix 112gm','Cooking Essentials',1,140,'National');
     ADD_PRODUCT('Hot sauce 300gm','Cooking Essentials',1,270,'Dippit');
     ADD_PRODUCT('Cooking Oil','Cooking Essentials',1,500,'Dalda');

     ADD_PRODUCT('Corn flour 500mg','Cooking Essentials',2,137,'N and L');
     ADD_PRODUCT('Shami kabab masala 500mg','Cooking Essentials',2,400,'Shan');
     ADD_PRODUCT('Pasta 500mg','Cooking Essentials',2,300,'Arbella');
     ADD_PRODUCT('Synthetic vinegar 200ml','Cooking Essentials',2,500,'Italia');

     ADD_PRODUCT('Plane olives 200gm','Cooking Essentials',3,700,'Italia');
     ADD_PRODUCT('Rock Salt 200gm','Cooking Essentials',3,150,'National');
     ADD_PRODUCT('Ginger powder 400gm','Cooking Essentials',3,1200,'Himaliyan');
     ADD_PRODUCT('Spaghetti 150gm','Cooking Essentials',3,500,'Arbella');

     ADD_PRODUCT('Biryani masala 80gm','Cooking Essentials',4,200,'Taj');
     ADD_PRODUCT('Seekh kabab masala 70gm','Cooking Essentials',4,210,'Arbella');
     ADD_PRODUCT('Chilli Garlic sauce 200gm','Cooking Essentials',4,310,'Italia');
     ADD_PRODUCT('Multigrain flour 800gm','Cooking Essentials',4,2500,'Himaliyan');

     ADD_PRODUCT('Mango pickle 140gm','Cooking Essentials',5,755,'National');
     ADD_PRODUCT('Corriandar powder 100gm','Cooking Essentials',5,100,'Arbella');
     ADD_PRODUCT('Canola Oil','Cooking Essentials',5,3500,'Italia');
     ADD_PRODUCT('Apple Vineger','Cooking Essentials',5,3700,'Himaliyan');
end;
/

BEGIN
    generate_purchases();
    generate_purchases();
    GENERATE_ORDERS(50);
    generate_staff_attendance();
end;
/
