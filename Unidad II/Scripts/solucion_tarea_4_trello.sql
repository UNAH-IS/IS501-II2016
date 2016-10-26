--1. Mostrar todos los usuarios que no han creado ning�n tablero, para dichos usuarios mostrar el nombre completo y correo, utilizar producto cartesiano con el operador (+).
SELECT A.NOMBRE, A.CORREO
FROM TBL_USUARIOS A,
      TBL_TABLERO B
WHERE A.CODIGO_USUARIO = B.CODIGO_USUARIO_CREA(+)
AND  B.CODIGO_TABLERO IS NULL;


--2. Mostrar la cantidad de usuarios que se han registrado por cada red social, mostrar inclusive la cantidad de usuarios que no est�n registrados con redes sociales.
SELECT NVL(B.NOMBRE_RED_SOCIAL,'NINGUNA') AS RED_SOCIAL, 
      COUNT(CODIGO_USUARIO) CANTIDAD_USUARIOS
FROM TBL_USUARIOS A
FULL OUTER JOIN TBL_REDES_SOCIALES B
ON A.CODIGO_RED_SOCIAL = B.CODIGO_RED_SOCIAL
GROUP BY NVL(B.NOMBRE_RED_SOCIAL,'NINGUNA');

--3. Consultar el usuario que ha hecho m�s comentarios sobre una tarjeta (El m�s prepotente), para este usuario mostrar el nombre completo, correo, cantidad de comentarios y cantidad de tarjetas a las que ha comentado (pista: una posible soluci�n para este �ltimo campo es utilizar count(distinct campo))

--nombre completo, correo, cantidad de comentarios y cantidad de tarjetas
--192
--253
SELECT CODIGO_USUARIO
FROM (
  SELECT CODIGO_USUARIO,CODIGO_TARJETA, COUNT(1) CANTIDAD_COMENTARIOS
  FROM TBL_COMENTARIOS
  GROUP BY CODIGO_USUARIO, CODIGO_TARJETA
  ORDER BY CANTIDAD_COMENTARIOS DESC
)
WHERE ROWNUM = 1;


SELECT A.NOMBRE||' '||A.APELLIDO AS NOMBRE_COMPLETO,
      A.CORREO, 
      COUNT(1) AS CANTIDAD_COMENTARIOS,
      COUNT(DISTINCT CODIGO_TARJETA) AS CANTIDAD_TARJETAS_COMENTADAS
FROM TBL_USUARIOS A
INNER JOIN TBL_COMENTARIOS B
ON (A.CODIGO_USUARIO = B.CODIGO_USUARIO)
WHERE A.CODIGO_USUARIO IN (
        SELECT CODIGO_USUARIO
        FROM (
          SELECT CODIGO_USUARIO,CODIGO_TARJETA, COUNT(1) CANTIDAD_COMENTARIOS
          FROM TBL_COMENTARIOS
          GROUP BY CODIGO_USUARIO, CODIGO_TARJETA
          ORDER BY CANTIDAD_COMENTARIOS DESC
        )
        WHERE ROWNUM = 1
) 
GROUP BY A.NOMBRE||' '||A.APELLIDO,
      A.CORREO;

/*4. Mostrar TODOS los usuarios con plan FREE, de dichos usuarios mostrar la siguiente informaci�n:
? Nombre completo
? Correo
? Red social (En caso de estar registrado con una)
? Cantidad de organizaciones que ha creado, mostrar 0 si no ha creado ninguna.
*/

SELECT *
FROM TBL_PLANES;

SELECT A.NOMBRE,A.APELLIDO, 
        nvl(B.NOMBRE_RED_SOCIAL,'Ninguna') as NOMBRE_RED_SOCIAL,
        nvl(C.CANTIDAD_ORGANIZACIONES,0) as CANTIDAD_ORGANIZACIONES
FROM TBL_USUARIOS A
LEFT JOIN TBL_REDES_SOCIALES B
ON (A.CODIGO_RED_SOCIAL = B.CODIGO_RED_SOCIAL)
LEFT JOIN (
    SELECT CODIGO_ADMINISTRADOR, COUNT(1) CANTIDAD_ORGANIZACIONES
    FROM TBL_ORGANIZACIONES
    GROUP BY CODIGO_ADMINISTRADOR
) C
ON (A.CODIGO_USUARIO= C.CODIGO_ADMINISTRADOR)
WHERE CODIGO_PLAN = 1;

