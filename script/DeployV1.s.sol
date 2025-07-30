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
        // Use the msg.sender from the `--private-key` as the owner
        address owner = msg.sender;

        // The vm.startBroadcast() cheatcode makes all subsequent calls come
        // from the `owner` address.
        vm.startBroadcast(owner);

        // 1. Deploy the ProxyAdmin: This contract will be the owner of the proxy.
        ProxyAdmin proxyAdmin = new ProxyAdmin(owner);
        proxyAdminAddress = address(proxyAdmin);
        console.log("ProxyAdmin deployed at:", proxyAdminAddress);

        // 2. Deploy the implementation contract (BoxV1)
        BoxV1 implementationV1 = new BoxV1();
        console.log("Implementation V1 (BoxV1) deployed at:", address(implementationV1));

        // 3. Prepare the initialization call.
        // We need to tell the proxy to call `initialize(42)` on BoxV1.
        // This is done by encoding the function selector and its arguments.
        bytes memory data = abi.encodeWithSelector(BoxV1.initialize.selector, _initialValue, owner);

        // 4. Deploy the TransparentUpgradeableProxy.
        // It takes the implementation address, the admin address, and the initialization data.
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementationV1),
            proxyAdminAddress,
            data
        );
        proxyAddress = address(proxy);
        console.log("Proxy for BoxV1 deployed at:", proxyAddress);

        vm.stopBroadcast();
    }
}