APP_NAME=api
COMMAND=docker-compose
IMAGE:=leia:devel

export COMPOSE_DOCKER_CLI_BUILD=1

PHONY += build
build: devel-environment-files
	docker build --target devel -t $(IMAGE) ./src/

PHONY += up-d
up-d: build devel-environment-files
	$(COMMAND) up -d --remove-orphans

PHONY += up
up: build devel-environment-files
	$(COMMAND) up --remove-orphans

PHONY += down
down:
	$(COMMAND) down

PHONY += shell
shell:
	$(COMMAND) exec $(APP_NAME) bash

PHONY += initial-data
initial-data:
	$(COMMAND) exec $(APP_NAME) bash -c 'python manage.py shell < scripts/initial_data.py'


PHONY += config
config:
	$(COMMAND) config

PHONY += chown-src
chown-src:
	sudo chown $(shell id -u):$(shell id -g) -R src/

PHONY += clean
clean:
	echo "Cleaning"

PHONY += translate
translate:
	$(COMMAND) exec api	python manage.py makemessages -a -e pug,html,py
	$(MAKE) chown-src

PHONY += compilemessages
compilemessages:
	$(COMMAND) exec api python manage.py compilemessages
	$(COMMAND) restart api

PHONY += mypy
mypy: build
ifndef CI_PIPELINE_ID
	$(COMMAND) run --rm --no-deps $(APP_NAME) mypy --config-file mypy.ini .
else
	docker run --rm testingcontainer mypy --config-file mypy.ini .
endif

PHONY += test
test: build
ifndef CI_PIPELINE_ID
	$(COMMAND) run --rm --no-deps $(APP_NAME) pytest
else
	docker run --rm testingcontainer pytest
endif

PHONY += test-watch
test-watch:
	$(COMMAND) run --rm --no-deps $(APP_NAME) pytest-watch

PHONY += watch-statics
watch-statics:
	$(COMMAND) run --rm $(APP_NAME) npm run watch


PHONY += devel-environment-files
devel-environment-files: config/secrets.env

define SECRETSENV
# Secrets
BR_LEIA_COGNITO_KEY=6gmgl72nmnhpg84dauq2ubsg7f
BR_LEIA_COGNITO_SECRET=j4h6t56urvsrtdssvjvaui1elebh3ui72j1rivd6acinf12s6d7
BR_LEIA_COGNITO_POOL_DOMAIN=https://br-auth-dev.auth.eu-central-1.amazoncognito.com
BR_LEIA_COGNITO_USER_POOL=eu-central-1_KV3btlVfA
BR_LEIA_COGNITO_REGION=eu-central-1
BR_LEIA_FILES_BUCKET=dev-treatments
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_SESSION_TOKEN=your-aws-token
BR_LEIA_FILES_BUCKET=dev-treatments
AWS_DEFAULT_REGION=eu-central-1
BR_APP_COGNITO_CLIENT_ID=your-api-clientid
BR_APP_API_LEIA_USERNAME=your-api-user-username
BR_APP_API_LEIA_PASSWORD=your-api-user-password
BR_APP_URL=https://api.your-domain-name
BR_LEGACY_TUNNEL_DATABASE_USER=your-db-user
BR_LEGACY_TUNNEL_DATABASE_PASSWORD=your-db-password

endef

export SECRETSENV
config/secrets.env:
	echo "$$SECRETSENV" >> $@

PHONY += generate-secret-key
generate-secret-key:
	$(COMMAND) exec $(APP_NAME) pipenv run python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'


.PHONY: $(PHONY)
