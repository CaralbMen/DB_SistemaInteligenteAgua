-- 
-- file for queries

CREATE DATABASE ;

-- 1.TABLA PAISES
CREATE TABLE Paises(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- 2.TABLA ESTADOS
CREATE TABLE Estados(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_pais INT NOT NULL,
    CONSTRAINT fk_estado_pais FOREIGN KEY (id_pais) REFERENCES Paises(id)
);

-- 3.TABLA MUNICIPIOS
CREATE TABLE Municipios(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_estado INT NOT NULL,
    CONSTRAINT fk_municipio_estado FOREIGN KEY (id_estado) REFERENCES Estados(id)
);

-- 4.TABLA CIUDADES
CREATE TABLE Ciudades(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_municipio INT NOT NULL,
    CONSTRAINT fk_ciudad_municipio FOREIGN KEY (id_municipio) REFERENCES Municipios(id)
);

-- 5.TABLA COLONIAS
CREATE TABLE Colonias(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_ciudad INT NOT NULL,
    CONSTRAINT fk_colonia_ciudad FOREIGN KEY (id_ciudad) REFERENCES Ciudades(id)
);

-- 6.TABLA CALLES
CREATE TABLE Calles(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_colonia INT NOT NULL,
    CONSTRAINT fk_calle_colonia FOREIGN KEY (id_colonia) REFERENCES Colonias(id)
);

-- 7.TABLA UBICACIONES
CREATE TABLE Ubicaciones(
    id SERIAL PRIMARY KEY,
    no_exterior VARCHAR(10) NOT NULL,
    no_interior VARCHAR(10),
    referencia VARCHAR(100),
    id_calle INT NOT NULL,
    CONSTRAINT fk_ubicacion_calle FOREIGN KEY (id_calle) REFERENCES Calles(id)
);

-- 8.TABLA CLIENTES
CREATE TABLE Clientes(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidoP VARCHAR(50) NOT NULL,
    apellidoM VARCHAR(50) NOT NULL,
    correo VARCHAR(50) NOT NULL UNIQUE,
    telefono VARCHAR(15)
);

-- 9.TABLA PROPIEDAD CLIENTE
CREATE TABLE Propiedad_clientes(
    id SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_ubicacion INT NOT NULL,
    CONSTRAINT fk_propiedad_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id),
    CONSTRAINT fk_propiedad_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id)
);

-- 10.TABLA SERVICIOS
CREATE TABLE Servicios(
    id SERIAL PRIMARY KEY,
    id_propiedad_cliente INT NOT NULL,
    CONSTRAINT fk_servicio_propiedad_cliente FOREIGN KEY (id_propiedad_cliente) REFERENCES Propiedad_clientes(id)
);

-- 11.TABLA ELEMENTOS
CREATE TABLE Elementos(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

-- 12.TABLA ESTADOS ACTIVOS
CREATE TABLE Estados_activos(
    id SERIAL PRIMARY KEY,
    estado VARCHAR(50) NOT NULL
);

-- 13.TABLA ACTIVOS
CREATE TABLE Activos(
    id SERIAL PRIMARY KEY,
    id_elemento INT NOT NULL,
    id_estado_activo INT NOT NULL,
    CONSTRAINT fk_activo_elemento FOREIGN KEY (id_elemento) REFERENCES Elementos(id),
    CONSTRAINT fk_activo_estado_activo FOREIGN KEY (id_estado_activo) REFERENCES Estados_activos(id)
);

-- 14.TABLA ELEMETOS INFRAESTRUCTURA
CREATE TABLE Elementos_infraestructura(
    id SERIAL PRIMARY KEY,
    capacidad INT NOT NULL,
    id_ubicacion INT,
    id_activo INT,
    CONSTRAINT fk_elemento_infraestructura_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id),
    CONSTRAINT fk_elemento_infraestructura_activo FOREIGN KEY (id_activo) REFERENCES Activos(id),
    CONSTRAINT chk_capacidad_positiva CHECK (capacidad > 0)
);

