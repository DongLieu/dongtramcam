#!/bin/bash
rm -rf $HOME/.dongtramcam/
killall dongtramcamd || true

# start a testnet
dongtramcamd testnet --v 4 --keyring-backend=test

# change staking denom to udongtramcam
cat $HOME/.dongtramcam/node0/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="udongtramcam"' > $HOME/.dongtramcam/node0/config/tmp_genesis.json && mv $HOME/.dongtramcam/node0/config/tmp_genesis.json $HOME/.dongtramcam/node0/config/genesis.json

# update crisis variable to udongtramcam
cat $HOME/.dongtramcam/node0/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="udongtramcam"' > $HOME/.dongtramcam/node0/config/tmp_genesis.json && mv $HOME/.dongtramcam/node0/config/tmp_genesis.json $HOME/.dongtramcam/node0/config/genesis.json

# udpate gov genesis
cat $HOME/.dongtramcam/node0/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="udongtramcam"' > $HOME/.dongtramcam/node0/config/tmp_genesis.json && mv $HOME/.dongtramcam/node0/config/tmp_genesis.json $HOME/.dongtramcam/node0/config/genesis.json

# update mint genesis
cat $HOME/.dongtramcam/node0/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="udongtramcam"' > $HOME/.dongtramcam/node0/config/tmp_genesis.json && mv $HOME/.dongtramcam/node0/config/tmp_genesis.json $HOME/.dongtramcam/node0/config/genesis.json

# change app.toml values

# validator 1
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.dongtramcam/node0/config/app.toml

# validator2
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1316|g' $HOME/.dongtramcam/node1/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9088|g' $HOME/.dongtramcam/node1/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9089|g' $HOME/.dongtramcam/node1/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.dongtramcam/node1/config/app.toml

# validator3
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1315|g' $HOME/.dongtramcam/node2/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9086|g' $HOME/.dongtramcam/node2/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9087|g' $HOME/.dongtramcam/node2/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.dongtramcam/node2/config/app.toml

# validator4
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1314|g' $HOME/.dongtramcam/node3/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9084|g' $HOME/.dongtramcam/node3/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9085|g' $HOME/.dongtramcam/node3/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' $HOME/.dongtramcam/node3/config/app.toml
# change config.toml values

# validator1
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.dongtramcam/node0/config/config.toml
# validator2
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26655|g' $HOME/.dongtramcam/node1/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.dongtramcam/node1/config/config.toml
# validator3
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26652|g' $HOME/.dongtramcam/node2/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.dongtramcam/node2/config/config.toml
#validator4
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26649|g' $HOME/.dongtramcam/node3/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' $HOME/.dongtramcam/node3/config/config.toml

# copy validator1 genesis file to validator2-3
cp $HOME/.dongtramcam/node0/config/genesis.json $HOME/.dongtramcam/node1/config/genesis.json
cp $HOME/.dongtramcam/node0/config/genesis.json $HOME/.dongtramcam/node2/config/genesis.json
cp $HOME/.dongtramcam/node0/config/genesis.json $HOME/.dongtramcam/node3/config/genesis.json

echo "start all three validators"
screen -S validator1 -d -m dongtramcamd start --home=$HOME/.dongtramcam/node0
screen -S validator2 -d -m dongtramcamd start --home=$HOME/.dongtramcam/node1
screen -S validator3 -d -m dongtramcamd start --home=$HOME/.dongtramcam/node2
screen -S validator4 -d -m dongtramcamd start --home=$HOME/.dongtramcam/node3

echo $(dongtramcamd keys show node0 -a --keyring-backend=test --home=$HOME/.dongtramcam/node0)
echo $(dongtramcamd keys show node1 -a --keyring-backend=test --home=$HOME/.dongtramcam/node1)
echo $(dongtramcamd keys show node2 -a --keyring-backend=test --home=$HOME/.dongtramcam/node2)
echo $(dongtramcamd keys show node3 -a --keyring-backend=test --home=$HOME/.dongtramcam/node3)