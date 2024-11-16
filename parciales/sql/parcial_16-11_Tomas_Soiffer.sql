/*
SQL
Tomas Soiffer Legajo: 158793-6 16/11/2024

realizar una consulta sql que muestre la siguiente informacion para los 
clientes que hayan comprado productos en mas de tres rubros diferentes en 
2012 y que no compro en años impares
1-numero de fila
2- codigo del cliente
3-el nombre del cliente
4-La cantidad total comprada por el cliente (historico)
5-La categoria que mas compro en 2012

El resultado debe estar ordenado por la cantidad en la que mas compro en 2012
edgardo.laquaniti@gmail.com
ASUNTO: APELLIDO NOMBRE LEGAJO
*/


SELECT ROW_NUMBER() OVER(
       ORDER BY SUM(item_cantidad) DESC) AS Fila, -- DURANTE el 2012
		f.fact_cliente,
		cl.clie_razon_social,
		( SELECT SUM(itf2.item_cantidad) FROM Factura f2
		INNER JOIN Item_Factura itf2 on itf2.item_tipo = f2.fact_tipo AND itf2.item_sucursal = f2.fact_sucursal AND itf2.item_numero = f2.fact_numero
		WHERE f2.fact_cliente = f.fact_cliente
		GROUP BY f2.fact_cliente
		) AS historico_cantidad_comprada, -- DURANTE el 2012
		(SELECT TOP 1 p2.prod_rubro FROM Factura f2
			INNER JOIN Item_Factura itf2 on itf2.item_tipo = f2.fact_tipo AND itf2.item_sucursal = f2.fact_sucursal AND itf2.item_numero = f2.fact_numero 
			AND YEAR(f2.fact_fecha)=2012 AND f2.fact_cliente=f.fact_cliente
			INNER JOIN Producto p2 on p2.prod_codigo = itf2.item_producto
			GROUP BY p2.prod_rubro
			order by SUM(item_cantidad) DESC
		) AS categoria_mas_comprada
		FROM Factura f 
	INNER JOIN Item_Factura itf on itf.item_tipo = f.fact_tipo AND itf.item_sucursal = f.fact_sucursal AND itf.item_numero = f.fact_numero AND YEAR(f.fact_fecha)=2012
	INNER JOIN Producto p on p.prod_codigo = itf.item_producto
	INNER JOIN Cliente cl on cl.clie_codigo = f.fact_cliente
	GROUP BY f.fact_cliente,cl.clie_razon_social
	HAVING
		COUNT (DISTINCT prod_rubro) > 3
		AND
		NOT EXISTS ( 
		SELECT * FROM Factura f2 WHERE f2.fact_cliente = f.fact_cliente
		AND YEAR(f2.fact_fecha) % 2 = 1
		)
	ORDER BY SUM(item_cantidad) DESC -- DURANTE el 2012
;



