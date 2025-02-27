
--            SQL SCRIPT ORDER
--            ****************
--            1.) Create Tables
--            2.) Add Constraints
--            3.) Insert Data
--            4.) Procedures
--            5.) Triggers
--            6.) Create Users & Roles
--
--  DIRECTIONS: Log in as SYSTEM and run script.
--  All users are Common users, so set container 
--  to CDB$ROOT before running the script.
-- -------------------------------------------------
-- 
--               DROP STATEMENTS
--
--     EXECUTING IN CASE ANY OBJECTS PRE-EXIST ON THE
--          SYSTEM PRIOR TO RUNNING SCRIPT.
--     ERRORS ARE EXPECTED TO APPEAR IF THE OBJECTS
--           DO NOT PRE-EXIST ON THE SYSTEM.
--
-- -------------------------------------------------
DROP TABLE EXCEPTIONS cascade constraints PURGE;
DROP TABLE USERS cascade constraints PURGE;
DROP TABLE TRANSACTIONS cascade constraints PURGE;
DROP TABLE KIOSKS cascade constraints PURGE;
DROP TABLE BOOKS cascade constraints PURGE;

DROP ROLE C##STUDENTS;
DROP ROLE C##EMPLOYEES;
DROP ROLE C##EMPLOYEES2;

DROP PROFILE C##LOGIN_FAIL CASCADE;

DROP USER C##SBROWN;
DROP USER C##SBASS;
DROP USER C##LMILLER;
DROP USER C##MTHOMAS;
DROP USER C##LCLARK;
DROP USER C##MLAMB;I

DROP PROCEDURE BOOKSEARCHISBN;
DROP PROCEDURE BOOKSEARCHTITLE;
DROP PROCEDURE CHECK_IN_BOOK;
DROP PROCEDURE CHECK_OUT_BOOK;
DROP PROCEDURE UPDATE_BOOK_KIOSKS;
DROP PROCEDURE DROP_USER;
DROP PROCEDURE SEARCH_TRANSACTIONS;
DROP PROCEDURE SEARCH_USERS;
DROP PROCEDURE SET_CONTEXT;

DROP FUNCTION SECURITY_FUNCTION;
DROP FUNCTION SECURITY_FUNCTION2;

DROP TRIGGER ON_LOGON;
DROP CONTEXT CONTEXT_VPD;
 
-- DROP Virtual Private Database Policies
BEGIN 
dbms_rls.drop_policy(object_schema => 'system', 
object_name => 'USERS', 
policy_name => 'users_policy'); 
END; 
/ 
BEGIN 
dbms_rls.drop_policy(object_schema => 'system', 
object_name => 'TRANSACTIONS', 
policy_name => 'transactions_policy'); 
END; 
/ 
-- -------------------------------------------------
-- 
--            CREATE TABLES
--
-- -------------------------------------------------
CREATE TABLE USERS (
   USER_ID         INT GENERATED ALWAYS AS IDENTITY (START WITH 100001 INCREMENT BY 1)  NOT NULL,
   USER_FIRSTNAME  VARCHAR2(15),
   USER_LASTNAME   VARCHAR2(15),
   USER_EMAIL      VARCHAR2(30),
   USER_PHONE      VARCHAR2(15),
   USER_PASSWORD   VARCHAR2(15),
   USER_TYPE       VARCHAR2(10), 
   USER_PROFILE    VARCHAR2(10),
   USERNAME        VARCHAR2(15)
);   
CREATE TABLE BOOKS (
   ISBN            VARCHAR2(20) NOT NULL,
   TITLE           VARCHAR2(100),
   YEAR            INT,
   BOOK_TYPE       VARCHAR2(9),
   MSRP            DECIMAL(9,2),
   PUBLISHER       VARCHAR2(100),
   PUBLISHED_DATE  DATE,
   AUTHOR_NAME     VARCHAR2(100)
);
CREATE TABLE KIOSKS (
   KIOSK_ID        VARCHAR2(10) NOT NULL,
   KIOSK_LOC       VARCHAR2(50),
   BOOK_ISBN       VARCHAR2(20) NOT NULL,
   BOOK_QTY        INT,
   CTRL_USER       VARCHAR2(25)
);
CREATE TABLE TRANSACTIONS (
   TRNS_ID          INT GENERATED ALWAYS AS IDENTITY (START WITH 300001 INCREMENT BY 1) NOT NULL,
   TRNS_TIMESTAMP   TIMESTAMP,
   TRNS_ISBN        VARCHAR2(20),
   KIOSK_ID         VARCHAR2(10),
   USER_ID          INT, 
   DUE_DATE         DATE, 
   RETURN_DATE      DATE,
   STATUS           VARCHAR2(25),
   KIOSK_LOC        VARCHAR2(50),
   CTRL_USER        VARCHAR2(25)
 );
CREATE TABLE EXCEPTIONS (
   FLAG_ID          INT GENERATED ALWAYS AS IDENTITY (START WITH 500001 INCREMENT BY 1) NOT NULL,
   FLAG_DESC        VARCHAR2(20),
   TRNS_ID          INT NOT NULL,
   USER_ID          INT NOT NULL,
   USER_FEE         DECIMAL(9,2),
   CTRL_USER        VARCHAR2(25)
);

-- ---------------------------------------
--
--         ADD TABLE CONSTRAINTS
--
-- ---------------------------------------
ALTER TABLE USERS ADD CONSTRAINT USERS_PK PRIMARY KEY (USER_ID);
ALTER TABLE BOOKS ADD CONSTRAINT BOOK_PK PRIMARY KEY (ISBN);

ALTER TABLE KIOSKS ADD CONSTRAINT KIOSKS_PK PRIMARY KEY (KIOSK_ID, BOOK_ISBN);
ALTER TABLE KIOSKS ADD CONSTRAINT LOCATION_NN CHECK (KIOSK_LOC IS NOT NULL);


ALTER TABLE TRANSACTIONS ADD CONSTRAINT TRNS_PK PRIMARY KEY (TRNS_ID);
ALTER TABLE TRANSACTIONS ADD CONSTRAINT TRNS_FK1 FOREIGN KEY (TRNS_ISBN) REFERENCES BOOKS (ISBN);
ALTER TABLE TRANSACTIONS ADD CONSTRAINT TRNS_FK3 FOREIGN KEY (USER_ID) REFERENCES USERS (USER_ID);

--ALTER TABLE KIOSKS ADD CONSTRAINT KIOSK_FK FOREIGN KEY (BOOK_ISBN) REFERENCES BOOKS (ISBN);
--ALTER TABLE TRANSACTIONS ADD CONSTRAINT TRNS_FK2 FOREIGN KEY (KIOSK_ID, TRNS_ISBN) REFERENCES KIOSKS (KIOSK_ID, BOOK_ISBN);

ALTER TABLE EXCEPTIONS ADD CONSTRAINT FLAG_PK PRIMARY KEY (FLAG_ID);
ALTER TABLE EXCEPTIONS ADD CONSTRAINT FLAG_FK FOREIGN KEY (TRNS_ID) REFERENCES TRANSACTIONS (TRNS_ID);

