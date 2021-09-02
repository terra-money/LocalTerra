#!/usr/bin/make -f


ifeq ($(LOCALTERRA_OLDER),)
  LOCALTERRA_OLDER := v0.4.1
endif

ifeq ($(LOCALTERRA_NEWER),)
  LOCALTERRA_NEWER := main
endif

DOCKER := $(shell which docker)
DOCKER_COMPOSE := $(shell which docker-compose)


init_columbus-4: get_columbus-4 run_columbus-4
init_columbus-5: get_columbus-5 run_columbus-5

clean: clean_columbus-4 clean_columbus-5
	@echo cleaning up...
	-@rm ./temp/* ./log/*
	-@rm ./LocalTerra.columbus-5/config/exported.json ./LocalTerra.columbus-5/config/genesis.json.old ./LocalTerra.columbus-5/config/pubkey-replace.json
	@git submodule update --init --force
	@echo
	@echo all clean.

clean_columbus-4: kill_columbus-4
	@echo cleaning up columbus-4... 
	-@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-4/docker-compose.yml rm -f
	-@rm ./LocalTerra.columbus-4/config/wasm.toml

clean_columbus-5: kill_columbus-5
	@echo cleaning up columbus-5... 
	-@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-5/docker-compose.yml rm -f

init_submodules:
	@git submodule update --init

get_columbus-4: init_submodules
	@echo checkout tags...
	@cd LocalTerra.columbus-4; git checkout tags/$(LOCALTERRA_OLDER)

get_columbus-5: init_submodules
	@cd LocalTerra.columbus-5; git checkout $(LOCALTERRA_NEWER)

run_columbus-4:
	@echo run LocalTerra for columbus-4...
	@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-4/docker-compose.yml pull
	@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-4/docker-compose.yml up -d
	@echo 
	@echo columbus-4 is running now.

run_columbus-5:
	@echo run LocalTerra for columbus-5...
	@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-5/docker-compose.yml pull
	@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-5/docker-compose.yml up -d
	@echo 
	@echo columbus-5 is running now.

kill_columbus-4:
	@echo kill containers for columbus-4...
	-@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-4/docker-compose.yml kill

kill_columbus-5:
	@echo kill containers for columbus-5...
	-@$(DOCKER_COMPOSE) -f ./LocalTerra.columbus-5/docker-compose.yml kill


# to migrate

export_columbus-4: kill_columbus-4
	@echo export columbus-4 state...
	-@mkdir ./temp
	@$(DOCKER) commit localterracolumbus-4_terrad_1 columbus-4.$(LOCALTERRA_OLDER)
	@$(DOCKER) run --rm -v "$(PWD)/LocalTerra.columbus-4/config":/root/.terrad/config columbus-4.$(LOCALTERRA_OLDER) terrad export --home /root/.terrad  > ./temp/exported.json

build_migrator:
	@$(DOCKER) build -t migrator:$(LOCALTERRA_NEWER) ./LocalTerra.columbus-5/terracore

migrate_to_columbus-5: build_migrator
	@echo migrate from columbus-4 to columbus-5...
	-@mkdir ./temp
	@cp -fp temp/exported.json ./LocalTerra.columbus-5/config/exported.json
	@cp -fp config/pubkey-replace.json ./LocalTerra.columbus-5/config/
	@$(DOCKER) run --rm --name state-migrator -v "$(PWD)/LocalTerra.columbus-5/config":/root/.terra/config migrator:$(LOCALTERRA_NEWER) \
		terrad migrate /root/.terra/config/exported.json \
		--chain-id localterra --replacement-cons-keys /root/.terra/config/pubkey-replace.json \
		--initial-height 1 --genesis-time "2021-07-12T01:00:00Z" > ./temp/migrated.json
	-@mv ./LocalTerra.columbus-5/config/genesis.json ./LocalTerra.columbus-5/config/genesis.json.old
	@mv ./temp/migrated.json ./LocalTerra.columbus-5/config/genesis.json
	@echo 
	@echo state of columbus-4 have migrated to genesis.json for columbus-5 


# transactions

deploy_contract:
	-@mkdir ./log
	@echo install npm packages to run terra.js
	@cd scripts/columbus-4; npm i
	@echo submit storeCode and instantiateContract
	@cd scripts/columbus-4; npm run test 

migrate_code:
	@echo install npm packages to run terra.js
	@cd scripts/columbus-5; npm i
	@echo submit migrateCode tx
	@cd scripts/columbus-5; npm run test

columbus-4: init_columbus-4

columbus-5: export_columbus-4 get_columbus-5 migrate_to_columbus-5 run_columbus-5 

