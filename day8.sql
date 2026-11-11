-- 1. CTE标记每个用户首单时间
WITH user_first_order AS (
    SELECT 
        user_id,
        MIN(order_time) AS first_order_time
    FROM order_info
    GROUP BY user_id
)
select * from user_first_order
-- 2. 查询复购用户（下单≥2），输出用户id、首单、第二单时间

WITH user_first_order AS (
    SELECT 
        user_id,
        MIN(order_time) AS first_order_time
    FROM order_info
    GROUP BY user_id
),
user_order_rn AS (
    SELECT 
        user_id,
        order_time,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_time ASC) AS rn
    FROM order_info
)
SELECT 
    f.user_id,
    f.first_order_time,
    uo.order_time AS second_order_time
FROM user_first_order f
INNER JOIN user_order_rn uo 
    ON f.user_id = uo.user_id AND uo.rn = 2;

-- 3. 复购率 = 复购用户数 / 全部下单用户数
WITH user_order_cnt AS (
    SELECT 
        user_id,
        COUNT(*) AS order_cnt
    FROM order_info
    GROUP BY user_id
),
total_buy_user AS (
    SELECT COUNT(DISTINCT user_id) AS total_user FROM user_order_cnt
),
repurchase_user AS (
    SELECT COUNT(DISTINCT user_id) AS rep_user FROM user_order_cnt WHERE order_cnt >= 2
)
SELECT 
    rep_user,
    total_user,
    ROUND(rep_user / total_user, 4) AS repurchase_rate
FROM repurchase_user, total_buy_user;



-- 4. 按月区分新老用户，统计当月新用户下单量、老用户下单量
WITH user_first_order AS (
    SELECT 
        user_id,
        MIN(order_time) AS first_order_time,
        DATE_FORMAT(MIN(order_time), '%Y-%m') AS first_month
    FROM order_info
    GROUP BY user_id
)
SELECT 
    DATE_FORMAT(o.order_time, '%Y-%m') AS stat_month,
    SUM(CASE WHEN uf.first_month = DATE_FORMAT(o.order_time, '%Y-%m') THEN 1 ELSE 0 END) AS new_user_order_cnt,
    SUM(CASE WHEN uf.first_month < DATE_FORMAT(o.order_time, '%Y-%m') THEN 1 ELSE 0 END) AS old_user_order_cnt
FROM order_info o
INNER JOIN user_first_order uf ON o.user_id = uf.user_id
GROUP BY stat_month
ORDER BY stat_month;
