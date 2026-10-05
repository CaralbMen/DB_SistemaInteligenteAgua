-- 
-- file for queries
-- CREATE DATABASE SistemaAgua;

-- INICIAN CATALOGOS PARA LAS UBICACIONES
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
-- TERMINAN CATALOGOS PARA UBICACIONES

-- INICIA ZONAS DE ABASTECIMIENTO
    -- 8.TABLA TIPOS DE ZONA (pozos, depositos, plantas de tratamiento, etc...)
    CREATE TABLE Tipos_zona(
        id SERIAL PRIMARY KEY,
        tipo VARCHAR(50) NOT NULL
    );
    -- 9.TABLA ZONAS DE ABASTECIMIENTO
    CREATE TABLE Zonas_abastecimiento(
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        id_tipo_zona INT not null,
        id_ubicacion INT NOT NULL,
        CONSTRAINT fk_zona_abastecimiento_tipo_zona FOREIGN KEY (id_tipo_zona) REFERENCES Tipos_zona(id),
        CONSTRAINT fk_zona_abastecimiento_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id)
    );
-- TERMINA ZONAS DE ABASTECIMIENTO

-- INICIAN ELEMENTOS DE LA INFRAESTRUCTURA
    -- 10.TABLA ELEMENTOS (estacion, tuberia, valvula, etc...)
    CREATE TABLE categorias_activos(
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL
    );
    -- 11.TABLA ESTADOS ACTIVOS DE LA EMPRESA (elementos)
    CREATE TABLE Estados_activos(
        id SERIAL PRIMARY KEY,
        estado VARCHAR(50) NOT NULL
    );
    -- 12.TABLA ACTIVOS
    CREATE TABLE Activos(
        id SERIAL PRIMARY KEY,
        id_categoria INT NOT NULL,
        no_serie varchar(20),
        id_estado_activo INT NOT NULL,
        CONSTRAINT fk_activo_elemento FOREIGN KEY (id_categoria) REFERENCES categorias_activos(id),
        CONSTRAINT fk_activo_estado_activo FOREIGN KEY (id_estado_activo) REFERENCES Estados_activos(id)
    );
    -- La empresa tiene activos de diferentes tipos y diferentes caracteristicas. Aqui se diferencian
    -- 13.TABLA ELEMETOS INFRAESTRUCTURA 
    -- Tanques, pozos, depositos, plantas de tratamiento, etc...
    CREATE TABLE Elementos_infraestructura(
        id_activo int PRIMARY KEY,
        capacidad INT NOT NULL,
        id_ubicacion INT,
        id_zona_abastecimiento int,
        caracteristicas_operativas JSONB,
        CONSTRAINT fk_elemento_infraestructura_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id),
        CONSTRAINT fk_elemento_infraestructura_activo FOREIGN KEY (id_activo) REFERENCES Activos(id),
        constraint fk_zona_elemento foreign key(id_zona_abastecimiento) references Zonas_abastecimiento(id),
        CONSTRAINT chk_capacidad_positiva CHECK (capacidad > 0)
    );
    -- 14. TABLA ASPECTOS MEDICION
    -- Que miden los sensores (Presion caudal, nivel de tanques, ph, turbidez, temperatura)
    create table aspectos_medicion(
        id serial primary key,
        tipo varchar(30)
    );
    -- 15. TABLA SENSORES
    create table sensores(
        id_activo int primary key,
        id_elemento_infraestructura int,
        id_aspecto_medicion int,
        constraint kf_elemento_sensor foreign key(id_elemento_infraestructura) references Elementos_infraestructura(id_activo),
        constraint fk_tipom_sensor foreign key(id_aspecto_medicion) references aspectos_medicion(id)
    );
-- TERMINAN ELEMENTOS DE LA INFRAESTRUCTURA

-- INICIAN TABLAS DE USUARIOS, PROPIEDADES Y SERVICIOS
    -- 16.TABLA CLIENTES
    CREATE TABLE Personas(
        id SERIAL PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        apellidoP VARCHAR(50) NOT NULL,
        apellidoM VARCHAR(50) NOT NULL,
        correo VARCHAR(50) NOT NULL UNIQUE,
        telefono VARCHAR(15)
    );
    -- 17. TABLA TIPOS PROPIEDAD
    CREATE TABLE Tipos_propiedad (
        id SERIAL PRIMARY KEY,
        tipo VARCHAR(30) NOT NULL
    );
    -- 18.TABLA PROPIEDAD CLIENTE
    CREATE TABLE Propiedades(
        id SERIAL PRIMARY KEY,
        id_cliente INT NOT NULL,
        id_ubicacion INT NOT NULL,
        id_tipo_propiedad int not null,
        CONSTRAINT fk_propiedad_cliente FOREIGN KEY (id_cliente) REFERENCES Personas(id),
        CONSTRAINT fk_propiedad_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id)
    );
    -- 19. TABLA ESTADOS_SERVICIOS
    -- activo, inactivo, cancelado, pendiente de pago, etc...
    create table estados_servicios(
        id serial primary key,
        estado varchar(30)
    );
    -- 20.TABLA SERVICIOS
    CREATE TABLE Servicios(
        id SERIAL PRIMARY KEY,
        id_propiedad INT NOT NULL,
        id_medidor int not null,
        id_estado int not null,
        id_zona_abastecimiento int not null,
        CONSTRAINT fk_servicio_propiedad_cliente FOREIGN KEY (id_propiedad) REFERENCES Propiedades(id),
        constraint fk_medidor_servicio foreign key(id_medidor) references activos(id),
        constraint fk_estado_servicio foreign key(id_estado) references estados_servicios(id),
        constraint fk_zona_servicio foreign key(id_zona_abastecimiento) references Zonas_abastecimiento(id)
    );
