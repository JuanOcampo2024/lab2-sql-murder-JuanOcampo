# Lab 2 - SQL Murder Mystery  
**Detective:** Juan Pablo Ocampo Soto

## Resumen del Caso

En esta investigación se resolvió el asesinato ocurrido en **SQL City** el **15 de enero de 2018**.  
A partir del reporte de la escena del crimen, las entrevistas a los testigos, los registros del gimnasio, las licencias de conducción y la asistencia a eventos, se logró identificar primero al asesino material, **Jeremy Bowers**, y después a la persona que lo contrató, **Miranda Priestly**.

## Bitácora de Investigación

La investigación comenzó consultando el reporte de la escena del crimen para conocer los detalles iniciales del caso. Este reporte indicó que existían dos testigos clave: una persona que vivía en la última casa de **Northwestern Dr** y otra llamada **Annabel** que residía en **Franklin Ave**.

A continuación, se buscaron ambos testigos en la tabla `person` y luego se consultaron sus entrevistas en la tabla `interview`. Gracias a estas declaraciones se descubrió que el sospechoso había salido del gimnasio **Get Fit Now**, que tenía una membresía tipo **gold** cuyo identificador comenzaba por **48Z**, que había estado allí el **9 de enero de 2018**, y que además era un hombre que conducía un **Tesla Model S** con una placa que contenía **H42W**.

Con estas pistas, se revisaron los registros de entrada al gimnasio y las membresías correspondientes. Esto permitió reducir los sospechosos a dos personas. Luego, al cruzar esa información con la tabla de licencias de conducción, se identificó a **Jeremy Bowers** como el asesino material.

Después se consultó la entrevista de Jeremy Bowers, donde confesó que había sido contratado por una mujer. Según su declaración, esta mujer era pelirroja, medía entre **65 y 67 pulgadas**, conducía un **Tesla Model S** y había asistido **tres veces** al evento **SQL Symphony Concert** durante diciembre de 2017.

Finalmente, se cruzaron las pistas físicas, del vehículo y del evento para encontrar a la autora intelectual del crimen. El resultado final señaló a **Miranda Priestly**, confirmando así el cierre del caso.

## Desarrollo de la Investigación

### 1. Reporte de la escena del crimen

```sql
SELECT *
FROM crime_scene_report
WHERE city = 'SQL City'
AND date = 20180115
AND type = 'murder';

--Esta consulta permitió obtener la descripción inicial del caso.
--La pista principal encontrada fue que había dos testigos: uno vivía en la última casa de Northwestern Dr y el otro testigo era Annabel, residente de Franklin Ave.

SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;

--Con esta consulta se identificó al testigo que vivía en la última casa de la calle mencionada.
--El resultado señaló a Morty Schapiro.

SELECT *
FROM person
WHERE name LIKE '%Annabel%'
AND address_street_name = 'Franklin Ave';

--Aquí se localizó al segundo testigo clave de la investigación.
--La consulta permitió identificar a Annabel Miller.

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

--Las entrevistas aportaron la mayor parte de las pistas iniciales del sospechoso.
--A partir de ellas se descubrió lo siguiente:
--El asesino estuvo en el gimnasio Get Fit Now.
--Su membresía comenzaba por 48Z.
--Tenía membresía gold.
--Estuvo allí el 2018-01-09.
--Era un hombre pelirrojo.
--Conducía un Tesla Model S.
--Su placa contenía H42W.

SELECT *
FROM get_fit_now_check_in
WHERE membership_id LIKE '48Z%'
AND check_in_date = 20180109;

--Esta consulta permitió filtrar los posibles sospechosos a partir de la información entregada por los testigos.
--Se encontraron las membresías que coincidían con la fecha y el patrón del identificador.

SELECT gm.id, gm.person_id, p.name, gm.membership_status
FROM get_fit_now_member gm
JOIN person p
ON gm.person_id = p.id
WHERE gm.id LIKE '48Z%';

--Aquí se identificaron los nombres de las personas asociadas a las membresías sospechosas.
--Los dos principales sospechosos encontrados fueron:
--Joe Germuska
--Jeremy Bowers

SELECT p.name, dl.hair_color, dl.gender, dl.car_make, dl.car_model, dl.plate_number
FROM person p
JOIN drivers_license dl
ON p.license_id = dl.id
WHERE p.name IN ('Joe Germuska','Jeremy Bowers');

--Esta consulta se usó para verificar cuál de los sospechosos coincidía con la descripción dada por Annabel Miller.
--El sospechoso que coincidió con cabello rojo, Tesla Model S y placa con H42W fue Jeremy Bowers.

SELECT *
FROM interview
WHERE person_id = (
SELECT id FROM person WHERE name = 'Jeremy Bowers');

--Esta entrevista confirmó que Jeremy Bowers era el asesino material.
--Además, reveló una nueva pista: había sido contratado por una mujer con ciertas características físicas y de comportamiento.

SELECT p.id, p.name, dl.height, dl.hair_color, dl.gender, dl.car_make, dl.car_model
FROM person p
JOIN drivers_license dl
ON p.license_id = dl.id
WHERE dl.gender = 'female'
AND dl.hair_color = 'red'
AND dl.height BETWEEN 65 AND 67
AND dl.car_make = 'Tesla'
AND dl.car_model = 'Model S';

--Con esta consulta se redujo la lista de posibles autoras intelectuales del crimen.
--El filtro se realizó usando la descripción física y el vehículo mencionados por Jeremy.

SELECT p.id, p.name, COUNT(*) AS veces_asistio
FROM person p
JOIN facebook_event_checkin f
ON p.id = f.person_id
WHERE f.event_name = 'SQL Symphony Concert'
AND f.date BETWEEN 20171201 AND 20171231
GROUP BY p.id, p.name
HAVING COUNT(*) = 3;

--Aquí se filtraron las personas que asistieron exactamente tres veces al evento mencionado.
--Esta pista permitió reducir aún más el número de candidatas.

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

--Esta fue la consulta decisiva de la segunda parte del caso.
--Al cruzar todas las pistas, la persona identificada como autora intelectual fue Miranda Priestly.