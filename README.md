# Decoding Customer Value: A SQL-Driven Retention Strategy

> **A full-stack analytics project** — feature engineering (Python), segmentation queries (SQL), and an executive dashboard (Power BI) — built for a 3,900-customer D2C fashion brand with no pre-existing loyalty scores, churn labels, or timestamps.

**Author:** Krishna Vijay Kunwar  
**Programme:** Consulting & Analytics Club, IIT Guwahati — Summer Projects '26  
**Stack:** Python · SQL · Power BI · Excel

---

## Table of Contents

- [Business Context](#business-context)
- [The Analytical Challenge](#the-analytical-challenge)
- [Project Structure](#project-structure)
- [Key Findings](#key-findings)
- [Methodology](#methodology)
  - [Phase 1 — Feature Engineering](#phase-1--feature-engineering-python)
  - [Phase 2 — SQL Analytics Layer](#phase-2--sql-analytics-layer)
  - [Phase 3 — Power BI Dashboard](#phase-3--power-bi-founder-dashboard)
  - [Phase 4 — Retention Playbook](#phase-4--retention-playbook)
- [How to Run](#how-to-run)
- [Deliverables](#deliverables)
- [Limitations & Caveats](#limitations--caveats)

---

## Business Context

A direct-to-consumer (D2C) fashion brand sells clothing, accessories, footwear, and outerwear exclusively across the United States — no physical stores, no third-party retailers. Every customer relationship is managed directly by the brand.

The brand runs a promotional discount programme and supports multiple payment methods and shipping options. It has grown to approximately 3,900 customers but has never built a structured intelligence layer on top of its transactional data. The founding team needed answers to five critical questions:

1. Who are the genuinely loyal customers vs. those who only buy when there is a discount?
2. What behavioural patterns today predict high customer value over time?
3. Which geographies and demographics are commercially underleveraged?
4. How should the brand restructure its promotional strategy to protect margins without losing volume?
5. What does the brand's ideal customer profile look like, and how can it acquire more of them?

---

## The Analytical Challenge

The dataset has **no loyalty score, no churn label, and no timestamps**. Every concept — loyalty, tenure, satisfaction, promo dependency — had to be *constructed* from raw behavioural signals, not assumed.

This project builds two competing loyalty definitions, tests both against four validation criteria (revenue correlation, promo-dependency correlation, internal consistency, statistical significance), and argues clearly for one — grounded in data, not intuition.

---

## Project Structure

```
d2c-customer-value/
│
├── data/
│   ├── transactions.csv                  # Raw dataset (3,900 customer records)
│   └── clean_customer_dimensions.csv     # Engineered feature table (output of notebook)
│
├── notebooks/
│   └── D2C_Feature_Engine.ipynb          # Full feature engineering pipeline (Python)
│
├── sql/
│   └── Retention_Queries.sql             # Five analytical queries mapped to key questions
│
├── dashboard/
│   └── D2C_Customer_Value_Dashboard.pbix # Four-panel Power BI founder dashboard
│
└── README.md
```

---

## Key Findings

| Metric | Value |
|--------|-------|
| Total customers analysed | 3,900 |
| Revenue proxy (estimated LTV pool) | $5.92M |
| Average promo dependency across base | 43% |
| True Loyalist share of customers | 17.1% |
| True Loyalist share of revenue | **33.3%** |
| True Loyalist promo dependency | **0%** |
| Bargain Hunter share of customers | 28.1% |
| Bargain Hunter share of revenue | 16.4% |

### Segment Breakdown

| Segment | Count | Revenue Share | Avg LTV | Promo Reliance |
|---------|-------|---------------|---------|----------------|
| **True Loyalists** | 668 (17.1%) | 33.3% | $2,954 | 0% |
| Standard Customers | 1,792 (45.9%) | 37.2% | $1,228 | ~43% |
| Frequent Modest Spenders | 343 (8.8%) | 13.1% | $2,264 | ~43% |
| Bargain Hunters | 1,097 (28.1%) | 16.4% | $884 | 100% |

### Geographic Opportunity

States with highest True Loyalist concentration and below-average promo sensitivity — indicating **organic demand not yet deliberately targeted**:

| State | True Loyalist % | Avg Spend |
|-------|----------------|-----------|
| Arizona | 29.2% | $1,934 |
| Alaska | 29.2% | $1,870 |
| Pennsylvania | 27.0% | $1,871 |
| Tennessee | 26.0% | $1,655 |
| Wyoming | 25.4% | $1,704 |

### Category Promo Exposure

| Category | Bargain Hunter % | Avg Promo Dependency |
|----------|-----------------|----------------------|
| Outerwear | 29.6% | 44% |
| Accessories | 28.3% | 44% |
| Clothing | 27.9% | 42% |
| Footwear | 27.7% | 43% |

---

## Methodology

### Phase 1 — Feature Engineering (Python)

**Notebook:** `D2C_Feature_Engine.ipynb`

The raw dataset (`transactions.csv`) is a single-row-per-customer table. `purchase_amount_usd` represents a recent transaction value; `previous_purchases` provides historical purchase count. No true transaction history exists.

#### Engineered Features

| Feature | Construction Logic | Business Question Answered |
|---------|-------------------|---------------------------|
| `total_spend_proxy` | `purchase_amount_usd × previous_purchases` | Estimated customer LTV |
| `promo_dependency_score` | `(discount_applied + promo_code_used) / 2` ∈ {0, 0.5, 1} | Is this customer discount-driven? |
| `satisfaction_flag` | `review_rating ≥ 4.0` | Is this customer genuinely satisfied? |
| `tenure_proxy` | `previous_purchases` | Time-with-brand surrogate |
| `frequency_score` | Quartile rank of `previous_purchases` | Purchase cadence signal |

#### Data Quality Finding

`discount_applied` and `promo_code_used` exhibit near-perfect collinearity. This is handled explicitly — the promo dependency score averages both rather than double-counting, and the finding is documented as a structural data quality note.

37 missing `review_rating` values were imputed via median with an explicit `review_rating_imputed_flag` audit column.

#### Two Competing Loyalty Definitions

| | Definition A — Revealed Preference | Definition B — Behavioural Consistency |
|--|-------------------------------------|----------------------------------------|
| **Criteria** | Top 30% by estimated spend AND zero promo usage | Top quartile by purchase frequency AND high-frequency category |
| **Logic** | Spend discipline signals commitment | Purchase cadence signals habit |
| **Promo correlation** | **−0.395** (strong negative) | +0.021 (no relationship) |
| **Verdict** | ✅ **Adopted as primary** | Retained as secondary lens |

Definition A wins decisively: on this brand's real customer data, spend discipline predicts discount independence far better than purchase frequency.

---

### Phase 2 — SQL Analytics Layer

**File:** `Retention_Queries.sql`

Five queries, each explicitly mapped to one of the brief's key questions:

| Query | Key Question | Core Logic |
|-------|-------------|------------|
| Q1 | Loyal vs. discount buyers | Segment aggregation by `final_loyalty_segment` |
| Q2 | Behavioural predictors of value | Group by frequency × subscription × payment method |
| Q3 | Underleveraged geographies | Filter: `avg_promo_reliance < global_avg` + low customer count |
| Q4 | Promo strategy restructure | Category × season cross-tab by Bargain Hunter concentration |
| Q5 | Ideal customer profile | True Loyalist demographic/behavioural intersection |

**Supplementary:** Category funnel query distinguishing entry-point categories (low tenure) from retention categories (high tenure).

All queries run against `clean_customer_dimensions.csv` as the source table.

---

### Phase 3 — Power BI Founder Dashboard

**File:** `D2C_Customer_Value_Dashboard.pbix`

A four-panel executive dashboard designed for a non-technical founding team:

| Panel | What It Shows |
|-------|--------------|
| **Customer Pyramid** | Revenue distribution across the four loyalty segments |
| **Promo Dependency vs. Retention** | Scatter by segment — who needs discounts to buy, and who doesn't |
| **Geographic Opportunity Map** | States with high spend + low promo sensitivity = untapped organic demand |
| **Category Funnel** | Entry-point categories (low purchase history) vs. retention categories (high purchase history) |

---

### Phase 4 — Retention Playbook

#### Promotional Sunset Plan

**Target segment:** Bargain Hunters (1,097 customers, $970K revenue, 100% promo dependency)

**Why this segment specifically:** These customers show no revenue response outside of promotional windows. Continuing discounts extracts margin without building retention. The elasticity risk (volume drop on promo removal) is real but bounded — their LTV without promos is already the lowest in the base ($884).

| Phase | Action | Timeline | Metric to Track |
|-------|--------|----------|----------------|
| 1 | Halt new promo codes for Bargain Hunters in Outerwear | Month 1–2 | Redemption rate, category margin |
| 2 | Replace discount messaging with value/quality content | Month 2–4 | Open rate, conversion without code |
| 3 | Evaluate volume retention; extend to Accessories if margin holds | Month 4–6 | Gross margin per category, segment migration |

**What you risk:** Up to 16.4% of current revenue volume (not profit) if Bargain Hunters churn entirely. In practice, partial conversion to Standard Customers is the expected outcome.

#### Ideal Customer Profile

Based on SQL Query 5 (True Loyalist demographic/behavioural intersection):

- **Age bracket:** 30–44 (peak representation in True Loyalists)
- **Subscription status:** Enrolled (subscription acts as a commitment signal, not just a perk)
- **Payment method:** Credit Card or PayPal (signals financial comfort and digital purchase habit)
- **Shipping preference:** Express (willingness to pay for speed correlates with spend level)
- **Promo behaviour:** Never uses discount codes
- **Geographies to prioritise:** Arizona, Alaska, Pennsylvania

**Acquisition implication:** Full-price brand campaigns in under-penetrated states (Arizona, Alaska) targeting 30–44 demographics on platforms where Credit Card / PayPal payment affinity can be used as a targeting signal.

---

## How to Run

### Prerequisites

```bash
pip install pandas numpy scipy jupyter
```

### Feature Engineering

```bash
jupyter notebook notebooks/D2C_Feature_Engine.ipynb
```

Outputs `clean_customer_dimensions.csv` to the project root.

### SQL Queries

Run `sql/Retention_Queries.sql` against any SQL engine (SQLite, DuckDB, PostgreSQL) with `clean_customer_dimensions` loaded as a table.

Using DuckDB (fastest for local CSV analytics):

```bash
pip install duckdb
duckdb -c "CREATE TABLE clean_customer_dimensions AS SELECT * FROM 'data/clean_customer_dimensions.csv'; $(cat sql/Retention_Queries.sql)"
```

### Power BI Dashboard

Open `dashboard/D2C_Customer_Value_Dashboard.pbix` in Power BI Desktop. Update the data source path to point to your local `clean_customer_dimensions.csv` if prompted.

---

## Deliverables

| Deliverable | File | Status |
|-------------|------|--------|
| Cleaned dataset + engineered features | `clean_customer_dimensions.csv` | ✅ Complete |
| Feature engineering notebook | `D2C_Feature_Engine.ipynb` | ✅ Complete |
| SQL analytics layer (5 key questions) | `Retention_Queries.sql` | ✅ Complete |
| Power BI founder dashboard | `D2C_Customer_Value_Dashboard.pbix` | ✅ Complete |
| Retention playbook | See README Phase 4 | ✅ Complete |
| Executive summary (1 page) | `exec_summary.html` | ✅ Complete |

---

## Limitations & Caveats

- **No true transaction history.** `total_spend_proxy` is an approximation (recent transaction × purchase count), not a summed transaction ledger. All LTV figures should be treated as relative rankings, not absolute dollar forecasts.
- **No timestamps.** Cohort analysis, true churn rate, and time-series retention curves are not possible with this dataset. `tenure_proxy` (previous purchase count) is a structural approximation.
- **Promo collinearity.** `discount_applied` and `promo_code_used` are nearly identical columns. The dependency score averages both; users should be aware this is one signal measured twice, not two independent signals.
- **Single cross-section.** This is a snapshot dataset, not a longitudinal panel. Segment membership can shift; the playbook recommendations should be validated against live data at 90-day intervals.

---

## Contact

**Point of Contact (per brief):**  
Achyuth — 6381774762  
Dhairya Nisar — 8928149400

---

*Consulting & Analytics Club, IIT Guwahati — Summer Projects 2026*
