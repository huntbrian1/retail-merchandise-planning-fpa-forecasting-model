# Retail Merchandise Planning & FP&A Forecasting Model

An Excel-based retail planning prototype combining category-level merchandise planning, open-to-buy decision support, markdown risk analysis, vendor/brand scorecarding, rolling P&L forecasting, and gross margin variance bridge analysis — built on SQL extracts from the public TheLook eCommerce dataset.

---

## Overview

This is a two-part retail planning and FP&A workbook built from Google BigQuery exports.

The workflow starts with SQL in BigQuery: raw order, product, and inventory data is aggregated into planning-ready extracts, exported to CSV, and loaded into Excel raw tabs. The workbook turns those pulls into formula-driven planning views, dashboard summaries, and FP&A forecast/variance analysis.

**Part 1: Merchandise Planning / OTB Model**

**Part 2: FP&A Forecasting & Gross Margin Bridge**

The model is built from public data with documented assumptions and auditable workbook logic. It is positioned as a portfolio prototype, not a production planning system.

---

## Business Problem

Retail planning teams need to answer several connected questions at once:

- Where are sales expected to land by department and category?
- Which categories appear over- or under-positioned on inventory?
- Where should receipts be chased, held, or reviewed for markdown risk?
- Which brands are driving revenue, margin dollars, and margin rate?
- How do changes in sales volume, category mix, and margin rate flow through gross margin dollars and GM%?

This workbook connects those questions in one Excel model.

---

## Part 1 — Merchandise Planning & OTB Model

Designed around category-level planning decisions. Core outputs:

- **Category Plan** — sales baseline, gross margin context, current inventory position, target WOS, receipt need, overbuy exposure, and planner action
- **Markdown Risk** — inventory cover and action flags: hold, markdown risk, margin watch, or chase/buy more
- **Vendor Scorecard** — brand-level revenue, cost, gross margin dollars, GM%, and planning recommendation context
- **Trend Summary** — monthly/category performance views derived from the raw brand-month source
- **Dashboard** — front-page readout of the most important planning signals

The workbook uses brand as a vendor proxy because the public dataset does not include a true vendor master. That limitation is documented rather than hidden.

---

## Part 2 — FP&A Forecasting & Gross Margin Bridge

Extends the same source data into a corporate finance view:

- Rolling three-month P&L forecast by department
- Plan vs. Actual/Forecast logic — actuals for closed months, prior-year same-month actuals scaled by a YoY run-rate factor for future months
- Gross margin bridge from Budget GM$ to Actual/Forecast GM$, decomposed into Volume, Mix, and Margin Rate effects
- Reconciliation check tying bridge output back to reported Actual/Forecast GM$

**Plan** is the benchmark. **Actual/Forecast** is the updated run-rate view. **The bridge** explains why gross margin dollars changed.

---

## Key Workbook Tabs

| Tab | Purpose |
|---|---|
| `Merch. Plan Dashboard` | Executive-style readout of planning signals and category/vendor risk |
| `Category_Plan` | Category-level planned sales, WOS, OTB, receipt action, and priority logic |
| `Vendor_Scorecard` | Brand/vendor proxy performance by revenue, margin dollars, and GM% |
| `Markdown_Risk` | Inventory action flags, markdown exposure, and cover logic |
| `Trend_Summary` | Category and department trend readout from monthly raw data |
| `FP&A_P&L_Forecast` | Rolling three-month department P&L view for revenue, COGS, GM$, and GM% |
| `FP&A_Variance_Bridge` | Gross margin bridge decomposing variance into volume, mix, and margin-rate effects |
| `Assumptions` | Planning assumptions, growth rates, and model drivers |
| `Data_Lineage` | Source routing, direct raw pulls, derived views, and QA notes |
| `Methodology` | Workbook logic notes and model interpretation |
| `Raw_BrandMonthly` | Monthly sales and margin by brand/category/department |
| `Raw_BrandSummary` | Brand/category/department summary metrics |
| `Raw_OTBGap` | Category/department OTB and inventory position extract |
| `Raw_InventoryActions` | Brand/category/department inventory action flags |

---

## Methodology

### Data Pull

SQL written for Google BigQuery against `bigquery-public-data.thelook_ecommerce`. Four base outputs feed the workbook directly:

1. Monthly category-brand sales and margin
2. All-time brand scorecard
3. Open-to-buy planning by category
4. Markdown risk tracker by brand

Additional query variants are retained in the SQL file for audit trail. Redundant rollups are treated as derived views rather than separate base sources.

### Merchandise Planning Logic

- Planned sales built from recent category performance, prior-period performance, and documented assumptions
- OTB logic compares planned demand against current inventory position and target coverage
- WOS and inventory exposure metrics identify categories needing receipt control, replenishment, or markdown review
- Markdown risk flags hold, margin watch, markdown risk, or chase/buy-more actions based on inventory cover and recent sales movement
- Brand/vendor performance summarized using brand as the closest available vendor proxy

### FP&A Logic

- Plan uses prior-year same-month raw data plus department-level planning assumptions
- Actuals pulled from `Raw_BrandMonthly` for closed months
- Future forecast uses prior-year same-month actuals multiplied by the selected YoY run-rate factor
- Gross margin bridge decomposes forecast/budget difference into volume, mix, and margin-rate effects
- QA checks reconcile bridge totals back to reported Actual/Forecast GM$

---

## Tools

- Google BigQuery / SQL
- Microsoft Excel — `SUMIFS`, `SUMPRODUCT`, `EDATE`, `IFERROR`, cross-tab references, dashboard formatting
- QA, data lineage, and reconciliation checks

No Power Query dependency. Source refresh path: SQL export → CSV → raw workbook tabs → formula-driven model views.

---

## Repository Structure

```
.
|-- README.md
|-- workbook/
|   `-- TheLook_Merchandise_Planning_FP&A_OTB_Model_Final.xlsx
|-- sql/
|   `-- thelook_ecommerce_planning_queries.sql
|-- data/
|   |-- README.md
|   `-- sql_exports/
|       `-- BigQuery CSV exports
|-- docs/
|   `-- model_notes.md
```

---

## How To Review

1. Open `workbook/TheLook_Merchandise_Planning_FP&A_OTB_Model_Final.xlsx`
2. Start with `Merch. Plan Dashboard` for the merchandise planning readout
3. Review `Category_Plan`, `Vendor_Scorecard`, and `Markdown_Risk` for detailed planning logic
4. Review `FP&A_P&L_Forecast` and `FP&A_Variance_Bridge` for the FP&A section
5. Check `Data_Lineage` and `Methodology` for source routing and model assumptions
6. Review `sql/thelook_ecommerce_planning_queries.sql` for the BigQuery extraction layer

---

## Assumptions & Limitations

- TheLook is a public synthetic ecommerce dataset, not an actual retailer's operating system
- Brand is used as a vendor proxy — no vendor master is available in the public data
- The forecast is a run-rate planning model, not a demand-planning system or ML model
- Source data limitations and derived-view routing are documented in the workbook and data notes

---

## What This Demonstrates

- Retail merchandise planning and open-to-buy logic
- Markdown risk analysis and vendor/brand scorecarding
- FP&A forecasting and gross margin bridge modeling
- Excel financial modeling and dashboard design
- SQL-to-Excel planning workflow
- QA, data lineage, and reconciliation discipline
