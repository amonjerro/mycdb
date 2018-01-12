-- Vistas

create view v_reporte_horas_tutor as
select 
	p.tutor,
	concat(a.nombre,' ',a.apellido) as alumno,
	pl.detalle as pluralidad,
	c.fecha,
	c.hora_inicio_planeada,
	c.hora_inicio_real,
	c.hora_final_planeada,
	c.hora_final_real,
	cu.nombre as curso,
	c.estado as estado
from pagos as p
inner join clases as c 
	on p.clase = c.id
inner join pluralidades as pl
	on c.pluralidad = pl.id
inner join clases_alumnos as ca 
	on ca.clase = c.id
inner join cursos as cu
	on cu.id = c.curso
inner join alumnos as a
	on ca.alumno = a.id;

create view v_ccee_nivel as
select 
    c.id as id,
    c.nombre as nombre,
    nce.nivel as nivel,
    n.descripcion as nivel_nombre
from nivel_centro_educativos as nce
inner join centros_educativos as c on c.id = nce.ccee
inner join niveles as n on n.id = nce.nivel;

create view v_rut_dias as
    select ru.rutina as rutina, 
        ru.dia as dia,
        ru.hora_inicio as inicio,
        ru.hora_fin as fin,
        FORMAT(TIME_TO_SEC(ru.hora_fin - ru.hora_inicio)/3600,2) as duracion,
        cu.id  as curso_id,
        cu.nombre as curso,
        rt.tutor as tutor,
        rt.fecha_vencimiento as vencimiento,
        ru.estado as estado
    from rut_dias as ru
    inner join rutinas as rt on ru.rutina = rt.id
    inner join cursos as cu on ru.curso = cu.id;

create view v_familia as
	select 
	f.id as id,
	f.apellido as apellido,
	t.nombre as tarifas,
	f.estado as estado
	from familias as f
	inner join tarifas as t  on f.tarifas = t.id;


create view v_rutinas as 
    select 
        r.id as rutina,
        ANY_VALUE(a.id) as alumno,
        ANY_VALUE(concat(a.nombre,' ', a.apellido)) as alumno_nombre,
        ANY_VALUE(r.tutor) as tutor,
        ANY_VALUE(t.tutor) as tutor_nombre,
        ANY_VALUE(r.estado) as estado,
        ANY_VALUE(r.fecha_vencimiento) as fecha_vencimiento,
        ANY_VALUE(r.fecha_creacion) as fecha_creacion,
        ANY_VALUE(r.rutina_key) as rutina_key,
        ANY_VALUE(c.pluralidad) as pluralidad
    from rutinas as r inner join clases as c on c.rutina = r.id
    inner join clases_alumnos as ca on ca.clase = c.id
    inner join alumnos as a on ca.alumno = a.id
    inner join tutores as t on r.tutor = t.id_tutor
    where r.estado = 'ACTIVO'
    group by r.id;
    
create view v_pagos_pendientes as 
    select
        id as id,
        tutor as tutor,
        month(fecha_creacion) as mes
    from pagos
    where estado = 'PENDIENTE';

create view v_cobranzas_pendientes as
    select
        id as id,
        familia as familia,
        month(fecha_creacion) as mes
    from cobranzas
    where estado = 'PENDIENTE';    

create view v_eventos as
select 
    e.id as evento,
    e.tipo_evento as tipo_id,
    te.nombre as tipo,
    e.clase as clase,
    a.id as alumno_id,
    concat(a.nombre,' ',a.apellido) as alumno,
    e.creacion as fecha_evento,
    e.causante as causante,
    e.estado as estado_evento,
    e.comentario as comentario
    from eventos as e
    inner join tipos_eventos as te on e.tipo_evento = te.id
    inner join alumnos as a on e.destinatario = a.id;

create view v_users as
    select
        usr.username as uname,
        grp.nombre as grupo,
        usr.ultimo_login as login,
        usr.estado as estado,
        if (usr.nombre is null, tut.tutor, concat(usr.nombre,' ',usr.apellido)) as nombre
    from intranet_usuarios as usr
    inner join grupos as grp on usr.grupo = grp.id
    left join tutores as tut on usr.tutor = tut.id_tutor;

create view v_tutores_cursos as
    select
    tc.tutor as id_t,
    tc.curso as id_c,
    c.nombre as curso
    from tutores_cursos as tc
    inner join tutores as t on tc.tutor = t.id_tutor
    inner join cursos as c on tc.curso = c.id;

create view v_tutores_distritos as
    select distrito, tutor, tipo, nombre 
    from distritos_profes as dp 
    inner join distritos as d on d.id = dp.distrito;