CREATE INDEX USERS_INDEX ON USERS (USER_PROFILE, USER_TYPE);
CREATE INDEX BOOKS_INDEX ON BOOKS (TITLE, YEAR, BOOK_TYPE);
CREATE INDEX KIOSKS_INDEX ON KIOSKS (KIOSK_LOC, BOOK_QTY, CTRL_USER);
CREATE INDEX TRANSACTIONS_INDEX ON TRANSACTIONS (TRNS_TIMESTAMP, DUE_DATE, RETURN_DATE, STATUS, CTRL_USER);
CREATE INDEX EXCEPTIONS_INDEX ON EXCEPTIONS (FLAG_DESC, USER_FEE, CTRL_USER);

CREATE INDEX KIOSKS_IFK ON KIOSKS (BOOK_ISBN);
CREATE INDEX TRANS_IFK1 ON TRANSACTIONS (TRNS_ISBN);
CREATE INDEX TRANS_IFK2 ON TRANSACTIONS (KIOSK_ID);
CREATE INDEX TRANS_IFK3 ON TRANSACTIONS (USER_ID);
CREATE INDEX EXCEPTIONS_IFK ON EXCEPTIONS (TRNS_ID);


-- ---------------------------------------
--
--        INSERT DATA INTO TABLES
--
-- ---------------------------------------
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##MTHOMAS', 'MICHAEL', 'THOMAS', 'MTHOMAS@STUDENTS.KSU.EDU', '555-11-1234', 'APPLES_01', 'STUDENT', 'USER');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##LMILLER', 'LAURA', 'MILLER', 'LMILLER@STUDENTS.KSU.EDU', '555-22-1234', 'ORANGES_01', 'STUDENT', 'USER');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##JBAKER', 'JASMINE', 'BAKER', 'JBAKER@STUDENTS.KSU.EDU', '555-33-1234', 'BANANAS_01', 'STUDENT', 'USER');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##JCLARK', 'JOSHUA', 'CLARK', 'JCLARK@STUDENTS.KSU.EDU', '555-44-1234', 'GRAPES_01', 'STUDENT', 'USER');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##SBROWN', 'SHARON', 'BROWN', 'SBROWN@STUDENTS.KSU.EDU', '555-55-1234', 'PEACHES_01', 'STUDENT', 'USER');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##LCLARK', 'LUKE', 'CLARK', 'LC@FACULTY.KSU.EDU', '555-12-3456',  'CORN_123', 'EMPLOYEE', 'ADMIN');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('C##ADODD', 'ALBERT', 'DODD', 'AD@FACULTY.KSU.EDU', '555-22-2222',  'PIZZA_123', 'EMPLOYEE', 'USER');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('SBASS', 'SAVANNAH', 'BASS', 'SB@FACULTY.KSU.EDU', '555-66-6666', 'PEANUTS_123', 'EMPLOYEE', 'ADMIN');
INSERT INTO USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE)
VALUES ('BDODD', 'BRANDON', 'DODD', 'BD@FACULTY.KSU.EDU', '555-77-7777', 'CHICKEN_123', 'EMPLOYEE', 'USER');

INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('CAFE123', 'MARIETTA', '787-0-31-1234', 15, '');
INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('POLY123', 'MARIETTA', '934-0-43-1234', 3, '');
INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('MAIN123', 'KENNESAW', '012-9-22-1234', 15, '');
INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('MAIN123', 'MARIETTA', '817-1-24-1234', 20, '');
INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('CAFE123', 'MARIETTA', '987-0-12-1234', 0, '');
INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('POLY123', 'MARIETTA', '999-1-89-1234', 2, '');
INSERT INTO KIOSKS (KIOSK_ID, KIOSK_LOC,  BOOK_ISBN, BOOK_QTY, CTRL_USER)
VALUES ('POLY123', 'MARIETTA', '679-2-21-1234', 21, '');

INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('987-0-12-1234', 'TO KILL A MOCKINGBIRD', 1990, 'NEW', 21.99, 'WESTINGHOUSE', '18-MAY-2020', 'HARPER LEE');
INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('012-9-22-1234', 'IRONMAN', 2009, 'NEW', 21.99, 'MARVEL PUBLISHING', '06-MAY-2009', 'CAPTAIN AMERICA');
INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('817-1-24-1234', 'BECOMING', 2019, 'NEW', 29.99, 'NEW WORLD BOOKS', '11-APR-2019', 'MICHELLE OBAMA');
INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('787-0-31-1234', 'THE GRAPES OF WRATH', 2010, 'NEW', 17.99,'PAPERBACK BOOKS', '10-JUN-2007', 'JOHN STEINBECK');
INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('679-2-21-1234', 'BRAVE NEW WORLD', 2011, 'USED', 22.99, 'INK PUBLISHING', '09-AUG-2011', 'ALDOUS HUXLEY');
INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('934-0-43-1234', 'LORD OF THE FLIES',  1988, 'USED', 19.99,  'STARLIGHT', '19-OCT-2010', 'WILLIAM GOLDING');
INSERT INTO BOOKS (ISBN, TITLE, YEAR, BOOK_TYPE, MSRP, PUBLISHER, PUBLISHED_DATE, AUTHOR_NAME)
VALUES ('999-1-89-1234', 'PRIDE AND PREJUDICE', 2002, 'NEW', 29.99,  'G M PUBLISHING', '21-APR-2003', 'JANE AUSTEN');


INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('17-OCT-19 09:32:32', '817-1-24-1234', 'MAIN123', 100002, '17-NOV-19', '25-NOV-19', 'RETURNED', 'KENNESAW', 'C##LMILLER');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('01-DEC-19 08:31:32', '999-1-89-1234', 'POLY123', 100004, '01-JAN-20', '11-DEC-19', 'RETURNED', 'MARIETTA', 'C##JCLARK');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('12-JAN-20 05:11:22', '934-0-43-1234', 'POLY123', 100001, '12-FEB-20', '07-FEB-20', 'RETURNED', 'MARIETTA', 'C##MTHOMAS');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('07-MAR-20 07:21:32', '787-0-31-1234', 'CAFE123', 100004, '07-APR-20', '01-APR-20', 'RETURNED', 'MARIETTA', 'C##JCLARK');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('13-APR-20 03:13:17', '679-2-21-1234', 'POLY123', 100003, '13-MAY-20', '', 'OVERDUE', 'MARIETTA', 'C##JBAKER');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('30-APR-20 09:13:17', '679-2-21-1234', 'POLY123', 100001, '30-MAY-20', '', 'OVERDUE', 'MARIETTA', 'C##MTHOMAS');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('08-MAY-20 07:30:32', '012-9-22-1234', 'MAIN123', 100002, '08-JUN-20', '', 'CHECKED OUT', 'KENNESAW', 'C##LMILLER');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('08-MAY-20 07:32:32', '817-1-24-1234', 'MAIN123', 100002, '08-JUN-20', '', 'CHECKED OUT', 'KENNESAW', 'C##LMILLER');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('12-JUN-20 05:11:22', '817-1-24-1234', 'MAIN123', 100001, '12-JUL-20', '', 'CHECKED OUT', 'KENNESAW', 'C##MTHOMAS');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('01-JUN-20 02:38:32', '817-1-24-1234', 'MAIN123', 100005, '01-JUL-20', '', 'CHECKED OUT', 'KENNESAW', 'C##SBROWN');
INSERT INTO TRANSACTIONS (TRNS_TIMESTAMP, TRNS_ISBN, KIOSK_ID, USER_ID, DUE_DATE, RETURN_DATE, STATUS, KIOSK_LOC, CTRL_USER)
VALUES ('07-JUL-20 02:38:32', '787-0-31-1234', 'CAFE123', 100005, '07-AUG-20', '', 'CHECKED OUT', 'MARIETTA', 'C##SBROWN');


