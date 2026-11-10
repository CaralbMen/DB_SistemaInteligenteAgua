-- 1. catálogos de ubicación
create table paises (
    id serial primary key,
    nombre varchar(50) not null
);

create table estados (
    id serial primary key,
    nombre varchar(50) not null,
    id_pais int not null,
    constraint fk_estado_pais foreign key (id_pais) references paises(id)
);

create table municipios (
    id serial primary key,
    nombre varchar(50) not null,
    id_estado int not null,
    constraint fk_municipio_estado foreign key (id_estado) references estados(id)
);

create table ciudades (
    id serial primary key,
    nombre varchar(50) not null,
    id_municipio int not null,
    constraint fk_ciudad_municipio foreign key (id_municipio) references municipios(id)
);

create table colonias (
    id serial primary key,
    nombre varchar(50) not null,
    id_ciudad int not null,
    constraint fk_colonia_ciudad foreign key (id_ciudad) references ciudades(id)
);

create table calles (
    id serial primary key,
    nombre varchar(50) not null,
    id_colonia int not null,
    constraint fk_calle_colonia foreign key (id_colonia) references colonias(id)
);

create table ubicaciones (
    id serial primary key,
    no_exterior varchar(10) not null,
    no_interior varchar(10),
    referencia varchar(100),
    id_calle int not null,
    constraint fk_ubicacion_calle foreign key (id_calle) references calles(id)
);

-- 2. zonas de abastecimiento
create table tipos_zona (
    id serial primary key,
    tipo varchar(50) not null
);

create table zonas_abastecimiento (
    id serial primary key,
    nombre varchar(50) not null,
    id_tipo_zona int not null,
    id_ubicacion int not null,
    constraint fk_zona_abastecimiento_tipo_zona foreign key (id_tipo_zona) references tipos_zona(id),
    constraint fk_zona_abastecimiento_ubicacion foreign key (id_ubicacion) references ubicaciones(id)
);

-- 3. infraestructura y activos
create table categorias_activos (
    id serial primary key,
    nombre varchar(50) not null
);

create table estados_activos (
    id serial primary key,
    estado varchar(50) not null
);

create table activos (
    id serial primary key,
    id_categoria int not null,
    no_serie varchar(20),
    id_estado_activo int not null,
    constraint fk_activo_categoria foreign key (id_categoria) references categorias_activos(id),
    constraint fk_activo_estado_activo foreign key (id_estado_activo) references estados_activos(id)
);

create table elementos_infraestructura (
    id_activo int primary key,
    capacidad int not null,
    id_ubicacion int,
    id_zona_abastecimiento int,
    caracteristicas_operativas jsonb,
    constraint fk_elemento_infraestructura_activo foreign key (id_activo) references activos(id),
    constraint fk_elemento_infraestructura_ubicacion foreign key (id_ubicacion) references ubicaciones(id),
    constraint fk_elemento_infraestructura_zona foreign key (id_zona_abastecimiento) references zonas_abastecimiento(id),
    constraint chk_capacidad_positiva check (capacidad > 0)
);

create table aspectos_medicion (
    id serial primary key,
    tipo varchar(30) not null
);

create table sensores (
    id_activo int primary key,
    id_elemento_infraestructura int not null,
    id_aspecto_medicion int not null,
    v_minimo numeric not null default 0,
    v_maximo numeric not null default 100,
    constraint fk_sensor_activo foreign key (id_activo) references activos(id),
    constraint fk_sensor_elemento foreign key (id_elemento_infraestructura) references elementos_infraestructura(id_activo),
    constraint fk_sensor_aspecto foreign key (id_aspecto_medicion) references aspectos_medicion(id),
    constraint chk_rango_sensor check (v_minimo < v_maximo)
);

-- 4. usuarios, propiedades y servicios
create table personas (
    id serial primary key,
    nombre varchar(50) not null,
    apellidop varchar(50) not null,
    apellidom varchar(50) not null,
    correo varchar(50) not null unique,
    telefono varchar(15)
);

create table tipos_propiedad (
    id serial primary key,
    tipo varchar(30) not null
);

create table propiedades (
    id serial primary key,
    id_cliente int not null,
    id_ubicacion int not null,
    id_tipo_propiedad int not null,
    constraint fk_propiedad_cliente foreign key (id_cliente) references personas(id),
    constraint fk_propiedad_ubicacion foreign key (id_ubicacion) references ubicaciones(id),
    constraint fk_propiedad_tipo foreign key (id_tipo_propiedad) references tipos_propiedad(id)
);

