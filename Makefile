.PHONY: up down verify lint shellcheck

up:
	./setup.sh

verify:
	./verify-setup.sh

down:
	docker-compose down -v || docker compose down -v

shellcheck:
	@command -v shellcheck >/dev/null 2>&1 || { echo 'shellcheck not installed'; exit 1; }
	@echo 'Running shellcheck...'
	shellcheck setup.sh verify-setup.sh init/00-init.sh pgadmin/setup-pgpass.sh

