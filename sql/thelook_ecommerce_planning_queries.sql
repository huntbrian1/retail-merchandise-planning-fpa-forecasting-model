-- Retail Merchandise Planning & FP&A Forecasting Model
-- Source system: Google BigQuery public dataset `bigquery-public-data.thelook_ecommerce`
-- SQL dialect: BigQuery Standard SQL
--
-- The final workbook directly uses four source pulls:
--   Query 1: Monthly revenue and margin by brand/category/department
--   Query 4: All-time brand summary
--   Query 6: Open-to-buy category gap
--   Query 7: Markdown risk / inventory action flags
--
-- Query 2, Query 3, and Query 5 are retained here for audit trail because they
-- were part of the original extraction set. In the final workbook they are
-- treated as duplicate or derivable views rather than separate base inputs.


-- Query 1: Category & Brand Monthly Sales, Margin, and Units
-- Workbook raw tab: Raw_BrandMonthly
-- Grain: month x category x department x brand
SELECT
  DATE_TRUNC(DATE(oi.created_at), MONTH) AS sales_month,
  p.category,
  p.department,
  p.brand,
  COUNT(DISTINCT oi.order_id) AS orders,
  COUNT(oi.id) AS units_sold,
  ROUND(SUM(oi.sale_price), 2) AS revenue,
  ROUND(SUM(p.cost), 2) AS total_cost,
  ROUND(SUM(oi.sale_price) - SUM(p.cost), 2) AS gross_margin_dollars,
  ROUND(SAFE_DIVIDE(SUM(oi.sale_price) - SUM(p.cost), SUM(oi.sale_price)), 4) AS gross_margin_rate
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p
  ON oi.product_id = p.id
WHERE oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY sales_month, p.category, p.department, p.brand
ORDER BY sales_month DESC, revenue DESC;


-- Query 2: Category / Brand / Month Sales and Margin Rollup
-- Status in final workbook: duplicate/reference pull
-- Reason: Same business grain and metric set as Query 1, using a CTE wrapper.
WITH base AS (
  SELECT
    DATE_TRUNC(DATE(oi.created_at), MONTH) AS sales_month,
    p.category,
    p.department,
    p.brand,
    oi.order_id,
    oi.id AS order_item_id,
    oi.sale_price,
    p.cost
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
)
SELECT
  sales_month,
  category,
  department,
  brand,
  COUNT(DISTINCT order_id) AS orders,
  COUNT(order_item_id) AS units_sold,
  ROUND(SUM(sale_price), 2) AS revenue,
  ROUND(SUM(cost), 2) AS total_cost,
  ROUND(SUM(sale_price) - SUM(cost), 2) AS gross_margin_dollars,
  ROUND(SAFE_DIVIDE(SUM(sale_price) - SUM(cost), SUM(sale_price)), 4) AS gross_margin_rate
FROM base
GROUP BY 1, 2, 3, 4
ORDER BY sales_month, revenue DESC;


-- Query 3: Category / Department Monthly Plan Summary
-- Status in final workbook: derived in Excel from Raw_BrandMonthly
-- Reason: Brand-free month/category/department rollups can be rebuilt from Query 1.
WITH base AS (
  SELECT
    DATE_TRUNC(DATE(oi.created_at), MONTH) AS sales_month,
    p.category,
    p.department,
    oi.sale_price,
    p.cost
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
)
SELECT
  sales_month,
  department,
  category,
  COUNT(*) AS units_sold,
  ROUND(SUM(sale_price), 2) AS revenue,
  ROUND(SUM(cost), 2) AS cost,
  ROUND(SUM(sale_price) - SUM(cost), 2) AS gross_margin_dollars,
  ROUND(SAFE_DIVIDE(SUM(sale_price) - SUM(cost), SUM(sale_price)), 4) AS gross_margin_rate
FROM base
GROUP BY 1, 2, 3
ORDER BY sales_month, revenue DESC;


-- Query 4: Brand Scorecard
-- Workbook raw tab: Raw_BrandSummary
-- Grain: brand x category x department
-- Note: Brand is used as a vendor proxy because the public dataset does not
-- include a separate vendor master.
WITH base AS (
  SELECT
    p.brand,
    p.category,
    p.department,
    oi.sale_price,
    p.cost
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
)
SELECT
  brand,
  category,
  department,
  COUNT(*) AS units_sold,
  ROUND(SUM(sale_price), 2) AS revenue,
  ROUND(SUM(cost), 2) AS cost,
  ROUND(SUM(sale_price) - SUM(cost), 2) AS gross_margin_dollars,
  ROUND(SAFE_DIVIDE(SUM(sale_price) - SUM(cost), SUM(sale_price)), 4) AS gross_margin_rate
FROM base
GROUP BY 1, 2, 3
ORDER BY gross_margin_dollars DESC;


