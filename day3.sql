USE test_shop;

-- 1. 查询所有订单对应的用户名和商品名称（内连接三张表）
select 
	o.order_id,
	o.order_amount,
	u.user_name,
	p.product_name,
	o.order_time, 
	o.order_status
from order_info o
join users u on o.order_id=u.user_id
join products p on p.product_id=o.product_id

-- 2. 查询每个用户的下单明细，没有下单的用户也要显示出来（左连接）
select 
	u.user_id,
    u.user_name,
    o.order_id,
    p.product_name,
    o.order_amount,
    o.order_status
from users u
left join order_info o on u.user_id=o.order_id 
left join products p on p.product_id =o.product_id

-- 3. 查询每个商品的销量和销售额
select 
	p.product_name,
	p.product_id,
	count(o.order_id) as sale_cent,
	sum(o.order_amount) as sale_money
from products p 
left join order_info o on p.product_id =o.order_id 
group by p.product_name,p.product_id

-- 4. 查询广州用户的所有订单总金额
select 
	sum(o.order_amount) as sale_money
from order_info o
join users u on o.user_id =u.user_id 
where u.city ='广州'

-- 5. 查询从未下过单的用户（左连接 + IS NULL）
select 
	u.user_id,
	u.user_name,
	u.city
from users u 
left join order_info o on u.user_id=o.user_id 
where o.order_id is null

-- 6. 查询每个品类的订单销量
select 
	p.category,
	count(o.order_id) as xiaoliang
from products p 
left join order_info o on p.product_id=o.product_id 
group by p.category

-- 7. 查询已完成订单中，每个城市的用户消费总额
-- order_status=3 代表已完成
select 
	u.city,
	sum(o.order_amount) as allxiaoliang
from order_info o
left join users u on o.user_id =u.user_id 
where o.order_status=3
group by u.city


