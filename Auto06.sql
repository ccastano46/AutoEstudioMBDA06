/*Tablas*/

CREATE TABLE STAFF(
    id VARCHAR2(20) NOT NULL,
    name VARCHAR2(50)
);

CREATE TABLE STUDENT(
    id varchar2(20) NOT NULL,
    name VARCHAR2(50),
    sze NUMBER(11,0),
    parent VARCHAR2(20)
);

CREATE TABLE ROOM(
    id VARCHAR2(20) NOT NULL,
    name VARCHAR2(50),
    capacity NUMBER(11),
    parent VARCHAR2(20)
);

CREATE TABLE EVENT(
    id VARCHAR2(20) NOT NULL,
    modle VARCHAR2(20),
    kind CHAR,
    dow VARCHAR2(15),
    tod VARCHAR2(5),
    duration NUMBER(1,0),
    room VARCHAR2(20),
    detail XMLTYPE
);

CREATE TABLE ATTENDS(
    student VARCHAR2(20) NOT NULL,
    event VARCHAR2(20) NOT NULL
);

CREATE TABLE TEACHES(
    staff VARCHAR2(20) NOT NULL,
    event VARCHAR2(20) NOT NULL
);

CREATE TABLE MODLE(
    id VARCHAR2(20) NOT NULL,
    name VARCHAR2(50)
);

CREATE TABLE WEEK(
    id CHAR(2) NOT NULL,
    wkstart DATE
);

/*Atributos*/

ALTER TABLE STAFF
ADD CONSTRAINT PK_Staff PRIMARY KEY (id);

ALTER TABLE STUDENT
ADD CONSTRAINT PK_Student PRIMARY KEY (id);

ALTER TABLE ROOM
ADD CONSTRAINT PK_Room PRIMARY KEY (id);

ALTER TABLE EVENT
ADD CONSTRAINT PK_Event PRIMARY KEY (id);

ALTER TABLE ATTENDS
ADD CONSTRAINT PK_Attends PRIMARY KEY (student,event);

ALTER TABLE TEACHES
ADD CONSTRAINT PK_Teaches PRIMARY KEY (staff,event);

ALTER TABLE MODLE
ADD CONSTRAINT PK_Modle PRIMARY KEY (id);

ALTER TABLE WEEK
ADD CONSTRAINT PK_Week PRIMARY KEY (id);

ALTER TABLE STUDENT
ADD CONSTRAINT FK_Student_Parent
FOREIGN KEY (parent) REFERENCES STUDENT (id);

ALTER TABLE ROOM
ADD CONSTRAINT FK_Room_Parent
FOREIGN KEY (parent) REFERENCES ROOM (id);

ALTER TABLE EVENT
ADD CONSTRAINT FK_Event_Modle
FOREIGN KEY (modle) REFERENCES MODLE (id);

ALTER TABLE EVENT
ADD CONSTRAINT FK_Event_Room
FOREIGN KEY (room) REFERENCES ROOM (id);

ALTER TABLE ATTENDS
ADD CONSTRAINT FK_Attends_student
FOREIGN KEY (student) REFERENCES STUDENT (id);

ALTER TABLE TEACHES
ADD CONSTRAINT FK_Teaches_Staff
FOREIGN KEY (staff) REFERENCES STAFF (id);

ALTER TABLE EVENT
ADD CONSTRAINT CK_EVENT_KIND CHECK (kind = 'L' OR kind = 'T');

