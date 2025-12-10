-- File Name: correlation_calculation.sql
-- Purpose: Calculates the statistical correlation coefficient (Pearson's R) between user engagement metrics (Active Time, Engaged Status) and the final Purchase event using BigQuery GA4 data.
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131 (GA4 Raw Event Data)
-- Author: dataanalysit26
-- Date: 2025-12-11
--------------------------------------------------------------------------------

-- OBJECTIVE: To quantify the statistical relationship between user behavior and conversion, providing data-backed insights for UX optimization.
-- BUSINESS LOGIC: Correlation analysis confirms if increased engagement time or an engaged session status leads to a higher probability of purchase.

WITH
  session_engaged_data AS (
    -- CTE 1: Oturum Bazında Etkileşim Metriklerini Hesapla
    -- CTE 1: Calculate Engagement Metrics per Session
  SELECT
    -- user_pseudo_id ve session_id'yi birleştirerek benzersiz oturum anahtarı oluştur.
    -- Create a unique session key by concatenating user_pseudo_id and ga_session_id.
    user_pseudo_id || CAST( (
      SELECT
        value.int_value
      FROM
        UNNEST(event_params)
      WHERE
        KEY = 'ga_session_id' ) AS string ) AS user_key,

    -- session_engaged parametresi 1 ise oturum etkileşimli sayılır.
    -- The session is considered 'engaged' if the 'session_engaged' parameter is > 0.
    (
      CASE
        WHEN SUM((
          SELECT
            COALESCE( CAST(value.string_value AS int64), value.int_value, value.float_value, value.double_value )
          FROM
            UNNEST(event_params)
          WHERE
            KEY = 'session_engaged' ) ) > 0 THEN 1
        ELSE 0
      END
      ) AS session_engaged_value, -- (Binary: 1=Engaged, 0=Not Engaged)

    -- engagement_time_msec değerlerini toplayarak oturumdaki toplam aktif süreyi hesapla.
    -- Sum the engagement_time_msec values to get the total active time for the session.
    SUM((
      SELECT
        value.int_value
      FROM
        UNNEST(event_params)
      WHERE
        KEY = 'engagement_time_msec' )) AS engagement_time_msec -- (Continuous: Total milliseconds)
  FROM
    bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131 -- Kullanılan genel veri seti
  GROUP BY
    1
  ORDER BY
    3 DESC
),
  cte_session_purchase AS (
    -- CTE 2: Satın Alma Gerçekleşen Oturumları Belirle (Purchase Flag)
    -- CTE 2: Identify Sessions where a Purchase Event Occurred (Purchase Flag)
  SELECT
    -- Benzersiz oturum anahtarını oluştur.
    -- Create the unique session key.
    user_pseudo_id || CAST( (
      SELECT
        value.int_value
      FROM
        UNNEST(event_params)
      WHERE
        KEY = 'ga_session_id' ) AS string ) AS user_key,
    1 AS users_by_purchases -- Satın alma olduysa 1 olarak işaretle (Binary: 1=Purchase)
  FROM
    bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131
  WHERE
    event_name = 'purchase' -- Sadece 'purchase' olaylarını filtrele
  GROUP BY
    1
)

-- ##########################################################################
-- # Final Output: Korelasyon Katsayısı Hesaplama (CORR Function)
-- # Final Output: Calculate the Correlation Coefficient (CORR Function)
-- ##########################################################################
SELECT
  -- Toplam aktif süre (engagement_time_msec) ile satın alma arasındaki korelasyon
  -- Correlation between Total Active Time and Purchase (Continuous vs Binary)
  ROUND(CORR(CAST(s.engagement_time_msec AS float64), CAST(IFNULL(p.users_by_purchases,0) AS float64)), 3) AS corr_engagedtime_vs_pruchase,
  
  -- Etkileşimli oturum durumu (session_engaged) ile satın alma arasındaki korelasyon
  -- Correlation between Engaged Session Status and Purchase (Binary vs Binary)
  ROUND(CORR(CAST(s.session_engaged_value AS float64), CAST(IFNULL(p.users_by_purchases,0) AS float64)), 3) AS corr_engaged_vs_purchase
FROM
  session_engaged_data AS s
LEFT JOIN
  cte_session_purchase AS p -- Satın alma verisini sol birleştirme ile eşleştir
ON
  s.user_key = p.user_key -- Benzersiz oturum anahtarı üzerinden birleştir
