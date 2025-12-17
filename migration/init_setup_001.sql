-- 001_init.sql  (MySQL 8+)

CREATE DATABASE IF NOT EXISTS dateworthy
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE dateworthy;

-- =========================
-- USERS
-- =========================
CREATE TABLE IF NOT EXISTS users (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email         VARCHAR(320)    NOT NULL,
  password_hash VARCHAR(255)    NOT NULL,
  display_name  VARCHAR(80)     NULL,

  created_at    TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at    TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =========================
-- PLACES (restaurants + activities)
-- =========================
CREATE TABLE IF NOT EXISTS places (
  id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  type                ENUM('restaurant','activity') NOT NULL,
  name                VARCHAR(200)    NOT NULL,

  address_line1       VARCHAR(200)    NULL,
  address_line2       VARCHAR(200)    NULL,
  city                VARCHAR(100)    NULL,
  state_region        VARCHAR(100)    NULL,
  country             VARCHAR(100)    NULL,
  postal_code         VARCHAR(20)     NULL,

  price_level         TINYINT UNSIGNED NULL, -- e.g. 1..4
  created_by_user_id  BIGINT UNSIGNED  NULL,

  created_at          TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at          TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

  PRIMARY KEY (id),

  KEY idx_places_type_city (type, city),
  KEY idx_places_name (name),
  KEY idx_places_created_by (created_by_user_id),

  CONSTRAINT fk_places_created_by
    FOREIGN KEY (created_by_user_id) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT chk_places_price_level
    CHECK (price_level IS NULL OR (price_level BETWEEN 1 AND 4))
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;

-- =========================
-- REVIEWS
-- =========================
CREATE TABLE IF NOT EXISTS reviews (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id    BIGINT UNSIGNED NOT NULL,
  place_id   BIGINT UNSIGNED NOT NULL,

  rating     TINYINT UNSIGNED NOT NULL,
  title      VARCHAR(200)     NULL,
  body       TEXT             NULL,
  visit_date DATE             NULL,

  created_at TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),

  PRIMARY KEY (id),
  KEY idx_reviews_place_created (place_id, created_at),
  KEY idx_reviews_user_created (user_id, created_at),

  CONSTRAINT fk_reviews_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

  CONSTRAINT fk_reviews_place
    FOREIGN KEY (place_id) REFERENCES places(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =========================
-- SESSIONS (cookie-session auth)
-- =========================
CREATE TABLE IF NOT EXISTS sessions (
  id          CHAR(36)         NOT NULL, -- UUID string
  user_id     BIGINT UNSIGNED  NOT NULL,

  created_at  TIMESTAMP(6)     NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  expires_at  TIMESTAMP(6)     NOT NULL,
  revoked_at  TIMESTAMP(6)     NULL,

  user_agent  VARCHAR(255)     NULL,
  ip_addr     VARCHAR(45)      NULL,

  PRIMARY KEY (id),

  KEY idx_sessions_user (user_id),
  KEY idx_sessions_expires (expires_at),

  CONSTRAINT fk_sessions_user
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;
