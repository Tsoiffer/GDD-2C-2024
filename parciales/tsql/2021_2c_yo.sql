/*
2.
Realizar un stored procedure que reciba un código de producto y una fecha y 
devuelva la mayor cantidad de días consecutivos a partir de esa fecha que el producto tuvo 
al menos la venta de una unidad en el día, el sistema de ventas on line está habilitado 24-7 
por lo que se deben evaluar todos los días incluyendo domingos y feriados.
*/

--Mi solucion
ALTER PROCEDURE cantidad_venta_consecutivas_desde(@producto char(8), @fecha_desde DATE )
AS 
BEGIN
	DECLARE @dias_consecutivos  INT = 0
	DECLARE @dias_consecutivos_maximos INT = 0
	DECLARE @fecha_auxiliar DATE = @fecha_desde
	DECLARE @fecha_cursor DATE 
	DECLARE cursor_e CURSOR FOR 
		SELECT CONVERT(DATE, fact_fecha) FROM Factura F 
			INNER JOIN Item_Factura ON item_sucursal = fact_sucursal AND item_tipo = fact_tipo AND item_numero = fact_numero
			WHERE item_producto = @producto AND CONVERT(DATE, fact_fecha) > @fecha_desde --Estrictamente mayor por que en @fecha_auxiliar tengo la fecha_desde
			GROUP BY CONVERT(DATE, fact_fecha)
			order by 1 ASC;

	 OPEN cursor_e;
	 FETCH NEXT from cursor_e INTO @fecha_cursor;

    WHILE @@FETCH_STATUS = 0
    BEGIN
		print(DATEDIFF(day,@fecha_auxiliar,@fecha_cursor))
        IF( DATEDIFF(day,@fecha_auxiliar,@fecha_cursor) = 1)
        begin
            SET @dias_consecutivos = @dias_consecutivos + 1
			IF( @dias_consecutivos > @dias_consecutivos_maximos)
			begin
				SET @dias_consecutivos_maximos = @dias_consecutivos
			end
        end
		ELSE
		begin
			SET  @dias_consecutivos = 0
        end
		print(@fecha_cursor)
		SET @fecha_auxiliar = @fecha_cursor
        FETCH NEXT from cursor_e INTO @fecha_cursor
    END

	CLOSE cursor_e
    DEALLOCATE cursor_e
    RETURN @dias_consecutivos_maximos
END


DECLARE @resultado INT;
EXEC @resultado = dbo.cantidad_venta_consecutivas_desde '00001415', '2012-03-01'

SELECT @resultado AS Resultado;