create table estados_servicios (
    id serial primary key,
    estado varchar(30) not null
);

create table servicios (
    id serial primary key,
    id_propiedad int not null,
    id_medidor int not null,
    id_estado int not null,
    id_zona_abastecimiento int not null,
    constraint fk_servicio_propiedad foreign key (id_propiedad) references propiedades(id),
    constraint fk_servicio_medidor foreign key (id_medidor) references activos(id),
    constraint fk_servicio_estado foreign key (id_estado) references estados_servicios(id),
    constraint fk_servicio_zona foreign key (id_zona_abastecimiento) references zonas_abastecimiento(id)
);

-- 5. telemetría
create table lecturas (
    id bigint generated always as identity primary key,
    id_sensor int not null,
    fecha_hora timestamptz not null,
    datos jsonb not null,
    constraint fk_lectura_sensor foreign key (id_sensor) references sensores(id_activo),
    constraint uq_lectura_instante unique (id_sensor, fecha_hora),
    constraint chk_documento check (
        jsonb_typeof(datos) = 'object'
        and datos ?& array['version', 'tipo_lectura', 'lectura', 'unidad', 'bateria_pct']
        and datos->>'version' = '1'
        and jsonb_typeof(datos->'tipo_lectura') = 'string'
        and jsonb_typeof(datos->'lectura') = 'number'
        and jsonb_typeof(datos->'unidad') = 'string'
        and jsonb_typeof(datos->'bateria_pct') = 'number'
        and (datos->>'bateria_pct')::numeric between 0 and 100
    )
);

-- 6. incidencias, alertas y reportes
create table tipos_incidencias (
    id serial primary key,
    tipo varchar(20) not null,
    descripcion text
);

create table incidencias (
    id serial primary key,
    id_tipo int not null,
    descripcion text,
    fecha_hora timestamptz default current_timestamp,
    constraint fk_incidencia_tipo foreign key (id_tipo) references tipos_incidencias(id)
);

create table alertas (
    id_incidencia int primary key,
    id_lectura bigint not null,
    constraint fk_alerta_incidencia foreign key (id_incidencia) references incidencias(id),
    constraint fk_alerta_lectura foreign key (id_lectura) references lecturas(id)
);

create table reportes (
    id_incidencia int primary key,
    id_servicio int not null,
    comentarios_cliente text,
    constraint fk_reporte_incidencia foreign key (id_incidencia) references incidencias(id),
    constraint fk_reporte_servicio foreign key (id_servicio) references servicios(id)
);

-- 7. órdenes de trabajo y personal
create table cuadrillas (
    id serial primary key,
    nombre varchar(30) not null
);

create table empleados (
    id_persona int primary key,
    id_cuadrilla int,
    id_domicilio int,
    no_empleado varchar(10) unique not null,
    constraint fk_empleado_persona foreign key (id_persona) references personas(id),
    constraint fk_empleado_cuadrilla foreign key (id_cuadrilla) references cuadrillas(id),
    constraint fk_empleado_domicilio foreign key (id_domicilio) references ubicaciones(id)
);

create table estados_ordenes (
    id serial primary key,
    estado varchar(20) not null
);

create table ordenes_trabajo (
    id serial primary key,
    id_incidencia int not null,
    id_cuadrilla int,
    id_estado int not null,
    fecha_inicio date,
    fecha_fin date,
    constraint fk_orden_incidencia foreign key (id_incidencia) references incidencias(id),
    constraint fk_orden_cuadrilla foreign key (id_cuadrilla) references cuadrillas(id),
    constraint fk_orden_estado foreign key (id_estado) references estados_ordenes(id)
);

-- 8. gestión de válvulas
create table estados_valvulas (
    id serial primary key,
    estado varchar(30) not null
);

create table eventos_valvulas (
    id serial primary key,
    id_valvula int not null,
    fecha_hora timestamptz not null,
    id_estado_anterior int,
    id_estado_actual int not null,
    motivo varchar(100),
    constraint fk_evento_valvula foreign key (id_valvula) references activos(id),
    constraint fk_evento_estado_anterior foreign key (id_estado_anterior) references estados_valvulas(id),
    constraint fk_evento_estado_actual foreign key (id_estado_actual) references estados_valvulas(id)
);



