## WASM code migration tester

---

smart contract migration tester for Terra via LocaTerra

Migration is needed because there are some breaking changes for wasm contract between columbus-004 and bombay-0009.

## Requirements

---

* [Docker](https://www.docker.com/) installed and configured on your system
* [`docker-compose`](https://github.com/docker/compose)
* Supported known architecture: x86_64
* node.js >= 14

## Usage

---

### Columbus

Run columbus and deploy(store code and instantiate contract) a contract.

It deploys send_to_burn_address.wasm for example.

  ```makefile
  make columbus
  ```

### Deploy contract on columbus

```bash
# place your wasm binary and its initMsg json file into ./contracts/columbus/ before run make
# set FILENAME_WASM as name of the binary
# set FILENAME_INITMSG as initMsg for the code ($(FILENAME_WASM.init.json) by default)
FILENAME_WASM=send_to_burn_address.wasm  FILENAME_INITMSG=s2ba.json make deploy_contract
# on success, see log/deployed.$(BLOCK_HEIGHT).log
```

### Bombay

Export columbus, run migrated bombay and do migrateCode

It migrates code for send_to_burn_address.wasm for example.

  ```makefile
  make bombay
  ```

### Migrate code on bombay

```bash
# place your wasm binary into ./contracts/bombay/ before run make
# set FILENAME_WASM as name of the binary
# set CODE_ID to use
FILENAME_WASM=send_to_burn_address.wasm CODE_ID=1 make migrate_code
```

### Cleanup

Clean LocalTerras, temporary files and logs

```bash
make clean
```

---

## License

This software is licensed under the MIT license.

© 2020 Terraform Labs, PTE.
