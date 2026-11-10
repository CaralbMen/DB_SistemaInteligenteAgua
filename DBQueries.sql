-- file for db, tables and relations creation

-- 1. Mostrar todos los servicios activos

SELECT 
    s.id AS id_servicio,
    c.nombre || ' ' || c.apellidoP || ' ' || c.apellidoM AS cliente,
    es.estado AS estado_servicio
FROM Servicios s
INNER JOIN Propiedades p ON s.id_propiedad = p.id
INNER JOIN Personas c ON p.id_cliente = c.id
INNER JOIN estados_servicios es ON s.id_estado = es.id
WHERE es.estado = 'Activo';


-- 2. Mostrar los datos de los clientes y su propiedad

SELECT 
    c.id AS id_cliente,
    c.nombre || ' ' || c.apellidoP || ' ' || c.apellidoM AS cliente,
    p.id AS id_propiedad,
    tp.tipo AS tipo_propiedad
FROM Personas c
INNER JOIN Propiedades p ON c.id = p.id_cliente
INNER JOIN Tipos_propiedad tp ON p.id_tipo_propiedad = tp.id;


-- 3. Mostrar el consumo registrado por cada servicio

SELECT 
    s.id AS id_servicio,
    c.nombre || ' ' || c.apellidoP || ' ' || c.apellidoM AS cliente,
    l.fecha_hora,
    l.valor_capturado AS consumo
FROM Servicios s
INNER JOIN Propiedades p ON s.id_propiedad = p.id
INNER JOIN Personas c ON p.id_cliente = c.id
INNER JOIN lecturas_consumo lc ON s.id = lc.id_servicio
INNER JOIN lecturas l ON lc.id_lectura = l.id
ORDER BY l.fecha_hora DESC;


-- 4. Calcular el consumo total de cada servicio

SELECT 
    s.id AS id_servicio,
    c.nombre || ' ' || c.apellidoP || ' ' || c.apellidoM AS cliente,
    SUM(l.valor_capturado) AS consumo_total
FROM Servicios s
INNER JOIN Propiedades p ON s.id_propiedad = p.id
INNER JOIN Personas c ON p.id_cliente = c.id
INNER JOIN lecturas_consumo lc ON s.id = lc.id_servicio
INNER JOIN lecturas l ON lc.id_lectura = l.id
GROUP BY s.id, c.nombre, c.apellidoP, c.apellidoM
ORDER BY consumo_total DESC;


-- 5. Obtener el consumo promedio por servicio

SELECT 
    s.id AS id_servicio,
    AVG(l.valor_capturado) AS consumo_promedio
FROM Servicios s
INNER JOIN lecturas_consumo lc ON s.id = lc.id_servicio
INNER JOIN lecturas l ON lc.id_lectura = l.id
GROUP BY s.id
ORDER BY consumo_promedio DESC;


-- 6. Mostrar las zonas de abastecimiento y su tipo

SELECT 
    z.id,
    z.nombre AS zona_abastecimiento,
    tz.tipo AS tipo_zona
FROM Zonas_abastecimiento z
INNER JOIN Tipos_zona tz ON z.id_tipo_zona = tz.id;


-- 7. Mostrar los elementos de infraestructura y su estado

SELECT 
    a.id AS id_activo,
    ca.nombre AS categoria,
    ea.estado,
    ei.capacidad
FROM Activos a
INNER JOIN categorias_activos ca ON a.id_categoria = ca.id
INNER JOIN Estados_activos ea ON a.id_estado_activo = ea.id
INNER JOIN Elementos_infraestructura ei ON a.id = ei.id_activo
ORDER BY ca.nombre;


-- 8. Obtener la capacidad total de infraestructura por zona

SELECT 
    z.nombre AS zona_abastecimiento,
    SUM(ei.capacidad) AS capacidad_total
FROM Zonas_abastecimiento z
INNER JOIN Elementos_infraestructura ei 
    ON z.id = ei.id_zona_abastecimiento
GROUP BY z.id, z.nombre
ORDER BY capacidad_total DESC;


-- 9. Mostrar los sensores y qué están midiendo
select * from Elementos_infraestructura;
select * from activos;

SELECT 
    s.id_activo AS id_sensor,
    am.tipo AS tipo_medicion,
	a.no_serie AS activo
FROM sensores s
INNER JOIN aspectos_medicion am 
    ON s.id_aspecto_medicion = am.id
INNER JOIN Elementos_infraestructura ei
    ON s.id_elemento_infraestructura = ei.id_activo
inner join activos a on a.id = ei.id_activo;


-- 10. Mostrar las lecturas de los sensores

SELECT 
    ls.id_sensor,
    am.tipo AS tipo_medicion,
    l.fecha_hora,
    l.valor_capturado AS valor
FROM lecturas_sensores ls
INNER JOIN lecturas l 
    ON ls.id_lectura = l.id
INNER JOIN sensores s 
    ON ls.id_sensor = s.id_activo
INNER JOIN aspectos_medicion am 
    ON s.id_aspecto_medicion = am.id
