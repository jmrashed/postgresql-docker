# Quick Reference Guide

## 🚀 Getting Started (30 seconds)

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Start all services
docker-compose up -d

# 3. Wait for initialization (check logs)
docker-compose logs postgres

# 4. Access pgAdmin
# Browser: http://localhost:5050
# Email: admin@example.com
# Password: admin123
```

## 📍 Service Addresses

| Service | Address | Type |
|---------|---------|------|
| PostgreSQL | localhost:5432 | Database Server |
| pgAdmin | http://localhost:5050 | Web UI |

## 🔑 Default Credentials

### PostgreSQL
```
Superuser:  postgres / postgres
User 1:     user1 / pass1 (Database: db1)
User 2:     user2 / pass2 (Database: db2)
User 3:     user3 / pass3 (Database: db3)
```

### pgAdmin4
```
Email:      admin@example.com
Password:   admin123
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
# Using psql directly
psql -h localhost -U user1 -d db1

# Using Docker
docker-compose exec postgres psql -U user1 -d db1
```

### Backup Database
```bash
docker-compose exec postgres pg_dump -U user1 db1 > db1_backup.sql
```

### View Table Data
```bash
docker-compose exec postgres psql -U user1 -d db1 << EOF
SELECT * FROM customers;
EOF
```

### List All Databases
```bash
docker-compose exec postgres psql -U postgres -c "\l"
```

### Remove Everything (⚠️ Deletes Data)
```bash
docker-compose down -v
```

## 🗄️ Sample Data Quick Check

### DB1 (CRM)
```bash
docker-compose exec postgres psql -U user1 -d db1 -c "\dt"
# Shows: customers, orders
```

### DB2 (Inventory)
```bash
docker-compose exec postgres psql -U user2 -d db2 -c "\dt"
# Shows: products, inventory_logs
```

### DB3 (HR)
```bash
docker-compose exec postgres psql -U user3 -d db3 -c "\dt"
# Shows: employees, departments
```

## 🔍 Health Check

```bash
# All services healthy?
docker-compose ps

# PostgreSQL responsive?
docker-compose exec postgres pg_isready

# Can connect to each DB?
docker-compose exec postgres psql -U user1 -d db1 -c "SELECT COUNT(*) FROM customers;"
docker-compose exec postgres psql -U user2 -d db2 -c "SELECT COUNT(*) FROM products;"
docker-compose exec postgres psql -U user3 -d db3 -c "SELECT COUNT(*) FROM employees;"
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
# Verify you're in the correct database
psql -U user1 -d db1 -c "\dt"

# Check user permissions
docker-compose exec postgres psql -U postgres -d db1 -c "\dp"
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
