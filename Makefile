.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo
	@echo vuejs-quarkus-oauth
	@echo
	@fgrep "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/:.*## / - /'
	@echo


.PHONY: run-keycloak-server
run-keycloak-server:  ## Create a new Docker container running KeyCloak
	@if [ "`docker ps -af \"name=authentication-service\" --format '{{.Names}}'`" != "authentication-service" ]; then \
	  echo Create and run authentication-service ;\
	  docker run -d \
	  --name authentication-service \
	  -e KEYCLOAK_USER=admin \
	  -e KEYCLOAK_PASSWORD=admin \
	  -p 8180:8080 \
	  quay.io/keycloak/keycloak ;\
	else \
	  echo Starting authentication-service ;\
	  docker start authentication-service ;\
	fi

.PHONY: start-keycloak-server
start-keycloak-server:  ## Start an existing Docker container running KeyCloak
	docker start authentication-service

.PHONY: stop-keycloak-server
stop-keycloak-server:  ## Stop KeyCloak docker container
	@if [ "`docker inspect -f {{.State.Running}} authentication-service`" == "true" ]; then \
	  echo Stopping container ;\
	  docker kill authentication-service ;\
	fi

.PHONY: remove-keycloak-server
remove-keycloak-server: stop-keycloak-server  ## Stop KeyCloak docker container
	docker rm authentication-service

.PHONY: dev-webclient-service
dev-webclient-service:  # Build WebClient application
	cd webclient-service && yarn serve

.PHONY: dev-backend-service
dev-backend-service:  ## Build Quarkus application
	cd backend-service && ./mvnw compile quarkus:dev

.PHONY: start
start: run-keycloak-server dev-backend-service dev-webclient-service  ## Start application stack

.PHONY: stop
stop: stop-keycloak-server  ## Stop application stack

.PHONY: destroy
destroy: remove-keycloak-server  ## Remove application stack
