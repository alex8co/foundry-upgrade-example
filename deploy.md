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
export PROXY_ADDRESS=0xe3765f851977Ed7B377D0234e9275845fc960775
export PROXY_ADMIN_ADDRESS=0xFb0a39aE8c44a0E83a1445d4d272294345fA2207
export BOXV1_ADDRESS=0x4300536b909FbA47e042fCa31B97c09F64643110
```
```bash
cast call $PROXY_ADDRESS "retrieve()" --rpc-url $RPC_URL 
cast send $PROXY_ADDRESS "store(uint256)"  0x112  --rpc-url $RPC_URL --private-key $PRIVATE_KEY
cast call $PROXY_ADDRESS "retrieve()" --rpc-url $RPC_URL 
```

# upgrade to V2
## Set your environment variables

## Run the upgrade script
```bash
forge script script/UpgradeToV2.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV2_add_name" --rpc-url $RPC_URL
--private-key $PRIVATE_KEY  --broadcast
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

