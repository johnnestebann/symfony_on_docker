build:
	@mkdir app
	@docker-compose build

up:
	@docker-compose up -d

down:
	@docker-compose stop

restart:
	@docker-compose restart

ssh:
	@docker-compose exec symfony-app-php sh