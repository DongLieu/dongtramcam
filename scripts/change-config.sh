#!/bin/bash

# change staking denom to udongtramcam
cat build/node0/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="udongtramcam"' > build/node0/config/tmp_genesis.json && mv build/node0/config/tmp_genesis.json build/node0/config/genesis.json

# update crisis variable to udongtramcam
cat build/node0/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="udongtramcam"' > build/node0/config/tmp_genesis.json && mv build/node0/config/tmp_genesis.json build/node0/config/genesis.json

# udpate gov genesis
cat build/node0/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="udongtramcam"' > build/node0/config/tmp_genesis.json && mv build/node0/config/tmp_genesis.json build/node0/config/genesis.json

# update mint genesis
cat build/node0/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="udongtramcam"' > build/node0/config/tmp_genesis.json && mv build/node0/config/tmp_genesis.json build/node0/config/genesis.json

# change app.toml values

# validator 1
sed -i -E 's|swagger = false|swagger = true|g' build/node0/config/app.toml

# validator2
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1318|g' build/node1/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9088|g' build/node1/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9089|g' build/node1/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' build/node1/config/app.toml

# validator3
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1319|g' build/node2/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9086|g' build/node2/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9087|g' build/node2/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' build/node2/config/app.toml

# validator4
sed -i -E 's|tcp://0.0.0.0:1317|tcp://0.0.0.0:1320|g' build/node3/config/app.toml
sed -i -E 's|0.0.0.0:9090|0.0.0.0:9084|g' build/node3/config/app.toml
sed -i -E 's|0.0.0.0:9091|0.0.0.0:9085|g' build/node3/config/app.toml
sed -i -E 's|swagger = false|swagger = true|g' build/node3/config/app.toml
# change config.toml values

# validator1
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' build/node0/config/config.toml
# validator2
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26661|g' build/node1/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' build/node1/config/config.toml
# validator3
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26664|g' build/node2/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' build/node2/config/config.toml
#validator4
sed -i -E 's|tcp://127.0.0.1:26658|tcp://127.0.0.1:26667|g' build/node3/config/config.toml
sed -i -E 's|allow_duplicate_ip = false|allow_duplicate_ip = true|g' build/node3/config/config.toml

# copy validator1 genesis file to validator2-3
cp build/node0/config/genesis.json build/node1/config/genesis.json
cp build/node0/config/genesis.json build/node2/config/genesis.json
cp build/node0/config/genesis.json build/node3/config/genesis.json
