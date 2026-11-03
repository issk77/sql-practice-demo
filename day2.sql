
-- 1. 统计每个城市的用户数量
select 
	city,
	count(user_name) as user_count
from users 
group by city

-- 2. 统计每个商品品类的平均价格
select 
	category,
	avg(price) as avg_price
from products
group by category

-- 3. 统计每天的订单总金额（GMV）和订单数
-- DATE(order_time) 把datetime转成日期，按天分组
select 
	date(order_time) as order_date,
	sum(order_amount) as GMV,
	count(*) as order_number
from order_info 
group by order_date

-- 4. 统计每个用户的下单次数和总消费金额
SELECT
    u.user_id,
    u.user_name,
    COUNT(o.order_id) AS order_cnt,
    SUM(o.order_amount) AS total_consume
FROM users u
LEFT JOIN order_info o ON u.user_id = o.user_id
GROUP BY u.user_id, u.user_name;

-- 5. 统计已支付订单中，每个用户的平均订单金额
-- order_status=1 已支付，WHERE在分组前过滤订单
select 
	u.user_id,
	u.user_name,
	avg(o.order_amount) as Average_order_amount
from users u
join order_info o ON u.user_id = o.user_id
where o.order_status = 1
group by u.user_id,user_name

-- 6. 筛选出总消费金额大于 200 元的用户
-- 先分组算出每个人总消费，再用HAVING过滤分组结果
select 
	u.user_id,
	u.user_name,
	sum(o.order_amount) as Sum_order_amount
from users u
join order_info o ON u.user_id = o.user_id
group by u.user_id,u.user_name
having sum(o.order_amount)>200
