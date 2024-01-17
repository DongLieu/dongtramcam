#!/bin/bash

KEY="test"
CHAINID="toddler"
KEYRING="test"
MONIKER="toddler"
KEYALGO="secp256k1"
LOGLEVEL="info"


# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }
command -v toml > /dev/null 2>&1 || { echo >&2 "toml not installed. More info: https://github.com/mrijken/toml-cli"; exit 1; }

dongtramcamd config keyring-backend $KEYRING
dongtramcamd config chain-id $CHAINID

dongtramcamd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO
dongtramcamd keys add test1 --keyring-backend $KEYRING --algo $KEYALGO
dongtramcamd keys add test2 --keyring-backend $KEYRING --algo $KEYALGO
dongtramcamd keys add test3 --keyring-backend $KEYRING --algo $KEYALGO

echo >&1 "\n"

# init chain
dongtramcamd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to udongtramcam
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json

# Set gas limit in genesis
# cat $HOME/.dongtramcam/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json

# enable rest server and swagger
toml set --toml-path $HOME/.dongtramcam/config/app.toml api.address "tcp://0.0.0.0:1350"
toml set --toml-path $HOME/.dongtramcam/config/app.toml api.swagger true
toml set --toml-path $HOME/.dongtramcam/config/app.toml api.enable true

# Allocate genesis accounts (cosmos formatted addresses)
dongtramcamd add-genesis-account $KEY 1000000000000udongtramcam --keyring-backend $KEYRING
dongtramcamd add-genesis-account test1 1000000000udongtramcam --keyring-backend $KEYRING
dongtramcamd add-genesis-account test2 1000000000udongtramcam --keyring-backend $KEYRING
dongtramcamd add-genesis-account test3 50000000udongtramcam --keyring-backend $KEYRING

# Sign genesis transaction
dongtramcamd gentx $KEY 1000000udongtramcam --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
dongtramcamd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
dongtramcamd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
dongtramcamd start --pruning=nothing --log_level $LOGLEVEL --minimum-gas-prices=0.0001udongtramcam --rpc.laddr tcp://localhost:26657