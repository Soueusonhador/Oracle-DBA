create TABLESPACE TBUSERS
DATAFILE 'C:\app\oracle\oradata\TBUSERS_01.dbf' 
SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 500M;



CREATE user ariel IDENTIFIED BY arielcobra
DEFAULT TABLESPACE TBUSERS

CREATE user guilherme IDENTIFIED BY guilhermecobra
DEFAULT TABLESPACE TBUSERS

GRANT create session, alter session, create table, create view to ariel;
GRANT create session, alter session, create table, create view to guilherme;

CREATE user regg IDENTIFIED BY regnier
DEFAULT TABLESPACE TBUSERS

GRANT create session, alter session, create table, create view to regg;