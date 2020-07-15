<p>&nbsp;</p>
<p align="center">
<img src="https://raw.githubusercontent.com/terra-project/LocalTerra/master/img/localterra_logo_with_name.svg" width=500>
</p>

<p align="center">
Instant, zero-config, Terra blockchain and ecosystem.
</p>

<br/>

## What is LocalTerra?

LocalTerra is a complete Terra testnet and ecosystem containerized with Docker and orchestrated with a simple `docker-compose` file, designed to make it easy for smart contract developers to test out their contracts on a sandboxed environment before moving to a live testnet or mainnet.

The advantages of LocalTerra over a public testnet are that:

- world state is easily modifiable
- quick to reset for quick iterations
- easy to simulate different scenarios
- validator behavior is controllable

## Requirements

- Docker installed and configured on your system
- `docker-compose`

## Usage

```sh
git clone https://www.github.com/terra-project/LocalTerra
cd LocalTerra
```

Make sure your Docker is running in the background and `docker-compose` is installed. Then start LocalTerra:

```sh
docker-compose up
```

You should now have an environment with the following:

- [terrad](http://github.com/terra-project/core) RPC node running on `tcp://localhost:26657`
- LCD running on http://localhost:1317
- [FCD](http://www.github.com/terra-project/fcd) running on http://localhost:3060

If you need to turn off LocalTerra:

```sh
docker-compose down
```

To reset the world state, issue the following:

```sh
docker-compose rm
```

## Using Station with LocalTerra

Terra Station has built-in support for LocalTerra, which enables you to interact with your LocalTerra. Open up station and switch to the `Localterra` network:

![station_localterra](./img/station-localterra.png)

## Mnemonics

LocalTerra comes with 10 accounts with LUNA balances.

| Account   | Address                                        | Mnemonic                                                                                                                                                                   |
| --------- | ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| validator | `terra1dcegyrekltswvyy0xy69ydgxn9x8x32zdtapd8` | `satisfy adjust timber high purchase tuition stool faith fine install that you unaware feed domain license impose boss human eager hat rent enjoy dawn`                    |
| test1     | `terra1x46rqay4d3cssq8gxxvqz8xt6nwlz4td20k38v` | `notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius`                       |
| test2     | `terra17lmam6zguazs5q5u6z5mmx76uj63gldnse2pdp` | `quality vacuum heart guard buzz spike sight swarm shove special gym robust assume sudden deposit grid alcohol choice devote leader tilt noodle tide penalty`              |
| test3     | `terra1757tkx08n0cqrw7p86ny9lnxsqeth0wgp0em95` | `symbol force gallery make bulk round subway violin worry mixture penalty kingdom boring survey tool fringe patrol sausage hard admit remember broken alien absorb`        |
| test4     | `terra199vw7724lzkwz6lf2hsx04lrxfkz09tg8dlp6r` | `bounce success option birth apple portion aunt rural episode solution hockey pencil lend session cause hedgehog slender journey system canvas decorate razor catch empty` |
| test5     | `terra18wlvftxzj6zt0xugy2lr9nxzu402690ltaf4ss` | `second render cat sing soup reward cluster island bench diet lumber grocery repeat balcony perfect diesel stumble piano distance caught occur example ozone loyal`        |
| test6     | `terra1e8ryd9ezefuucd4mje33zdms9m2s90m57878v9` | `spatial forest elevator battle also spoon fun skirt flight initial nasty transfer glory palm drama gossip remove fan joke shove label dune debate quick`                  |
| test7     | `terra17tv2hvwpg0ukqgd2y5ct2w54fyan7z0zxrm2f9` | `noble width taxi input there patrol clown public spell aunt wish punch moment will misery eight excess arena pen turtle minimum grain vague inmate`                       |
| test8     | `terra1lkccuqgj6sjwjn8gsa9xlklqv4pmrqg9dx2fxc` | `cream sport mango believe inhale text fish rely elegant below earth april wall rug ritual blossom cherry detail length blind digital proof identify ride`                 |
| test9     | `terra1333veey879eeqcff8j3gfcgwt8cfrg9mq20v6f` | `index light average senior silent limit usual local involve delay update rack cause inmate wall render magnet common feature laundry exact casual resource hundred`       |
| test10    | `terra1fmcjjt6yc9wqup2r06urnrd928jhrde6gcld6n` | `prefer forget visit mistake mixture feel eyebrow autumn shop pair address airport diesel street pass vague innocent poem method awful require hurry unhappy shoulder`     |

## License

This software is licensed under the MIT license.

© 2020 Terraform Labs, PTE.

<hr/>

<p>&nbsp;</p>
<p align="center">
    <a href="https://terra.money/"><img src="http://terra.money/logos/terra_logo.svg" align="center" width=200/></a>
</p>
<div align="center">
  <sub><em>Powering the innovation of money.</em></sub>
</div>
