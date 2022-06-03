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

@3_pos_db_procedures_and_triggers