SELECT CODIGO_ADMINISTRADOR, COUNT(1) CANTIDAD_ORGANIZACIONES
FROM TBL_ORGANIZACIONES
GROUP BY CODIGO_ADMINISTRADOR;

/*5. Mostrar los usuarios que han creado m�s de 5 tarjetas, para estos usuarios mostrar:
Nombre completo, correo, cantidad de tarjetas creadas*/
SELECT  A.NOMBRE||' '||A.APELLIDO AS NOMBRE_COMPLETO,
        A.CORREO,
        COUNT(1) CANTIDAD_TARJETAS
FROM TBL_USUARIOS A
INNER JOIN TBL_TARJETAS B
ON (A.CODIGO_USUARIO = B.CODIGO_USUARIO)
GROUP BY A.NOMBRE||' '||A.APELLIDO,
        A.CORREO
HAVING COUNT(1)>5;
/*
6. Un usuario puede estar suscrito a tableros, listas y tarjetas, de tal forma que si hay alg�n cambio se le notifica en su tel�fono o por tel�fono, sabiendo esto, se necesita mostrar los nombres de todos los usuarios con la cantidad de suscripciones de cada tipo, en la consulta se debe mostrar:
? Nombre completo del usuario
? Cantidad de tableros a los cuales est� suscrito
? Cantidad de listas a las cuales est� suscrito
? Cantidad de tarjetas a las cuales est� suscrito
*/

SELECT A.NOMBRE|| ' '||A.APELLIDO AS NOMBRE_COMPLETO,
      COUNT(CODIGO_LISTA) AS CANTIDAD_LISTAS,
      COUNT(CODIGO_TABLERO) AS CANTIDAD_TABLEROS,
      COUNT(CODIGO_TARJETA) AS CANTIDAD_TARJETAS
FROM TBL_USUARIOS A
INNER JOIN TBL_SUSCRIPCIONES B
ON (A.CODIGO_USUARIO = B.CODIGO_USUARIO)
GROUP BY A.NOMBRE|| ' '||A.APELLIDO;


SELECT *
FROM TBL_SUSCRIPCIONES;

/*
7. Consultar todas las organizaciones con los siguientes datos:
? Nombre de la organizaci�n
? Cantidad de usuarios registrados en cada organizaci�n*/

SELECT CODIGO_ORGANIZACION, COUNT(*) CANTIDAD_USUARIOS
FROM TBL_USUARIOS_X_ORGANIZACION
GROUP BY CODIGO_ORGANIZACION;

/*
? Cantidad de Tableros por cada organizaci�n
*/
SELECT CODIGO_ORGANIZACION, COUNT( CODIGO_TABLERO) CANTIDAD_TABLEROS
FROM TBL_TABLERO
GROUP BY CODIGO_ORGANIZACION;
/*
? Cantidad de Listas asociadas a cada organizaci�n
*/
SELECT A.CODIGO_ORGANIZACION, COUNT(B.CODIGO_LISTA) AS CANTIDAD_LISTAS
FROM TBL_TABLERO A 
INNER JOIN TBL_LISTAS B
ON (A.CODIGO_TABLERO = B.CODIGO_TABLERO)
GROUP BY A.CODIGO_ORGANIZACION;

/*
? Cantidad de Tarjetas asociadas a cada organizaci�n
*/
SELECT A.CODIGO_ORGANIZACION, COUNT(C.CODIGO_TARJETA) AS CANTIDAD_TARJETAS
FROM TBL_TABLERO A 
LEFT JOIN TBL_LISTAS B
ON (A.CODIGO_TABLERO = B.CODIGO_TABLERO)
LEFT JOIN TBL_TARJETAS C
ON (B.CODIGO_LISTA = C.CODIGO_LISTA)
GROUP BY A.CODIGO_ORGANIZACION;



SELECT A.NOMBRE_ORGANIZACION,
      NVL(B.CANTIDAD_USUARIOS,0) AS CANTIDAD_USUARIOS,
      NVL(C.CANTIDAD_TABLEROS,0) AS CANTIDAD_TABLEROS,
      NVL(D.CANTIDAD_LISTAS,0) AS CANTIDAD_LISTAS,
      NVL(E.CANTIDAD_TARJETAS,0) AS CANTIDAD_TARJETAS
