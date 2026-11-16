-- =========================================================
-- 카페 주문 DB - 핵심 쿼리 15개
-- 14, 15번(UPDATE/DELETE)은 데이터를 바꾸므로 맨 마지막에 실행
-- =========================================================
USE cafe;  -- [MySQL 전용]


-- ---------- [기본 조회] ----------

-- Q1. 가격이 5000원 이상인 메뉴를 비싼 순으로 조회
SELECT name, price
FROM menu
WHERE price >= 5000
ORDER BY price DESC;

-- Q2. 가장 최근에 가입한 고객 5명 조회
SELECT customer_id, name, joined_at
FROM customer
ORDER BY joined_at DESC
LIMIT 5;

-- Q3. 현재 판매 중지된 메뉴 조회
SELECT menu_id, name, price
FROM menu
WHERE is_available = FALSE;

-- Q4. 2026년 11월에 들어온 주문을 시간순으로 조회
SELECT order_id, customer_id, ordered_at, status
FROM orders
WHERE ordered_at >= '2026-11-01' AND ordered_at < '2026-12-01'
ORDER BY ordered_at;


-- ---------- [조인] ----------

-- Q5. (INNER JOIN) 메뉴 이름과 카테고리 이름을 함께 조회
SELECT c.name AS category, m.name AS menu, m.price
FROM menu m
INNER JOIN category c ON m.category_id = c.category_id
ORDER BY c.category_id, m.price;

-- Q6. (INNER JOIN) 주문 상세 내역: 누가, 언제, 무엇을, 몇 개, 얼마에 샀는지
SELECT o.order_id, cu.name AS customer, o.ordered_at,
       m.name AS menu, oi.quantity, oi.quantity * oi.unit_price AS amount
FROM orders o
INNER JOIN customer   cu ON o.customer_id = cu.customer_id
INNER JOIN order_item oi ON o.order_id    = oi.order_id
INNER JOIN menu       m  ON oi.menu_id    = m.menu_id
ORDER BY o.order_id;

-- Q7. (LEFT JOIN) 메뉴가 하나도 없는 카테고리 찾기
SELECT c.category_id, c.name
FROM category c
LEFT JOIN menu m ON c.category_id = m.category_id
WHERE m.menu_id IS NULL;

-- Q8. (LEFT JOIN) 고객별 주문 횟수 - 주문이 없는 고객도 0으로 표시
SELECT cu.customer_id, cu.name, COUNT(o.order_id) AS order_count
FROM customer cu
LEFT JOIN orders o ON cu.customer_id = o.customer_id
GROUP BY cu.customer_id, cu.name
ORDER BY order_count DESC, cu.customer_id;


-- ---------- [집계] ----------

-- Q9. 판매 수량 TOP 5 메뉴 (취소된 주문 제외)
SELECT m.name, SUM(oi.quantity) AS total_qty
FROM order_item oi
INNER JOIN menu   m ON oi.menu_id  = m.menu_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status <> 'CANCELED'
GROUP BY m.menu_id, m.name
ORDER BY total_qty DESC
LIMIT 5;

-- Q10. 카테고리별 메뉴 개수와 평균 가격
SELECT c.name AS category, COUNT(m.menu_id) AS menu_count, ROUND(AVG(m.price)) AS avg_price
FROM category c
INNER JOIN menu m ON c.category_id = m.category_id
GROUP BY c.category_id, c.name
ORDER BY avg_price DESC;

-- Q11. 일별 매출 합계 (결제 완료된 주문만)
SELECT DATE(o.ordered_at) AS order_date,                -- [MySQL 전용] DATE()
       SUM(oi.quantity * oi.unit_price) AS daily_sales
FROM orders o
INNER JOIN order_item oi ON o.order_id = oi.order_id
WHERE o.status = 'COMPLETED'
GROUP BY DATE(o.ordered_at)
ORDER BY order_date;


-- ---------- [서브쿼리] ----------

-- Q12. 한 번도 주문하지 않은 고객 찾기
SELECT customer_id, name, joined_at
FROM customer
WHERE customer_id NOT IN (SELECT customer_id FROM orders);


-- ---------- [인덱스] ----------

-- Q13. 주문 일시에 인덱스 생성
-- 이유: Q4, Q11처럼 날짜 범위로 주문을 조회하는 경우가 많아서, 주문이 쌓여도 빠르게 찾기 위함
CREATE INDEX idx_orders_ordered_at ON orders (ordered_at);
SHOW INDEX FROM orders;                                  -- [MySQL 전용] 인덱스 확인


-- ---------- [수정 / 삭제] ----------

-- Q14. 대기 중이던 14번 주문을 완료 처리
UPDATE orders
SET status = 'COMPLETED'
WHERE order_id = 14;

SELECT order_id, status FROM orders WHERE order_id = 14;  -- 결과 확인

-- Q15. 취소된 13번 주문 삭제 (ON DELETE CASCADE로 주문 상세도 함께 삭제됨)
DELETE FROM orders
WHERE order_id = 13;

SELECT * FROM orders     WHERE order_id = 13;            -- 결과 확인: 0행
SELECT * FROM order_item WHERE order_id = 13;            -- 결과 확인: 0행
