# FoodFlow ERP - Installation & Setup Guide

## 📋 Prerequisites

- Node.js 18+
- PostgreSQL 14+
- Git
- npm or yarn

---

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/oilcool758-lab/foodflow-erp.git
cd foodflow-erp
```

### 2. Setup Database

```bash
# Create database
createdb foodflow_db

# Import schema
psql foodflow_db < database/schema.sql

# Verify tables
psql foodflow_db -c "\dt"
```

### 3. Setup Backend

```bash
cd backend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your credentials
# DB_HOST=localhost
# DB_PORT=5432
# DB_NAME=foodflow_db
# DB_USER=postgres
# DB_PASSWORD=your_password
# JWT_SECRET=your_secret_key_min_32_chars

# Run server
npm run dev
```

Server will run on `http://localhost:5000`

### 4. Setup Frontend

```bash
cd ../frontend

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env if needed
# REACT_APP_API_URL=http://localhost:5000/api/v1

# Start React
npm start
```

Frontend will open on `http://localhost:3000`

---

## 🔑 Default Login

**Email:** admin@example.com  
**Password:** admin123

(You'll need to register first via the signup flow)

---

## 📁 Project Structure

```
foodflow-erp/
├── database/
│   └── schema.sql                 # PostgreSQL schema
├── backend/
│   ├── src/
│   │   ├── database.js            # Database connection
│   │   ├── middlewares/auth.js    # JWT middleware
│   │   └── routes/                # API endpoints
│   ├── server.js                  # Express app
│   ├── package.json
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── pages/                 # React pages
│   │   ├── components/            # React components
│   │   ├── services/api.js        # API client
│   │   └── App.js                 # Main app
│   ├── package.json
│   └── .env.example
└── README.md
```

---

## 🛠️ API Endpoints

### Authentication
- `POST /auth/register` - Register new company
- `POST /auth/login` - Login user

### Dashboard
- `GET /dashboard/daily-summary?date=YYYY-MM-DD` - Get daily cost summary
- `GET /dashboard/monthly-stats?year=YYYY&month=MM` - Get monthly statistics
- `GET /dashboard/weekly-trend` - Get last 12 weeks trend

### Recipes
- `GET /recipes` - List recipes
- `POST /recipes` - Create recipe
- `GET /recipes/:recipe_id/cost?servings=N` - Calculate recipe cost

### Inventory
- `GET /inventory/status` - Get stock status
- `POST /inventory/transactions` - Record stock movement
- `GET /inventory/purchase-suggestions` - Get purchase recommendations

### Menus
- `POST /menus/weekly` - Create weekly menu
- `GET /menus/daily?date=YYYY-MM-DD` - Get daily menu

### Reports
- `GET /reports/daily-cost?date=YYYY-MM-DD` - Daily cost report
- `GET /reports/monthly-investment?year=YYYY&month=MM` - Monthly investment report
- `GET /reports/nutrition?date=YYYY-MM-DD` - Nutrition analysis

### Settings
- `GET /settings/company` - Get company settings
- `PUT /settings/company` - Update company settings

---

## 🧪 Testing Endpoints

### Using curl

```bash
# Register
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patron@fabrika.com",
    "password": "secure123",
    "company_name": "Fabrika Yemekhanesi",
    "first_name": "Ahmet",
    "last_name": "Yilmaz"
  }'

# Login
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "patron@fabrika.com",
    "password": "secure123"
  }'

# Get Daily Summary (with token)
curl -X GET http://localhost:5000/api/v1/dashboard/daily-summary?date=2026-06-05 \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📱 Features Implemented

✅ **Authentication** (Register/Login with JWT)
✅ **Dashboard** (Daily & Monthly summaries)
✅ **Recipe Management** (Create, list, cost calculation)
✅ **Inventory Management** (Stock tracking, transactions)
✅ **Menu Planning** (Weekly & daily menus)
✅ **Reporting** (Cost, nutrition, investment analysis)
✅ **Role-based Access** (Admin, Manager, Chef, Warehouse, Accountant)

---

## 🚧 Features In Progress

🔄 Mobile app (React Native)
🔄 Advanced analytics (ML-based optimization)
🔄 Multi-location support
🔄 Payment integration (Stripe/Iyzico)
🔄 Email notifications
🔄 Export to Excel/PDF

---

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check if port 5000 is in use
lsof -i :5000

# Check database connection
psql -U postgres -d foodflow_db -c "SELECT 1;"
```

### Frontend won't start
```bash
# Clear node_modules
rm -rf node_modules
npm install
npm start
```

### Database connection error
- Verify PostgreSQL is running
- Check .env credentials
- Ensure database exists: `createdb foodflow_db`

---

## 📞 Support

For issues or questions, please open a GitHub issue:
https://github.com/oilcool758-lab/foodflow-erp/issues

---

## 📄 License

MIT License - See LICENSE file for details

---

**FoodFlow ERP © 2026**
