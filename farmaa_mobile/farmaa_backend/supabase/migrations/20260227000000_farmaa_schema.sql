-- ============================================================
-- Farmaa Database Schema – Supabase PostgreSQL Migration
-- Run with: supabase migration new farmaa_schema
--           supabase db push
-- ============================================================

-- ── Enable UUID extension ────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── Users ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id          TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
    phone       VARCHAR(15) NOT NULL UNIQUE,
    name        VARCHAR(100) NOT NULL,
    role        VARCHAR(10) NOT NULL DEFAULT 'buyer',      -- farmer | buyer | admin
    village     VARCHAR(100),
    district    VARCHAR(100),
    organization VARCHAR(150),
    is_verified BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role  ON users(role);

-- ── Crops ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS crops (
    id                TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
    farmer_id         TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name              VARCHAR(100) NOT NULL,
    variety           VARCHAR(100),
    description       TEXT,
    category          VARCHAR(50) DEFAULT 'Other',
    price_per_kg      DOUBLE PRECISION NOT NULL,
    stock_kg          DOUBLE PRECISION NOT NULL DEFAULT 0,
    min_order_kg      DOUBLE PRECISION DEFAULT 50,
    unit              VARCHAR(10) DEFAULT 'kg',
    status            VARCHAR(20) DEFAULT 'approved',      -- approved | pending_qa | sold_out
    is_available      BOOLEAN DEFAULT TRUE,
    image_url         VARCHAR(500),
    location          VARCHAR(200),
    last_price_update TIMESTAMPTZ DEFAULT NOW(),
    created_at        TIMESTAMPTZ DEFAULT NOW(),
    updated_at        TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crops_farmer   ON crops(farmer_id);
CREATE INDEX IF NOT EXISTS idx_crops_category ON crops(category);
CREATE INDEX IF NOT EXISTS idx_crops_status   ON crops(status);

-- ── Orders ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id               TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
    buyer_id         TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    farmer_id        TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    crop_id          TEXT NOT NULL REFERENCES crops(id) ON DELETE CASCADE,
    quantity_kg      DOUBLE PRECISION NOT NULL,
    total_amount     DOUBLE PRECISION NOT NULL,
    delivery_address TEXT,
    status           VARCHAR(20) DEFAULT 'pending',        -- pending | confirmed | shipped | delivered | cancelled
    payment_id       VARCHAR(100),
    created_at       TIMESTAMPTZ DEFAULT NOW(),
    updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_buyer  ON orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_farmer ON orders(farmer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);

-- ── Market Prices ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS market_prices (
    id           TEXT PRIMARY KEY DEFAULT uuid_generate_v4()::TEXT,
    crop_name    VARCHAR(100) NOT NULL,
    category     VARCHAR(50),
    price_per_kg DOUBLE PRECISION NOT NULL,
    market_name  VARCHAR(150),
    source       VARCHAR(100) DEFAULT 'manual',
    recorded_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_market_prices_crop ON market_prices(crop_name);

-- ── Seed data: Sample market prices ──────────────────────
INSERT INTO market_prices (crop_name, category, price_per_kg, market_name, source) VALUES
    ('Basmati Rice',     'Rice',    85.00,  'Chennai Koyambedu',  'manual'),
    ('Ponni Rice',       'Rice',    52.00,  'Madurai',            'manual'),
    ('Wheat',            'Wheat',   32.00,  'Delhi Azadpur',      'manual'),
    ('Pearl Millet',     'Millet',  28.00,  'Coimbatore',         'manual'),
    ('Finger Millet',    'Millet',  45.00,  'Bengaluru',          'manual'),
    ('Barley',           'Barley',  30.00,  'Jaipur',             'manual'),
    ('Sorghum',          'Sorghum', 26.00,  'Hyderabad',          'manual'),
    ('Yellow Maize',     'Maize',   22.00,  'Pune',               'manual'),
    ('Red Lentils',      'Pulses',  95.00,  'Kolkata',            'manual'),
    ('Black Gram',       'Pulses',  88.00,  'Chennai',            'manual'),
    ('Green Gram',       'Pulses',  92.00,  'Mumbai APMC',        'manual'),
    ('Chickpea',         'Pulses',  65.00,  'Indore',             'manual')
ON CONFLICT DO NOTHING;

-- ── Updated_at trigger function ──────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_users_updated') THEN
        CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_crops_updated') THEN
        CREATE TRIGGER trg_crops_updated BEFORE UPDATE ON crops
        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_orders_updated') THEN
        CREATE TRIGGER trg_orders_updated BEFORE UPDATE ON orders
        FOR EACH ROW EXECUTE FUNCTION update_updated_at();
    END IF;
END;
$$;
