/*
Realiza una consulta SQL que permita saber los clientes que compraron todos los rubros disponibles del sistema en el 2012

	De los clientes mostrar, siempre para el 2012
	1-codigo de cliente
	2-codigo de producto que en cantidades mas compre
	3-El nombre del producto mas comprado por el cliente
	4-Cantidad de productos comprados por el cliente
	5-Cantidad de productos con composicion comprados por el cliente
	
El resultado debera ser ordenado por razon social del cliente alfabeticamente promero y luego, los clientes que compraron entre un 20% y 30% del total facturado en el 2012, luego los restantes.

*/

SELECT c.clie_codigo,
	(SELECT TOP 1 item_producto FROM FACTURA f2
		inner join Item_Factura itf2 on itf2.item_tipo = f2.fact_tipo AND itf2.item_sucursal = f2.fact_sucursal AND itf2.item_numero = f2.fact_numero AND f2.fact_cliente = c.clie_codigo AND year(f2.fact_fecha) = 2012
		GROUP BY itf2.item_producto
		order by SUM(itf2.item_cantidad) DESC
	) as cod_producto_mas_comprado,
	(SELECT TOP 1 p2.prod_detalle FROM FACTURA f2
		inner join Item_Factura itf2 on itf2.item_tipo = f2.fact_tipo AND itf2.item_sucursal = f2.fact_sucursal AND itf2.item_numero = f2.fact_numero AND f2.fact_cliente = c.clie_codigo AND year(f2.fact_fecha) = 2012
		INNER JOIN Producto p2 on p2.prod_codigo = itf2.item_producto
		GROUP BY itf2.item_producto,p2.prod_detalle
		order by SUM(itf2.item_cantidad) DESC
	) as detalle_producto_mas_comprado,
	SUM(itf.item_cantidad) as cantidad_productos_comprados, -- podria ser COUNT(DISTINCT itf2.item_producto)
	COUNT(DISTINCT CC.comp_producto)  AS [5.Cantidad de productos con composición comprados por el cliente.],
	( case when (SELECT SUM(FT.fact_total) 
						FROM Factura FT
						WHERE YEAR(FT.fact_fecha) = 2012 AND FT.fact_cliente = c.clie_codigo)
				 BETWEEN (
					(SELECT SUM(FT.fact_total) 
						FROM Factura FT
						WHERE YEAR(FT.fact_fecha) = 2012) * 0.2) 
					and (
					(SELECT SUM(FT.fact_total) 
						FROM Factura FT
						WHERE YEAR(FT.fact_fecha) = 2012) * 0.3)   
					then 1 
					ELSE 0
		end
		),
		COUNT(*)
	FROM Cliente c
	INNER join Factura f on f.fact_cliente = c.clie_codigo AND year(f.fact_fecha) = 2012
	inner join Item_Factura itf on itf.item_tipo = f.fact_tipo AND itf.item_sucursal = f.fact_sucursal AND itf.item_numero = f.fact_numero
	inner join Producto p on p.prod_codigo = itf.item_producto
	LEFT JOIN Composicion cc ON cc.comp_producto = p.prod_codigo
	GROUP by c.clie_codigo,c.clie_razon_social
	HAVING
	count(distinct prod_rubro) = (SELECT COUNT(rubr_id) FROM Rubro) --Nadie compro en el 2012 prodcutos de todos los rubros
	ORDER by 
		( case when (SELECT SUM(FT.fact_total) 
						FROM Factura FT
						WHERE YEAR(FT.fact_fecha) = 2012 AND FT.fact_cliente = c.clie_codigo)
				 BETWEEN (
					(SELECT SUM(FT.fact_total) 
						FROM Factura FT
						WHERE YEAR(FT.fact_fecha) = 2012) * 0.2) --733343.46 * 0.2
					and (
					(SELECT SUM(FT.fact_total) 
						FROM Factura FT
						WHERE YEAR(FT.fact_fecha) = 2012) * 0.3)   --733343.46 * 0.3
					then 1 
					ELSE 0
		end
		)DESC,c.clie_razon_social  ASC