create view v_tutores as
    select
        tu.id_tutor as id,
        tu.tutor as tutor,
        tu.insight as descripcion,
        tu.telefono as fono,
        tu.email as mail,
        it.edad as edad,
        it.genero as genero,
        it.colegio_origen as id_colegio,
        ce.nombre as colegio,
        it.universidad as id_universidad,
        cu.nombre as universidad,
        it.carrera as id_carrera,
        ca.nombre as carrera,
        it.grado as id_grado,
        g.nombre as ciclo,
        it.horas_max as hmx,
        it.fecha_vencimiento as vencimiento,
        it.ultima_renovacion as ultima_renovacion,
        it.supervisor as supervisor
    from tutores as tu
    inner join internal_tutores as it on tu.id_tutor = it.id
    left join centros_educativos as ce on it.colegio_origen = ce.id
    left join centros_educativos as cu on it.universidad = cu.id
    left join carreras as ca on it.carrera = ca.id
    left join grados as g on it.grado = g.id;

create view v_tutores_alumnos as
    select
        ta.id_a as id_alumno,
        ta.id_t as id_tutor,
        concat(a.nombre,' ',a.apellido) as alumno,
        t.tutor as tutor
    from tutores_alumnos as ta
    inner join alumnos as a on ta.id_a = a.id
    inner join tutores as t on ta.id_t = t.id_tutor;

create view v_ocupancia_subquery as
    select 
        sum(floor(time_to_sec(timediff(c.hora_final_planeada,c.hora_inicio_planeada))/3600)) as horas_max, 
        tutor 
        from clases as c 
        where c.estado != 'INACTIVO' and MONTH(c.fecha) = MONTH(NOW())+1 and YEAR(fecha) = YEAR(NOW())
        group by tutor;

create view v_ocupancia_tutor as
select 
    it.id as id, 
    t.tutor as tutor, 
    it.horas_max as horas_max,
    it.fecha_vencimiento as fecha_vencimiento,
    it.ultima_renovacion as ultima_renovacion,
    it.estado as estado,
    cla.horas_max as horas_ocupadas,
    floor((cla.horas_max / it.horas_max)*100) as ocupacion
from internal_tutores as it
inner join tutores as t on it.id = t.id_tutor
left join v_ocupancia_subquery as cla on it.id = cla.tutor;

create view v_bloque_clases as
select id,
Floor(time_to_sec(timediff(hora_final_planeada,hora_inicio_planeada))/1800) as bloques
from clases;

create view v_reporte_clase_i as
select
    c.id as clase,
    t.tutor as tutor,
    concat(a.nombre,' ',a.apellido) as alumno,
    c.fecha  as fecha,
    YEAR(c.fecha) as annum,
    MONTH(c.fecha) as mes,
    DAY(c.fecha) as dia,
    p.detalle as pluralidad,
    c.hora_inicio_planeada, 
    c.hora_final_planeada,
    Floor(time_to_sec(timediff(c.hora_final_planeada,c.hora_inicio_planeada))/1800) as bloques,
    c.estado as estado
from clases as c
inner join tutores as t on c.tutor = t.id_tutor
inner join clases_alumnos as ca on c.id = ca.clase
inner join alumnos as a on a.id = ca.alumno
inner join pluralidades as p on p.id = c.pluralidad
where c.estado != 'INACTIVO'
order by annum,mes,dia,hora_inicio_planeada;

create view v_reporte_clase_a as
select
    YEAR(c.fecha) as annum,
    MONTH(c.fecha) as mes,
    DAY(c.fecha) as dia,
    c.fecha as fecha,
    count(c.estado) as conteo,
    c.estado as estado
from clases as c
where c.estado != 'INACTIVO'
group by annum,mes,dia,estado
order by annum,mes,dia;


create view v_distrito_alumnos as
select 
    a.id as id,
    concat(a.nombre,' ',a.apellido) as alumno,
    d.id as id_distrito,
    d.nombre as distrito
from alumnos as a inner join distritos as d on d.id = a.distrito
where a.estado = 'ACTIVO';

create view v_horas_familia as
select
    ANY_VALUE(f.id) as id_familia,
    ANY_VALUE(f.apellido) as familia,
    FORMAT(sum(
        CASE when c.pluralidad = 1 THEN 
            (c.bloques * t.valor_clase_individual * c.modificador)
        ELSE
            (c.bloques * t.valor_clase_grupal * c.modificador)
        END)/2,1) as monto_mes,
    ANY_VALUE(t.moneda_tarifa) as moneda,
    month(c.fecha_creacion) as mes,
    ANY_VALUE(year(c.fecha_creacion)) as annum
from cobranzas as c
inner join familias as f  on c.familia = f.id
inner join tarifas as t on f.tarifas = t.id
where c.estado = 'PENDIENTE'
group by c.familia, MONTH(c.fecha_creacion);

create view v_reporte_mail as
select
    c.familia as familia,
    FORMAT(CASE when c.pluralidad = 1 then
        c.bloques * ta.valor_clase_individual * c.modificador
    else
        c.bloques * ta.valor_clase_grupal * c.modificador
    end/2,1) as monto,
    ta.moneda_tarifa as moneda,
    t.tutor as tutor,
    cl.estado as estado,
    cl.fecha as fecha,
    cl.hora_inicio_planeada as hora_inicio,
    cl.hora_final_planeada as hora_final
