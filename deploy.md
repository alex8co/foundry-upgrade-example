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
forge script script/DeployV1.s.sol:DeployV1Script --sig "run(uint256)" $INITIAL_VALUE --rpc-url $RPC_URL --private-key $PRIVATE_KEY
cast balance $OWNER_ADDRESS --ether --rpc-url $RPC_URL
```

# upgrade to V2
## Set your environment variables
```bash
export PROXY_ADDRESS=0xEAD683c29178d41A511311c1Eb0fce8aD618c3CF
export PROXY_ADMIN_ADDRESS=0xaA19aff541ed6eBF528f919592576baB138370DC
export BOXV1_ADDRESS=0xEAD683c29178d41A511311c1Eb0fce8aD618c3CF
```

## Run the upgrade script
```bash
forge script script/UpgradeToV2.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV2_add_name" --rpc-url $RPC_URL   --private-key $PRIVATE_KEY
```

```bash
cast balance $OWNER_ADDRESS --ether --rpc-url $RPC_URL
cast call $PROXY_ADMIN_ADDRESS "owner()(address)" --rpc-url $RPC_URL
cast wallet address $PRIVATE_KEY
cast balance $PROXY_ADMIN_ADDRESS --ether --rpc-url $RPC_URL
```


# upgrade to V3

## Set your environment variables
```bash
export PROXY_ADDRESS=<your_proxy_address>
export PROXY_ADMIN_ADDRESS=<your_proxy_admin_address>
export RPC_URL=<your_rpc_url>
```

## Run the upgrade script
```bash
forge script script/UpgradeToV3.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV3_add_description" --rpc-url $RPC_URL   --private-key $PRIVATE_KEY
```