INSERT INTO EXCEPTIONS (FLAG_DESC, TRNS_ID, USER_ID, USER_FEE, CTRL_USER)
VALUES ('OVERDUE', 300005, 100003, 5.00, 'C##JBAKER' ); 
INSERT INTO EXCEPTIONS (FLAG_DESC, TRNS_ID, USER_ID, USER_FEE, CTRL_USER)
VALUES ('OVERDUE', 300007, 100002,  5.00, 'C##LMILLER'); 

-- ---------------------------------------
--
-- CONTEXT: CONTEXT FOR VPD
--
-- ---------------------------------------
Create or Replace context context_vpd using set_context; 

-- -------------------------------------------
--
--  PROCEDURE: SET CONTEXT
--
-- -------------------------------------------
Create or Replace Procedure set_context  
AS  
BEGIN  
   dbms_session.set_context( 'context_vpd', 'session_user', user);  
END; 
/ 

-- ---------------------------------------
--
-- TRIGGER: LOGON SET CONTEXT FOR VPD
--
-- ---------------------------------------
Create or Replace Trigger on_logon  
After logon on database  
BEGIN  
   set_context;  
END;  
/ 

-- ---------------------------------------
--
--  PROCEDURE: BOOK SEARCH BY ISBN
--
-- ---------------------------------------
Create or replace PROCEDURE BookSearchISBN(INPUTISBN VARCHAR2)
AUTHID DEFINER
IS
    temp0 VARCHAR2(30); 
    temp1 VARCHAR2(30);
    temp2 INT;
    temp3 VARCHAR2(30);
    temp4 VARCHAR2(30);
    temp5 INT;
    USEREXIST INT DEFAULT 0;
    THIS_USER  VARCHAR2(50);
BEGIN 

SELECT  COUNT(*)
    INTO USEREXIST
    FROM SYSTEM.USERS A,
         SYS.V_$SESSION B
   WHERE A.USERNAME = B.USERNAME
      AND B.SID = SYS_CONTEXT('USERENV','SID');

IF USEREXIST = 0 THEN
 dbms_output.put_line
 ('*** YOU ARE NOT A REGISTERED USER FOR THE KSU BOOKSTORE DATABASEE!***'
 || u'\000A'|| ' '
 || u'\000A'||
 'Please register to the KSU Library Database to gain search access to Kiosks'
 );
ELSE
SELECT
    A.ISBN,
    A.TITLE,
    A.YEAR,
    A.BOOK_TYPE,   
    A.AUTHOR_NAME, 
    B.BOOK_QTY  
INTO temp0,
     temp1,
     temp2,
     temp3,
     temp4,
     temp5
FROM BOOKS  A
   , KIOSKS B
WHERE A.ISBN = INPUTISBN
  AND A.ISBN = B.BOOK_ISBN
;

IF temp0 = INPUTISBN and temp5 > 0 THEN
   dbms_output.put_line
   ('*** WELCOME TO KSU BOOK KIOSK!***'
    || u'\000A'|| ' '
    || u'\000A'||
    'Your book search returned ther following results:' 
    || u'\000A'|| ' '
    || u'\000A'||
    'ISBN: ' || temp0 ||' '
    || u'\000A'||
    'Book Title: ' || temp1 ||' ' 
    || u'\000A'||
    'Author Name: ' || temp4 ||' '
    || u'\000A'||
    'Quantity available for checkout: ' || temp5 || ' ' 
    || u'\000A'|| ' '
    || u'\000A'||
    'This book is available for checkout!'
   );
END IF;
IF temp0 = INPUTISBN and temp5 = 0 THEN
   dbms_output.put_line
   ('*** WELCOME TO KSU BOOK KIOSK!***'
    || u'\000A'|| ' '
    || u'\000A'||
    'Your book search returned ther following results:'
    || u'\000A'|| ' '
    || u'\000A'||
    'ISBN:' || temp0 ||' '
    || u'\000A'||
    'Book Title:' || temp1 ||' ' 
    || u'\000A'||
    'Author Name:' || temp4 ||' '
    || u'\000A'||
    'Quantity available for checkout: ' || temp5 || ' ' 
    || u'\000A'|| ' '
    || u'\000A'||
    'This book is NOT available for checkout. Check back another time for availability!'
   );
END IF;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   dbms_output.put_line
   ('*** WELCOME TO KSU BOOK KIOSK!***'
    || u'\000A'|| ' '
    || u'\000A'||
   'The ISBN "' || INPUTISBN || '" does not exist in the KSU Library System');
END;
/

-- ---------------------------------------
--
--  PROCEDURE: BOOK SEARCH BY TITLE
--
-- ---------------------------------------
Create or replace PROCEDURE BookSearchTitle(INPUTTITLE VARCHAR2)
AUTHID DEFINER
IS
    temp0 VARCHAR2(30); 
    temp1 VARCHAR2(30);
    temp2 INT;
    temp3 VARCHAR2(30);
    temp4 VARCHAR2(30);
    temp5 INT;
    USEREXIST INT;
    THIS_USER  VARCHAR2(50);

BEGIN 

SELECT  COUNT(*)
    INTO USEREXIST
    FROM SYSTEM.USERS A,
         SYS.V_$SESSION B
   WHERE A.USERNAME = B.USERNAME
      AND B.SID = SYS_CONTEXT('USERENV','SID');

IF USEREXIST = 0 THEN
 dbms_output.put_line
 ('*** YOU ARE NOT A REGISTERED USER FOR THE KSU BOOKSTORE DATABASEE!***'
 || u'\000A'|| ' '
 || u'\000A'||
 'Please register to the KSU Library Database to gain search access to Kiosks'
 );

ELSE
SELECT
    A.ISBN,
    A.TITLE,
    A.YEAR,
    A.BOOK_TYPE,   
    A.AUTHOR_NAME, 
    B.BOOK_QTY  
INTO temp0,
     temp1,
     temp2,
     temp3,
     temp4,
     temp5
FROM BOOKS  A
   , KIOSKS B
WHERE A.TITLE = INPUTTITLE
  AND A.ISBN = B.BOOK_ISBN
;