-- Query 5: Inventory Position by Category / Brand
-- Status in final workbook: reference/derivable pull
-- Reason: Inventory position, sell-through proxy, and cover logic can be
-- calculated from the direct inventory-action source used by Query 7.
WITH inv AS (
  SELECT
    p.category,
    p.department,
    p.brand,
    COUNT(*) AS inventory_units,
    ROUND(SUM(p.cost), 2) AS inventory_cost,
    ROUND(SUM(p.retail_price), 2) AS inventory_retail_value
  FROM `bigquery-public-data.thelook_ecommerce.inventory_items` ii
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON ii.product_id = p.id
  WHERE ii.sold_at IS NULL
  GROUP BY 1, 2, 3
),
sales AS (
  SELECT
    p.category,
    p.department,
    p.brand,
    COUNT(*) AS units_sold_90d
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
    AND DATE(oi.created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  GROUP BY 1, 2, 3
)
SELECT
  inv.category,
  inv.department,
  inv.brand,
  inv.inventory_units,
  inv.inventory_cost,
  inv.inventory_retail_value,
  COALESCE(sales.units_sold_90d, 0) AS units_sold_90d,
  ROUND(SAFE_DIVIDE(COALESCE(sales.units_sold_90d, 0), NULLIF(inv.inventory_units + COALESCE(sales.units_sold_90d, 0), 0)), 4) AS sell_through_proxy,
  ROUND(SAFE_DIVIDE(inv.inventory_units, NULLIF(COALESCE(sales.units_sold_90d, 0), 0)), 2) AS weeks_of_supply_proxy
FROM inv
LEFT JOIN sales
  ON inv.category = sales.category
 AND inv.department = sales.department
 AND inv.brand = sales.brand
ORDER BY inv.inventory_units DESC, inv.inventory_cost DESC;


-- Query 6: Open-to-Buy Planning by Category
-- Workbook raw tab: Raw_OTBGap
-- Grain: category x department
WITH sales_90d AS (
  SELECT
    p.category,
    p.department,
    SUM(oi.sale_price) AS sales_dollars,
    SUM(p.cost) AS sales_cost
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
    AND DATE(oi.created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  GROUP BY 1, 2
),
inventory AS (
  SELECT
    p.category,
    p.department,
    SUM(p.cost) AS on_hand_cost,
    COUNT(*) AS on_hand_units
  FROM `bigquery-public-data.thelook_ecommerce.inventory_items` ii
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON ii.product_id = p.id
  WHERE ii.sold_at IS NULL
  GROUP BY 1, 2
)
SELECT
  COALESCE(s.category, i.category) AS category,
  COALESCE(s.department, i.department) AS department,
  ROUND(COALESCE(s.sales_dollars, 0), 2) AS sales_dollars_90d,
  ROUND(COALESCE(s.sales_cost, 0), 2) AS sales_cost_90d,
  ROUND(COALESCE(i.on_hand_cost, 0), 2) AS on_hand_cost,
  COALESCE(i.on_hand_units, 0) AS on_hand_units,
  ROUND(SAFE_DIVIDE(COALESCE(i.on_hand_cost, 0), NULLIF(COALESCE(s.sales_cost, 0), 0)), 2) AS inventory_to_sales_cost_ratio,
  ROUND(SAFE_DIVIDE(COALESCE(s.sales_cost, 0), 90), 2) AS avg_daily_cogs,
  ROUND(COALESCE(i.on_hand_cost, 0) - SAFE_DIVIDE(COALESCE(s.sales_cost, 0), 90) * 30, 2) AS estimated_otb_gap_30d
FROM sales_90d s
FULL OUTER JOIN inventory i
  ON s.category = i.category
 AND s.department = i.department
ORDER BY estimated_otb_gap_30d DESC;


-- Query 7: Markdown Risk Tracker by Brand
-- Workbook raw tab: Raw_InventoryActions
-- Grain: brand x category x department
WITH brand_sales AS (
  SELECT
    p.brand,
    p.category,
    p.department,
    COUNT(*) AS units_sold_90d,
    SUM(oi.sale_price) AS sales_dollars_90d,
    SUM(p.cost) AS sales_cost_90d
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
    AND DATE(oi.created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  GROUP BY 1, 2, 3
),
brand_inventory AS (
  SELECT
    p.brand,
    p.category,
    p.department,
    COUNT(*) AS inventory_units,
    SUM(p.cost) AS inventory_cost
  FROM `bigquery-public-data.thelook_ecommerce.inventory_items` ii
  JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON ii.product_id = p.id
  WHERE ii.sold_at IS NULL
  GROUP BY 1, 2, 3
)
SELECT
  COALESCE(s.brand, i.brand) AS brand,
  COALESCE(s.category, i.category) AS category,
  COALESCE(s.department, i.department) AS department,
  COALESCE(s.units_sold_90d, 0) AS units_sold_90d,
  COALESCE(s.sales_dollars_90d, 0) AS sales_dollars_90d,
  COALESCE(i.inventory_units, 0) AS inventory_units,
  COALESCE(i.inventory_cost, 0) AS inventory_cost,
  ROUND(SAFE_DIVIDE(COALESCE(i.inventory_units, 0), NULLIF(COALESCE(s.units_sold_90d, 0), 0)), 2) AS unit_cover_ratio,
  CASE
    WHEN COALESCE(s.units_sold_90d, 0) >= 20
      AND COALESCE(i.inventory_units, 0) <= COALESCE(s.units_sold_90d, 0) * 1.2
      THEN 'Chase / Buy More'
    WHEN COALESCE(s.units_sold_90d, 0) >= 20
      AND COALESCE(i.inventory_units, 0) > COALESCE(s.units_sold_90d, 0) * 1.2
      THEN 'Hold'
    WHEN COALESCE(s.units_sold_90d, 0) < 10
      AND COALESCE(i.inventory_units, 0) > COALESCE(s.units_sold_90d, 0) * 2
      THEN 'Markdown Risk'
    ELSE 'Margin Watch'
  END AS action_flag
FROM brand_sales s
FULL OUTER JOIN brand_inventory i
  ON s.brand = i.brand
 AND s.category = i.category
 AND s.department = i.department
ORDER BY sales_dollars_90d DESC;
