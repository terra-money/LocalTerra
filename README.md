<p>&nbsp;</p>
<p align="center">
<img src="https://raw.githubusercontent.com/terra-money/LocalTerra/master/img/localterra_logo_with_name.svg" width=500>
</p>

<p align="center">
An instant, zero-config Terra blockchain and ecosystem.
</p>

<br/>

## What is LocalTerra?

LocalTerra is a complete Terra testnet and ecosystem containerized with Docker and orchestrated with a simple `docker-compose` file. It simplifies the way smart-contract developers test their contracts in a sandbox before they deploy them on a testnet or mainnet.

LocalTerra comes preconfigured with opinionated, sensible defaults for standard testing environments. If other projects mention testing on LocalTerra, they are referring to the settings defined in this repo.

LocalTerra has the following advantages over a public testnet:

- Easily modifiable world states
- Quick to reset for rapid iterations
- Simple simulations of different scenarios
- Controllable validator behavior

## Prerequisites

- [Docker](https://www.docker.com/)
- [`docker-compose`](https://github.com/docker/compose)
- Supported known architecture: x86_64
- 16+ GB of RAM is recommended (for 8+ GB, [Bombay testnet](https://docs.terra.money/docs/develop/dapp/quick-start/using-terrain-testnet.html) is recommended)

## Install LocalTerra

1. Run the following commands::

```sh
$ git clone --depth 1 https://www.github.com/terra-money/LocalTerra
$ cd LocalTerra
```

2. Make sure your Docker daemon is running in the background and [`docker-compose`](https://github.com/docker/compose) is installed.

## Start, stop, and reset LocalTerra

- Start LocalTerra:

```sh
$ docker-compose up
```

Your environment now contains:

- [terrad](http://github.com/terra-money/core) RPC node running on `tcp://localhost:26657`
- LCD running on http://localhost:1317
- [FCD](http://www.github.com/terra-money/fcd) running on http://localhost:3060
- An oracle feeder feeding live prices from mainnet, trailing by one vote period



Stop LocalTerra:

```sh
$ docker-compose stop
```

Reset the world state:

```sh
$ docker-compose rm
```

## Integrations

You can integrate LocalTerra in Terra Station, `terrad`, and the Terra JavaScript and Python SDKs.

### Terra Station

Terra Station has built-in support for LocalTerra so that you can quickly and easily interact with it. Open Station, and switch to the `Localterra` network, as shown in the following image

![station_localterra](./img/station-localterra.png)

### terrad

**Important:** 'terracli' has been deprecated, and all of its functionalities are merged into 'terrad'.

1. Ensure the same version of `terrad` and LocalTerra are installed.

2. Use `terrad` to talk to your LocalTerra `terrad` node:

```sh
$ terrad status
```

This command automatically works because `terrad` connects to `localhost:26657` by default.

The following command is the explicit form:
```sh
$ terrad status --node=tcp://localhost:26657
```

3. Run any of the `terrad` commands against your LocalTerra network, as shown in the following example:

```sh
$ terrad query account terra1dcegyrekltswvyy0xy69ydgxn9x8x32zdtapd8
```

### Terra SDK for Python

Connect to the chain through LocalTerra's LCD server:

```python
from terra_sdk.client.lcd import LCDClient
terra = LCDClient("localterra", "http://localhost:1317")
```

### Terra SDK for JavaScript

Connect to the chain through LocalTerra's LCD server:

```ts
import { LCDClient } from "@terra-money/terra.js";

const terra = new LCDClient({
  URL: "http://localhost:1317",
  chainID: "localterra",
});
```

## Configure LocalTerra

The majority of LocalTerra is implemented through a `docker-compose.yml` file, making it easily customizable. You can use LocalTerra as a starting template point for setting up your own local Terra testnet with Docker containers.

Out of the box, LocalTerra comes preconfigured with opinionated settings such as:

- ports defined for RPC (26657), LCD (1317) and FCD (3060)
- standard [accounts](#accounts)

### Modifying node configuration

You can modify the node configuration of your validator in the `config/config.toml` and `config/app.toml` files.

#### Pro tip: Speed Up Block Time

LocalTerra is often used alongside a script written with the Terra.js SDK or Terra Python SDK as a convenient way to do integration tests. You can greatly improve the experience by speeding up the block time.

To increase block time, edit the `[consensus]` parameters in the `config/config.toml` file, and specify your own values.

The following example configures all timeouts to `200ms`:

```diff
##### consensus configuration options #####
[consensus]

wal_file = "data/cs.wal/wal"
- timeout_propose = "3s"
- timeout_propose_delta = "500ms"
- timeout_prevote = "1s"
- timeout_prevote_delta = "500ms"
- timeout_precommit_delta = "500ms"
- timeout_commit = "5s"
+ timeout_propose = "200ms"
+ timeout_propose_delta = "200ms"
+ timeout_prevote = "200ms"
+ timeout_prevote_delta = "200ms"
+ timeout_precommit_delta = "200ms"
+ timeout_commit = "200ms"
```

Additionally, you can use the following single line to configure timeouts:

```sh
sed -E -i '/timeout_(propose|prevote|precommit|commit)/s/[0-9]+m?s/200ms/' config/config.toml
```

### Modifying genesis

You can change the `genesis.json` file by altering `config/genesis.json`. To load your changes, restart your LocalTerra.

## Accounts

LocalTerra is pre-configured with one validator and 10 accounts with LUNA balances.

| Account   | Address                                                                                                  | Mnemonic                                                                                                                                                                   |
| --------- | -------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| validator | `osmo1l0jjmvdtj4c3f8cxzzgfhq0zhdzf2x8cgpg056`<br/>`terravaloper1dcegyrekltswvyy0xy69ydgxn9x8x32zdy3ua5` | `artefact coral banana cereal split tower produce topple grow tennis juice fiber health easy song vessel uncover online cycle team struggle pattern spider tomorrow`                    |
| test1     | `osmo13wywdhs4pu605ra7f85aczcnmfhdu4xfrphlyp`                                                           | `salad lecture coach machine enough suffer cost nut gaze clever dismiss castle sustain armed display scheme forget gasp mutual alarm miracle online tomato nature`                       |
| test2     | `osmo13vzhfxds5sflq2hsq77z3clztkdxs30mwza78s`                                                           | `multiply panel hole remind flush chapter scan true one fancy cable combine venture wagon nose fatal there toast middle prison lumber tail empower current`              |
| test3     | `osmo19fzuy7e8cy8y4v9dv6gv0xtpdpqt530sf8ctn9`                                                           | `caught dad suit staff come pause trigger bleak economy ostrich food crawl taxi wrong day damage alpha deer humble fault debate they excite scrub`        |
| test4     | `osmo12jlcxnyh0gxjtvy4cdxlwqggw39w5dhg7wq8gh`                                                           | `flavor receive field puppy mesh tired tone long venture bright truck detail goose they fan slush cram fix gold hire midnight cannon kiwi quit` |
| test5     | `osmo1gp5yl0x8dcj42xmx7hyjp7j5fwe788ht4keanc`                                                           | `require lemon mechanic forward team maid kiss escape combine wrist resource jealous spring police couple design fork era lunar crunch resist differ size lounge`        |
| test6     | `osmo1hrt9t9wc7q6htgq3xhss4g9txxn9mchgd5jf0c`                                                           | `churn long tragic robust under surprise eyebrow whale guilt aerobic bronze again tank cash runway lucky resemble tobacco idea turn ice express churn acoustic`                  |
| test7     | `osmo1axxc8sswmvwd5q3hgq6upz9dejj8qadsgw5g53`                                                           | `miss middle hover receive weather roof swap lava luxury cloud focus stadium wage hover all purity omit flush message lend fiscal choose rug simple`                       |
| test8     | `osmo1hguhwtag9tfsva0n2ejugkhm48txu20eql882z`                                                           | `april current put adjust point move moment soap hood sun flavor hurdle venue mushroom acquire squeeze win coffee draft urge path roast flame close`                 |
| test9     | `osmo1g44fj3swmf3muzh8rd72ffr7pqld8jasu2fmc7`                                                           | `average walnut harbor fan arrive culture area night quote wrong magnet depend scene merit blast result paddle original version prefer ice ecology across trigger`       |
| test10    | `osmo1etkjkyrknvue3w6mlv76c6dhm3e00q5xvz5p4c`                                                           | `control print cruise room rocket excuse lawsuit sniff awake valley achieve cement casino arm produce rubber panda online van loyal myth chaos enact aspect`     |
