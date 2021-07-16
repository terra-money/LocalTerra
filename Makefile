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
	-rm -rf ./LocalTerra.columbus
	-rm -rf ./LocalTerra.bombay
	-docker rm state-migrator
	-docker image rm migrator:$(LOCALTERRA_NEWER)

clean_columbus: kill_columbus
	-docker-compose -f ./LocalTerra.columbus/docker-compose.yml rm -f
clean_bombay: kill_bombay
	-docker-compose -f ./LocalTerra.bombay/docker-compose.yml rm -f

init_submodules:
	git submodule init

get_columbus: init_submodules
	cd LocalTerra.columbus; git checkout $(LOCALTERRA_OLDER)

get_bombay:
	cd LocalTerra.columbus; git checkout $(LOCALTERRA_NEWER)

run_columbus:
	docker-compose -f ./LocalTerra.columbus/docker-compose.yml up -d
run_bombay:
	docker-compose -f ./LocalTerra.bombay/docker-compose.yml up -d

kill_columbus:
	docker-compose -f ./LocalTerra.columbus/docker-compose.yml kill
kill_bombay:
	docker-compose -f ./LocalTerra.bombay/docker-compose.yml kill


# to migrate

export_columbus: kill_columbus
	$(eval OLDER_LOCALTERRA_CONTAINER := $(shell echo localterra$(LOCALTERRA_OLDER)_terrad_1 | sed -e 's/\.//g'))
	$(DOCKER) commit ${OLDER_LOCALTERRA_CONTAINER} origin.$(LOCALTERRA_OLDER)
	$(DOCKER) run -v "$(PWD)/LocalTerra.columbus/config":/root/.terrad/config origin.$(LOCALTERRA_OLDER) terrad export --home /root/.terrad  > ./temp/exported.json

build_migrator:
	$(DOCKER) build -t migrator:$(LOCALTERRA_NEWER) ./LocalTerra.bombay/terracore

migrate_to_bombay: build_migrator
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
	cd scripts/columbus; LOCALTERRA_OLDER=$(LOCALTERRA_OLDER) yarn test

migrate_code:
	cd scripts/bombay; LOCALTERRA_NEWER=$(LOCALTERRA_NEWER) yarn test 


# shortcuts
sleep:
	sleep 5

columbus: prepare init_columbus sleep deploy_contract

bombay: export_columbus get_bombay migrate_to_bombay run_bombay sleep migrate_code

