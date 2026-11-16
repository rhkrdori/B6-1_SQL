-- =========================================================
-- 카페 주문 DB - 스키마 생성 스크립트
-- DB: MySQL 8.0
-- 실행 순서: 이 파일 → data.sql → queries.sql
-- =========================================================

-- [MySQL 전용] DB를 새로 만들고 선택
DROP DATABASE IF EXISTS cafe;
CREATE DATABASE cafe;
USE cafe;

-- 1. 고객
CREATE TABLE customer (
    customer_id INT          AUTO_INCREMENT PRIMARY KEY,   -- [MySQL 전용] AUTO_INCREMENT
    name        VARCHAR(50)  NOT NULL,
    phone       VARCHAR(20)  NOT NULL UNIQUE,              -- 전화번호는 중복 불가
    joined_at   DATE         NOT NULL
);

-- 2. 메뉴 카테고리
CREATE TABLE category (
    category_id INT          AUTO_INCREMENT PRIMARY KEY,   -- [MySQL 전용] AUTO_INCREMENT
    name        VARCHAR(30)  NOT NULL UNIQUE
);

-- 3. 메뉴 (카테고리 1 : N 메뉴)
CREATE TABLE menu (
    menu_id      INT          AUTO_INCREMENT PRIMARY KEY,  -- [MySQL 전용] AUTO_INCREMENT
    category_id  INT          NOT NULL,
    name         VARCHAR(50)  NOT NULL UNIQUE,
    price        INT          NOT NULL CHECK (price > 0),
    is_available BOOLEAN      NOT NULL DEFAULT TRUE,       -- 판매 중 여부
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- 4. 주문 (고객 1 : N 주문)
CREATE TABLE orders (
    order_id    INT          AUTO_INCREMENT PRIMARY KEY,   -- [MySQL 전용] AUTO_INCREMENT
    customer_id INT          NOT NULL,
    ordered_at  DATETIME     NOT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'PENDING'
                CHECK (status IN ('PENDING', 'COMPLETED', 'CANCELED')),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

-- 5. 주문 상세 (주문 1 : N 주문상세, 메뉴 1 : N 주문상세)
CREATE TABLE order_item (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,          -- [MySQL 전용] AUTO_INCREMENT
    order_id      INT NOT NULL,
    menu_id       INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    INT NOT NULL,                            -- 주문 당시 가격 (메뉴 가격이 바뀌어도 기록 유지)
    UNIQUE (order_id, menu_id),                            -- 한 주문에 같은 메뉴가 두 줄로 들어가지 않게
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,  -- 주문 삭제 시 상세도 같이 삭제
    FOREIGN KEY (menu_id)  REFERENCES menu(menu_id)
);
