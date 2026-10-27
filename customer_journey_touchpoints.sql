-- =====================================================================
-- OMNICHANNEL MARKETING JOURNEY PATH AGGREGATION PIPELINE
-- Author: Puneet Goswami
-- Description: Reconstructs end-to-end customer interaction touchpoints
--              across paid channels prior to conversion events.
-- =====================================================================

WITH session_events AS (
    SELECT 
        user_pseudo_id,
        session_id,
        channel_grouping,
        event_timestamp,
        converted_flag,
        conversion_value_usd,
        -- Sequence number of touchpoints per user
        ROW_NUMBER() OVER (
            PARTITION BY user_pseudo_id 
            ORDER BY event_timestamp ASC
        ) AS touchpoint_sequence
    FROM analytics_warehouse.marketing_clickstream
    WHERE event_timestamp >= CURRENT_DATE - INTERVAL '60 DAYS'
),

user_path_summary AS (
    SELECT 
        user_pseudo_id,
        MAX(converted_flag) AS is_converted,
        MAX(conversion_value_usd) AS revenue_usd,
        COUNT(session_id) AS total_touchpoint_count,
        -- Builds chronological conversion path string e.g. "Paid Search > Social > Email"
        STRING_AGG(channel_grouping, ' > ' ORDER BY touchpoint_sequence) AS journey_path,
        MIN(event_timestamp) AS first_touch_at,
        MAX(event_timestamp) AS last_touch_at
    FROM session_events
    GROUP BY user_pseudo_id
),

path_level_performance AS (
    SELECT 
        journey_path,
        COUNT(user_pseudo_id) AS total_users_traversed,
        SUM(is_converted) AS total_conversions,
        ROUND(SUM(revenue_usd), 2) AS total_revenue_generated,
        ROUND((SUM(is_converted) * 100.0) / COUNT(user_pseudo_id), 2) AS path_conversion_rate_pct,
        ROUND(AVG(total_touchpoint_count), 1) AS avg_touchpoints_to_convert
    FROM user_path_summary
    GROUP BY journey_path
)

SELECT 
    journey_path,
    total_users_traversed,
    total_conversions,
    total_revenue_generated,
    path_conversion_rate_pct,
    avg_touchpoints_to_convert
FROM path_level_performance
WHERE total_conversions > 0
ORDER BY total_conversions DESC
LIMIT 50;