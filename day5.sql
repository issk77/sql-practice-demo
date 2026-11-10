-- 1. 用子查询，查询消费总额大于 200 的所有用户姓名、城市
SELECT user_name, city
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM order_info
    GROUP BY user_id
    HAVING SUM(order_amount) > 200
);

-- 2. 用 EXISTS 查询从来没有下过有效订单的用户（NOT EXISTS版本 + LEFT JOIN对照）
-- NOT EXIST
SELECT user_name, city
FROM users u
WHERE NOT EXISTS (
    SELECT 1
    FROM order_info o
    WHERE o.user_id = u.user_id
      AND o.order_status IN (1,3)
);

-- LEFT JOIN + IS NULL 
SELECT u.user_name, u.city
FROM users u
LEFT JOIN order_info o ON u.user_id = o.user_id AND o.order_status IN (1,3)
WHERE o.order_id IS NULL;

-- 3. 用 IN 子查询，查询购买过 “手机” 品类商品的用户名字
SELECT user_name
FROM users
WHERE user_id IN (
    SELECT DISTINCT o.user_id
    FROM order_info o
    JOIN products p ON o.product_id = p.product_id
    WHERE p.category = '手机'
);

-- 4. 标量子查询：查询每一条订单记录，附带该用户的历史总消费金额
SELECT 
    o.*,
    (SELECT SUM(order_amount) FROM order_info o2 WHERE o2.user_id = o.user_id) AS total_consume
FROM order_info o;

-- 5. 派生表子查询：先算出每个用户总消费，再查询平均用户消费金额
SELECT AVG(user_total) AS avg_consume
FROM (
    SELECT SUM(order_amount) AS user_total
    FROM order_info
    GROUP BY user_id
) t; 

-- 6. 子查询过滤：查询价格高于品类平均价格的商品（相关子查询）
SELECT *
FROM products p
WHERE price > (
    SELECT AVG(price)
    FROM products p2
    WHERE p2.category = p.category
);

-- 7. 相关子查询：找出每个城市里面消费最高的用户
SELECT u.user_name, u.city, t.city_total
FROM (
    SELECT user_id, SUM(order_amount) AS city_total
    FROM order_info o
    GROUP BY user_id
) t
JOIN users u ON t.user_id = u.user_id
WHERE t.city_total = (
    SELECT MAX(tt.city_total)
    FROM (
        SELECT user_id, SUM(order_amount) AS city_total
        FROM order_info o2
        GROUP BY user_id
    ) tt
    JOIN users uu ON tt.user_id = uu.user_id
    WHERE uu.city = u.city
);
