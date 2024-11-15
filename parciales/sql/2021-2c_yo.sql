/*1Armar una consulta Sql que retorne: █:DONE

	█Razón social del cliente
	█Límite de crédito del cliente
	█Producto más comprado en la historia (en unidades)     -- Yo interpreto que es el producto mas comprado en la historia del cliente

	█Solamente deberá mostrar aquellos clientes que tuvieron mayor cantidad de ventas en el 2012 que
    en el 2011 en cantidades y cuyos montos de ventas en dichos años sean un 30 % mayor el 2012 con
    respecto al 2011. 

	█El resultado deberá ser ordenado por código de cliente ascendente

NOTA: No se permite el uso de sub-selects en el FROM.
*/

--Mi solucion
SELECT c.clie_codigo,c.clie_razon_social,c.clie_limite_credito,
	ISNULL((SELECT TOP 1 item_producto FROM Item_Factura itf INNER JOIN Factura f on 
		f.fact_tipo = itf.item_tipo
		AND f.fact_sucursal = itf.item_sucursal
		AND f.fact_numero = itf.item_numero
		AND f.fact_cliente = c.clie_codigo
		GROUP by item_producto order by SUM(item_cantidad) desc),0) AS 'producto_mas_comprado'
 FROM Cliente c 
	INNER JOIN Factura f1 on f1.fact_cliente = c.clie_codigo AND YEAR(f1.fact_fecha) = 2011
	INNER JOIN Item_Factura itf1 on f1.fact_tipo = itf1.item_tipo
		AND f1.fact_sucursal = itf1.item_sucursal
		AND f1.fact_numero = itf1.item_numero
	INNER JOIN Factura f2 on f1.fact_cliente = c.clie_codigo AND YEAR(f2.fact_fecha) = 2012
	INNER JOIN Item_Factura itf2 on f2.fact_tipo = itf2.item_tipo
		AND f2.fact_sucursal = itf2.item_sucursal
		AND f2.fact_numero = itf2.item_numero
	GROUP BY c.clie_codigo,c.clie_razon_social,c.clie_limite_credito
	HAVING 
		SUM(f2.fact_total) > SUM(f1.fact_total) * 1.3
		AND
		SUM(itf2.item_cantidad) > SUM(itf1.item_cantidad)
	 order by c.clie_codigo ASC;


--Solucion Chabe
	 SELECT 
    c.clie_razon_social,
    c.clie_limite_credito,
    (
        SELECT TOP 1 p.prod_detalle FROM Item_Factura i3
        INNER JOIN Producto p ON p.prod_codigo = i3.item_producto
        INNER JOIN Factura f4 ON f4.fact_numero = i3.item_numero AND i3.item_sucursal = f4.fact_sucursal AND i3.item_tipo = f4.fact_tipo
        WHERE f4.fact_cliente = c.clie_codigo
        GROUP BY p.prod_detalle
        ORDER BY SUM(i3.item_cantidad) DESC
    ) AS producto_mas_vendido
FROM Factura f
INNER JOIN Cliente c ON f.fact_cliente = c.clie_codigo
GROUP BY c.clie_codigo, c.clie_razon_social, c.clie_limite_credito
HAVING ISNULL((SELECT SUM(i.item_cantidad) FROM Item_Factura i
        INNER JOIN Factura f2 ON i.item_numero = f2.fact_numero 
            AND i.item_sucursal = f2.fact_sucursal 
            AND f2.fact_tipo = i.item_tipo
        WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo),0) 
        >
        ISNULL((SELECT SUM(i.item_cantidad) FROM Item_Factura i
        INNER JOIN Factura f2 ON i.item_numero = f2.fact_numero 
            AND i.item_sucursal = f2.fact_sucursal 
            AND f2.fact_tipo = i.item_tipo
        WHERE YEAR(f2.fact_fecha) = 2011 AND f2.fact_cliente = c.clie_codigo),0)
        AND
        ISNULL((
        SELECT SUM(f2.fact_total) FROM Item_Factura i
        INNER JOIN Factura f2 ON i.item_numero = f2.fact_numero 
            AND i.item_sucursal = f2.fact_sucursal 
            AND f2.fact_tipo = i.item_tipo
        WHERE YEAR(f2.fact_fecha) = 2012 AND f2.fact_cliente = c.clie_codigo
        ),0)
        >
        ISNULL((
        SELECT 1.3 * SUM(f2.fact_total) FROM Item_Factura i
        INNER JOIN Factura f2 ON i.item_numero = f2.fact_numero 
            AND i.item_sucursal = f2.fact_sucursal 
            AND f2.fact_tipo = i.item_tipo
        WHERE YEAR(f2.fact_fecha) = 2011 AND f2.fact_cliente = c.clie_codigo
        ),0)
ORDER BY c.clie_codigo ASC