DROP VIEW IF EXISTS orders_summary;
CREATE VIEW IF NOT EXISTS orders_summary(
	order_id,
	order_date,
	order_total,
	beer_id,
	beer_name,
  brand_name,
  brewery_name,
	beer_amount, 
	unit_price, 
	alcvol)
AS
SELECT 
	o.id, 
	o.date, 
	o.total, 
	b.id,
	b.name,
  br.name,
  bw.name,
	bo.amount,
	b.unit_price,
	b.alcvol
FROM 
	orders o
JOIN
	beers_orders bo
ON
	bo.order_id = o.id
JOIN
	beers b
ON
	bo.beer_id = b.id
JOIN
  brands br
ON
  b.brand_id = br.id
JOIN
  breweries bw
ON
  br.brewery_id = bw.id;