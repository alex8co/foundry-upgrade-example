# deploy V1

# upgrade to V2
## Set your environment variables first
```
export PROXY_ADDRESS=<your_proxy_address>
export PROXY_ADMIN_ADDRESS=<your_proxy_admin_address>
export RPC_URL=<your_rpc_url>
```

## Run the upgrade script
```
forge script script/UpgradeToV2.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV2" --rpc-url $RPC_URL --broadcast
```

# upgrade to V3

## Set your environment variables first
```
export PROXY_ADDRESS=<your_proxy_address>
export PROXY_ADMIN_ADDRESS=<your_proxy_admin_address>
export RPC_URL=<your_rpc_url>
```

## Run the upgrade script
```
forge script script/UpgradeToV3.s.sol --sig "run(address,address,string)" $PROXY_ADDRESS $PROXY_ADMIN_ADDRESS "BoxV3" --rpc-url $RPC_URL --broadcast
```