IF temp1 = INPUTTITLE and temp5 > 0 THEN
   dbms_output.put_line
   ('***WELCOME TO KSU BOOK KIOSK!***'
    || u'\000A'|| ' '
    || u'\000A'||
    'Your book search returned the following results:'
    || u'\000A'|| ' '
    || u'\000A'||
    'ISBN: ' || temp0
    || u'\000A'|| 
    'Book Title: ' || temp1
     || u'\000A'|| 
    'Author Name: ' || temp4
     || u'\000A'|| 
    'Quantity available for checkout: ' || temp5
     || u'\000A'|| ' '
     || u'\000A'||
    'This book is available for checkout!'
   );
END IF;
IF temp1 = INPUTTITLE and temp5 = 0 THEN
   dbms_output.put_line
   ('*** WELCOME TO KSU BOOK KIOSK!***'
    || u'\000A'|| ' '
    || u'\000A'||
    'Your book search returned the following results:'
    || u'\000A'|| ' '
    || u'\000A'||
    'ISBN: ' || temp0
    || u'\000A'|| 
    'Book Title: ' || temp1
     || u'\000A'|| 
    'Author Name: ' || temp4
     || u'\000A'|| 
    'Quantity available for checkout: ' || temp5
     || u'\000A'|| ' '
     || u'\000A'||
    'This book is NOT available for checkout Check back another time for availability!'
   );
END IF;
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
   dbms_output.put_line
   ('*** WELCOME TO KSU BOOK KIOSK!***'
    || u'\000A'|| ' '
    || u'\000A'||
     'The book title "' || INPUTTITLE || '" does not exist in the KSU Library System');
END;
/

-- ---------------------------------------
--
--  PROCEDURE: CHECK OUT A BOOK
--
-- ---------------------------------------
create or replace PROCEDURE CHECK_OUT_BOOK(IN_USERID INT, IN_ISBN VARCHAR2) 
IS 
    tempCNT INT DEFAULT 0; 
    tempUSER INT; 
    tempFEE NUMBER; 
    RETDATE DATE DEFAULT SYSDATE+30; 
    LOCATION VARCHAR(20); 
BEGIN 
SELECT 
      COUNT(*), 
      USER_ID, 
      USER_FEE 
INTO  tempCNT, tempUSER, tempFEE 
FROM  EXCEPTIONS 
WHERE USER_ID = IN_USERID 
  AND USER_FEE > 0 
GROUP BY USER_ID, USER_FEE 
; 

-- PL/SQL or SQL statements will Check if the input User has an outstanding Fee. 
IF tempCNT > 0 THEN 
   dbms_output.put_line     
   ('***ATTENTION***   ***ATTENTION***    ***ATTENTION***' 
    || u'\000A'|| 
    'You currently have a library fee of $' || tempFEE || '.' 
    || u'\000A'||' ' 
    || u'\000A'|| 
    'Your ability to check out books have been suspended at this time!' 
    || u'\000A'|| 
    'Please pay this fee in full to restore your library check-out privileges.' 
    || u'\000A'|| ' ' 
    || u'\000A'|| 
    'Thank You!!!') ; 
END IF; 

-- PL/SQL or SQL statements will insert system generated transaction after each check out Only If Book Available. 
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
DECLARE 
    tempKIOSK VARCHAR2(10);  
    tempQTY INT DEFAULT 0; 
    tempTITLE VARCHAR2(100); 
    tempAUTHOR VARCHAR2(100); 
    NEWQTY INT DEFAULT TEMPQTY - 1; 
BEGIN 
SELECT 
      A.KIOSK_ID, 
      A.BOOK_QTY, 
      B.TITLE, 
      B.AUTHOR_NAME, A.KIOSK_LOC 
INTO  tempkiosk, tempQTY, tempTITLE, tempAUTHOR, LOCATION 
FROM  KIOSKS A, 
      BOOKS  B 
WHERE A.BOOK_ISBN = IN_ISBN 
  AND A.BOOK_ISBN = B.ISBN 
; 
IF tempQTY > 0 THEN  
   INSERT INTO TRANSACTIONS(  
            TRNS_TIMESTAMP,  
            TRNS_ISBN,  
            KIOSK_ID,   
            USER_ID,  
            DUE_DATE,  
            RETURN_DATE, 
            STATUS,  
            KIOSK_LOC,
            CTRL_USER
         )      
        VALUES(  
            SYSTIMESTAMP, 
            IN_ISBN, 
            tempKIOSK, 
            IN_USERID, 
            RETDATE, 
            '', 
            'CHECKED OUT',  
            LOCATION,
            SYS_CONTEXT('USERENV', 'SESSION_USER')
             ); 
   UPDATE KIOSKS 
    SET BOOK_QTY = BOOK_QTY-1 
    WHERE KIOSK_ID = tempKIOSK  
      AND BOOK_ISBN = IN_ISBN 
      ;  
   dbms_output.put_line     
   ('YOUR CHECKOUT IS COMPLETE!' 
    || u'\000A'|| ' ' 
    || u'\000A'|| 
    'Below is your Transaction Receipt:' 
    || u'\000A'|| ' ' 
    || u'\000A'|| 
    'Book ISBN: ' || IN_ISBN 
    || u'\000A'||  
    'Book Title: ' || tempTITLE 
     || u'\000A'||  
    'Author Name: ' || tempAUTHOR 
     || u'\000A'||  
    'Checkout Date: ' || SYSDATE 
     || u'\000A'|| 
    'Return Date: ' || RETDATE 
     || u'\000A'|| ' ' 
     || u'\000A'|| 
    'NOTE: There is a flat rate $5.00 late fee for any books returned past the due date.' 
     || u'\000A'|| ' ' 
     || u'\000A'|| 
    'Thank You for visiting the KSU Bookstore!!!') ; 
END IF; 
EXCEPTION 
WHEN NO_DATA_FOUND THEN 
   dbms_output.put_line 
   ('*** WELCOME TO THE KSU BOOK KIOSK!***' 
    || u'\000A'||' ' 
    || u'\000A'|| 
   'The book ISBN "' || IN_ISBN || '" is not available for checkout.' 
    || u'\000A'|| 
    'Please check back at a later date for book availability.' 
    || u'\000A'|| ' ' 
    || u'\000A'|| 
    'Thank You for visiting the KSU Bookstore!!!'); 
END; 
END; 
/ 

-- ---------------------------------------
--
--  PROCEDURE: RETURN A BOOK
--
-- ---------------------------------------
create or replace PROCEDURE CHECK_IN_BOOK(IN_USERID INT, IN_ISBN VARCHAR2)
IS
    tempUSER INT;
    tempTRNS INT;
    tempDUE DATE;
    tempSYSDT DATE DEFAULT to_char(SYSDATE);
    tempNEWDUE DATE DEFAULT to_char(tempDUE);
    tempKIOSK VARCHAR2(10); 
    tempQTY INT DEFAULT 0;
    NEWFEE DECIMAL DEFAULT 5.00;

BEGIN
SELECT
      A.KIOSK_ID,
      A.BOOK_QTY,
      C.USER_ID,
      C.DUE_DATE,
      C.TRNS_ID
