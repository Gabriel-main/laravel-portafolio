.PHONY: up down build restart logs shell artisan migrate seed fresh setup mysql status

# Start containers
up:
	docker compose up -d

# Stop containers
down:
	docker compose down

# Build containers
build:
	docker compose build --no-cache

# Restart containers
restart:
	docker compose restart

# View logs
logs:
	docker compose logs -f

# Shell into PHP container
shell:
	docker compose exec php bash

# Run artisan commands
artisan:
	docker compose exec php php artisan $(cmd)

# Run migrations
migrate:
	docker compose exec php php artisan migrate

# Run seeders
seed:
	docker compose exec php php artisan db:seed

# Fresh migration + seed
fresh:
	docker compose exec php php artisan migrate:fresh --seed

# Full setup (first time)
setup:
	docker compose build --no-cache
	docker compose up -d
	docker compose exec php php artisan key:generate
	docker compose exec php php artisan migrate --force
	docker compose exec php php artisan db:seed
	docker compose exec php pnpm run build

# Open MySQL in terminal
mysql:
	docker compose exec mysql mysql -u portafilo -psecret portafilo

# Status
status:
	docker compose ps
