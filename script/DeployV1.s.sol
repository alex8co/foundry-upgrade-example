// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployV1Script is Script {
    function run(uint256 _initialValue)
        external
        returns (address proxyAddress, address proxyAdminAddress)
    {
        console.log("msg.sender:", msg.sender);
        console.log("_initialValue:", _initialValue);
        // Use the msg.sender from the `--private-key` as the owner
        //address owner = msg.sender;

        // It's best practice to load your private key and other secrets
        // from environment variables rather than hardcoding them in the script.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");        
        // If you want to set a different owner from the deployer, you can use:
        // address owner = vm.envAddress("OWNER_ADDRESS");
        address owner = vm.addr(deployerPrivateKey);
        console.log("owner:", owner);

        // The vm.startBroadcast() cheatcode makes all subsequent calls come
        // from the `owner` address.
        vm.startBroadcast(owner);

        // 1. Deploy the ProxyAdmin: This contract will be the owner of the proxy.
        ProxyAdmin proxyAdmin = new ProxyAdmin(owner);
        proxyAdminAddress = address(proxyAdmin);
        console.log("proxyAdminAddress:", proxyAdminAddress);

        // 2. Deploy the implementation contract (BoxV1)
        BoxV1 implementationV1 = new BoxV1();
        console.log("implementationV1:", address(implementationV1));

        // 3. Prepare the initialization call data.
        // We use abi.encodeCall which is type-safe and preferred over abi.encodeWithSelector.
        // This will be executed by the proxy in its constructor via delegatecall.
        bytes memory data = abi.encodeCall(BoxV1.initialize, (_initialValue, owner));

        //bytes memory data; // data is empty

        // 4. Deploy the TransparentUpgradeableProxy, passing in the initialization data.
        // This combines deployment and initialization into a single transaction.
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementationV1),
            proxyAdminAddress,
            data
        );

        // 5. Initialize the proxy in a separate, subsequent call.
        // This ensures msg.sender in the implementation's context is the 'owner' EOA.
        //BoxV1(proxyAddress).initialize(_initialValue, owner);
        //console.log("Proxy initialized correctly. Owner is:", owner);

        proxyAddress = address(proxy);
        console.log("Proxy for BoxV1 deployed at:", proxyAddress);
        console.log("Proxy initialized. Business logic owner is:", BoxV1(proxyAddress).owner());

        vm.stopBroadcast();
    }
}