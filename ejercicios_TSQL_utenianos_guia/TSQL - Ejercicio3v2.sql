/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que deber�a existir un �nico gerente general
(deber�a ser el �nico empleado sin jefe). Si detecta que hay m�s de un empleado
sin jefe deber� elegir entre ellos el gerente general, el cual ser� seleccionado por
mayor salario. Si hay m�s de uno se seleccionara el de mayor antig�edad en la
empresa. Al finalizar la ejecuci�n del objeto la tabla deber� cumplir con la regla
de un �nico empleado sin jefe (el gerente general) y deber� retornar la cantidad
de empleados que hab�a sin jefe antes de la ejecuci�n.*/

ALTER PROC Ejercicio3v2

AS
DECLARE @GerenteGral numeric(6,0) = ( 
										SELECT TOP 1 empl_codigo
										FROM Empleado
										ORDER BY empl_salario DESC, empl_ingreso ASC
									)
DECLARE @Modif numeric(6,0)

WHILE (
		SELECT COUNT(*)
		FROM Empleado E
		WHERE E.empl_jefe IS NULL
	) > 1 
BEGIN
UPDATE Empleado SET empl_jefe = @GerenteGral
	WHERE empl_jefe IS NULL
		AND empl_codigo <> @GerenteGral

SET @Modif = @Modif + 1
PRINT @Modif
END


EXEC Ejercicio3v2