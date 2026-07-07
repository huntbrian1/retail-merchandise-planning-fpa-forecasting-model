# Retail Merchandise Planning & FP&A Forecasting Model

An Excel-based retail planning prototype that combines category-level merchandise planning, open-to-buy decision support, markdown risk analysis, vendor/brand scorecarding, dashboard reporting, rolling P&L forecasting, and gross margin variance bridge analysis.

## Overview

This project is a two-part retail planning and FP&A workbook built from Google BigQuery exports from the public TheLook eCommerce dataset.

The workflow starts with SQL in BigQuery: raw order, product, and inventory data is aggregated into planning-ready extracts, exported to CSV, and loaded into Excel raw tabs. The workbook then turns those raw pulls into formula-driven planning views, dashboard summaries, and FP&A forecast/variance analysis.

The workbook has two connected sections:

- **Part 1: Merchandise Planning / OTB Model**
- **Part 2: FP&A Forecasting & Gross Margin Bridge**

It is intentionally positioned as a portfolio prototype: the model is built from available public data, documented assumptions, and auditable workbook logic. It is not presented as a production planning system.

## Business Problem

Retail planning teams need to answer several connected questions at once:

- Where are sales expected to land by department and category?
- Which categories appear over-positioned or under-positioned on inventory?
- Where should receipts be chased, held, or reviewed for markdown risk?
- Which brands are driving revenue, margin dollars, and margin rate?
- How do changes in sales volume, category mix, and margin rate flow through revenue, COGS, gross margin dollars, and GM%?

This workbook connects those questions in one Excel model. The merchandise planning section focuses on category-level actionability. The FP&A section translates the same raw data into plan vs actual/forecast P&L logic and a gross margin bridge.

## Part 1 - Merchandise Planning & OTB Model

The merchandise planning section is designed around category-level planning decisions:

- Category-level 30-day planned sales
- Open-to-buy / receipt need logic
- Weeks of supply and inventory exposure logic
- Markdown risk flags
- Vendor/brand scorecard
- Priority scoring
- Dashboard readout
- QA and data lineage documentation

The workbook uses brand as a vendor proxy because the public dataset does not include a true vendor master. That limitation is called out in the workbook and in the data documentation rather than hidden.

Core planning outputs include:

- **Category Plan:** sales baseline, gross margin context, current inventory position, target WOS, receipt need, overbuy exposure, and planner action.
- **Markdown Risk:** inventory cover and action flags such as hold, markdown risk, margin watch, or chase/buy more.
- **Vendor Scorecard:** brand-level revenue, cost, gross margin dollars, GM%, and planning recommendation context.
- **Trend Summary:** monthly/category performance views derived from the raw brand-month source.
- **Dashboard:** front-page readout for the most important planning signals, without internal QA cards taking over the business view.

## Part 2 - FP&A Forecasting & Gross Margin Bridge

The FP&A section extends the same source data into a corporate finance view:

- Rolling three-month P&L forecast by department
- Plan revenue and COGS based on prior-year same-month raw data plus department growth assumptions
- Actual/Forecast logic that pulls actuals for closed months and forecasts future months using prior-year same-month actuals scaled by a selected YoY run-rate factor
- Gross margin bridge from Budget GM$ to Actual/Forecast GM$
- Bridge components: Volume, Mix, and Margin Rate Effect
- Reconciliation check tying bridge output to reported Actual/Forecast GM$

The framing is:

- **Plan** remains the benchmark.
- **Actual/Forecast** is the updated run-rate view.
- **The bridge** explains why gross margin dollars changed.

This makes the workbook usable as either a merchandise planning prototype or a corporate FP&A prototype, depending on the audience.

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

## Methodology

### Data Pull

The SQL in `sql/thelook_ecommerce_planning_queries.sql` was written for Google BigQuery against:

```text
bigquery-public-data.thelook_ecommerce
```

The query set pulls order, product, and inventory data from TheLook and aggregates it into planning-ready grains. The final workbook directly uses four base SQL outputs:

1. Monthly category-brand sales and margin
2. All-time brand scorecard
3. Open-to-buy planning by category
4. Markdown risk tracker by brand

Additional query variants are retained in the SQL file and export folder for audit trail, but the workbook treats redundant rollups as derived views rather than separate base sources.

### Merchandise Planning Logic

- Planned sales are built from recent category performance, prior-period performance, and documented planning assumptions.
- OTB logic compares planned demand against current inventory position and target inventory coverage.
- WOS and inventory exposure metrics identify categories that may need receipt control, replenishment, or markdown review.
- Markdown risk uses inventory cover and recent sales movement to flag hold, margin watch, markdown risk, or chase/buy-more actions.
- Brand/vendor performance is summarized using brand as the closest available vendor proxy.

### FP&A Logic

- Plan uses prior-year same-month raw data plus department-level planning assumptions.
- Actuals are pulled from `Raw_BrandMonthly` for closed months.
- Future forecast uses prior-year same-month actuals multiplied by the selected YoY run-rate factor.
- Gross margin dollars are calculated as revenue less COGS.
- GM% is calculated from gross margin dollars divided by revenue.
- The gross margin bridge decomposes the forecast/budget difference into volume, mix, and margin-rate effects.
- QA checks reconcile bridge totals back to reported Actual/Forecast GM$.

## Tools Used

- Google BigQuery
- SQL
- Microsoft Excel
- Excel formulas and structured workbook logic
- Formula patterns including `SUMIFS`, `SUMPRODUCT`, `EDATE`, `IFERROR`, and cross-tab references
- Dashboard formatting and financial modeling techniques
- QA, data lineage, and reconciliation checks

The final workbook does not depend on Power Query. The source refresh path is documented as SQL export to CSV, then raw workbook tabs and formula-driven model views.

## Repository Structure

```text
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
`-- assets/
    `-- screenshots/
```

## How To Review The Workbook

1. Open `workbook/TheLook_Merchandise_Planning_FP&A_OTB_Model_Final.xlsx`.
2. Start with `Merch. Plan Dashboard` for the merchandise planning readout.
3. Review `Category_Plan`, `Vendor_Scorecard`, and `Markdown_Risk` for the detailed planning logic.
4. Review `FP&A_P&L_Forecast` and `FP&A_Variance_Bridge` for the FP&A section.
5. Check `Data_Lineage` and `Methodology` to understand source routing, direct SQL pulls, and model assumptions.
6. Review `sql/thelook_ecommerce_planning_queries.sql` to see the BigQuery extraction layer.

## Assumptions & Limitations

- TheLook is a public synthetic ecommerce dataset, not an actual retailer's operating system.
- Brand is used as a vendor proxy because no vendor master is available.
- Inventory, on-hand, WOS, and receipt logic depend on the available public data fields and planning assumptions.
- The forecast is a run-rate planning model, not a full demand-planning system or machine-learning model.
- The workbook is a portfolio prototype, not an official planning system.
- Source data limitations and derived-view routing are documented in the workbook and data notes.

## What This Demonstrates

- Retail merchandise planning
- Open-to-buy logic
- Markdown risk analysis
- Vendor/brand scorecarding
- FP&A forecasting
- Gross margin analysis
- Variance bridge modeling
- Excel modeling and dashboard design
- Financial storytelling
- QA and data lineage discipline
- Turning raw SQL exports into business actions

## Screenshot Placeholders

Screenshots can be added to `assets/screenshots/` for a stronger GitHub landing page:

- Main Dashboard
- Category Plan
- FP&A P&L Forecast
- Gross Margin Variance Bridge
