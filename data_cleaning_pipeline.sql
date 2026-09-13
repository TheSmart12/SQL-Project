-- Customer Data Cleaning & Deduplication Pipeline

-- 1. Standardize text, trim whitespace, and clean phone numbers
CREATE OR REPLACE VIEW cleaned_leads_stage1 AS
SELECT 
    lead_id,
    TRIM(raw_name) AS cleaned_name,
    LOWER(TRIM(raw_email)) AS cleaned_email,
    REGEXP_REPLACE(raw_phone, '[^0-9+]', '') AS formatted_phone,
    UPPER(TRIM(country)) AS standard_country,
    entry_date
FROM raw_leads;

-- 2. Identify duplicate records using ROW_NUMBER()
WITH DeduplicatedLeads AS (
    SELECT 
        lead_id,
        cleaned_name,
        cleaned_email,
        formatted_phone,
        standard_country,
        ROW_NUMBER() OVER (
            PARTITION BY cleaned_email 
            ORDER BY lead_id ASC
        ) AS duplicate_rank
    FROM cleaned_leads_stage1
    WHERE cleaned_email IS NOT NULL AND cleaned_email != ''
)
-- 3. Final unique and validated dataset
SELECT 
    lead_id,
    cleaned_name,
    cleaned_email,
    formatted_phone,
    standard_country
FROM DeduplicatedLeads
WHERE duplicate_rank = 1 
  AND cleaned_email LIKE '%_@__%.__%';
