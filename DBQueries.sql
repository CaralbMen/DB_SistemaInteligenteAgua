-- file for db, tables and relations creation

-- 1. Mostrar todos los servicios activos

SELECT 
    s.id AS id_servicio,
    c.nombre || ' ' || c.apellidoP || ' ' || c.apellidoM AS cliente,
    es.estado AS estado_servicio
FROM Servicios s
INNER JOIN Propiedades p ON s.id_propiedad = p.id
INNER JOIN Clientes c ON p.id_cliente = c.id
INNER JOIN estados_servicios es ON s.id_estado = es.id
WHERE es.estado = 'Activo';


-- 2. Mostrar los datos de los clientes y su propiedad

SELECT 
    c.id AS id_cliente,
    c.nombre || ' ' || c.apellidoP || ' ' || c.apellidoM AS cliente,
    p.id AS id_propiedad,
    tp.tipo AS tipo_propiedad
FROM Clientes c
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
INNER JOIN Clientes c ON p.id_cliente = c.id
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
INNER JOIN Clientes c ON p.id_cliente = c.id
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

SELECT 
    s.id_activo AS id_sensor,
    am.tipo AS tipo_medicion,
    ei.id_activo AS infraestructura
FROM sensores s
INNER JOIN aspectos_medicion am 
    ON s.id_aspecto_medicion = am.id
INNER JOIN Elementos_infraestructura ei
    ON s.id_elemento_infraestructura = ei.id_activo;


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


