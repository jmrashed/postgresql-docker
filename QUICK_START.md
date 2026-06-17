# Quick Reference Guide

## 🚀 Getting Started (30 seconds)

```bash
# One-command setup - generates random passwords, imports custom SQL, starts services
./setup.sh

# OR manually:
# 1. Create environment file (optional - setup.sh does this automatically)
cp .env.example .env

# 2. Start all services
docker-compose up -d

# 3. Wait for initialization (check logs)
docker-compose logs postgres

# 4. Access pgAdmin
# Browser: http://localhost:5050
# Email: admin@example.com
# Password: (shown in setup output or from .env)
```

## 📍 Service Addresses

| Service | Address | Type |
|---------|---------|------|
| PostgreSQL | localhost:5432 | Database Server |
| pgAdmin | http://localhost:5050 | Web UI |

## 🔑 Credentials

After running `./setup.sh`, credentials are printed to console and saved to `.env`:

### PostgreSQL
```
Superuser:      postgres / (randomly generated)
DB1:          crm_app / (randomly generated)  (Database: crm_db)
DB2:          inventory_app / (randomly generated)  (Database: inventory_db)
DB3:          hr_app / (randomly generated)  (Database: hr_db)
```

### pgAdmin4
```
Email:      admin@example.com
Password:   (randomly generated - shown in setup output)
```

## 💻 Common Commands

### Start Environment
```bash
docker-compose up -d
```

### Stop (Keep Data)
```bash
docker-compose stop
```

### View Logs
```bash
docker-compose logs -f postgres
```

### Connect to Database
```bash
# Using psql directly (replace with actual credentials from .env)
psql -h localhost -U crm_app -d crm_db

# Using Docker
docker-compose exec postgres psql -U crm_app -d crm_db
```

### Backup Database
```bash
docker-compose exec postgres pg_dump -U crm_app crm_db > db1_backup.sql
```

### View Table Data
```bash
docker-compose exec postgres psql -U crm_app -d crm_db << EOF
SELECT * FROM customers;
EOF
```

### List All Databases
```bash
docker-compose exec postgres psql -U postgres -c "\\l"
```

### Remove Everything (⚠️ Deletes Data)
```bash
docker-compose down -v
```

## 🗄️ Sample Data Quick Check

### DB1 (CRM)
```bash
docker-compose exec postgres psql -U crm_app -d crm_db -c "\\dt"
# Shows: customers, orders
```

### DB2 (Inventory)
```bash
docker-compose exec postgres psql -U inventory_app -d inventory_db -c "\\dt"
# Shows: products, inventory_logs
```

### DB3 (HR)
```bash
docker-compose exec postgres psql -U hr_app -d hr_db -c "\\dt"
# Shows: employees, departments
```

## 🔍 Health Check

```bash
# All services healthy?
docker-compose ps

# PostgreSQL responsive?
docker-compose exec postgres pg_isready

# Can connect to each DB?
docker-compose exec postgres psql -U crm_app -d crm_db -c "SELECT COUNT(*) FROM customers;"
docker-compose exec postgres psql -U inventory_app -d inventory_db -c "SELECT COUNT(*) FROM products;"
docker-compose exec postgres psql -U hr_app -d hr_db -c "SELECT COUNT(*) FROM employees;"
```

## 🛑 Troubleshooting

**Port Already in Use?**
```bash
# Find process using port 5432
sudo lsof -i :5432

# Kill the process or change port in docker-compose.yml
```

**Connection Refused?**
```bash
# Wait longer for initialization
docker-compose logs postgres

# Check if container is running
docker-compose ps
```

**Can't See Tables?**
```bash
# Check user permissions
```bash
docker-compose exec postgres psql -U postgres -d crm_db -c "\\dp"
```
```

## 📖 Full Documentation

See `README.md` for comprehensive documentation including:
- Detailed setup instructions
- Database schemas and sample data
- Security best practices
- Backup and restore procedures
- Advanced troubleshooting
- Connection strings for various frameworks

---

**Need Help?** Check README.md or view logs with `docker-compose logs`