INTO  tempkiosk, tempQTY, tempUSER, tempDUE,tempTRNS
FROM  KIOSKS A,
      BOOKS  B,
      TRANSACTIONS C
WHERE A.BOOK_ISBN = IN_ISBN
  AND A.BOOK_ISBN = B.ISBN
  AND A.BOOK_ISBN = TRNS_ISBN
  AND C.USER_ID   = IN_USERID
  AND C.TRNS_ISBN = IN_ISBN
  AND C.STATUS    = 'CHECKED OUT'
;

IF tempSYSDT <= tempDUE THEN
   dbms_output.put_line    
   ('Your book return has completed successfully!' 
    || u'\000A'||' '
    || u'\000A'||'  Book Due Date: ' ||tempDUE|| ' '
    || u'\000A'||'  Book Return Date: ' ||tempSYSDT||' '
    || u'\000A'||' '
    || u'\000A'||
    'Thank You for returning the book on time!!!') ; 

    UPDATE TRANSACTIONS 
    SET RETURN_DATE = SYSDATE
    WHERE USER_ID = IN_USERID
      AND TRNS_ISBN = IN_ISBN
    ; 
    UPDATE TRANSACTIONS 
    SET STATUS = 'RETURNED'
    WHERE USER_ID = IN_USERID 
      AND TRNS_ISBN = IN_ISBN
    ; 
    UPDATE TRANSACTIONS 
    SET TRNS_TIMESTAMP = SYSTIMESTAMP
    WHERE USER_ID = IN_USERID
      AND TRNS_ISBN = IN_ISBN
    ; 
    UPDATE KIOSKS 
    SET BOOK_QTY = BOOK_QTY+1
    WHERE KIOSK_ID = tempKIOSK 
      AND BOOK_ISBN = IN_ISBN
    ; 
END IF;
IF tempSYSDT > tempDUE THEN
   dbms_output.put_line    
   ('*** OVERDUE BOOK ALERT ***'
    || u'\000A'||
    'The book you are returning was Due on ' || tempDUE ||'.' 
    || u'\000A'||
    'You have incurrerd a library fee : $' || NEWFEE || '.00'
    || u'\000A'||
    'Please pay this fee in full to preserve your library privileges.'
    || u'\000A'|| ' '
    || u'\000A'||
    'Thank You!!!') ;
    INSERT INTO EXCEPTIONS( 
           FLAG_DESC, 
           TRNS_ID, 
           USER_ID, 
           USER_FEE 
            )     
     VALUES( 
          'OVERDUE',
           tempTRNS,
           IN_USERID,
           NEWFEE
           );
    UPDATE TRANSACTIONS 
    SET RETURN_DATE = SYSDATE
    WHERE USER_ID = IN_USERID
      AND TRNS_ISBN = IN_ISBN
      ; 
    UPDATE TRANSACTIONS 
    SET STATUS = 'RETURNED'
    WHERE USER_ID = IN_USERID
      AND TRNS_ISBN = IN_ISBN
      ; 
    UPDATE TRANSACTIONS 
    SET TRNS_TIMESTAMP = SYSTIMESTAMP
    WHERE USER_ID = IN_USERID
      AND TRNS_ISBN = IN_ISBN
      ; 
    UPDATE KIOSKS 
    SET BOOK_QTY = BOOK_QTY+1
    WHERE KIOSK_ID = tempKIOSK 
      AND BOOK_ISBN = IN_ISBN
      ;    
END IF;
-- PL/SQL or SQL statements will appear if the ISBN does not have a checkout status in the system.
EXCEPTION
WHEN NO_DATA_FOUND THEN
   dbms_output.put_line    
   ('The book ISBN "' || IN_ISBN || '" is currently not checked out at this KSU Book Kiosk.'
     || u'\000A'|| ' '
     || u'\000A'||
    'Your book return has been rejected.') ;
END;
/

-- -------------------------------------------
--
--  PROCEDURE: UPDATE KIOSK/BOOK INFORMATION
--
-- -------------------------------------------
create or replace PROCEDURE UPDATE_BOOK_KIOSKS(IN_ISBN VARCHAR2, IN_QTY INT)
IS
    tempISBN  VARCHAR2(50);
    tempTITLE VARCHAR2(50);
    tempKID   VARCHAR2(20);
    tempKLOC  VARCHAR2(20);
    tempQTY   INT;
BEGIN
SELECT
      A.ISBN,
      A.TITLE,
      B.KIOSK_ID,
      B.KIOSK_LOC,
      B.BOOK_QTY
INTO  tempISBN, tempTITLE,tempKID,tempKLOC,tempQTY
FROM  BOOKS  A,
      KIOSKS B
WHERE A.ISBN = IN_ISBN
  AND A.ISBN = B.BOOK_ISBN
;

UPDATE KIOSKS
SET BOOK_QTY = BOOK_QTY + IN_QTY
WHERE BOOK_ISBN = IN_ISBN
;
DECLARE
  NEW_QTY INT DEFAULT IN_QTY + TEMPQTY;
BEGIN
-- PL/SQL or SQL statements will Check if the input ISBN Exists and will update the table with user input
   dbms_output.put_line (   
  'Your request to add ' ||IN_QTY|| ' new book(s) to the KSU Library for "' ||tempTITLE|| '" is complete!' 
   || u'\000A'||
  'Please review the latest book inventory and confirmation of your request.'
   || u'\000A'||' '
   || u'\000A'||
   'BOOK ISBN: '||IN_ISBN||' '
   || u'\000A'||
   'BOOK KIOSK LOCATION: '||tempKID|| ', '||tempKLOC||' '
   || u'\000A'||
   'Original Book Quantity: '||tempQTY||' '
   || u'\000A'||
   'New Book Quantity: '|| NEW_QTY
   || u'\000A'||' '
   || u'\000A'||
  'All Kiosks will reflect this update accordingly.');

-- PL/SQL or SQL statements will appear if the ISBN does not have a checkout status in the system.
EXCEPTION
WHEN NO_DATA_FOUND THEN
   dbms_output.put_line    
   ('*** BOOK DELETION REQUEST ***'
     || u'\000A'||
    'The Book ISBN "' || IN_ISBN || '" does not exist within the KSU Book Kiosk.'
     || u'\000A'|| ' '
     || u'\000A'||
    'Your request to remove this book from the system has been rejected.') ;
END;
END;
/

-- -------------------------------------------
--
--  PROCEDURE: DELETE A TECHNICIAN
--
-- -------------------------------------------
create or replace PROCEDURE DROP_USER(IN_USERNAME VARCHAR2)
AUTHID CURRENT_USER
IS
    tempUID    VARCHAR2(50);
    tempUNAME  VARCHAR2(50);
    tempFNAME  VARCHAR2(20);
    tempLNAME  VARCHAR2(20);
    SQL_TEXT   VARCHAR2(100);
BEGIN
SELECT
      A.USER_ID,
      A.USERNAME,
      A.USER_FIRSTNAME,
      A.USER_LASTNAME
INTO  tempUID, tempUNAME,tempFNAME,tempLNAME
FROM  SYSTEM.USERS A
WHERE A.USERNAME = IN_USERNAME
;
-- PL/SQL or SQL statements will remove the input user from the database

