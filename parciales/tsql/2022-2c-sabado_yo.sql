/*
2. Implementar una regla de negocio de validación en línea que permita
validar el STOCK al realizarse una venta. Cada venta se debe
descontar sobre el depósito 00. En caso de que se venda un producto
compuesto, el descuento de stock se debe realizar por sus
componentes. Si no hay STOCK para ese artículo, no se deberá
guardar ese artículo, pero si los otros en los cuales hay stock positivo.
Es decir, solamente se deberán guardar aquellos para los cuales si hay
stock, sin guardarse los que no poseen cantidades suficientes.
*/

ALTER TRIGGER control_stock
	ON item_factura
	INSTEAD OF INSERT
AS
BEGIN TRANSACTION
	DECLARE @deposito char(2) = '00'
	DECLARE @producto_codigo char(8)
	DECLARE @producto_cantidad DECIMAL (12,2)
	DECLARE @item_tipo char(1)
	DECLARE @item_sucursal char(4)
	DECLARE @item_numero char(8)
	DECLARE @item_precio DECIMAL (12,2)
	DECLARE @producto_comp_codigo char(8)
	DECLARE @producto_comp_cantidad DECIMAL (12,2)
	DECLARE cursor_insert CURSOR FOR
    SELECT
        I.item_producto,
        I.item_cantidad,
		I.item_tipo,
		I.item_sucursal,
		I.item_numero,
		I.item_precio
    FROM inserted i

	OPEN cursor_insert
    FETCH NEXT FROM cursor_insert
    INTO @producto_codigo, @producto_cantidad, @item_tipo, @item_sucursal, @item_numero, @item_precio

	WHILE @@FETCH_STATUS = 0
    BEGIN
		IF(EXISTS(SELECT * FROM Composicion  WHERE comp_producto = @producto_codigo ))
		BEGIN
			IF(
				(SELECT COUNT(DISTINCT comp_componente) FROM Composicion 
					INNER JOIN STOCK on comp_componente = stoc_producto and stoc_deposito = @deposito AND stoc_cantidad > comp_cantidad *  @producto_cantidad
					WHERE comp_producto = @producto_codigo) 
				= 
				(SELECT COUNT (DISTINCT comp_componente) FROM Composicion WHERE comp_producto = @producto_codigo)
			)
			BEGIN
				DECLARE cursor_componente CURSOR FOR
					SELECT comp_componente,comp_cantidad FROM Composicion WHERE comp_producto = @producto_codigo
				OPEN cursor_componente
				FETCH NEXT FROM cursor_componente
				INTO @producto_comp_codigo, @producto_comp_cantidad
				WHILE @@FETCH_STATUS = 0
				BEGIN
					PRINT( @producto_comp_codigo)
					UPDATE STOCK SET stoc_cantidad=stoc_cantidad-(@producto_cantidad*@producto_comp_cantidad) WHERE stoc_deposito = @deposito AND stoc_producto = @producto_comp_codigo
					
				FETCH NEXT FROM cursor_componente
				INTO @producto_comp_codigo, @producto_comp_cantidad
				END
    
				CLOSE cursor_componente
				DEALLOCATE cursor_componente
				INSERT INTO Item_Factura (item_tipo,item_sucursal,item_numero,item_producto,item_cantidad,item_precio) 
						VALUES (@item_tipo,@item_sucursal,@item_numero,@producto_codigo,@producto_cantidad,@item_precio)
			END
		END
		ELSE
		BEGIN
			IF( ISNULL((SELECT stoc_cantidad FROM STOCK WHERE stoc_deposito = @deposito AND stoc_producto = @producto_codigo),0) > @producto_cantidad )
			BEGIN
				PRINT( @producto_codigo)
				UPDATE STOCK SET stoc_cantidad=stoc_cantidad-@producto_cantidad WHERE stoc_deposito = @deposito AND stoc_producto = @producto_codigo
				INSERT INTO Item_Factura (item_tipo,item_sucursal,item_numero,item_producto,item_cantidad,item_precio) 
					VALUES (@item_tipo,@item_sucursal,@item_numero,@producto_codigo,@producto_cantidad,@item_precio)

			END
		END
	FETCH NEXT FROM cursor_insert
	INTO @producto_codigo, @producto_cantidad, @item_tipo, @item_sucursal, @item_numero, @item_precio
	END
  
	CLOSE cursor_insert
    DEALLOCATE cursor_insert

COMMIT TRANSACTION



/* --PARA TESTEAR
SELECT * FROM Item_Factura;

INSERT INTO Item_Factura (item_tipo,item_sucursal,item_numero,item_producto,item_cantidad,item_precio) 
	VALUES ('A','0003','00092444','00001415',100.00,1.24),
	('A','0003','00092444','00001415',5961.00,1.24),
	('A','0003','00092444','00001707',1.00,1.24),
	('A','0003','00092444','00001707',100.00,1.24),
	('A','0003','00092444','00001707',100.00,1.24),
	('A','0003','00092444','00001707',100.00,1.24),
	('A','0003','00092444','00001707',100.00,1.24),
	('A','0003','00092444','00001707',100.00,1.24),
	('A','0003','00092444','00001707',100.00,1.24)


DELETE FROM Item_Factura WHERE  item_tipo = 'A' AND item_sucursal  = '0003' AND item_numero =  '00092444' AND item_producto =  '00001415'
DELETE FROM Item_Factura WHERE  item_tipo = 'A' AND item_sucursal  = '0003' AND item_numero =  '00092444' AND item_producto =  '00001707'
	SELECT stoc_cantidad,stoc_producto FROM Composicion
	INNEr JOIN Producto on prod_codigo = comp_componente
	INNEr JOIN STOCK on stoc_producto = comp_componente
	inner join DEPOSITO on depo_codigo = stoc_deposito where depo_codigo = '00' AND comp_producto = '00001707'
	UNION
	SELECT stoc_cantidad,stoc_producto FROM STOCK WHERE stoc_deposito = '00' AND stoc_producto = '00001415'


	IF((SELECT COUNT(DISTINCT comp_componente) FROM Composicion 
	INNER JOIN STOCK on comp_componente = stoc_producto and stoc_deposito = '00' AND stoc_cantidad > comp_cantidad * 100
	WHERE comp_producto = '00001707') = (SELECT COUNT (DISTINCT comp_componente) FROM Composicion WHERE comp_producto = '00001707')
	)
	BEGIN
		PRINT('iguales')
	END

*/