ORDER BY l.fecha_hora DESC;


-- 11. Obtener el promedio, mínimo y máximo de cada tipo de medición

SELECT 
    am.tipo AS tipo_medicion,
    AVG(l.valor_capturado) AS promedio,
    MIN(l.valor_capturado) AS minimo,
    MAX(l.valor_capturado) AS maximo
FROM lecturas_sensores ls
INNER JOIN lecturas l 
    ON ls.id_lectura = l.id
INNER JOIN sensores s 
    ON ls.id_sensor = s.id_activo
INNER JOIN aspectos_medicion am 
    ON s.id_aspecto_medicion = am.id
GROUP BY am.tipo
ORDER BY am.tipo;


-- 12. Mostrar todas las incidencias y su tipo
SELECT 
    i.id,
    ti.tipo AS tipo_incidencia,
    i.descripcion,
    i.fecha_hora
FROM Incidencias i
INNER JOIN tipos_incidencias ti 
    ON i.id_tipo = ti.id
ORDER BY i.fecha_hora DESC;


-- 13. Contar cuántas incidencias existen por tipo

SELECT 
    ti.tipo AS tipo_incidencia,
    COUNT(i.id) AS cantidad_incidencias
FROM tipos_incidencias ti
LEFT JOIN Incidencias i 
    ON ti.id = i.id_tipo
GROUP BY ti.id, ti.tipo
ORDER BY cantidad_incidencias DESC;


-- 14. Mostrar las órdenes de trabajo y su estado
SELECT 
    ot.id AS id_orden,
    ot.fecha_inicio,
    ot.fecha_fin,
    eo.estado AS estado_orden,
    c.nombre AS cuadrilla
FROM Ordenes_trabajo ot
INNER JOIN estados_ordenes eo 
    ON ot.id_estado = eo.id
INNER JOIN cuadrillas c 
    ON ot.id_cuadrilla = c.id
ORDER BY ot.fecha_inicio DESC;


-- 15. Contar las órdenes de trabajo asignadas a cada cuadrilla

SELECT 
    c.id AS id_cuadrilla,
    c.nombre AS cuadrilla,
    COUNT(ot.id) AS total_ordenes
FROM cuadrillas c
LEFT JOIN Ordenes_trabajo ot 
    ON c.id = ot.id_cuadrilla
GROUP BY c.id, c.nombre
ORDER BY total_ordenes DESC;


insert into lecturas (id_sensor, fecha_hora, datos)
values (1, now(),
        '{"tipo_lectura": "monitoreo", "valores": {"caudal": 15.2}}'::jsonb)
returning id, datos;
 

select id, fecha_hora, datos->'valores'->>'caudal' as caudal
from lecturas
where id_sensor = 1
  and datos->>'tipo_lectura' = 'monitoreo'
order by fecha_hora desc
limit 3;
 

update lecturas
set datos = jsonb_set(datos, '{valores,caudal}', '16.8')
where id = (select max(id) from lecturas where id_sensor = 1);
 
-- UPDATE (b): agregar un campo nuevo con || (concatenación)
update lecturas
set datos = datos || '{"calibrado": true}'::jsonb
where id = (select max(id) from lecturas where id_sensor = 1);
 
select id, datos from lecturas
where id = (select max(id) from lecturas where id_sensor = 1);
 

update lecturas
set datos = datos - 'calibrado'
where id = (select max(id) from lecturas where id_sensor = 1);
 

delete from lecturas
where id = (select max(id) from lecturas where id_sensor = 1)
  and datos->'valores'->>'caudal' = '16.8';

--CONSULTAS JSONB
--1. Solo lecturas de monitoreo
select id, id_sensor, fecha_hora, datos->'valores' as valores
from lecturas
where datos->>'tipo_lectura' = 'monitoreo'
order by fecha_hora;
 
-- 2. Lecturas que contienen una clave 
select id, id_sensor, fecha_hora
from lecturas
where datos->'valores' ? 'presion';
 
-- 3. Contención de documento 
select id, id_sensor, fecha_hora, datos
from lecturas
where datos @> '{"tipo_lectura": "consumo", "id_servicio": 1}';
 
-- 4. Consumo con filtro numérico sobre un campo JSONB 
select id, datos->>'id_servicio' as id_servicio,
       (datos->>'valor_capturado')::numeric as consumo, fecha_hora
from lecturas
where datos->>'tipo_lectura' = 'consumo'
  and (datos->>'valor_capturado')::numeric > 1000
order by consumo desc;
 
-- 5. Consumo total y promedio por servicio 
select (datos->>'id_servicio')::int as id_servicio,
       count(*) as lecturas,
       sum((datos->>'valor_capturado')::numeric) as consumo_total,
       round(avg((datos->>'valor_capturado')::numeric), 2) as consumo_promedio
from lecturas
where datos->>'tipo_lectura' = 'consumo'
group by 1
order by consumo_total desc;
 