SQL_TEXT := 'DROP USER '||TEMPUNAME|| ' CASCADE';
EXECUTE IMMEDIATE SQL_TEXT;

COMMIT;
   dbms_output.put_line  
   ('Your request to remove ' ||TEMPFNAME||' '||TEMPLNAME|| ' from the KSU Library database is complete!');

-- PL/SQL or SQL statements will appear if the ISBN does not have a checkout status in the system.
EXCEPTION
WHEN NO_DATA_FOUND THEN
   dbms_output.put_line    
    ('Your request to remove '||IN_USERNAME|| ' from the KSU Library database was denied!'
     || u'\000A'|| ' '
     || u'\000A'||
     'The username does not exist in system.'
     || u'\000A'||
     'Please verify that your requested username to remove is correct.');
END;
/

-- -------------------------------------------
--
--  PROCEDURE: WEEKLY REPORT - CHECKOUTS
--
-- -------------------------------------------
create or replace PROCEDURE REPORT_CHECKOUT
AUTHID DEFINER
IS
RC SYS_REFCURSOR;
STATUS VARCHAR2(20) DEFAULT 'CHECKED OUT';

BEGIN
OPEN RC FOR
'SELECT A.KIOSK_ID, 
              A.KIOSK_LOC, 
              B.ISBN, 
              B.TITLE, 
              C.USER_ID, 
              C.USER_FIRSTNAME, 
              C.USER_LASTNAME, 
              D.TRNS_TIMESTAMP AS CHECKOUT_DATE, 
              D.DUE_DATE 
FROM          SYSTEM.KIOSKS A, 
              SYSTEM.BOOKS  B, 
              SYSTEM.USERS  C, 
              SYSTEM.TRANSACTIONS D 
WHERE A.BOOK_ISBN = B.ISBN 
     AND A.BOOK_ISBN = D.TRNS_ISBN 
     AND C.USER_ID   = D.USER_ID
';
dbms_sql.return_result(RC);
END;
/
-- -------------------------------------------
--
--  PROCEDURE: REPORT UNPAID FEES
--
-- -------------------------------------------
create or replace PROCEDURE UNPAID_FEE
AUTHID DEFINER
IS
RC SYS_REFCURSOR;
STATUS VARCHAR2(20) DEFAULT 'CHECKED OUT';

BEGIN
OPEN RC FOR
'SELECT A.USER_ID, 
              A.USER_FIRSTNAME, 
              A.USER_LASTNAME, 
              D.USER_FEE 
FROM       SYSTEM.USERS  A, 
           SYSTEM.TRANSACTIONS C, 
           SYSTEM.EXCEPTIONS  D 
WHERE A.USER_ID   = C.USER_ID 
AND   A.USER_ID   = D.USER_ID 
AND   C.TRNS_ID   = D.TRNS_ID 
';
dbms_sql.return_result(RC);
END;
/

-- -------------------------------------------
--
--  PROCEDURE: OVERDUE BOOKS
--
-- -------------------------------------------
create or replace PROCEDURE OVERDUE_BOOKS
AUTHID CURRENT_USER
IS
RC SYS_REFCURSOR;
STATUS VARCHAR2(20) DEFAULT 'CHECKED OUT';

BEGIN
OPEN RC FOR
'SELECT        A.USER_ID, 
               A.USER_FIRSTNAME, 
               A.USER_LASTNAME, 
               B.ISBN, 
               B.TITLE, 
               C.DUE_DATE 
FROM           SYSTEM.USERS  A, 
               SYSTEM.BOOKS  B, 
               SYSTEM.TRANSACTIONS C 
WHERE    A.USER_ID   = C.USER_ID 
AND      B.ISBN    = C.TRNS_ISBN 
AND      C.DUE_DATE < SYSDATE 
';
dbms_sql.return_result(RC);
END;
/

-- -------------------------------------------
--
--  PROCEDURE: BOOK INVENTORY
--
-- -------------------------------------------
create or replace PROCEDURE BOOK_INVENTORY
AUTHID DEFINER
IS
RC SYS_REFCURSOR;
STATUS VARCHAR2(20) DEFAULT 'CHECKED OUT';

BEGIN
OPEN RC FOR
'SELECT      A.KIOSK_ID, 
             A.KIOSK_LOC, 
             B.ISBN, 
             B.TITLE, 
             B.PUBLISHER, 
             A.BOOK_QTY  AS BOOK_QUANTITY 
FROM       SYSTEM.KIOSKS A, 
           SYSTEM.BOOKS  B 
WHERE A.BOOK_ISBN = B.ISBN 
';
dbms_sql.return_result(RC);
END;
/

-- -------------------------------------------
--
--  PROCEDURE: SEARCH TRANSACTIONS
--
-- -------------------------------------------
create or replace PROCEDURE Search_Transactions
AUTHID DEFINER
IS
RC SYS_REFCURSOR;
BEGIN
   OPEN RC FOR

  'SELECT * FROM SYSTEM.TRANSACTIONS'; 

   dbms_sql.return_result(RC);
END;
/

-- -------------------------------------------
--
--  PROCEDURE: SEARCH USERS
--
-- -------------------------------------------
create or replace PROCEDURE Search_Users
AUTHID DEFINER
IS
RC SYS_REFCURSOR;
BEGIN
   OPEN RC FOR

  'SELECT * FROM SYSTEM.USERS'; 

   dbms_sql.return_result(RC);
END;
/

-- -------------------------------------------
--
--  FUNCTION: Security_Function
--
-- -------------------------------------------
create or replace FUNCTION security_function (obj_schema varchar2, obj_name varchar2)  
RETURN VARCHAR2  
AUTHID DEFINER 

AS  
returned_string VARCHAR2(100);   
usertype VARCHAR2(10); 

BEGIN  
SELECT USER_TYPE 
INTO USERTYPE 
FROM SYSTEM.USERS 
WHERE USERNAME = UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER')); 

--  IF USER IS AN EMPLOYEE ON THE KSU KIOSK DATABASE, THEY CAN VIEW ALL ROWS ON THE TRANSACTIONS TABLE 
IF usertype = 'EMPLOYEE'  THEN 
   returned_string := 'ctrl_user '||'IS NOT NULL';  
   return returned_string;  
