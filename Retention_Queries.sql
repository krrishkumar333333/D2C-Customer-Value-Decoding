-- =================================================================================
-- D2C RETAIL: CUSTOMER VALUE & RETENTION SQL ENGINE
-- AUTHOR: KRRISH KUMAR | IIT GUWAHATI CONSULTING & ANALYTICS
-- =================================================================================

-- QUESTION 1: Loyalists vs. Discount Buyers (Revenue Contribution)
-- Insight: Measures how much topline revenue is dangerously tied to discount hunters.
SELECT 
    c.loyalty_segment,
    COUNT(c.customer_id) as total_customers,
    ROUND(SUM(c.total_spend), 2) as total_revenue,
    ROUND(AVG(c.promo_dependency_score) * 100, 1) as avg_promo_reliance_pct,
    ROUND(AVG(c.avg_review_score), 2) as avg_satisfaction
FROM clean_customer_dimensions c
GROUP BY c.loyalty_segment
ORDER BY total_revenue DESC;

-- QUESTION 2: Behavioral Predictors of Value
-- Insight: Maps payment preferences and shipping types to high-value behavior.
SELECT 
    t.payment_method,
    t.shipping_type,
    COUNT(DISTINCT c.customer_id) as customer_volume,
    ROUND(AVG(c.total_spend), 2) as avg_lifetime_value,
    ROUND(AVG(c.total_transactions), 1) as avg_purchase_frequency
FROM transactions t
JOIN clean_customer_dimensions c ON t.customer_id = c.customer_id
WHERE c.loyalty_segment = 'True Loyalists'
GROUP BY t.payment_method, t.shipping_type
ORDER BY avg_lifetime_value DESC
LIMIT 5;

-- QUESTION 3: Commercially Underleveraged Geographies
-- Insight: Identifies states with high organic demand (low promo usage) but low penetration.
SELECT 
    t.location as geographic_region,
    COUNT(DISTINCT c.customer_id) as regional_customer_count,
    ROUND(AVG(c.total_spend), 2) as regional_avg_spend,
    ROUND(AVG(c.promo_dependency_score) * 100, 1) as regional_promo_reliance_pct
FROM transactions t
JOIN clean_customer_dimensions c ON t.customer_id = c.customer_id
GROUP BY t.location
HAVING regional_promo_reliance_pct < 50.0 AND regional_customer_count > 20
ORDER BY regional_avg_spend DESC, regional_customer_count ASC
LIMIT 10;

-- QUESTION 4: Category Funnel (Entry vs. Retention Categories)
-- Insight: Shows which categories drive loyalty vs. one-time bargain hunting.
SELECT 
    t.category,
    COUNT(CASE WHEN c.loyalty_segment = 'True Loyalists' THEN 1 END) as loyalist_purchases,
    COUNT(CASE WHEN c.loyalty_segment = 'Bargain Hunters' THEN 1 END) as discount_purchases,
    ROUND(COUNT(CASE WHEN c.loyalty_segment = 'True Loyalists' THEN 1 END) * 1.0 / COUNT(*), 2) as loyalist_retention_ratio
FROM transactions t
JOIN clean_customer_dimensions c ON t.customer_id = c.customer_id
GROUP BY t.category
ORDER BY loyalist_retention_ratio DESC;

-- QUESTION 5: Ideal Customer Profile (ICP) Extraction
-- Insight: Extracts the exact demographic and seasonal intersections of top-tier buyers.
SELECT 
    t.season as entry_season,
    t.gender,
    t.subscription_status,
    COUNT(DISTINCT c.customer_id) as profile_volume,
    ROUND(AVG(c.total_spend), 2) as profile_avg_spend
FROM transactions t
JOIN clean_customer_dimensions c ON t.customer_id = c.customer_id
WHERE c.loyalty_segment = 'True Loyalists'
GROUP BY t.season, t.gender, t.subscription_status
ORDER BY profile_avg_spend DESC
LIMIT 5;