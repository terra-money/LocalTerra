#!/usr/bin/make -f


ifeq ($(LOCALTERRA_OLDER),)
  LOCALTERRA_OLDER := v0.4.1
endif

ifeq ($(LOCALTERRA_NEWER),)
  LOCALTERRA_NEWER := main
endif

DOCKER := $(shell which docker)


# to prepare

prepare: get_columbus get_bombay
	yarn upgrade --cwd scripts/columbus
	yarn upgrade --cwd scripts/bombay

init_columbus: get_columbus run_columbus
init_bombay: get_bombay run_bombay

clean: clean_columbus clean_bombay
	-rm ./temp/* ./log/*
	-docker rm state-migrator
	-docker image rm migrator:$(LOCALTERRA_NEWER)
	-rm ./LocalTerra.bombay/config/exported.json ./LocalTerra.bombay/config/genesis.json.old ./LocalTerra.bombay/config/pubkey-replace.json
	git submodule update --init --force

clean_columbus: kill_columbus
	-docker-compose -f ./LocalTerra.columbus/docker-compose.yml rm -f
clean_bombay: kill_bombay
	-docker-compose -f ./LocalTerra.bombay/docker-compose.yml rm -f

init_submodules:
	git submodule update --init

get_columbus: init_submodules
	@echo checkout tags...
	cd LocalTerra.columbus; git checkout tags/$(LOCALTERRA_OLDER)

get_bombay: init_submodules
	cd LocalTerra.bombay; git checkout $(LOCALTERRA_NEWER)

run_columbus:
	docker-compose -f ./LocalTerra.columbus/docker-compose.yml pull
	docker-compose -f ./LocalTerra.columbus/docker-compose.yml up -d
run_bombay:
	docker-compose -f ./LocalTerra.bombay/docker-compose.yml pull
	docker-compose -f ./LocalTerra.bombay/docker-compose.yml up -d

kill_columbus:
	docker-compose -f ./LocalTerra.columbus/docker-compose.yml kill
kill_bombay:
	docker-compose -f ./LocalTerra.bombay/docker-compose.yml kill


# to migrate

export_columbus: kill_columbus
	$(DOCKER) commit localterracolumbus_terrad_1 columbus.$(LOCALTERRA_OLDER)
	$(DOCKER) run -v "$(PWD)/LocalTerra.columbus/config":/root/.terrad/config columbus.$(LOCALTERRA_OLDER) terrad export --home /root/.terrad  > ./temp/exported.json

build_migrator:
	$(DOCKER) build -t migrator:$(LOCALTERRA_NEWER) ./LocalTerra.bombay/terracore

migrate_to_bombay: build_migrator
	-mkdir ./temp
	cp -fp temp/exported.json ./LocalTerra.bombay/config/exported.json
	cp -fp config/pubkey-replace.json ./LocalTerra.bombay/config/
	$(DOCKER) run --name state-migrator -v "$(PWD)/LocalTerra.bombay/config":/root/.terra/config migrator:$(LOCALTERRA_NEWER) \
		terrad migrate /root/.terra/config/exported.json \
		--chain-id localterra --replacement-cons-keys /root/.terra/config/pubkey-replace.json \
		--initial-height 1 --genesis-time "2021-07-12T01:00:00Z" > ./temp/migrated.json
	-mv ./LocalTerra.bombay/config/genesis.json ./LocalTerra.bombay/config/genesis.json.old
	mv ./temp/migrated.json ./LocalTerra.bombay/config/genesis.json


# transactions

deploy_contract:
	#cd scripts/columbus; LOCALTERRA_OLDER=$(LOCALTERRA_OLDER) yarn test
	-mkdir ./log
	cd scripts/columbus; yarn test 

migrate_code:
	#cd scripts/bombay; LOCALTERRA_NEWER=$(LOCALTERRA_NEWER) yarn test 
	cd scripts/bombay; yarn test 

# shortcuts
sleep:
	sleep 5

columbus: init_columbus sleep deploy_contract

bombay: export_columbus get_bombay migrate_to_bombay run_bombay sleep migrate_code

