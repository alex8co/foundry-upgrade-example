// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract Deploy is Script {
    function run() external returns (address, address) {
        vm.startBroadcast();

        // 1. Deploy the implementation contract (BoxV1)
        BoxV1 implementationV1 = new BoxV1();
        console.log("Implementation V1 (BoxV1) deployed at:", address(implementationV1));

        // 2. Deploy the ProxyAdmin
        ProxyAdmin proxyAdmin = new ProxyAdmin();
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));

        // 3. Deploy the proxy and initialize it
        bytes memory data = abi.encodeWithSignature("initialize()");
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(implementationV1), address(proxyAdmin), data);
        console.log("Proxy deployed at:", address(proxy));

        vm.stopBroadcast();
        return (address(proxy), address(proxyAdmin));
    }
}
