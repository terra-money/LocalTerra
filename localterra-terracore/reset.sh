terrad add-genesis-account terra1dcegyrekltswvyy0xy69ydgxn9x8x32zdtapd8 1000000000000uluna,1000usd
echo "123456789\n123456789\n123456789\n123456789\n" | terrad gentx --name test1 --amount 1000000000uluna
terrad collect-gentxs
