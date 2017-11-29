-- Triggers

DELIMITER //

CREATE TRIGGER actualizar_clase AFTER UPDATE ON clases
for each row
BEGIN
    IF NEW.hora_final_real is not null and OLD.hora_final_real is null then
        insert into pagos (tutor, bloques, pluralidad, fecha_creacion,clase,estado)
        select tutor,
        ROUND(FLOOR(TIME_TO_SEC(TIMEDIFF(hora_final_planeada,hora_inicio_planeada))/60)/30),
        pluralidad,
        NOW(),
        id,
        'PENDIENTE'
        from clases where id = New.id;
        insert into cobranzas (bloques,pluralidad, fecha_creacion,clase,estado,modificador,familia)
            select 
                Floor(time_to_sec(timediff(c.hora_final_planeada,c.hora_inicio_planeada))/1800),
                c.pluralidad,
                NOW(),
                c.id,
                'PENDIENTE',
                1.0,
                a.familia
                from clases as c
                inner join clases_alumnos as ca on c.id = ca.clase
                inner join alumnos as a on ca.alumno = a.id
                where c.id = New.id;
    ELSEIF  NEW.estado = 'INACTIVO' then
        update clases_alumnos set estado = 'INACTIVO' where clase = NEW.id;
    ELSEIF NEW.estado = 'CANCELADA' then
        update clases_alumnos set estado = 'CANCELADA' where clase = NEW.id;
    end if;
END;//


CREATE TRIGGER desactivar_clases_alumno AFTER UPDATE on alumnos
for each row
BEGIN
    IF NEW.estado = 'INACTIVO' then
        update clases set clases.estado = 'INACTIVO' 
        where clases.id in (select clases.id 
                        from clases 
                        inner join clases_alumnos on clases.id = clases_alumnos.clase 
                        where clases_alumnos.alumno = NEW.id and clases.fecha > NOW());
    END IF;
END;//


CREATE TRIGGER crear_tutor_interno AFTER INSERT on tutores
for each row
BEGIN
   INSERT INTO internal_tutores (id,fecha_vencimiento,ultima_renovacion,estado,fecha_creacion) 
   values (NEW.id_tutor,DATE_ADD(DATE(NOW()),INTERVAL 30 DAY),DATE(NOW()),'ACTIVO',DATE(NOW()));
END;//
DELIMITER //
CREATE TRIGGER extender_rutina AFTER UPDATE ON rutinas
for each row
BEGIN
    IF NEW.fecha_vencimiento > OLD.fecha_vencimiento then
        insert into clases (tutor, fecha, estado, hora_inicio_planeada,hora_final_planeada, curso, rutina, wd)
        select 
            New.tutor,
            v.dt,
            'ACTIVO',
            v.hora_inicio,
            v.hora_fin,
            v.curso,
            New.id,
            v.dia
        from v_calendario_rut_dias as v
        where rutina = New.id and v.dt < New.fecha_vencimiento and v.dt > OLD.fecha_vencimiento AND v.estado = 'ACTIVO';
        insert into clases_alumnos (alumno, clase, estado, rutina)
            select  a.alumno, c.id, 'ACTIVO', c.rutina 
            from clases as c 
            join (select alumno from v_rutinas_alumnos where rutina = New.id) as a 
            where c.fecha <= New.fecha_vencimiento and c.fecha >= OLD.fecha_vencimiento and rutina = NEW.id;
    end if;
END;//
DELIMITER ;

-- CREATE TRIGGER actualizar_alumnos AFTER UPDATE ON clases
-- for each row
-- BEGIN
--     IF NEW.estado = 'INACTIVO' then
--         update clases_alumnos set estado = 'INACTIVO' where clase = NEW.id;
--     elseif 
--     end if;
-- END;//

-- CREATE TRIGGER cancelar_clase AFTER UPDATE on clases
-- for each row
-- BEGIN
--     IF NEW.estado = 'CANCELADA' then
--         update clases_alumnos set estado = 'CANCELADA' where clase = NEW.id;
--     END IF;
-- END;//

-- CREATE TRIGGER actualizar_pagos_y_cobranzas AFTER UPDATE ON clases
-- for each row
-- BEGIN
--     IF NEW.hora_final_real is not null and OLD.hora_final_real is null then
--         insert into pagos (tutor, bloques, pluralidad, fecha_creacion,clase,estado)
--         select tutor,
--         ROUND(FLOOR(TIME_TO_SEC(TIMEDIFF(hora_final_planeada,hora_inicio_planeada))/60)/30),
--         pluralidad,
--         NOW(),
--         id,
--         'PENDIENTE'
--         from clases where id = New.id;
--         insert into cobranzas (bloques,pluralidad, fecha_creacion,clase,estado,modificador,familia)
--             select 
--                 Floor(time_to_sec(timediff(c.hora_final_planeada,c.hora_inicio_planeada))/1800),
--                 c.pluralidad,
--                 NOW(),
--                 c.id,
--                 'PENDIENTE',
--                 1.0,
--                 a.familia
--                 from clases as c
--                 inner join clases_alumnos as ca on c.id = ca.clase
--                 inner join alumnos as a on ca.alumno = a.id
--                 where c.id = New.id;
--     end if;
-- END;//


-- Store Procedures

drop procedure if exists actualizar_categoria_tutores;
DELIMITER //
create procedure actualizar_categoria_tutores()
BEGIN
    DECLARE finished INTEGER default 0;
    DECLARE tutor_id integer default 0;
    declare count_tutores integer default 0;
    declare counter integer default 0;
    declare cat varchar(40) default '';
    declare horas integer default 0;
    DECLARE cursor_tutores CURSOR FOR select id from internal_tutores where estado = 'ACTIVO';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    
    OPEN cursor_tutores;
    
    select count(id) into count_tutores from internal_tutores where estado = 'ACTIVO';
    set counter = 0;
    
    actualizar_tutores: LOOP
    FETCH cursor_tutores into tutor_id;
    if counter = count_tutores then 
        leave actualizar_tutores; 
    end if;
    
    select 
    sum(floor(time_to_sec(timediff(c.hora_final_planeada,c.hora_inicio_planeada))/3600))
    into horas
    from clases as c where tutor = tutor_id and year(fecha) = year(NOW()) and month(fecha) = month(now())-1 and estado = 'ATENDIDO';
    
    IF horas IS NULL THEN
        set horas = 0;
    end if;


    select nombre_constante into cat 
    from constantes 
    where valor_1 <= horas and valor_2 >= horas;
    
    if cat is null then
    set cat = 'STARTER';
    end if;
    
    update internal_tutores set categoria = cat where id = tutor_id;
    
    set horas = 0;
    set cat = '';
    set counter = counter + 1;
    
    
    END LOOP actualizar_tutores;
    CLOSE cursor_tutores;
END;//

DELIMITER ;