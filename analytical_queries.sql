-- ПРОДУКТОВАЯ АНАЛИТИКА ФИТНЕС-ЦЕНТРА «ActiveLife» (PostgreSQL)

-- 1. РАСЧЁТ OCCUPANCY RATE (Заполняемость групповых занятий)
SELECT 
    ct.name AS class_name,
    ct.category,
    h.name AS hall_name,
    s.start_time,
    s.max_participants,
    COUNT(v.id) AS actual_attendees,
    ROUND(COUNT(v.id)::NUMERIC / s.max_participants * 100, 2) AS occupancy_rate_pct
FROM schedule s
JOIN class_types ct ON s.class_type_id = ct.id
JOIN halls h ON s.hall_id = h.id
LEFT JOIN visits v ON s.id = v.schedule_id AND v.status = 'attended'
GROUP BY ct.name, ct.category, h.name, s.start_time, s.max_participants
ORDER BY occupancy_rate_pct DESC;


-- 2. ОКОННЫЕ ФУНКЦИИ: Накопительная выручка и скользящее среднее
SELECT 
    sub.start_date,
    c.full_name AS client_name,
    sub.price,
    SUM(sub.price) OVER (ORDER BY sub.start_date) AS cumulative_revenue,
    AVG(sub.price) OVER (ORDER BY sub.start_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_price
FROM subscriptions sub
JOIN clients c ON sub.client_id = c.id
ORDER BY sub.start_date;


-- 3. АКТИВНОСТЬ И СЕГМЕНТАЦИЯ КЛИЕНТОВ (Retention Proxy & Cost per Visit)
WITH client_activity AS (
    SELECT 
        c.id AS client_id,
        c.full_name,
        s.id AS subscription_id,
        s.start_date,
        s.end_date,
        s.price,
        COUNT(v.id) AS total_visits
    FROM clients c
    JOIN subscriptions s ON c.id = s.client_id
    LEFT JOIN visits v ON s.id = v.subscription_id AND v.status = 'attended'
    GROUP BY c.id, c.full_name, s.id, s.start_date, s.end_date, s.price
)
SELECT 
    full_name,
    total_visits,
    price,
    ROUND(price / NULLIF(total_visits, 0), 2) AS cost_per_visit,
    CASE 
        WHEN total_visits = 0 THEN 'Zero Engagement (Risk Churn)'
        WHEN total_visits BETWEEN 1 AND 3 THEN 'Low Engagement'
        ELSE 'High Engagement'
    END AS user_segment
FROM client_activity
ORDER BY total_visits DESC;


-- 4. РЕЙТИНГ ТРЕНЕРОВ ПО ПОСЕЩАЕМОСТИ
SELECT 
    t.full_name AS trainer_name,
    COUNT(v.id) AS total_attended_clients,
    DENSE_RANK() OVER (ORDER BY COUNT(v.id) DESC) AS trainer_rank
FROM trainers t
JOIN schedule s ON t.id = s.trainer_id
JOIN visits v ON s.id = v.schedule_id AND v.status = 'attended'
GROUP BY t.id, t.full_name;
