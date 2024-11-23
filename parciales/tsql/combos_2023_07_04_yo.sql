/*
2. Se requiere realizar una verificación de los precios de los COMBOS, para
ello se solicita que cree el o los objetos necesarios para realizar una
operación que actualice que el precio de un producto compuesto
(COMBO) es el 90% de la suma de los precios de sus componentes por
las cantidades que los componen. Se debe considerar que un producto
compuesto puede estar compuesto por otros productos compuestos.
*/


--
GO
DROP FUNCTION dbo.nuevo_precio_prodcuto_combo;

GO
CREATE FUNCTION nuevo_precio_prodcuto_combo(@codigo_producto_combo char(8))
RETURNS decimal(12,2)
AS
BEGIN
	DECLARE @precio_combo decimal(12,2) = 0 
	DECLARE @precio_producto decimal(12,2)
	DECLARE @cantidad_producto decimal(12,2)

	DECLARE cursor_companentes CURSOR FOR
		SELECT comp_cantidad,prod_precio FROM Composicion
			INNER JOIN Producto ON comp_componente = prod_codigo
			WHERE comp_producto = @codigo_producto_combo
	OPEN cursor_companentes
	FETCH NEXT FROM cursor_companentes 
	INTO @cantidad_producto, @precio_producto
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
			set @precio_combo += @cantidad_producto * @precio_producto

	FETCH NEXT FROM cursor_companentes 
	INTO @cantidad_producto, @precio_producto
	END
	CLOSE cursor_companentes
	DEALLOCATE cursor_companentes
	RETURN @precio_combo * 0.9
END

GO
DROP PROCEDURE actualizar_precios_combos
GO
CREATE PROCEDURE actualizar_precios_combos 
AS
BEGIN
	DECLARE @id_prodcuto char(8)
	--PRIMERO AHOGO LOS COMPUESTOS QUE NO TIENEN COMPUESTOS
	DECLARE cursor_combos_simples CURSOR FOR
	SELECT comp_producto  FROM Composicion c1 --SOLO SELECCIONO LOS PRODUCTOS COMPUESTOS QUE NO TIENEN COMPUESTO
		GROUP BY c1.comp_producto
		HAVING
		NOT EXISTS(SELECT * FROM Composicion c2 WHERE c1.comp_producto = c2.comp_componente) ;
	
	OPEN cursor_combos_simples
		FETCH NEXT FROM cursor_combos_simples 
		INTO @id_prodcuto
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			UPDATE Producto SET prod_precio = dbo.nuevo_precio_prodcuto_combo(@id_prodcuto)
				WHERE prod_codigo = @id_prodcuto
			
		FETCH NEXT FROM cursor_combos_simples 
		INTO @id_prodcuto
		END
		CLOSE cursor_combos_simples
		DEALLOCATE cursor_combos_simples

	--AHORA AHOGO LOS COMPUESTOS DE COMPUESTOS
	DECLARE cursor_combos_de_combos CURSOR FOR
	SELECT comp_producto  FROM Composicion c1 --SOLO SELECCIONO LOS PRODUCTOS COMPUESTOS QUE TIENEN COMPUESTO
		GROUP BY c1.comp_producto
		HAVING
		EXISTS(SELECT * FROM Composicion c2 WHERE c1.comp_producto = c2.comp_componente) ;
	
	OPEN cursor_combos_de_combos
		FETCH NEXT FROM cursor_combos_de_combos 
		INTO @id_prodcuto
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			UPDATE Producto SET prod_precio = dbo.nuevo_precio_prodcuto_combo(@id_prodcuto)
				WHERE prod_codigo = @id_prodcuto
			
		FETCH NEXT FROM cursor_combos_de_combos 
		INTO @id_prodcuto
		END
		CLOSE cursor_combos_de_combos
		DEALLOCATE cursor_combos_de_combos

END

-- PARA VERIFICAR


SELECT * FROM Composicion WHERE comp_producto NOT IN(SELECT comp_componente FROM Composicion) ; -- PRIMERO HACEMOS LOS QUE NO SON compuestos con compuestos
SELECT prod_codigo,prod_precio FROM Producto WHERE prod_codigo IN (
	SELECT comp_producto  FROM Composicion c1
		GROUP BY c1.comp_producto
		HAVING
		NOT EXISTS(SELECT * FROM Composicion c2 WHERE c1.comp_producto = c2.comp_componente) 
	);

SELECT prod_codigo,prod_precio FROM Producto WHERE prod_codigo IN (
	SELECT comp_producto  FROM Composicion c1
		GROUP BY c1.comp_producto
		HAVING
		EXISTS(SELECT * FROM Composicion c2 WHERE c1.comp_producto = c2.comp_componente)
		);

SELECT * FROM Composicion WHERE comp_producto IN(SELECT comp_componente FROM Composicion) ;

SELECT prod_precio * 10 * 0.9 FROM Producto WHERE prod_codigo IN ('00006408','00006409')

EXECUTE actualizar_precios_combos