COMMAND=docker-compose
export COMPOSE_DOCKER_CLI_BUILD=1


PHONY += build
build:
	docker run --rm -it -v $(shell pwd)/src:/src klakegg/hugo:0.101.0-alpine

PHONY += shell
shell:
	docker run --rm -it -v $(shell pwd)/src:/src klakegg/hugo:0.101.0-alpine shell

PHONY += up
up:
	$(COMMAND) up --remove-orphans

PHONY += down
down:
	$(COMMAND) down

PHONY += chown-src
chown-src:
	sudo chown $(shell id -u):$(shell id -g) -R src/

.PHONY: $(PHONY)
