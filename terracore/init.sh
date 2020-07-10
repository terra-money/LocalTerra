terrad init localterra --chain-id=localterra
terracli keys add test1 --recover < $HOME/mnemonic.txt --keyring-backend test
terrad add-genesis-account terra1dcegyrekltswvyy0xy69ydgxn9x8x32zdtapd8 1000000000000uluna,1000usd
terrad gentx --name test1 --amount 1000000000uluna --keyring-backend test
terrad collect-gentxs
