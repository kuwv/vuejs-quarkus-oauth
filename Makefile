.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo
	@echo vuejs-quarkus-oauth
	@echo
	@fgrep "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/:.*## / - /'
	@echo

.PHONY: dev-webclient-service
dev-webclient-service:  # Build WebClient application
	cd webclient-service && yarn serve

.PHONY: dev-backend-service
dev-backend-service:  ## Build Quarkus application
	cd backend-service && ./mvnw compile quarkus:dev

.PHONY: run-keycloak-server
run-keycloak-server:  ## Create a new Docker container running KeyCloak
	docker run -d --name authentication-service -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin -p 8180:8080 quay.io/keycloak/keycloak

.PHONY: start-keycloak-server
start-keycloak-server:  ## Start an existing Docker container running KeyCloak
	docker start authentication-service

.PHONY: start
start: run-keycloak-server dev-backend-service dev-webclient-service  ## Start application stack
