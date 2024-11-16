/*3. Cree el/los objetos de base de datos necesarios para corregir la tabla empleado
en caso que sea necesario. Se sabe que deber�a existir un �nico gerente general
(deber�a ser el �nico empleado sin jefe). Si detecta que hay m�s de un empleado
sin jefe deber� elegir entre ellos el gerente general, el cual ser� seleccionado por
mayor salario. Si hay m�s de uno se seleccionara el de mayor antig�edad en la
empresa. Al finalizar la ejecuci�n del objeto la tabla deber� cumplir con la regla
de un �nico empleado sin jefe (el gerente general) y deber� retornar la cantidad
de empleados que hab�a sin jefe antes de la ejecuci�n.*/

CREATE PROC Ejercicio3v3 (@Modif int OUTPUT)
AS
BEGIN
DECLARE @GerenteGral numeric(6,0) = ( 
										SELECT TOP 1 empl_codigo
										FROM Empleado
										ORDER BY empl_salario DESC, empl_ingreso ASC
									)
SET @Modif = ( 
										SELECT count(*)
										FROM Empleado E
										WHERE E.empl_jefe IS NULL
											AND empl_codigo <> @GerenteGral
									)	
UPDATE Empleado SET empl_jefe = @GerenteGral
WHERE empl_jefe IS NULL
	AND empl_codigo <> @GerenteGral

--ELSE PRINT 'Solo hay un Gerente General'

--SELECT @Modif AS [Rows Modificadas]
RETURN
END

DECLARE @Cant_de_empl_sin_jefe_modificados int
EXEC Ejercicio3v3 @Modif = @Cant_de_empl_sin_jefe_modificados OUTPUT
SELECT @Cant_de_empl_sin_jefe_modificados AS [Cant de filas afectadas]


UPDATE Empleado SET empl_jefe = NULL
WHERE empl_codigo IN (1,10,11)