-- 6. Mezcla relacional + JSONB: lectura con su tipo de medición
select l.id, l.fecha_hora, am.tipo as aspecto, kv.key as variable, kv.value::numeric as valor
from lecturas l
join sensores s on s.id_activo = l.id_sensor
join aspectos_medicion am on am.id = s.id_aspecto_medicion
cross join lateral jsonb_each_text(l.datos->'valores') kv
where l.datos->>'tipo_lectura' = 'monitoreo'
order by l.fecha_hora;
 
-- 7. Lecturas que dispararon alerta 
select a.id_incidencia, i.descripcion, l.id as id_lectura, l.id_sensor,
       l.datos->'valores' as valores, l.fecha_hora
from alertas a
join incidencias i on i.id = a.id_incidencia
join lecturas l on l.id = a.id_lectura
order by l.fecha_hora;
 
-- 8. Estructura de claves usadas por los documentos 
select distinct jsonb_object_keys(datos->'valores') as variable
from lecturas
where datos->>'tipo_lectura' = 'monitoreo'
order by 1;
 
-- 9. Consulta con jsonb_path_query 
select id, id_sensor, datos
from lecturas
where jsonb_path_exists(datos, '$.valores.* ? (@ > 90)');

-- 1. Máximo, mínimo y promedio por variable de monitoreo
select kv.key as variable,
       count(*) as lecturas,
       min(kv.value::numeric) as minimo,
       max(kv.value::numeric) as maximo,
       round(avg(kv.value::numeric), 2) as promedio
from lecturas l
cross join lateral jsonb_each_text(l.datos->'valores') kv
where l.datos->>'tipo_lectura' = 'monitoreo'
group by kv.key
order by kv.key;
 
-- A2. Cantidad de alertas totales y por tipo de incidencia
select ti.tipo, count(*) as alertas
from alertas a
join incidencias i on i.id = a.id_incidencia
join tipos_incidencias ti on ti.id = i.id_tipo
group by ti.tipo
order by alertas desc;
 
select count(*) as total_alertas from alertas;
 
-- 3. Sensores con mayor actividad (más lecturas)
select l.id_sensor, am.tipo as aspecto, count(*) as lecturas
from lecturas l
join sensores s on s.id_activo = l.id_sensor
join aspectos_medicion am on am.id = s.id_aspecto_medicion
group by l.id_sensor, am.tipo
order by lecturas desc, l.id_sensor
limit 5;
 
-- 4. Sensores con mayor número de alertas
select l.id_sensor, am.tipo as aspecto, count(*) as alertas
from alertas a
join lecturas l on l.id = a.id_lectura
join sensores s on s.id_activo = l.id_sensor
join aspectos_medicion am on am.id = s.id_aspecto_medicion
group by l.id_sensor, am.tipo
order by alertas desc, l.id_sensor;
 
-- 5. Lecturas fuera del rango esperado del sensor (v_minimo / v_maximo)
select l.id as id_lectura, l.id_sensor, am.tipo as aspecto,
       kv.key as variable, kv.value::numeric as valor,
       s.v_minimo, s.v_maximo,
       case when kv.value::numeric < s.v_minimo then 'por debajo'
            else 'por encima' end as desviacion
from lecturas l
join sensores s on s.id_activo = l.id_sensor
join aspectos_medicion am on am.id = s.id_aspecto_medicion
cross join lateral jsonb_each_text(l.datos->'valores') kv
where l.datos->>'tipo_lectura' = 'monitoreo'
  and (kv.value::numeric < s.v_minimo or kv.value::numeric > s.v_maximo)
order by l.id_sensor, l.fecha_hora;
 
-- 6. Elementos con valores fuera de rango y su zona de abastecimiento
select distinct s.id_elemento_infraestructura, za.nombre as zona
from lecturas l
join sensores s on s.id_activo = l.id_sensor
join elementos_infraestructura ei on ei.id_activo = s.id_elemento_infraestructura
left join zonas_abastecimiento za on za.id = ei.id_zona_abastecimiento
cross join lateral jsonb_each_text(l.datos->'valores') kv
where l.datos->>'tipo_lectura' = 'monitoreo'
  and (kv.value::numeric < s.v_minimo or kv.value::numeric > s.v_maximo);
 
-- 7. Servicios con mayor consumo
select (datos->>'id_servicio')::int as id_servicio,
       sum((datos->>'valor_capturado')::numeric) as consumo_total
from lecturas
where datos->>'tipo_lectura' = 'consumo'
group by 1
order by consumo_total desc
limit 5;
 
-- 8. Válvulas con más cambios de estado
select ev.id_valvula, count(*) as eventos,
       count(*) filter (where ev.motivo is not null) as con_motivo
from eventos_valvulas ev
group by ev.id_valvula
order by eventos desc, ev.id_valvula;
 
-- 9. Transiciones de estado de válvulas
select ea.estado as estado_anterior, ec.estado as estado_actual, count(*) as veces
from eventos_valvulas ev
left join estados_valvulas ea on ea.id = ev.id_estado_anterior
join estados_valvulas ec on ec.id = ev.id_estado_actual
group by 1, 2
order by veces desc;