ALTER TABLE EVENT
ADD CONSTRAINT CK_EVENT_DOW CHECK (dow IN ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'));

ALTER TABLE EVENT
ADD CONSTRAINT CK_EVENT_TOD CHECK (REGEXP_LIKE (tod,'^([8-9]|1[0-9]|20)(:00)$'));

ALTER TABLE EVENT
ADD CONSTRAINT CK_EVENT_DURATION CHECK (duration = 1 OR duration = 2);

/*Tuplas*/

ALTER TABLE EVENT
ADD CONSTRAINT CK_EVENT_TOD_DURATION CHECK(NOT (tod = '20:00' AND duration <> 1));

/*Disparadores*/

CREATE SEQUENCE Seq_CodigoEvento START WITH 1 INCREMENT BY 1 MAXVALUE 99999999;
CREATE OR REPLACE TRIGGER TR_Event_Codigo
BEFORE INSERT ON EVENT
FOR EACH  ROW
BEGIN
        :new.ID := Seq_CodigoSolicitudes.NEXTVAL;
END;
/
DROP TRIGGER TR_Event_Codigo;

/*XTablas*/
DROP TABLE ATTENDS;
DROP TABLE EVENT;
DROP TABLE MODLE;
DROP TABLE ROOM;
DROP TABLE STUDENT;
DROP TABLE TEACHES;
DROP TABLE STAFF;
DROP TABLE WEEK;
/*CRUDE*/
CREATE OR REPLACE PACKAGE PC_EVENT AS
    FUNCTION ad(modle IN VARCHAR2, kind IN char, dow IN VARCHAR2, durtion IN NUMBER, room IN VARCHAR2) RETURN VARCHAR2;
    PROCEDURE upProce(id IN VARCHAR2, room IN VARCHAR2);
    PROCEDURE adStaff(event IN VARCHAR2, staff IN VARCHAR2);
    PROCEDURE delE(event IN VARCHAR2);
    FUNCTION coTeams RETURN SYS_REFCURSOR;
    FUNCTION coEvents(staff IN VARCHAR2) RETURN SYS_REFCURSOR;
END PC_EVENT;
/
/*CRUDI*/

CREATE OR REPLACE PACKAGE BODY PC_EVENT AS
     FUNCTION ad(modle IN VARCHAR2, kind IN char, dow IN VARCHAR2, durtion IN NUMBER, room IN VARCHAR2) RETURN VARCHAR2 IS
        ident VARCHAR2(20);
        BEGIN
            INSERT INTO EVENT(modle,kind,dow,duration,room) VALUES (modle,kind,dow,durtion,room);
            SELECT id INTO ident  FROM event
            WHERE(EVENT.modle = modle AND EVENT.kind = kind AND EVENT.dow = dow AND EVENT.duration = durtion AND EVENT.room = room);
            RETURN ident;
        END;
    PROCEDURE upProce(id IN VARCHAR2, room IN VARCHAR2) IS
        BEGIN
            NULL;
        END upProce;
    PROCEDURE adStaff(event IN VARCHAR2, staff IN VARCHAR2) IS
        BEGIN
            INSERT INTO TEACHES VALUES(staff,event);
        END adStaff;
    PROCEDURE delE(event IN VARCHAR2) IS
        BEGIN
            DELETE FROM EVENT WHERE(EVENT.id = event);
        END delE;
        FUNCTION coTeams RETURN SYS_REFCURSOR IS
        coTeam_cursor SYS_REFCURSOR;
        BEGIN
            OPEN coTeam_cursor FOR
            SELECT event.modle, COUNT(teaches.staff)
            FROM event INNER JOIN teaches ON event.id = teaches.event 
            GROUP BY event.modle
            HAVING event.modle LIKE('%co7%');
            RETURN coTeam_cursor;
        END;
        FUNCTION coEvents(staff IN VARCHAR2) RETURN SYS_REFCURSOR IS
        coEvent_cursor SYS_REFCURSOR;
        BEGIN
            OPEN coEvent_cursor FOR
            SELECT event FROM TEACHES
            WHERE (TEACHES.staff = staff);
            RETURN coEvent_cursor;
        END;
END PC_EVENT;
/
/*XCRUD*/
DROP PACKAGE PC_EVENT;

/*Poblando (3 Ejemplos)*/

INSERT INTO EVENT(DETAIL) VALUES(XMLTYPE('<?xml version="1.0"?>
<Detail evaluacion="3">
    <Comentarios>
        <Comentario>Una_actividad_completa,_llena_de_experiencias_enriquecedoras_para_el_mundo_tanto_personal_como_laboral</Comentario>
        <Comentario>Un_poco_aburrida_al_inicio_pero,_al_final_wow</Comentario>
    </Comentarios>
    <Biografia titulo="Las_aventuras_de_la_ciencia" direccion="https://www.CienceAdventures.com" tipo="video">
    </Biografia>
</Detail>'));

INSERT INTO EVENT(DETAIL) VALUES(XMLTYPE('<?xml version="1.0"?>
<Detail evaluacion="5">
    <Comentarios>
        <Comentario>tEXTO1</Comentario>
        <Comentario>Comentario2</Comentario>
    </Comentarios>
    <Biografia titulo="Prueba2" direccion="https://www.escueladeingenieros.com" tipo="texto">
    </Biografia>
</Detail>'));

INSERT INTO EVENT(DETAIL) VALUES(XMLTYPE('<?xml version="1.0"?>
<Detail evaluacion="4">
    <Comentarios>
        <Comentario>Una_actividad_completa,_llena_de_experiencias_enriquecedoras_para_el_mundo_tanto_personal_como_laboral</Comentario>
        <Comentario>Un_poco_aburrida_al_inicio_pero,_al_final_wow</Comentario>
    </Comentarios>
    <Biografia titulo="Las_aventuras_de_tom" direccion="https://www.CienceAdventures.com" tipo="audio">
    </Biografia>
</Detail>'));

TRUNCATE TABLE EVENT;






