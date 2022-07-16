COMMAND=docker-compose
export COMPOSE_DOCKER_CLI_BUILD=1

PHONY += up
up:
	$(COMMAND) up --remove-orphans

PHONY += down
down:
	$(COMMAND) down

PHONY += shell
shell:
	$(COMMAND) exec $(APP_NAME) bash

PHONY += chown-src
chown-src:
	sudo chown $(shell id -u):$(shell id -g) -R src/

.PHONY: $(PHONY)