ELSE  
--  IF USER IS NOT AN EMPLOYEE THEN USER CAN ONLY VIEW THE ROWS FOR THEIR USERNAME 
   returned_string := 'ctrl_user= ''' || UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER')) || ''''; 
   return returned_string;  
END IF;

EXCEPTION 
WHEN NO_DATA_FOUND THEN 
--  IF USER IS NOT AN EMPLOYEE THEN CHECK IF SYSTEM (CAN VIEW ALL ROWS ON DATABASE) 
IF UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER')) IN ('SYS','SYSTEM') THEN  
   returned_string := 'ctrl_user '||'IS NOT NULL';  
   return returned_string;
ELSE
   returned_string := 'ctrl_user '||'IS NULL'; 
   return returned_string;
END IF; 
END;
/

-- -------------------------------------------
--
--  FUNCTION: Security_Function2
--
-- -------------------------------------------
create or replace FUNCTION security_function2 (obj_schema varchar2, obj_name varchar2)   
RETURN VARCHAR2   
AS   
returned_string VARCHAR2(100);   
NAME VARCHAR2(50) DEFAULT 'USERNAME IS NOT NULL'; 

BEGIN  

IF UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER')) IN('SYSTEM','SYS','C##LCLARK','C##MLAMB') THEN 

--  IF USER IS AN EMPLOYEE ON THE KSU KIOSK DATABASE, THEY CAN VIEW ALL ROWS ON THE TRANSACTIONS TABLE 

   returned_string := NAME; 

   return returned_string;  
ELSE  
--  IF USER IS NOT AN EMPLOYEE THEN USER CAN ONLY VIEW THE ROWS FOR THEIR USERNAME 

   returned_string := 'USERNAME= ''' || UPPER(SYS_CONTEXT('USERENV', 'SESSION_USER')) || ''''; 

   return returned_string;    
END IF; 
END; 
/ 


-- -------------------------------------------
--
--  ENABLE VPD POLICIES
--
-- -------------------------------------------
BEGIN  
   dbms_rls.add_policy(object_schema => 'system',  
   object_name => 'USERS',  
   policy_name => 'users_policy',  
   function_schema =>'system',  
   policy_function => 'security_function2',  
   statement_types =>'select', 
   enable =>true);  
END;  
/ 
BEGIN  
   dbms_rls.add_policy(object_schema => 'system',  
   object_name => 'TRANSACTIONS',  
   policy_name => 'transactions_policy',  
   function_schema =>'system',  
   policy_function => 'security_function',  
   statement_types =>'select', 
   enable =>true);  
END;  
/

-- -------------------------------------------
--
--  CREATE USERS
--
-- -------------------------------------------
-- ---------------------------------------
-- MANAGER WITH ADMINISTRATOR ACCESS
-- ---------------------------------------
CREATE USER C##LCLARK
IDENTIFIED BY oracle18cdb
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
QUOTA 15M ON users 
PROFILE default; 
GRANT CONNECT, RESOURCE, DBA to C##LCLARK;
GRANT ALL PRIVILEGES TO C##LCLARK;

-- ---------------------------------------
-- EMPLOYEE WITH REGISTERED ACCESS
-- ---------------------------------------
CREATE USER C##MLAMB
IDENTIFIED BY oracle18cdb
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
QUOTA 15M ON users 
PROFILE default;  
GRANT CONNECT to C##MLAMB;
GRANT CREATE SESSION TO C##MLAMB;

-- -----------------------------------
-- UNRESIGISTERED STUDENT
-- ------------------------------------
CREATE USER C##SBASS
IDENTIFIED BY oracle18cdb
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
QUOTA 15M ON users 
PROFILE default; 
GRANT CONNECT to C##SBASS;
GRANT CREATE SESSION TO C##SBASS;

-- ---------------------------------------
-- RESIGISTERED STUDENT
-- ---------------------------------------
CREATE USER C##MTHOMAS
IDENTIFIED BY oracle18cdb 
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
QUOTA 10M ON users 
PROFILE default; 
GRANT CONNECT to C##MTHOMAS; 
GRANT CREATE SESSION TO C##MTHOMAS; 

-- -----------------------------------
-- RESIGISTERED STUDENT
-- ------------------------------------
CREATE USER C##LMILLER
IDENTIFIED BY oracle18cdb
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
QUOTA 15M ON users 
PROFILE default; 
GRANT CONNECT to C##LMILLER;
GRANT CREATE SESSION TO C##LMILLER;

-- -----------------------------------
-- RESIGISTERED STUDENT
-- ------------------------------------
CREATE PROFILE C##LOGIN_FAIL LIMIT
FAILED_LOGIN_ATTEMPTS 3;

CREATE USER C##SBROWN
IDENTIFIED BY oracle18cdb
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
QUOTA 10M ON users
PROFILE C##LOGIN_FAIL;
GRANT CONNECT to C##SBROWN; 
GRANT CREATE SESSION TO C##SBROWN;

-- -----------------------------------
-- CREATE AND GRANT ROLE FOR EMPLOYEES (Admins)
-- ------------------------------------
CREATE ROLE C##EMPLOYEES;
GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.USERS TO C##EMPLOYEES;
GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.BOOKS TO C##EMPLOYEES;
GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.KIOSKS TO C##EMPLOYEES;
GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.EXCEPTIONS TO C##EMPLOYEES;
GRANT SELECT, INSERT, UPDATE, DELETE ON SYSTEM.TRANSACTIONS TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.BOOKSEARCHISBN TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.BOOKSEARCHTITLE TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.CHECK_IN_BOOK TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.CHECK_OUT_BOOK TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.UPDATE_BOOK_KIOSKS TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.PAY_FEE TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.SEARCH_TRANSACTIONS TO C##EMPLOYEES;
GRANT EXECUTE ON SYSTEM.SEARCH_USERS TO C##EMPLOYEES;
GRANT C##EMPLOYEES TO C##LCLARK;

-- -----------------------------------
-- CREATE AND GRANT ROLE FOR EMPLOYEES (Non-Admins)
-- ------------------------------------
CREATE ROLE C##EMPLOYEES2;
GRANT SELECT, INSERT, UPDATE ON SYSTEM.USERS TO C##EMPLOYEES2;
GRANT SELECT, INSERT, UPDATE ON SYSTEM.BOOKS TO C##EMPLOYEES2;
GRANT SELECT, INSERT, UPDATE ON SYSTEM.KIOSKS TO C##EMPLOYEES2;
GRANT SELECT, INSERT, UPDATE ON SYSTEM.EXCEPTIONS TO C##EMPLOYEES2;
GRANT SELECT, INSERT, UPDATE ON SYSTEM.TRANSACTIONS TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.BOOKSEARCHISBN TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.BOOKSEARCHTITLE TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.CHECK_IN_BOOK TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.CHECK_OUT_BOOK TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.UPDATE_BOOK_KIOSKS TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.PAY_FEE TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.SEARCH_TRANSACTIONS TO C##EMPLOYEES2;
GRANT EXECUTE ON SYSTEM.SEARCH_USERS TO C##EMPLOYEES2;
GRANT C##EMPLOYEES2 TO C##MLAMB;

-- -----------------------------------
-- CREATE AND GRANT ROLE FOR STUDENTS
-- ------------------------------------
CREATE ROLE C##STUDENTS;
GRANT SELECT, INSERT ON SYSTEM.USERS TO C##STUDENTS;
GRANT SELECT, INSERT ON SYSTEM.BOOKS TO C##STUDENTS;
GRANT SELECT, INSERT ON SYSTEM.KIOSKS TO C##STUDENTS;
GRANT SELECT, INSERT ON SYSTEM.TRANSACTIONS TO C##STUDENTS;
GRANT SELECT, INSERT ON SYSTEM.EXCEPTIONS TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.BOOKSEARCHISBN TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.BOOKSEARCHTITLE TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.CHECK_IN_BOOK TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.CHECK_OUT_BOOK TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.PAY_FEE TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.SEARCH_TRANSACTIONS TO C##STUDENTS;
GRANT EXECUTE ON SYSTEM.SEARCH_USERS TO C##STUDENTS;
GRANT C##STUDENTS TO C##MTHOMAS;
GRANT C##STUDENTS TO C##SBASS;
GRANT C##STUDENTS TO C##LMILLER;
GRANT C##STUDENTS TO C##SBROWN;


--------------------------------------------------------------------------------------------------------------------------------Unified AUDITING
--------------------------------------------------------------------------------------------------------

SHOW CON_NAME;

SELECT SYS_CONTEXT('USERENV','SESSION_USER') FROM DUAL
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select * from v$option where PARAMETER = 'Unified Auditing'; 

GRANT AUDIT_ADMIN to C##LCLARK; -- Permissions given from sys as sysdba account
 GRANT AUDIT_VIEWER to C##LCLARK; 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----Failed Login------

CREATE AUDIT POLICY ORA_LOGON_FAILURES ACTIONS LOGON; 
AUDIT POLICY ORA_LOGON_FAILURES WHENEVER NOT SUCCESSFUL; 

select event_timestamp, audit_type, dbusername, action_name, return_code 

from unified_audit_trail  

where unified_audit_policies = 'ORA_LOGON_FAILURES' 

and event_timestamp > systimestamp - ((1/24/60) *10) -- happened in the last 10 minutes 

order by event_timestamp desc 
-------------------------------------------------------------------------------------------------------------------------------------------------------

--------Audit Privileges------

 CREATE AUDIT POLICY PRIVILEGE_AUDITS
  PRIVILEGES CREATE ANY TABLE, ALTER ANY TABLE, DROP ANY TABLE

AUDIT POLICY PRIVILEGE_AUDITS by c##mlamb;

SELECT audit_option,
       condition_eval_opt,
       audit_condition, policy_name
FROM   audit_unified_policies 
WHere policy_name = 'PRIVILEGE_AUDITS';


select event_timestamp, DBUSERNAME,  ACTION_NAME, SQL_TEXT, UNIFIED_AUDIT_POLICIES 
from unified_audit_trail where unified_audit_policies = 'PRIVILEGE_AUDITS'
order by event_timestamp desc
------------------------------------------------------------------------------------------------------------------
-- Dropping the Policy with Privileges---

NOAUDIT POLICY PRIVILEGE_AUDITS by C##MLAMB; 
DROP AUDIT POLICY PRIVILEGE_AUDITS;

--------------------------------------------------------------------------------------------------------------

---------Audit Search Books----------

CREATE AUDIT POLICY search_book
ACTIONS  SELECT ON sys.books

AUDIT POLICY search_book;

SELECT audit_option,
       condition_eval_opt,
       audit_condition, policy_name
FROM   audit_unified_policies 
WHere policy_name =  'SEARCH_BOOK';
  
select event_timestamp, DBUSERNAME,  ACTION_NAME, SQL_TEXT, UNIFIED_AUDIT_POLICIES 
from unified_audit_trail where unified_audit_policies = 'SEARCH_BOOK'
order by event_timestamp desc

----Dropping the Policy---

NOAUDIT POLICY SEARCH_BOOK;
DROP AUDIT POLICY SEARCH_BOOK;
_____________________________________________________________________________________________________________

-----Audit Book Kiosks information-
  create audit policy Kiosks_Audit
    actions update on sys.Kiosks
    when 'sys_context(''userenv'', ''session_user'')   =  ''C##LCLARK'''
    evaluate per session

