# Model Notes

## Source Flow

1. SQL was run in Google BigQuery against `bigquery-public-data.thelook_ecommerce`.
2. Query results were exported as CSV files.
3. The Excel workbook imports raw tabs from the core CSV exports.
4. Merchandise planning, OTB, markdown risk, vendor/brand scorecarding, FP&A forecast, and variance bridge views are formula-driven from those raw tabs and documented assumptions.

## Direct Source Pulls

- `Raw_BrandMonthly`: monthly sales, COGS, gross margin dollars, and GM% by brand/category/department.
- `Raw_BrandSummary`: all-time brand/category/department margin summary used for scorecarding.
- `Raw_OTBGap`: 90-day sales and current inventory cost by category/department for OTB logic.
- `Raw_InventoryActions`: brand/category/department inventory action flags and cover ratios.

## Derived Views

- Brand-free category/month trend summaries are derived from `Raw_BrandMonthly`.
- Sell-through and cover logic is handled in workbook formulas instead of treating every SQL export as a separate base source.
- FP&A plan and actual/forecast views are built from raw monthly sales, COGS, and margin fields with documented assumptions.

## Prototype Caveat

The workbook is a portfolio prototype built from public synthetic data. It is designed to show model structure, planning logic, variance analysis, QA discipline, and business storytelling. It is not a production planning system.
