# Data Exports

This folder contains the downloaded BigQuery CSV exports used while building the workbook. The final workbook directly imports four base outputs and documents the other exports as duplicate or derivable reference pulls.

| File | Query | Final workbook treatment |
|---|---|---|
| `bq-results-20260705-223604-1783290992683.csv` | Query 1: monthly category-brand sales and margin | Direct source for `Raw_BrandMonthly` |
| `job_EwEvddawhWzI6O6JVXKJsv8zG1yJ.csv` | Query 4: brand scorecard | Direct source for `Raw_BrandSummary` |
| `bq-results-20260705-230451-1783292724786.csv` | Query 6: open-to-buy planning by category | Direct source for `Raw_OTBGap` |
| `bq-results-20260706-050204-1783314142247.csv` | Query 7: markdown risk tracker by brand | Direct source for `Raw_InventoryActions` |
| `bq-results-20260705-230108-1783292476249.csv` | Query 2-style monthly rollup variant | Duplicate/reference pull, not loaded as a separate base tab |
| `job_voFXRerhXPpAlWe6JD0jac2C8kQg.csv` | Query 3: category-department monthly summary | Derivable from `Raw_BrandMonthly` |
| `job_JhCcCVcU1IWOn7WKQu6NfLmCttct.csv` | Query 5: inventory position | Derivable/reference pull relative to Query 7 inventory action logic |
| `bq-results-20260705-230451-1783292768031.csv` | Query 6 duplicate export | Duplicate/reference pull |

The data comes from Google BigQuery's public TheLook eCommerce dataset. TheLook is synthetic ecommerce data, so workbook outputs should be read as prototype planning logic rather than official retail operating results.
