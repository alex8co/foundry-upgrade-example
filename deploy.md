# deploy V1
## Start testnet
```bash
anvil --fork-url https://reth-ethereum.ithaca.xyz/rpc
```

## Set your environment variables first
```bash
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export INITIAL_VALUE=100
export OWNER_ADDRESS=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
export RPC_URL=http://127.0.0.1:8545
cast balance $OWNER_ADDRESS --ether --rpc-url $RPC_URL
```


## Run the deploy script
```bash
forge script script/DeployV1.s.sol:DeployV1Script --sig "run(uint256)" $INITIAL_VALUE --rpc-url $RPC_URL --private-key $PRIVATE_KEY  --broadcast
cast balance $OWNER_ADDRESS --ether --rpc-url $RPC_URL 
```

```bash
export PROXY_ADDRESS=0xdb88CFC18875e3eD6797de31dfAae31F942231F2
export PROXY_ADMIN_ADDRESS=0xFEE2d383Ee292283eC43bdf0fa360296BE1e1149
export BOXV1_ADDRESS=0xf0014CBe67b3aB638bdaA2e2Cb1B531935829E50
```
```bash
cast call $PROXY_ADDRESS "retrieve()" --rpc-url $RPC_URL 
cast send $PROXY_ADDRESS "store(uint256)"  0x112  --rpc-url $RPC_URL --private-key $PRIVATE_KEY
cast call $PROXY_ADDRESS "retrieve()" --rpc-url $RPC_URL 
```

```bash
cast call $PROXY_ADDRESS "owner()(address)" --rpc-url $RPC_URL
cast call $PROXY_ADMIN_ADDRESS "owner()(address)" --rpc-url $RPC_URL
cast call $BOXV1_ADDRESS "owner()(address)" --rpc-url $RPC_URL
```


# upgrade to V2
## Set your environment variables

## Run the upgrade script
```bash
forge script script/UpgradeToV2.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV2_add_name" --rpc-url $RPC_URL --private-key $PRIVATE_KEY  --broadcast
```
```bash
export BOXV2_ADDRESS=0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141
```

```bash
cast send $PROXY_ADDRESS "setName(string)" "BoxV2"   --rpc-url $RPC_URL   --private-key $PRIVATE_KEY
cast send $BOXV2_ADDRESS "setName(string)" "BoxV2"   --rpc-url $RPC_URL   --private-key $PRIVATE_KEY
cast call $PROXY_ADDRESS "name()" --rpc-url $RPC_URL
```

# upgrade to V3

## Set your environment variables

## Run the upgrade script
```bash
forge script script/UpgradeToV3.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV3_add_description" --rpc-url $RPC_URL
--private-key $PRIVATE_KEY  --broadcast
```

# other

```bash
cast balance $OWNER_ADDRESS --ether --rpc-url $RPC_URL
cast call $PROXY_ADMIN_ADDRESS "owner()(address)" --rpc-url $RPC_URL
cast wallet address $PRIVATE_KEY
cast balance $PROXY_ADMIN_ADDRESS --ether --rpc-url $RPC_URL
```

