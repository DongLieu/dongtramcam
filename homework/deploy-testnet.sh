#!/bin/bash
rm -rf $HOME/.dongtramcam/
killall screen

KEY="test"
KEYRING="test"
CHAINID="toddler"
MONIKER="localtestnet"
KEYALGO="secp256k1"
LOGLEVEL="info"

BALANCE_1="1000000000udongtramcam"
BALANCE_2="50000000udongtramcam"
VALIDATOR_1="dongtramcam1"
VALIDATOR_2="dongtramcam2"
VALIDATOR_3="dongtramcam3"

# config chain
dongtramcamd config keyring-backend $KEYRING
dongtramcamd config chain-id $CHAINID

# determine if user wants to recorver or create new
dongtramcamd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

# Initialize chain
dongtramcamd init $MONIKER --chain-id $CHAINID

# change staking denom to udongtramcam
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json
cat $HOME/.dongtramcam/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="udongtramcam"' > $HOME/.dongtramcam/config/tmp_genesis.json && mv $HOME/.dongtramcam/config/tmp_genesis.json $HOME/.dongtramcam/config/genesis.json

# api listen address: tcp://0.0.0.0:1350
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1350|g' $HOME/.dongtramcam/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.dongtramcam/config/app.toml
sed -i -E 's|enable = false|enable = true|g' $HOME/.dongtramcam/config/app.toml

# Allocate genesis accounts (cosmos formatted addresses)
dongtramcamd add-genesis-account $KEY 1000000000000000udongtramcam --keyring-backend $KEYRING

# Sign genesis transaction
dongtramcamd gentx $KEY 1000000udongtramcam --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
dongtramcamd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
dongtramcamd validate-genesis

dongtramcamd keys add $VALIDATOR_1
dongtramcamd keys add $VALIDATOR_2
dongtramcamd keys add $VALIDATOR_3

dongtramcamd keys list

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
#rpc listen address: tcp://0.0.0.0:26657
screen -S validator1 -d -m dongtramcamd start --pruning=nothing \
    --log_level $LOGLEVEL \
    --minimum-gas-prices=0.0001udongtramcam \
    --p2p.laddr tcp://0.0.0.0:1700 \
    --rpc.laddr tcp://0.0.0.0:26657 \
    --grpc.address 0.0.0.0:1701 \
    --grpc-web.address 0.0.0.0:1702

sleep 10

#get addresses of main wallet and accounts
KEY_ADDRESS=$(dongtramcamd keys show $KEY -a)
VALIDATOR1_ADDRESS=$(dongtramcamd keys show $VALIDATOR_1 -a)
VALIDATOR2_ADDRESS=$(dongtramcamd keys show $VALIDATOR_2 -a)
VALIDATOR3_ADDRESS=$(dongtramcamd keys show $VALIDATOR_3 -a)

echo $KEY_ADDRESS;
echo $VALIDATOR1_ADDRESS;
echo $VALIDATOR2_ADDRESS;
echo $VALIDATOR3_ADDRESS;

dongtramcamd q bank balances $KEY_ADDRESS --node tcp://0.0.0.0:26657
dongtramcamd q bank balances $VALIDATOR1_ADDRESS --node tcp://0.0.0.0:26657
dongtramcamd q bank balances $VALIDATOR2_ADDRESS --node tcp://0.0.0.0:26657
dongtramcamd q bank balances $VALIDATOR3_ADDRESS --node tcp://0.0.0.0:26657

#Transmit tokens
dongtramcamd tx bank send $KEY_ADDRESS $VALIDATOR1_ADDRESS $BALANCE_1 --chain-id $CHAINID --node tcp://0.0.0.0:26657 --gas auto --fees 10udongtramcam -y --keyring-backend=$KEYRING
sleep 5

dongtramcamd tx bank send $KEY_ADDRESS $VALIDATOR2_ADDRESS $BALANCE_1 --chain-id $CHAINID --node tcp://0.0.0.0:26657 --gas auto --fees 10udongtramcam -y --keyring-backend=$KEYRING
sleep 5

dongtramcamd tx bank send $KEY_ADDRESS $VALIDATOR3_ADDRESS $BALANCE_2 --chain-id $CHAINID --node tcp://0.0.0.0:26657 --gas auto --fees 10udongtramcam -y --keyring-backend=$KEYRING
sleep 5

dongtramcamd q bank balances $VALIDATOR1_ADDRESS --node tcp://0.0.0.0:26657
dongtramcamd q bank balances $VALIDATOR2_ADDRESS --node tcp://0.0.0.0:26657
dongtramcamd q bank balances $VALIDATOR3_ADDRESS --node tcp://0.0.0.0:26657

# cungx ddow