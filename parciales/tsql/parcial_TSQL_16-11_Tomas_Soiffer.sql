/*
T-SQL
Tomas Soiffer Legajo: 158793-6 16/11/2024

Implementar los objetos necesarios para registrar, en tiempo real, los 10 productos mas vendidos por año en una tabla especifica. 
Esta tabla debe contener exclusivamente la informacion requerida, sin incluir filas adicionales.
Los "mas vendidos" se definden como aquellos productos con el mayor numero de unidades vendidas

*/
--DROP TABLE producto_mas_vendidos;

CREATE TABLE producto_mas_vendidos (
producto_codigo CHAR(8),
)

--DROP PROCEDURE actualizar_mas_vendidos

GO
CREATE PROCEDURE actualizar_mas_vendidos
AS
BEGIN
	DELETE FROM producto_mas_vendidos;
	INSERT INTO producto_mas_vendidos (producto_codigo)
            SELECT TOP 10 
				p.prod_codigo FROM Producto p
				INNER JOIN Item_Factura ON item_producto = p.prod_codigo
				GROUP BY  p.prod_codigo
				ORDER BY SUM(item_cantidad) DESC	
END

exec actualizar_mas_vendidos

SELECT * FROM producto_mas_vendidos;

--DROP TRIGGER registrar_mas_vendidos

GO
CREATE TRIGGER registrar_mas_vendidos
	ON ITEM_FACTURA
	AFTER INSERT
AS
BEGIN TRANSACTION
	IF( (SELECT COUNT(producto_codigo ) FROM producto_mas_vendidos pmv WHERE
        pmv.producto_codigo IN (SELECT TOP 10 
		p.prod_codigo FROM Producto p
		INNER JOIN Item_Factura ON item_producto = p.prod_codigo
		GROUP BY  p.prod_codigo
		ORDER BY SUM(item_cantidad) DESC)) <> 10 --Verificamos si el top 10 actual es distinto al top 10 original
	) 
	BEGIN
		exec actualizar_mas_vendidos
		PRINT('Se actulazo la tabla producto_mas_vendidos')
	END
	--Solo actualizamos si es distintos el top 10
COMMIT TRANSACTION


/*
--PARA TESTEAR


UPDATE producto_mas_vendidos SET producto_codigo = '00001444' WHERE producto_codigo = '00001420'
SELECT * FROM producto_mas_vendidos;
DELETE FROM Item_Factura WHERE  item_tipo = 'A' AND item_sucursal  = '0003' AND item_numero =  '00092444' AND item_producto =  '00001415'
INSERT INTO Item_Factura (item_tipo,item_sucursal,item_numero,item_producto,item_cantidad,item_precio) 
	VALUES ('A','0003','00092444','00001415',100.00,1.24)
SELECT * FROM producto_mas_vendidos;
*/