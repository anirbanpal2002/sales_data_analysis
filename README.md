# E-commerce Sales Analysis (Intermediate)

## Business objective
Analyze one year of synthetic e-commerce orders to understand revenue, customer value,
product/category performance, geography, discounts, and payment preferences.

## Dataset
`data/ecommerce_orders.csv` contains 1,200 synthetic order-line records for 2025.
It includes a small number of missing values intentionally for data-cleaning practice.
Each row represents one order line. `order_id` is unique in this generated dataset.

Columns:
- order_id, order_date, customer_id
- product_id, product_name, category
- region, quantity, unit_price, discount_pct, payment_mode

## Revenue definitions
- gross_sales = quantity * unit_price
- discount_amount = gross_sales * discount_pct
- net_sales = gross_sales - discount_amount
- Average order value (AOV) = total net sales / distinct orders

Discount is stored as a fraction (0.10 means 10%).

## Setup
```bash
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
python python/analysis.py
```

## Workflow
1. Inspect the raw CSV in Excel: data types, missing values, duplicates, outliers.
2. Run Python cleaning and create `data/cleaned_ecommerce_orders.csv`.
3. Create the SQL table using `sql/analysis_queries.sql`, then import the cleaned CSV.
4. Run each SQL query and validate KPI totals against Python.
5. Open `excel/ecommerce_analysis_template.xlsx` and use the cleaned CSV as the source:
   Insert PivotTables for month/category/region/payment mode and add PivotCharts.
6. Write 4-6 business insights and 2 recommendations.

## Excel formulas
Assuming an Excel table named `Orders`:
- Gross Sales: `=[@quantity]*[@unit_price]`
- Discount Amount: `=[@Gross_Sales]*[@discount_pct]`
- Net Sales: `=[@Gross_Sales]-[@Discount_Amount]`
- Month: `=TEXT([@order_date],"yyyy-mm")`
- AOV (summary cell): `=SUM(Orders[Net_Sales])/COUNTA(UNIQUE(Orders[order_id]))`

If UNIQUE is unavailable, use a PivotTable with order_id in Rows and net_sales in Values.

## Suggested Excel dashboard
KPI cards: Total Revenue, Total Orders, Unique Customers, AOV.
Charts: monthly revenue line chart; revenue by category bar chart; revenue by region
column chart; payment mode doughnut chart; top 10 products bar chart.
Add slicers for year/month, category, region, and payment mode.

## Analysis questions
1. Which month generated the highest and lowest revenue?
2. Which category and product contribute most to revenue?
3. Which region is strongest?
4. What percentage of customers are repeat buyers?
5. Which payment mode is most frequently used?
6. How much discount was given, and which category received the most?
7. Does the highest-volume product also generate the highest revenue?

## Quality checks
- No duplicate order IDs.
- Quantity is positive; unit price is non-negative.
- Discount is between 0 and 1.
- Net sales = gross sales - discount amount.
- Python and SQL total revenue should match (allowing for rounding).
- State clearly that this is synthetic practice data, not real company performance.