Audit policy Kiosks_Audit;

  SELECT audit_option,
       condition_eval_opt,
       audit_condition, policy_name
FROM   audit_unified_policies 
WHere policy_name =   'Kiosks_Audit';
  
  select event_timestamp, DBUSERNAME,  ACTION_NAME, SQL_TEXT, UNIFIED_AUDIT_POLICIES 
from unified_audit_trail where unified_audit_policies = 'KIOSKS_AUDIT'
order by event_timestamp desc

-- select * from sys.kiosks;
--- update sys.kiosks set BOOK_QTY = 1 where KIOSK_ID = 'MAIN123';
 update sys.kiosks set BOOK_QTY = 15 where BOOK_ISBN ='012-9-22-1234';
  update sys.kiosks set BOOK_QTY = 20 where BOOK_ISBN ='817-1-24-1234';
-----------------------------------------------------------------------------------------------------------------

------Audit Transactions-----

  create audit policy Transactions_audit
    actions all on sys.TRANSACTIONS
    when 'sys_context(''userenv'', ''session_user'')   in (''C##SBASS'', ''C##MTHOMAS'', ''C##LMILLER'', ''C##SBROWN'')'
    evaluate per session
  
  Audit policy Transactions_audit;
  
  SELECT audit_option,
       condition_eval_opt,
       audit_condition, policy_name
FROM   audit_unified_policies 
WHere policy_name =   'TRANSACTIONS_AUDIT';
  
  select event_timestamp, DBUSERNAME,  ACTION_NAME, SQL_TEXT, UNIFIED_AUDIT_POLICIES 
from unified_audit_trail where unified_audit_policies = 'TRANSACTIONS_AUDIT'
order by event_timestamp desc

-------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Auditing User Deletion--

create audit policy Deleting_users
actions delete on sys.users;

Audit policy Deleting_users;

  SELECT audit_option,
       condition_eval_opt,
       audit_condition, policy_name
FROM   audit_unified_policies 
WHere policy_name =  'DELETING_USERS';
  
 select event_timestamp, DBUSERNAME,  ACTION_NAME, SQL_TEXT, UNIFIED_AUDIT_POLICIES 
from unified_audit_trail where unified_audit_policies = 'DELETING_USERS'
order by event_timestamp desc

-- INSERT INTO sys.USERS (USERNAME, USER_FIRSTNAME, USER_LASTNAME, USER_EMAIL, USER_PHONE, USER_PASSWORD, USER_TYPE, USER_PROFILE) 
-- VALUES ('C##ST', 'SANDRA', 'Teresa', null,  '555-11-1114', 'APPLS_01', 'EMPLOYEE', 'USER');

-- delete from sys.users where USER_FIRSTNAME = 'SANDRA' and USER_TYPE = 'EMPLOYEE'
  

----------------------------------------------------------------------------------------------------------------------------------------------------------------


SELECT *  FROM audit_unified_enabled_policies --Enabled Policies

---Policies created for our Project--

 select event_timestamp, DBUSERNAME,  ACTION_NAME, SQL_TEXT, UNIFIED_AUDIT_POLICIES 
from unified_audit_trail where unified_audit_policies in ('ORA_LOGON_FAILURES', 'PRIVILEGE_AUDITS', 'SEARCH_BOOK',   'TRANSACTIONS_AUDIT', 'DELETING_USERS')  
order by EVENT_TIMESTAMP desc;
_________________________________________________________________________________________________________________




