from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "data" / "ecommerce_orders.csv"
OUTPUT = ROOT / "data" / "cleaned_ecommerce_orders.csv"

def load_and_clean(path=INPUT):
    df = pd.read_csv(path)
    df["order_date"] = pd.to_datetime(df["order_date"], errors="coerce")
    df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce")
    df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce")
    df["discount_pct"] = pd.to_numeric(df["discount_pct"], errors="coerce").fillna(0)
    df["region"] = df["region"].fillna("Unknown")
    df["payment_mode"] = df["payment_mode"].fillna("Unknown")
    df = df.drop_duplicates(subset=["order_id"])
    df = df.dropna(subset=["order_id", "order_date", "customer_id", "product_id",
                           "quantity", "unit_price"])
    df = df[(df["quantity"] > 0) & (df["unit_price"] >= 0)]
    df["gross_sales"] = df["quantity"] * df["unit_price"]
    df["discount_amount"] = df["gross_sales"] * df["discount_pct"]
    df["net_sales"] = df["gross_sales"] - df["discount_amount"]
    df["order_month"] = df["order_date"].dt.to_period("M").astype(str)
    return df

def main():
    df = load_and_clean()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUTPUT, index=False)
    print("Rows after cleaning:", len(df))
    print("Total net sales:", round(df["net_sales"].sum(), 2))
    print("\\nMonthly sales:")
    print(df.groupby("order_month")["net_sales"].sum().round(2))
    print("\\nCategory performance:")
    print(df.groupby("category")["net_sales"].sum().sort_values(ascending=False).round(2))
    print("\\nTop 10 customers:")
    print(df.groupby("customer_id")["net_sales"].sum().nlargest(10).round(2))

if __name__ == "__main__":
    main()