FROM TBL_ORGANIZACIONES A 
LEFT JOIN (
    SELECT CODIGO_ORGANIZACION, COUNT(*) CANTIDAD_USUARIOS
    FROM TBL_USUARIOS_X_ORGANIZACION
    GROUP BY CODIGO_ORGANIZACION
) B
ON (A.CODIGO_ORGANIZACION = B.CODIGO_ORGANIZACION)
LEFT JOIN (
    SELECT CODIGO_ORGANIZACION, COUNT( CODIGO_TABLERO) CANTIDAD_TABLEROS
    FROM TBL_TABLERO
    GROUP BY CODIGO_ORGANIZACION
) C
ON (A.CODIGO_ORGANIZACION = C.CODIGO_ORGANIZACION)
LEFT JOIN (
    SELECT A.CODIGO_ORGANIZACION, COUNT(B.CODIGO_LISTA) AS CANTIDAD_LISTAS
    FROM TBL_TABLERO A 
    INNER JOIN TBL_LISTAS B
    ON (A.CODIGO_TABLERO = B.CODIGO_TABLERO)
    GROUP BY A.CODIGO_ORGANIZACION
) D
ON (A.CODIGO_ORGANIZACION = D.CODIGO_ORGANIZACION)
LEFT JOIN (
    SELECT A.CODIGO_ORGANIZACION, COUNT(C.CODIGO_TARJETA) AS CANTIDAD_TARJETAS
    FROM TBL_TABLERO A 
    LEFT JOIN TBL_LISTAS B
    ON (A.CODIGO_TABLERO = B.CODIGO_TABLERO)
    LEFT JOIN TBL_TARJETAS C
    ON (B.CODIGO_LISTA = C.CODIGO_LISTA)
    GROUP BY A.CODIGO_ORGANIZACION
) E
ON (A.CODIGO_ORGANIZACION = E.CODIGO_ORGANIZACION)
ORDER BY CANTIDAD_TARJETAS DESC;


/*
8. Crear una vista materializada con la informaci�n de facturaci�n, los campos a incluir son los siguientes:
? C�digo factura
? Nombre del plan a facturar
? Nombre completo del usuario
? Fecha de pago (Utilizar fecha inicio, mostrarla en formato D�a-Mes-A�o)
? A�o y Mes de pago (basado en la fecha inicio)
? Monto de la factura
? Descuento
? Total neto
*/
CREATE MATERIALIZED VIEW MVW_FACTURAS_USUARIOS AS
SELECT A.NOMBRE||' '||A.APELLIDO AS NOMBRE_COMPLETO,
      B.CODIGO_FACTURA,
      TO_CHAR(B.FECHA_INICIO,'dd-mm-yyyy') FECHA_PAGO,
      TO_CHAR(B.FECHA_INICIO,'yyyy-MM') ANIO_MES_PAGO,
      C.NOMBRE_PLAN,
      ROUND(B.MONTO,2) AS MONTO,
      ROUND(B.DESCUENTO,2) AS DESCUENTO,
      ROUND(B.MONTO - B.DESCUENTO,2) AS TOTAL_NETO
FROM TBL_USUARIOS A
INNER JOIN TBL_FACTURACION_PAGOS B
ON (A.CODIGO_USUARIO = B.CODIGO_USUARIO)
INNER JOIN TBL_PLANES C 
ON (B.CODIGO_PLAN = C.CODIGO_PLAN);

SELECT * FROM MVW_FACTURAS_USUARIOS;
/*
9. Crear una tabla din�mica en excel que consulte la informaci�n de la vista materializada del inciso anterior, de dicha tabla din�mica crear un gr�fico de l�nea que muestre en el eje X el campo A�o/mes de pago y en el eje Y los nombres de los planes, el valor num�rico a mostrar en la grafica deber� ser el Total neto.*/




/*Mostrar la cantidad de usuarios que han hecho m�s de 2 comentarios, mostrar la siguiente informaci�n:
? Nombre completo del usuario
? Correo
? Cantidad de comentario
? Fecha del �ltimo comentario
? Fecha del primer comentario
? Red social en caso de estar registrado con una*/

SELECT A.NOMBRE||' '||A.APELLIDO AS NOMBRE_COMPLETO,
      A.CORREO,
      COUNT(1) CANTIDAD_COMENTARIOS,
      MAX(B.FECHA_PUBLICACION) AS FECHA_ULTIMO_COMENTARIO,
      MIN(B.FECHA_PUBLICACION) AS FECHA_PRIMER_COMENTARIO
FROM TBL_USUARIOS A
INNER JOIN TBL_COMENTARIOS B
ON (A.CODIGO_USUARIO = B.CODIGO_USUARIO)
GROUP BY A.NOMBRE||' '||A.APELLIDO,
      A.CORREO
HAVING COUNT(1)>2;