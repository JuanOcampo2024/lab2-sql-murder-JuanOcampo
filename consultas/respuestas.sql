-- Paso 1: Buscar el reporte del asesinato ocurrido el 15 de enero de 2018 en SQL City.
--El cual nos dará la descripción del crimen y los posibles testigos.

SELECT *
FROM crime_scene_report
WHERE city = 'SQL City'
  AND date = 20180115
  AND type = 'murder';

-- Paso 2: Encontrar al testigo que vive en la última casa de Northwestern Dr.
-- Ordenamos las direcciones de mayor a menor para encontrar la ultima casa.
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;

-- Paso 3: Averiguar por la testiga llamada Annabel, que vive en Franklin Ave.
SELECT *
FROM person
WHERE name LIKE '%Annabel%'
AND address_street_name = 'Franklin Ave';

-- Paso 4: Leer las entrevistas de los testigos para encontrar pistas del asesino.
SELECT *
FROM interview
WHERE person_id IN (
    SELECT id
    FROM person
    WHERE name = 'Morty Schapiro')
OR person_id IN (
    SELECT id
    FROM person
    WHERE name = 'Annabel Miller');

-- Paso 5: Buscar registros de entrada al gimnasio el 9 de enero del 2018.
-- para membresías que comiencen con 48Z.
SELECT *
FROM get_fit_now_check_in
WHERE membership_id LIKE '48Z%'
AND check_in_date = 20180109;

-- Paso 6: Identificar a las personas que tienen membresías del gimnasio con id "48Z"
SELECT gm.id, gm.person_id, p.name, gm.membership_status
FROM get_fit_now_member gm
JOIN person p
ON gm.person_id = p.id
WHERE gm.id LIKE '48Z%';

-- Paso 7: Revisar cuál de los sospechosos coincide con la descripción del vehículo.
SELECT p.name, dl.hair_color, dl.gender, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl
ON p.license_id = dl.id
WHERE p.name IN ('Joe Germuska','Jeremy Bowers');

-- Paso 8: Confirmo revisando la entrevista de Jeremy Bowers.
SELECT *
FROM interview
WHERE person_id = (
SELECT id FROM person WHERE name = 'Jeremy Bowers');

-- Paso 9: La entrevista de Jeremy Bowers dice que fue contratado por una mujer
-- pelirroja, de entre 65 y 67 pulgadas de estatura, que conduce un Tesla Model S.
-- Busco a las candidatas que cumplen esas características.
SELECT p.id, p.name, dl.height, dl.hair_color, dl.gender, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl
ON p.license_id = dl.id
WHERE dl.gender = 'female'
AND dl.hair_color = 'red'
AND dl.height BETWEEN 65 AND 67
AND dl.car_make = 'Tesla'
AND dl.car_model = 'Model S';

-- Paso 10: Jeremy también dice que la mujer asistió 3 veces al SQL Symphony Concert
-- en diciembre de 2017. Filtro las personas que cumplan con esa asistencia exacta.
SELECT p.id, p.name, COUNT(*) AS veces_asistio
FROM person p
JOIN facebook_event_checkin f
ON p.id = f.person_id
WHERE f.event_name = 'SQL Symphony Concert'
AND f.date BETWEEN 20171201 AND 20171231
GROUP BY p.id, p.name
HAVING COUNT(*) = 3;

-- Paso 11: Cruzo ambas pistas para encontrar a la autora intelectual del crimen.
SELECT p.id, p.name
FROM person p
JOIN drivers_license dl
ON p.license_id = dl.id
JOIN facebook_event_checkin f
ON p.id = f.person_id
WHERE dl.gender = 'female'
AND dl.hair_color = 'red'
AND dl.height BETWEEN 65 AND 67
AND dl.car_make = 'Tesla'
AND dl.car_model = 'Model S'
AND f.event_name = 'SQL Symphony Concert'
AND f.date BETWEEN 20171201 AND 20171231
GROUP BY p.id, p.name
HAVING COUNT(*) = 3;

-- Paso 12: Envío a la plataforma el nombre del asesino identificado
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
        
        SELECT value FROM solution;

-- Paso 13: Envío a la plataforma el nombre de la persona que contrató al asesino
INSERT INTO solution VALUES (1, 'Miranda Priestly');
        
        SELECT value FROM solution;