-- 15.TABLA MEDIDORES
CREATE TABLE Medidores(
    id SERIAL PRIMARY KEY,
    ultima_lectura DECIMAL(10,2) NOT NULL,
    Fecha DATE,
    Consumo_acomulado DECIMAL(10,2) NOT NULL,
    Consumo_registrado DECIMAL(10,2) NOT NULL,
    id_activo INT NOT NULL,
    CONSTRAINT fk_medidor_activo FOREIGN KEY (id_activo) REFERENCES Activos(id),
    CONSTRAINT chk_consumo_no_negativo CHECK (
        ultima_lectura >= 0 AND
        consumo_acomulado >= 0 AND
        consumo_registrado >= 0
    )
);

-- 16.TABLA RECIBOS
CREATE TABLE Recibos(
    id SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    id_servicio INT NOT NULL,
    id_medidor INT NOT NULL,
    CONSTRAINT fk_recibo_medidor FOREIGN KEY (id_medidor) REFERENCES Medidores(id),
    CONSTRAINT fk_recibo_servicio FOREIGN KEY (id_servicio) REFERENCES Servicios(id)
);

-- 17.TABLA TIPOS DE ZONA
CREATE TABLE Tipos_zona(
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL
);

-- 18.TABLA ZONAS DE ABASTECIMIENTO
CREATE TABLE Zonas_abastecimiento(
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    id_tipo_zona INT not null,
    id_ubicacion INT NOT NULL,
    CONSTRAINT fk_zona_abastecimiento_tipo_zona FOREIGN KEY (id_tipo_zona) REFERENCES Tipos_zona(id),
    CONSTRAINT fk_zona_abastecimiento_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id)
);

-- ESTAS LAS AGREGUE YO CHARLY CHECALAS O NADA 
-- 19. TABLA INCIDENCIAS
create table tipos_incidencias(
    id serial primary key,
    tipo varchar(20),
    descripcion text
);
CREATE TABLE Incidencias(
    id SERIAL PRIMARY KEY,
    id_tipo int, -- fuga, falta_suministro, mala_calidad
    descripcion TEXT,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
    CONSTRAINT fk_incidencia_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id),
    CONSTRAINT fk_tipo_incidencia FOREIGN KEY (id_tipo) REFERENCES tipos_incidencias(id)
);

-- 20. TABLA ORDENES DE TRABAJO
CREATE TABLE Ordenes_trabajo(
    id SERIAL PRIMARY KEY,
    id_incidencia INT,
    id_caudrilla int,
    id_estado int, -- pendiente, en_proceso, finalizada
    fecha_inicio DATE,
    fecha_fin DATE,
    CONSTRAINT fk_orden_incidencia FOREIGN KEY (id_incidencia) REFERENCES Incidencias(id),
    constraint fk_cuadrilla_orden foreign key(id_cuadrilla) references cuadrillas(id),
    CONSTRAINT fk_estado_orden foreign key(id_estado) references estados_ordenes(id)

);
create table estados_ordenes(
    id serial primary key,
    estado varchar(20)
);
create table cuadrillas(
    id serial primary key,
    nombre varchar(30)
);
create table empleados(
    id serial primary key,
    nombre varchar(20),
    apaterno varchar(20),
    amaterno varchar(20),
    correo varchar(50),
    id_domicilio int,
    id_cuadrilla int,
    constraint fk_ubicacion_empleado foreign key(id_domicilio) references Ubicaciones(id),
    constraint fk_cuadrilla_empleado foreign key(id_cuadrilla) references cuadrillas(id)
);

-- 21. TABLA EVENTOS VALVULAS
CREATE TABLE Eventos_valvulas(
    id SERIAL PRIMARY KEY,
    id_valvula INT,
    fecha TIMESTAMP NOT NULL,
    id_estado_actual int,
    id_estado_anterior int, -- abierta, cerrada, mantenimiento
    motivo VARCHAR(100),
    CONSTRAINT fk_evento_valvula FOREIGN KEY (id_valvula) REFERENCES Activos(id),
    CONSTRAINT fk_status_actual_valvula foreign key(id_estado_actual) REFERENCES estados_valvulas(id),
    CONSTRAINT fk_status_anterior_valvula foreign key(id_estado_anterior) REFERENCES estados_valvulas(id)
);
create table estados_valvulas(
    id serial primary KEy,
    estado varchar(30)
);
