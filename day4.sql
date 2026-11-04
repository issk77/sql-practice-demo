-- 1. 统计每个城市的用户数、订单数、总 GMV
SELECT
    u.city,
    COUNT(DISTINCT u.user_id) AS 用户数,
    COUNT(DISTINCT o.order_id) AS 订单数,
    IFNULL(SUM(o.order_amount),0) AS 总GMV
FROM users u
LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status = 1
GROUP BY u.city;

-- 2. 找出消费最高的用户，输出姓名、城市、总消费金额
SELECT
    u.user_name,
    u.city,
    SUM(o.order_amount) AS 总消费金额
FROM users u
JOIN order_info o ON u.user_id = o.user_id AND o.order_status = 1
GROUP BY u.user_id, u.user_name, u.city
ORDER BY 总消费金额 DESC
LIMIT 1;

-- 3. 统计每个品类的销量，按销量从高到低排序
SELECT
    p.category,
    COUNT(o.order_id) AS 销量
FROM products p
JOIN order_info o ON p.product_id = o.product_id AND o.order_status = 1
GROUP BY p.category
ORDER BY 销量 DESC;

-- 4. 查询 2024 年 6 月上旬（1-10 号），每天的支付订单数和客单价
SELECT
    DATE(o.order_time) AS 下单日期,
    COUNT(o.order_id) AS 支付订单数,
    ROUND(SUM(o.order_amount)/COUNT(o.order_id),2) AS 客单价
FROM order_info o
WHERE o.order_status = 1
  AND o.order_time >= '2024-06-01'
  AND o.order_time < '2024-06-11'
GROUP BY DATE(o.order_time)
ORDER BY 下单日期;

-- 5. 统计不同性别用户的平均消费金额
SELECT
    CASE u.gender
        WHEN '1' THEN '男'
        WHEN '2' THEN '女'
        ELSE '未知'
    END AS 性别,
    ROUND(AVG(user_total),2) AS 平均消费金额
FROM (
    SELECT
        u.gender,
        IFNULL(SUM(o.order_amount),0) AS user_total
    FROM users u
    LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status = 1
    GROUP BY u.user_id, u.gender
) t
GROUP BY u.gender;
