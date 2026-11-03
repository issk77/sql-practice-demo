-- 第1周 day1 基础WHERE、ORDER BY、LIMIT、DISTINCT练习
-- 题目1：查询所有广州的用户姓名和注册时间
SELECT user_name, register_time
FROM user_info
WHERE city = '广州';

-- 题目2：查询价格大于 100 元的商品名称和品类
SELECT product_name, category
FROM products
WHERE price > 100;

-- 题目3：查询 2024-06-03 当天的所有订单，按金额从高到低排序
SELECT *
FROM order_info
WHERE DATE(create_time) = '2024-06-03'
ORDER BY order_amount DESC;

-- 题目4：查询所有已支付（状态 = 1）的订单，只取前 3 条
SELECT *
FROM order_info
WHERE status = 1
LIMIT 3;

-- 题目5：查询订单表中所有出现过的用户 ID（去重）
SELECT DISTINCT user_id
FROM order_info;

-- 题目6：查询品类是「数码配件」且价格低于 200 的商品
SELECT *
FROM products
WHERE category = '数码配件' AND price < 200;