from cobranzas as c 
inner join clases as cl on c.clase = cl.id
inner join tutores as t on cl.tutor = t.id_tutor
inner join familias as f on c.familia = f.id
inner join tarifas as ta on f.tarifas = ta.id;

create view v_horas_tutor as
select
    tu.id_tutor as id,
    tu.tutor as tutor,
    FORMAT(sum(
    CASE when p.pluralidad = 1 THEN 
        p.bloques
    ELSE
        0
    END)/2,1) as horas_individuales,
    FORMAT(sum(
    CASE when p.pluralidad = 2 THEN 
        p.bloques
    ELSE
        0
    END)/2,1) as horas_grupales,
    month(p.fecha_creacion) as mes,
    year(p.fecha_creacion) as year
from pagos as p
inner join tutores as tu on p.tutor = tu.id_tutor
inner join internal_tutores as it on p.tutor = it.id
where p.estado = 'PENDIENTE'
group by p.tutor, MONTH(p.fecha_creacion),YEAR(p.fecha_creacion);

create view v_detalle_pagos as
select
	p.id as id,
	p.tutor as tutor,
	pl.detalle as pluralidad,
	month(p.fecha_creacion) as mes,
	year(p.fecha_creacion) as year,
	c.fecha as fecha_clase,
	c.hora_inicio_planeada as hora_inicio_planeada,
	c.hora_inicio_real as hora_inicio_real,
	c.hora_final_planeada as hora_final_planeada,
	c.hora_final_real as hora_final_real,
    c.estado as estado_clase,
	cu.nombre as curso
from pagos as p
inner join clases as c 
	on p.clase = c.id
inner join pluralidades as pl on p.pluralidad = pl.id
inner join cursos as cu on c.curso = cu.id
where p.estado = 'PENDIENTE';

create view v_detalles_cobranzas as
select
	c.familia as familia,
	f.apellido as apellido,
	pl.detalle as pluralidad,
	month(c.fecha_creacion) as mes,
	year(c.fecha_creacion) as year,
	tu.tutor as tutor,
	cl.fecha as fecha,
	cl.hora_inicio_planeada as hora_inicio_planeada,
	cl.hora_inicio_real as hora_inicio_real,
	cl.hora_final_planeada as hora_final_planeada,
	cl.hora_final_real as hora_final_real,
	cl.estado as estado_clase,
	cu.nombre as curso,
	FORMAT(CASE when c.pluralidad = 1 THEN (c.modificador * c.bloques * t.valor_clase_individual)/2 ELSE (c.modificador * c.bloques * t.valor_clase_grupal)/2 END,1) as monto,
	t.moneda_tarifa as moneda
from cobranzas as c
inner join pluralidades as pl
	on c.pluralidad = pl.id
inner join clases as cl 
	on c.clase = cl.id
inner join familias as f
	on f.id = c.familia
inner join tarifas as t
	on f.tarifas = t.id
inner join cursos as cu on cl.curso = cu.id
inner join tutores as tu
	on cl.tutor = tu.id_tutor
where c.estado = 'PENDIENTE';

create view v_calendario_rut_dias as
    select
        ca.dt as dt,
        ru.rutina as rutina,
        ru.dia as dia,
        ru.hora_inicio as hora_inicio,
        ru.hora_fin as hora_fin,
        ru.estado as estado,
        ru.curso as curso
    from calendario as ca
    inner join rut_dias as ru on ru.dia = ca.dw;

create view v_detalles_clase as
    select
    ca.clase as clase_id,
    ca.alumno as alumno_id,
    c.tutor as tutor,
    t.tutor as n_tutor,
    concat(a.nombre,' ',a.apellido) as alumno,
    c.fecha as fecha,
    c.tipo as tipo_id,
    ti.detalle as tipo,
    c.pluralidad as id_plur,
    plr.detalle as pluralidad,
    c.hora_inicio_planeada as hora_inicio_planeada,
    c.hora_inicio_real as hora_inicio_real,
    c.hora_final_planeada as hora_final_planeada,
    c.hora_final_real as hora_final_real,
    c.curso as curso_id,
    cu.nombre as curso,
    c.rutina as rutina,
    c.estado as estado
    from clases_alumnos as ca
    inner join alumnos as a on ca.alumno = a.id
    inner join clases as c on ca.clase = c.id
    inner join tutores as t on c.tutor = t.id_tutor
    inner join tipos_clase as ti on c.tipo = ti.id
    inner join pluralidades as plr on c.pluralidad = plr.id
    inner join cursos as cu on cu.id = c.curso
    where ca.estado != 'INACTIVO'
    order by fecha, hora_inicio_planeada, clase_id;
