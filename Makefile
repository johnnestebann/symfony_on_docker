build:
	@docker-compose build --no-cache

up:
	@docker-compose up -d

down:
	@docker-compose stop

restart:
	@docker-compose restart

rebuild:
	@make down
	@make build
	@make up

ssh:
	@docker-compose exec symfony-app-php sh