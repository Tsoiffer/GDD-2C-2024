/*1. Hacer una funci�n que dado un art�culo y un deposito devuelva un string que
indique el estado del dep�sito seg�n el art�culo. Si la cantidad almacenada es
menor al l�mite retornar �OCUPACION DEL DEPOSITO XX %� siendo XX el
% de ocupaci�n. Si la cantidad almacenada es mayor o igual al l�mite retornar
�DEPOSITO COMPLETO�.*/

CREATE FUNCTION dbo.Ejercicio1 (@art varchar(8),@depo char(2))

RETURNS varchar(30)

AS
BEGIN 
	DECLARE @result DECIMAL(12,2)
	(
		SELECT @result = ISNULL((S.stoc_cantidad*100) / S.stoc_stock_maximo,0)
		FROM STOCK S
		WHERE S.stoc_producto = @art AND S.stoc_deposito = @depo
	)
RETURN
	CASE
		WHEN @result < 100
		THEN 
			('Ocupacion del Deposito: ' + CONVERT(varchar(10),@result) + '%')
		ELSE
			'Deposito Completo'
	END
END
GO



/*
SELECT dbo.Ejercicio1('00000102','00')

SELECT dbo.Ejercicio2('00000102','2011-18-08 00:00:00')
*/