use myc599g_bd;

--Crear Tablas
create table categorias (
	id varchar(2) primary key,
    detalle varchar(50)
);

create table niveles (
    id int primary key,
    descripcion varchar(30)
);

create table distritos (
	id int primary key,
    nombre varchar(80)
);

create table tipos_clase(
	id int primary key,
    detalle varchar(20)
);

create table estados(
	id varchar(15) primary key
);

create table tarifas(
    id int primary key auto_increment,
    nombre varchar(5),
    valor_clase_individual int,
    valor_clase_grupal int,
    moneda_tarifa varchar(3)
);

create table familias (
    id int primary key auto_increment,
    apellido varchar(100),
    tarifas int,
    estado varchar(15),
    foreign key (tarifas) references tarifas(id)
);

create table padres(
	id int primary key auto_increment,
    nombre varchar(60),
    apellidos varchar(60),
    genero binary,
    estado varchar(15),
    telefono varchar(20),
    mail varchar(80),
    familia int,
    foreign key (familia) references familias(id),
    foreign key (estado) references estados(id)
);

create table centros_educativos (
	id int primary key auto_increment,
    nombre varchar(80),
    categoria varchar(2),
    foreign key (categoria) references categorias(id)
);

create table nivel_centro_educativos (
    id int primary key auto_increment,
    ccee int,
    nivel int,
    foreign key (ccee) references centros_educativos(id),
    foreign key (nivel) references niveles(id)
);

create table carreras (
    id int primary key auto_increment,
    nombre varchar(50)
);
create table ccee_carreras(
    centro_educativo int,
    carrera int,
    ciclos int,
    foreign key (centro_educativo) references centros_educativos(id),
    foreign key (carrera) references carreras(id)
);

create table grados (
	id int primary key auto_increment,
    nombre varchar(50),
    nivel int,
    foreign key (nivel) references niveles(id)
);

create table distritos_profes(
	distrito int,
    tutor int,
    tipo int,
    foreign key (tutor) references tutores(id_tutor),
    foreign key (distrito) references distritos(id)
);

create table alumnos(
	id int primary key auto_increment,
    nombre varchar(80),
    apellido varchar(80),
    distrito int,
    ccee int,
    genero binary,
    direccion varchar(255),
    familia int,
    grado int,
    nivel int,
    estado varchar(15),
    foreign key (grado) references grados(id),
    foreign key (distrito) references distritos(id),
    foreign key (familia) references familias(id),
    foreign key (ccee) references centros_educativos(id),
    foreign key (estado) references estados(id)
);

create table rutinas (
	id int primary key auto_increment,
    tutor int,
    estado varchar(15),
    fecha_vencimiento date,
    fecha_creacion datetime,
    rutina_key varchar(60),
    foreign key (estado) references estados(id),
    foreign key (tutor) references tutores(id_tutor)
);

create table cursos (
    id int primary key,
    nombre varchar(50),
    nivel int,
    foreign key (nivel) references niveles(id)
);

create table rut_dias (
	rutina int,
    dia int,
    hora_inicio time,
    hora_fin time,
    estado varchar(15),
    curso int,
    foreign key (estado) references estados(id),
    foreign key (rutina) references rutinas(id),
    foreign key (curso) references cursos(id)
);

create table cobranzas (
    id int primary key auto_increment,
    familia int,
    bloques int,
    pluralidad int,
    fecha_creacion datetime,
    clase int,
    estado varchar(15),
    modificador decimal(2,1),
    foreign key (familia) references familias(id),
    foreign key (estado) references estados(id)
);
create table pagos (
    id int primary key auto_increment,
    tutor int,
    bloques int,
    pluralidad int,
    fecha_creacion datetime,
    clase int,
    estado varchar(15),
    foreign key (tutor) references tutores(id_tutor),
    foreign key (estado) references estados(id)
);

create table pluralidades (
    id int primary key,
    detalle varchar(20)
);

create table clases (
	id int primary key auto_increment,
    tutor int,
    fecha date,
    tipo int,
    pluralidad int,
    rutina int,
    estado varchar(15),
    hora_inicio_planeada time,
    hora_inicio_real time,
    hora_final_planeada time,
    hora_final_real time,
    curso int,
    wd int,
    foreign key (estado) references estados(id),
    foreign key (rutina) references rutinas(id),
    foreign key (pluralidad) references pluralidades(id),
    foreign key (tutor) references tutores(id_tutor),
    foreign key (tipo) references tipos_clase(id),
    foreign key (curso) references cursos(id)
);

create table intranet_usuarios (
    username varchar(100) primary key,
    nombre varchar(100),
    apellido varchar(100),
    pass_hash varchar(100),
    create_date datetime,
    grupo int,
    ultimo_login datetime,
    estado varchar(15),
    tutor int null,
    foreign key (grupo) references grupos(id),
    foreign key (tutor) references tutores(id_tutor),
    foreign key (estado) references estados(id)
);

create table tutores_cursos(
    tutor int,
    curso int,
    foreign key (tutor) references tutores(id_tutor),
    foreign key (curso) references cursos(id)
);

create table internal_tutores(
    id int primary key,
    edad smallint,
    categoria varchar(20),
    genero varchar(1),
    colegio_origen int,
    universidad int,
    carrera int,
    grado int,
    horas_max int,
    fecha_creacion date,
    fecha_vencimiento date,
    ultima_renovacion date,
    supervisor varchar(100),
    estado varchar(15),
    foreign key (supervisor) references intranet_usuarios(username),
    foreign key (id) references tutores(id_tutor),
    foreign key (carrera) references carreras(id),
    foreign key (estado) references estados(id),
    foreign key (colegio_origen) references centros_educativos(id),
    foreign key (universidad) references centros_educativos(id),
    foreign key (grado) references grados(id),
    foreign key (estado) references estados(id)
    
);

create table tipos_eventos(
    id int primary key,
    nombre varchar(20)
);

create table calendario (
    dt date not null primary key,
    y smallint null,
    m tinyint null,
    d tinyint null,
    dw tinyint null
);

create table integers (
    i tinyint
);

create table eventos (
    id int primary key auto_increment,
    tipo_evento int,
    clase int,
    destinatario int,
    causante varchar(20),
    creacion datetime,
    estado varchar(15),
    comentario varchar(255),
    foreign key (tipo_evento) references tipos_eventos(id),
    foreign key (clase) references clases(id),
    foreign key (destinatario) references padres(id)
    
);

create table tutores_alumnos(
    id_t int,
    id_a int,
    foreign key (id_t) references tutores(id_tutor),
    foreign key (id_a) references alumnos(id)
);

create table clases_alumnos(
    id int primary key auto_increment,
    alumno int,
    clase int,
    estado varchar(15),
    rutina int,
    foreign key (alumno) references alumnos(id),
    foreign key (clase) references clases(id),
    foreign key (rutina) references rutinas(id),
    foreign key (estado) references estados(id)
);

create table constantes (
    id int primary key auto_increment,
    nombre_constante varchar(40),
    valor_1 int,
    valor_2 int,
    valor_3 int
);
--Testeado 19/9/2017