## WASM code migration tester

---

smart contract migration tester for Terra

Migration is needed because there are some breaking changes for wasm contract between columbus-004 and bombay-0008.

## Requirements

---

* [Docker](https://www.docker.com/) installed and configured on your system
* [`docker-compose`](https://github.com/docker/compose)
* Supported known architecture: x86_64
* node.js >= 12

## Usage

---

See preparation in Steps section first.

### Columbus

  Run columbus and deploy(store code and instantiate contract) a contract

  ```makefile
  make columbus
  ```

### Bombay

  Export columbus, run migrated bombay and do migrateCode

  ```makefile
  make bombay
  ```

---

## Steps

### 1. preparation

Set envrionment variables, get submodules for each network and get terra.js module.

```bash
# set environment variables
# LOCALTERRA_OLDER is tag name for older version of LocalTerra to test. (v0.4.1 by default)
export LOCALTERRRA_OLDER=v0.4.1 

# LOCALTERRA_NEWER is tag name for older version of LocalTerra to test. (main by default)
export LOCALTERRRA_NEWER=main

# FILENAME_WASM is the name of binary to test (send_to_burn_address.wasm by default)
# pathfile for older wasm should be contracts/$(LOCALTERRA_OLDER)/$(FILENAME_WASM)
# pathfile for newer wasm should be contracts/$(LOCALTERRA_NEWER)/$(FILENAME_WASM)
export FILENAME_WASM=send_to_burn_address.wasm 

# CODE_ID will be used when migrateCode (1 by default)
export CODE_ID=1

make preapre
```

### 2. build an older network

Run LocalTerra for older network

```bash
make run_columbus
```

### 3. deploy wasm on older network

Store code and instantiate contract.

Instantiate result will be in ./log on success so you can find code_id in there.

```bash
# place your wasm binary into ./contracts/$(LOCALTERRA_OLDER)/ before run make
make deploy_contract
# on success, see log/deployed.$(BLOCK_HEIGHT).log
```

Do something else you need for code migration test



### 4. export columbus state

Kill older network and export their state to temp/exported.json.

```bash
make export_columbus
```

### 5. migrate older state to newer

Convert exported.json to acceptable genesis.json for newer network.

```bash
make migrate_to_bombay
```

### 6. build a newer network

with migrated genesis.json.

```bash
make run_bombay
```

### 7. store new code via migrateCode

CODE_ID will be set manually. See log when deploy_contract

```bash
CODE_ID=1 make migrate_code
```

### 8. cleanup

Clean LocalTerras, temporary files and logs

```bash
make clean
```


---

## License

This software is licensed under the MIT license.

© 2020 Terraform Labs, PTE.
