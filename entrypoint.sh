#!/bin/sh

# Fetch minimum gas prices from the Phoenix FCD.
MIN_GAS_PRICES=$(wget -qO- "https://phoenix-fcd.terra.dev/v1/txs/gas_prices" | awk -F'"' -vRS=',' '/uluna/{print $4$2}')

# Replace minimum-gas-price in ~/.terra/config/app.toml with Phoenix FCD response.
sed -e "s/^\(minimum-gas-prices\s*=\s*\).*$/\1\"${MIN_GAS_PRICES}\"/" -i ~/.terra/config/app.toml

exec "$@"
