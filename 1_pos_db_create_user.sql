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

@2_pos_db_ddl