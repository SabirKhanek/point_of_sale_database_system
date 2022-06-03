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

@4_pos_db_populate_tables