-- ==========================================
-- FOODFLOW ERP - DATABASE SCHEMA
-- ==========================================

-- ==========================================
-- 1. TEMEL TABLOLAR
-- ==========================================

-- Şirketler
CREATE TABLE companies (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  city VARCHAR(100),
  postal_code VARCHAR(10),
  country VARCHAR(100) DEFAULT 'TR',
  subscription_tier VARCHAR(50) DEFAULT 'starter', -- starter, professional, enterprise
  monthly_budget DECIMAL(12,2),
  status VARCHAR(50) DEFAULT 'active', -- active, suspended, inactive
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kullanıcılar
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  phone VARCHAR(20),
  role VARCHAR(50) DEFAULT 'staff', -- admin, manager, chef, warehouse, accountant, staff
  status VARCHAR(50) DEFAULT 'active', -- active, inactive, suspended
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 2. PERSONEL & YEMEKHANE YÖNETİMİ
-- ==========================================

-- Personel Listesi
CREATE TABLE staff_members (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  employee_id VARCHAR(50) UNIQUE,
  dietary_restrictions TEXT, -- Vegan, Vegetarian, Gluten-Free, etc.
  status VARCHAR(50) DEFAULT 'active', -- active, on_leave, inactive
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Yemekhane Kayıtları (Günlük Katılım)
CREATE TABLE meal_attendance (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  staff_id INTEGER REFERENCES staff_members(id),
  meal_type VARCHAR(50) DEFAULT 'lunch', -- breakfast, lunch, dinner, snack
  attendance_count INTEGER DEFAULT 1, -- Misafir varsa
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. MENÜ & TARİF YÖNETİMİ
-- ==========================================

-- Tarifler
CREATE TABLE recipes (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(100), -- soup, main, side, dessert, drink
  preparation_time_minutes INTEGER,
  cooking_time_minutes INTEGER,
  servings INTEGER DEFAULT 1, -- Default porsiyon sayısı
  calories_per_serving DECIMAL(8,2),
  protein_grams DECIMAL(8,2),
  carbs_grams DECIMAL(8,2),
  fat_grams DECIMAL(8,2),
  instructions TEXT,
  difficulty_level VARCHAR(50) DEFAULT 'medium', -- easy, medium, hard
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tarif Malzemeleri
CREATE TABLE recipe_ingredients (
  id SERIAL PRIMARY KEY,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  ingredient_name VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) NOT NULL,
  unit VARCHAR(50), -- kg, g, ml, litre, cup, piece
  unit_cost DECIMAL(10,2), -- Birim maliyeti
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Haftalık Menü Planı
CREATE TABLE weekly_menus (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  notes TEXT,
  status VARCHAR(50) DEFAULT 'draft', -- draft, confirmed, completed
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(company_id, week_start_date)
);

-- Günlük Menüler
CREATE TABLE daily_menus (
  id SERIAL PRIMARY KEY,
  weekly_menu_id INTEGER NOT NULL REFERENCES weekly_menus(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  day_name VARCHAR(20), -- Monday, Tuesday, etc.
  expected_servings INTEGER,
  actual_servings INTEGER,
  status VARCHAR(50) DEFAULT 'planned', -- planned, preparing, completed
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Günlük Menü Yemekleri
CREATE TABLE daily_menu_items (
  id SERIAL PRIMARY KEY,
  daily_menu_id INTEGER NOT NULL REFERENCES daily_menus(id) ON DELETE CASCADE,
  recipe_id INTEGER NOT NULL REFERENCES recipes(id),
  meal_course_number INTEGER, -- 1: Soup, 2: Main, 3: Side, 4: Dessert
  status VARCHAR(50) DEFAULT 'planned', -- planned, preparing, completed
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 4. DEPO & ENVANTER YÖNETİMİ
-- ==========================================

-- Malzeme Listesi
CREATE TABLE ingredients (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100), -- protein, vegetable, grain, dairy, spice, etc.
  unit VARCHAR(50), -- kg, g, ml, litre, piece
  current_stock DECIMAL(12,2),
  minimum_stock DECIMAL(12,2),
  maximum_stock DECIMAL(12,2),
  unit_cost DECIMAL(10,2),
  supplier_id INTEGER,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Depo Hareketi (Giriş/Çıkış)
CREATE TABLE inventory_transactions (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  ingredient_id INTEGER NOT NULL REFERENCES ingredients(id),
  transaction_type VARCHAR(50), -- purchase, usage, waste, adjustment
  quantity DECIMAL(12,2) NOT NULL,
  unit_cost DECIMAL(10,2),
  total_cost DECIMAL(12,2),
  reference_id VARCHAR(100), -- Fatura numarası veya menü ID
  notes TEXT,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tedarikçiler
CREATE TABLE suppliers (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  contact_person VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(20),
  address TEXT,
  payment_terms VARCHAR(100),
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Satın Alma Siparişleri
CREATE TABLE purchase_orders (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  supplier_id INTEGER REFERENCES suppliers(id),
  order_date DATE NOT NULL,
  expected_delivery_date DATE,
  actual_delivery_date DATE,
  total_amount DECIMAL(12,2),
  status VARCHAR(50) DEFAULT 'draft', -- draft, confirmed, delivered, cancelled
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Satın Alma Siparişi Detayları
CREATE TABLE purchase_order_items (
  id SERIAL PRIMARY KEY,
  purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
  ingredient_id INTEGER REFERENCES ingredients(id),
  quantity DECIMAL(12,2),
  unit_cost DECIMAL(10,2),
  total_cost DECIMAL(12,2)
);

-- ==========================================
-- 5. MALİYET & RAPORLAMA
-- ==========================================

-- Günlük Maliyet Özeti
CREATE TABLE daily_cost_summary (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  total_cost DECIMAL(12,2),
  actual_servings INTEGER,
  cost_per_serving DECIMAL(10,2),
  budget_allocated DECIMAL(12,2),
  variance DECIMAL(12,2), -- Budget - Actual
  waste_amount DECIMAL(12,2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(company_id, date)
);

-- Haftalık Maliyet Özeti
CREATE TABLE weekly_cost_summary (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  week_end_date DATE NOT NULL,
  total_cost DECIMAL(12,2),
  total_servings INTEGER,
  average_cost_per_serving DECIMAL(10,2),
  budget_allocated DECIMAL(12,2),
  variance DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Aylık Maliyet Özeti
CREATE TABLE monthly_cost_summary (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  year INTEGER,
  month INTEGER,
  total_cost DECIMAL(12,2),
  total_servings INTEGER,
  average_cost_per_serving DECIMAL(10,2),
  budget_allocated DECIMAL(12,2),
  variance DECIMAL(12,2),
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(company_id, year, month)
);

-- Malzeme Tüketim Analizi
CREATE TABLE ingredient_usage (
  id SERIAL PRIMARY KEY,
  company_id INTEGER NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  ingredient_id INTEGER NOT NULL REFERENCES ingredients(id),
  date DATE,
  planned_quantity DECIMAL(12,2),
  actual_quantity DECIMAL(12,2),
  waste_quantity DECIMAL(12,2),
  waste_percentage DECIMAL(5,2),
  cost DECIMAL(12,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 6. İNDEKSLER
-- ==========================================

CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_staff_company_id ON staff_members(company_id);
CREATE INDEX idx_recipes_company_id ON recipes(company_id);
CREATE INDEX idx_ingredients_company_id ON ingredients(company_id);
CREATE INDEX idx_daily_menus_date ON daily_menus(date);
CREATE INDEX idx_inventory_ingredient ON inventory_transactions(ingredient_id);
CREATE INDEX idx_daily_cost_date ON daily_cost_summary(date);
CREATE INDEX idx_meal_attendance_date ON meal_attendance(date);
CREATE INDEX idx_purchase_orders_status ON purchase_orders(status);

-- ==========================================
-- 7. VIEWS (Raporlama için)
-- ==========================================

-- Bugünün Maliyet Raporu
CREATE VIEW v_today_cost_report AS
SELECT 
  c.id as company_id,
  c.name as company_name,
  dcs.date,
  dcs.total_cost,
  dcs.actual_servings,
  dcs.cost_per_serving,
  dcs.budget_allocated,
  dcs.variance
FROM daily_cost_summary dcs
JOIN companies c ON c.id = dcs.company_id
WHERE dcs.date = CURRENT_DATE;

-- Malzeme Stok Durumu
CREATE VIEW v_inventory_status AS
SELECT 
  i.id,
  i.name as ingredient_name,
  i.current_stock,
  i.minimum_stock,
  i.maximum_stock,
  CASE 
    WHEN i.current_stock <= i.minimum_stock THEN 'CRITICAL'
    WHEN i.current_stock <= (i.minimum_stock * 1.5) THEN 'LOW'
    ELSE 'OK'
  END as stock_status,
  i.unit_cost,
  (i.current_stock * i.unit_cost) as total_stock_value
FROM ingredients i;

-- Tarif Maliyeti
CREATE VIEW v_recipe_cost AS
SELECT 
  r.id,
  r.name as recipe_name,
  r.servings,
  SUM(ri.quantity * i.unit_cost) as total_cost,
  ROUND(SUM(ri.quantity * i.unit_cost) / r.servings, 2) as cost_per_serving
FROM recipes r
LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
LEFT JOIN ingredients i ON ri.ingredient_name = i.name
GROUP BY r.id, r.name, r.servings;