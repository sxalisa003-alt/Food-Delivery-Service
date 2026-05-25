import pandas as pd

SAVE_PATH = "C:/Users/kamva/OneDrive/Desktop/PORTFOLIO/FoodDelivery/cleaned_orders.csv"

df = pd.read_csv(
    'C:/Users/kamva/OneDrive/Desktop/PORTFOLIO/FoodDelivery/order_history_kaggle_data.csv',
    sep=';',
    encoding='utf-8',
    on_bad_lines='skip'
)

print(f"Raw rows loaded: {len(df)}")

# --- Column names ---
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
    .str.replace("/", "_")
)

# --- Dates ---
df['order_placed_at'] = pd.to_datetime(df['order_placed_at'], errors='coerce', dayfirst=True)

# --- Distance ---
df['distance'] = df['distance'].astype(str).str.extract(r'(\d+\.?\d*)')[0]
df['distance'] = pd.to_numeric(df['distance'], errors='coerce')

# --- Drop blanks in critical columns ---
critical_cols = ["restaurant_id", "restaurant_name", "subzone", "order_id", "order_placed_at"]
df = df.dropna(subset=critical_cols)
print(f"After critical dropna: {len(df)}")

# --- Valid IDs ---
df["restaurant_id"] = pd.to_numeric(df["restaurant_id"], errors="coerce")
df["order_id"] = pd.to_numeric(df["order_id"], errors="coerce")
df = df[(df["restaurant_id"] > 0) & (df["order_id"] > 0)]
print(f"After ID filter: {len(df)}")

# --- Money columns (keep NaN, reject negatives) ---
money_cols = ["bill_subtotal", "packaging_charges", "total"]
for col in money_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")
    df = df[df[col].isna() | (df[col] >= 0)]
print(f"After money filter: {len(df)}")

# --- Ratings ---
df["rating"] = pd.to_numeric(df["rating"], errors="coerce")
df = df[df["rating"].isna() | ((df["rating"] >= 0) & (df["rating"] <= 5))]
print(f"After rating filter: {len(df)}")


# --- Time columns ---
df["kpt_duration_minutes"] = pd.to_numeric(df["kpt_duration_minutes"], errors="coerce")
df["rider_wait_time_minutes"] = pd.to_numeric(df["rider_wait_time_minutes"], errors="coerce")
df = df[df["kpt_duration_minutes"].isna() | (df["kpt_duration_minutes"] >= 0)]
df = df[df["rider_wait_time_minutes"].isna() | (df["rider_wait_time_minutes"] >= 0)]
print(f"After time filter: {len(df)}")

# --- Text columns ---
text_cols = ["review", "instructions", "cancellation_rejection_reason"]
for col in text_cols:
    df[col] = df[col].fillna("unknown").str.strip()

# --- Distance ---
print("Distance max:", df["distance"].max())
df = df[df["distance"].isna() | (df["distance"] < 100)]
print(f"After distance filter: {len(df)}")

# --- Save ---
df.to_csv(
    SAVE_PATH,
    index=False,
    encoding="utf-8",
    lineterminator="\r\n",
    date_format="%Y-%m-%d %H:%M:%S"
)

# --- Quality Report ---
reloaded = pd.read_csv(SAVE_PATH)
print(f"\n Final dataset size:      {len(df)} rows, {df.shape[1]} columns")
print(f" Reloaded from CSV:       {len(reloaded)} rows")
print(f" Remaining missing values: {df.isnull().sum().sum()}")
print("\nMissing by column:")
print(df.isnull().sum()[df.isnull().sum() > 0])