-- TERMINAN TABLAS DE USUARIOS, PROPIEDADES Y SERVICIOS

-- INICIAN TABLAS DE LECTURAS
    -- 21. TABLA LECTURAS
    create table lecturas(
        id serial primary key,
        fecha_hora timestamp default current_timestamp,
        valor_capturado decimal (15,2)
    );
    -- 21. TABLA LECTURAS DE CONSUMO
    create table lecturas_consumo(
        id_lectura int primary key,
        id_servicio int not null,
        constraint fk_lectura_consumo foreign key(id_lectura) references lecturas(id),
        constraint fk_servicio_lectura foreign key(id_servicio) references Servicios(id)
    );
    -- 22. TABLA LECTURAS DE SENSORES
    create table lecturas_sensores(
        id_lectura int primary key,
        id_sensor int,
        constraint fk_lectura_sensor foreign key(id_lectura) references lecturas(id),
        constraint fk_sensor_lectura foreign key(id_sensor) references sensores(id_activo)
    );
-- TERMINAN REGISTROS DE LECTURAS

-- INICIAN TABLAS SOBRE INCIDENCIAS
    -- 23. TABLA TIPOS_INCIDENCIAS
    -- Fuga, mala calidad, suministro
    create table tipos_incidencias(
        id serial primary key,
        tipo varchar(20),
        descripcion text
    );
    --24. TABLA INCIDENCIAS
    CREATE TABLE Incidencias(
        id SERIAL PRIMARY KEY,
        id_tipo int, -- fuga, falta_suministro, mala_calidad
        descripcion TEXT, -- Qué ha sucedido
        fecha_hora timestamp default current_timestamp,
        CONSTRAINT fk_tipo_incidencia FOREIGN KEY (id_tipo) REFERENCES tipos_incidencias(id)
    );
    -- 25. TABLA ALERTAS (es un tipo de incidencia)
    create table alertas(
        id_incidencia int primary key,
        id_lectura int,
        constraint fk_incidencia_alerta foreign key(id_incidencia) references Incidencias(id),
        constraint fk_lectura_alerta foreign key(id_lectura) references lecturas_sensores(id_lectura)
    );
    -- 26. TABLA REPORTES (es otro tipo de incidencia)
    create table reportes(
        id_incidencia int primary key,
        id_servicio int,
        comentarios_cliente text,
        constraint fk_incidencia_reporte foreign key(id_incidencia) references Incidencias(id),
        constraint fk_servicio_reporte foreign key(id_servicio) references Servicios(id)
    );
-- TERMINSN TABLAS SOBRE INCIDENCIAS

-- INICIAN TABLAS SOBRE ORDENES DE TRABAJO, EMPLEADOS Y CUADRILLAS
    -- 27. TABLA CUADRILLAS
    create table cuadrillas(
        id serial primary key,
        nombre varchar(30)
    );
    -- 28. TABLA EMPLEADOS
    create table empleados(
        id_persona int primary key,
        id_cuadrilla int,
        id_domicilio int,
        no_empleado varchar(10) unique,
        constraint fk_empleado_persona foreign key(id_persona) references Personas(id),
        constraint fk_cuadrilla_empleado foreign key(id_cuadrilla) references cuadrillas(id),
        constraint fk_ubicacion_empleado foreign key(id_domicilio) references Ubicaciones(id)
    );
    -- 29. TABLA ESTADOS_ORDENES
    create table estados_ordenes(
        id serial primary key,
        estado varchar(20)
    );
    -- 30. TABLA ORDENES_TRABAJO
    CREATE TABLE Ordenes_trabajo(
        id SERIAL PRIMARY KEY,
        id_incidencia INT,
        id_cuadrilla int,
        id_estado int, -- pendiente, en_proceso, finalizada
        fecha_inicio DATE,
        fecha_fin DATE,
        CONSTRAINT fk_orden_incidencia FOREIGN KEY (id_incidencia) REFERENCES Incidencias(id),
        constraint fk_cuadrilla_orden foreign key(id_cuadrilla) references cuadrillas(id),
        CONSTRAINT fk_estado_orden foreign key(id_estado) references estados_ordenes(id)

    );
-- TERMINAN TABLAS SOBRE ORDENES DE TRABAJO, EMPLEADOS Y CUADRILLAS

-- INICIAN TABLAS SOBRE CAMBIOS DE VALVULAS
    -- 31. TABLA ESTADOS_VALVUlAS
    create table estados_valvulas(
        id serial primary KEy,
        estado varchar(30)
    );
    -- 32. TABLA EVENTOS_VALVULAS
    CREATE TABLE Eventos_valvulas(
        id SERIAL PRIMARY KEY,
        id_valvula INT,
        fecha_hora TIMESTAMP NOT NULL,
        id_estado_anterior int, -- abierta, cerrada, mantenimiento
        id_estado_actual int,
        motivo VARCHAR(100),
        CONSTRAINT fk_evento_valvula FOREIGN KEY (id_valvula) REFERENCES Activos(id),
        CONSTRAINT fk_status_actual_valvula foreign key(id_estado_actual) REFERENCES estados_valvulas(id),
        CONSTRAINT fk_status_anterior_valvula foreign key(id_estado_anterior) REFERENCES estados_valvulas(id)
    );
-- TERMINAN TABLAS SOBRE CAMBIOS DE VALVULAS

