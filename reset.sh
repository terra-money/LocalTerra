#!/bin/sh
rm -rf volume.terrad/data
mkdir volume.terrad/data
echo '{ "height": "0", "round": "0", "step": 0 }' > volume.terrad/data/priv_validator_state.json
