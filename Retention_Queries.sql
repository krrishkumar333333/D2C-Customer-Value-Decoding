-- =================================================================================
-- D2C FASHION BRAND: CUSTOMER VALUE & RETENTION SQL ANALYTICS LAYER
-- Author: Krishna Vijay Kunwar | Consulting & Analytics Club, IIT Guwahati
--
-- Each query below is explicitly mapped to one of the brief's 5 numbered
-- Key Questions, quoted in full above each query.
-- =================================================================================

-- ===================================================================================
-- KEY QUESTION 1: "Who are the genuinely loyal customers vs. those who only buy
-- when there is a discount?"
-- ===================================================================================
SELECT
    final_loyalty_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend_proxy), 2) AS avg_lifetime_spend,
    ROUND(AVG(promo_dependency_score) * 100, 1) AS avg_promo_reliance_pct,
    ROUND(AVG(review_rating), 2) AS avg_satisfaction,
    ROUND(SUM(total_spend_proxy), 2) AS total_segment_revenue,
    ROUND(SUM(total_spend_proxy) * 100.0 / (SELECT SUM(total_spend_proxy) FROM clean_customer_dimensions), 1) AS pct_of_total_revenue
FROM clean_customer_dimensions
GROUP BY final_loyalty_segment
ORDER BY total_segment_revenue DESC;

-- ===================================================================================
-- KEY QUESTION 2: "What behavioral patterns today predict high customer value
-- over time?" (using previous_purchases/frequency as the tenure-free proxy for
-- "over time", since the dataset has no timestamps)
-- ===================================================================================
SELECT
    frequency_of_purchases,
    subscription_status,
    payment_method,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend_proxy), 2) AS avg_value,
    ROUND(AVG(previous_purchases), 1) AS avg_purchase_count,
    ROUND(AVG(promo_dependency_score) * 100, 1) AS avg_promo_reliance_pct
FROM clean_customer_dimensions
GROUP BY frequency_of_purchases, subscription_status, payment_method
HAVING COUNT(*) >= 15
ORDER BY avg_value DESC
LIMIT 10;

-- ===================================================================================
-- KEY QUESTION 3: "Which geographies and demographics are commercially
-- underleveraged?" (high genuine value signal, but currently low customer count
-- -- i.e. proven demand the brand hasn't capitalized on with marketing spend)
-- ===================================================================================
SELECT
    location,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend_proxy), 2) AS avg_spend,
    ROUND(AVG(promo_dependency_score) * 100, 1) AS avg_promo_reliance_pct,
    ROUND(SUM(CASE WHEN final_loyalty_segment = 'True Loyalists' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_true_loyalists
FROM clean_customer_dimensions
GROUP BY location
HAVING avg_promo_reliance_pct < (SELECT AVG(promo_dependency_score) * 100 FROM clean_customer_dimensions)
ORDER BY avg_spend DESC, customer_count ASC
LIMIT 10;

-- ===================================================================================
-- KEY QUESTION 4: "How should the brand restructure its promotional strategy to
-- protect margins without losing volume?" -- identifies which CATEGORIES and
-- SEASONS are most exposed to discount-driven (vs organic) purchasing
-- ===================================================================================
SELECT
    category,
    season,
    COUNT(*) AS customer_count,
    ROUND(AVG(promo_dependency_score) * 100, 1) AS avg_promo_reliance_pct,
    ROUND(SUM(CASE WHEN final_loyalty_segment = 'Bargain Hunters' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_bargain_hunters,
    ROUND(AVG(total_spend_proxy), 2) AS avg_spend
FROM clean_customer_dimensions
GROUP BY category, season
ORDER BY pct_bargain_hunters DESC
LIMIT 10;

-- ===================================================================================
-- KEY QUESTION 5: "What does the brand's ideal customer profile look like, and
-- how can it acquire more of them?" -- extracts the exact demographic/behavioral
-- intersection of True Loyalists specifically (per Definition A, our primary
-- adopted loyalty definition)
-- ===================================================================================
SELECT
    CASE WHEN age < 30 THEN 'Under 30'
         WHEN age < 45 THEN '30-44'
         WHEN age < 60 THEN '45-59'
         ELSE '60+' END AS age_bracket,
    gender,
    subscription_status,
    payment_method,
    shipping_type,
    COUNT(*) AS profile_volume,
    ROUND(AVG(total_spend_proxy), 2) AS profile_avg_spend,
    ROUND(AVG(review_rating), 2) AS profile_avg_satisfaction
FROM clean_customer_dimensions
WHERE final_loyalty_segment = 'True Loyalists'
GROUP BY age_bracket, gender, subscription_status, payment_method, shipping_type
HAVING COUNT(*) >= 5
ORDER BY profile_avg_spend DESC
LIMIT 10;

-- ===================================================================================
-- SUPPLEMENTARY: Category Funnel (entry-point vs retention categories)
-- Directly supports the Power BI "Category Funnel" panel requirement.
-- ===================================================================================
SELECT
    category,
    ROUND(AVG(CASE WHEN tenure_proxy <= 10 THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_low_tenure_customers,
    ROUND(AVG(CASE WHEN tenure_proxy > 30 THEN 1.0 ELSE 0.0 END) * 100, 1) AS pct_high_tenure_customers,
    ROUND(AVG(tenure_proxy), 1) AS avg_tenure_proxy,
    COUNT(*) AS customer_count
FROM clean_customer_dimensions
GROUP BY category
ORDER BY pct_high_tenure_customers DESC;
