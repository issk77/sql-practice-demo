-- 1. 按日期统计：每日支付订单数、支付 GMV、支付用户数、客单价
WITH day_stat AS (
    SELECT
        DATE(order_time) AS dt,
        COUNT(order_id) AS pay_order_cnt,
        SUM(order_amount) AS pay_gmv,
        COUNT(DISTINCT user_id) AS pay_user_cnt
    FROM order_info
    WHERE order_status IN (1,3)
    GROUP BY DATE(order_time)
)
SELECT
    dt,
    pay_order_cnt,
    pay_gmv,
    pay_user_cnt,
    pay_gmv / pay_order_cnt AS avg_order_price
FROM day_stat;

-- 2. 按城市 + 性别分组，统计有效订单 GMV、下单人数、订单数量
SELECT
    u.city,
    u.gender,
    SUM(o.order_amount) AS gmv,
    COUNT(DISTINCT u.user_id) AS user_cnt,
    COUNT(o.order_id) AS order_cnt
FROM users u
LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
GROUP BY u.city, u.gender;

-- 3. 按商品品类统计销量、销售额、销售占比（品类销售额 / 总 GMV）
WITH total_gmv AS (
    SELECT SUM(order_amount) AS all_gmv
    FROM order_info
    WHERE order_status IN (1,3)
)
SELECT
    p.category,
    COUNT(o.order_id) AS sale_cnt,
    SUM(o.order_amount) AS category_gmv,
    SUM(o.order_amount) / (SELECT all_gmv FROM total_gmv) AS gmv_ratio
FROM products p
LEFT JOIN order_info o ON p.product_id = o.product_id AND o.order_status IN (1,3)
GROUP BY p.category;

-- 4. 统计注册在 2024 年的用户，他们的累计消费总额、人均消费
WITH reg2024_user_consume AS (
    SELECT
        u.user_id,
        SUM(o.order_amount) AS user_gmv
    FROM users u
    LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
    WHERE YEAR(u.register_date) = 2024
    GROUP BY u.user_id
)
SELECT
    SUM(user_gmv) AS total_gmv,
    AVG(user_gmv) AS avg_user_consume
FROM reg2024_user_consume;

-- 5. 统计订单金额大于 150 的订单，对应的用户名、商品名、品类
SELECT
    u.user_name,
    p.product_name,
    p.category,
    o.order_amount,
    o.order_time
FROM order_info o
JOIN users u ON o.user_id = u.user_id
JOIN products p ON o.product_id = p.product_id
WHERE o.order_status IN (1,3)
  AND o.order_amount > 150;