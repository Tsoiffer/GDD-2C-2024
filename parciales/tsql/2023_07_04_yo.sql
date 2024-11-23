/*
2. Actualmente el campo fact_vendedor representa al empleado que vendió
la factura. Implementar el/los objetos necesarios para respetar la
integridad referenciales de dicho campo suponiendo que no existe una
foreign key entre ambos.

NOTA: No se puede usar una foreign key para el ejercicio, deberá buscar
otro método
*/

-- integridad_factura_vendedor
GO
DROP TRIGGER integridad_factura_vendedor
GO
CREATE TRIGGER integridad_factura_vendedor
ON FACTURA 
INSTEAD OF INSERT,UPDATE
AS
BEGIN TRANSACTION
		DECLARE @id_vendedor NUMERIC(6,0)
		DECLARE @factura_tipo Char(1)
		DECLARE @factura_sucursal Char(4)
		DECLARE @factura_numero  Char(8)
		SELECT * FROM inserted;
		DECLARE facturas_insertadas CURSOR FOR
			SELECT fact_vendedor,fact_tipo,fact_sucursal,fact_numero FROM inserted
		OPEN facturas_insertadas
		FETCH NEXT FROM facturas_insertadas 
		INTO @id_vendedor, @factura_tipo, @factura_sucursal, @factura_numero
		WHILE(@@FETCH_STATUS = 0)
			BEGIN
				IF(EXISTS(SELECT * FROM Empleado WHERE empl_codigo = @id_vendedor))
				BEGIN
					PRINT('EXISTE EL EMPLADO ID ' + CAST(@id_vendedor AS VARCHAR(6)))
					if((SELECT COUNT(*) FROM deleted) > 1) --VERIFICO SI ES UN UPDATE
					BEGIN
						DELETE FROM Factura --Elimino la factura que se actualiza y la cargo con la informaicon nueva
							WHERE @factura_tipo = fact_tipo AND @factura_sucursal = fact_sucursal AND @factura_numero = fact_numero 
					END
					INSERT INTO Factura 
						SELECT * FROM inserted WHERE @factura_tipo = inserted.fact_tipo AND @factura_sucursal = inserted.fact_sucursal AND @factura_numero = inserted.fact_numero
				END
				ELSE
				BEGIN
					PRINT('CONSTRAIN VENDEDOR - NO EXISTE EL EMPLADO ID ' + CAST(@id_vendedor AS VARCHAR(6)))
				END
				FETCH NEXT FROM facturas_insertadas 
					INTO @id_vendedor, @factura_tipo, @factura_sucursal, @factura_numero
			END	
		CLOSE facturas_insertadas
		DEALLOCATE facturas_insertadas

COMMIT  


-- integridad_vendedor_factura
GO
DROP TRIGGER integridad_vendedor_factura
GO
CREATE TRIGGER integridad_vendedor_factura
ON EMPLEADO 
INSTEAD OF DELETE
AS
BEGIN TRANSACTION
	DECLARE @id_vendedor NUMERIC(6,0)
	DECLARE empleados_eliminados CURSOR FOR
			SELECT empl_codigo FROM deleted
		OPEN empleados_eliminados
		FETCH NEXT FROM empleados_eliminados 
		INTO @id_vendedor
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			IF(EXISTS(SELECT * FROM Factura f WHERE @id_vendedor = f.fact_vendedor))
			BEGIN
				PRINT('CONSTRAIN FACTURA - EMPLADO ID ' + CAST(@id_vendedor AS VARCHAR(6)) + ' REFERENCIADO EN FACTURAS')
			END
			ELSE
			BEGIN
				DELETE FROM Empleado WHERE empl_codigo = @id_vendedor
				PRINT('SE ELIMINO EL EMPLADO ID ' + CAST(@id_vendedor AS VARCHAR(6)))
			END
		FETCH NEXT FROM empleados_eliminados 
		INTO @id_vendedor
		END
		CLOSE empleados_eliminados
		DEALLOCATE empleados_eliminados
COMMIT


-- TEST integridad_factura_vendedor
DELETE FACTURA WHERE  '10068711' = fact_numero 

SELECT * FROM Factura  WHERE  '10068711' = fact_numero ;

INSERT INTO Factura (fact_tipo,fact_sucursal, fact_numero,fact_fecha, fact_vendedor,fact_total, fact_total_impuestos,fact_cliente )
	VALUES ('B', '0004', '10068711', GETDATE(), 9, 105.73, 18.33, '01634');

DELETE FACTURA WHERE  '20068711' = fact_numero 

SELECT * FROM Factura  WHERE  '20068711' = fact_numero ;

INSERT INTO Factura 
	VALUES ('B', '0004', '20068711', GETDATE(), 9, 105.73, 18.33, '01634');


--TEST INTEGRIDAD EMPLEADO

SELECT * FROM Empleado WHERE empl_codigo = 9;
DELETE FROM Empleado WHERE empl_codigo = 9;

INSERT INTO Empleado 
	VALUES(99,'TEST', 'test',CAST(GETDATE() AS smalldatetime),CAST(GETDATE() AS smalldatetime),'testear',9200.00,0.17,3,2)

SELECT * FROM Empleado WHERE empl_codigo = 99;
DELETE FROM Empleado WHERE empl_codigo = 99;