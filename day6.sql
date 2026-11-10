-- 1. 使用 WITH CTE 改写：每个城市用户数、订单数、GMV 统计
WITH city_stat AS (
    SELECT
        u.city,
        COUNT(DISTINCT u.user_id) AS user_cnt,
        COUNT(o.order_id) AS order_cnt,
        SUM(o.order_amount) AS gmv
    FROM users u
    LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
    GROUP BY u.city
)
SELECT * FROM city_stat;

-- 2. ROW_NUMBER：每个用户，按 order_time 倒序，取出每个用户最近一笔有效订单
WITH order_rn AS (
    SELECT
        o.*,
        ROW_NUMBER() OVER(PARTITION BY o.user_id ORDER BY o.order_time DESC) AS rn
    FROM order_info o
    WHERE o.order_status IN (1,3)
)
SELECT * FROM order_rn WHERE rn = 1;

-- 3. RANK：每个商品品类内部，按价格从高到低排名
SELECT
    *,
    RANK() OVER(PARTITION BY category ORDER BY price DESC) AS rk
FROM products;

-- 4. DENSE_RANK：统计所有用户总消费，给出消费排名（并列名次不跳号）
WITH user_total AS (
    SELECT
        u.user_name,
        SUM(o.order_amount) AS total_amt
    FROM users u
    LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
    GROUP BY u.user_name
)
SELECT
    *,
    DENSE_RANK() OVER(ORDER BY total_amt DESC) AS dr
FROM user_total;

-- 5. CTE+ROW_NUMBER：找出每个城市消费前 2 名的用户
WITH user_consume AS (
    SELECT
        u.user_name,
        u.city,
        SUM(o.order_amount) AS total_amt
    FROM users u
    LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
    GROUP BY u.user_id, u.user_name, u.city
),
city_rank AS (
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY city ORDER BY total_amt DESC) AS rn
    FROM user_consume
)
SELECT * FROM city_rank WHERE rn <= 2;

-- 6. CTE：先统计每日 GMV，再筛选 GMV 大于 1000 的日期
WITH day_gmv AS (
    SELECT
        DATE(order_time) AS dt,
        SUM(order_amount) AS gmv
    FROM order_info
    WHERE order_status IN (1,3)
    GROUP BY DATE(order_time)
)
SELECT * FROM day_gmv WHERE gmv > 1000;

-- 7. 对比题：同一份消费数据，分别用 row_number /rank/dense_rank 写排名
WITH user_total AS (
    SELECT
        u.user_name,
        SUM(o.order_amount) AS total_amt
    FROM users u
    LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
    GROUP BY u.user_id, u.user_name
)
SELECT
    *,
    ROW_NUMBER() OVER(ORDER BY total_amt DESC) AS rn,
    RANK() OVER(ORDER BY total_amt DESC) AS rk,
    DENSE_RANK() OVER(ORDER BY total_amt DESC) AS dr
FROM user_total;
