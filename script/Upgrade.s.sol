// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract UpgradeScript is Script {
        address public proxyAddress;
    address public proxyAdminAddress;

    function run() external {
        (proxyAddress, proxyAdminAddress) = new Deploy().run();
        vm.startBroadcast();

        // 1. Deploy the new implementation contract (BoxV2)
        BoxV2 implementationV2 = new BoxV2();
        console.log("Implementation V2 (BoxV2) deployed at:", address(implementationV2));

        // 2. Get an instance of the ProxyAdmin.
        ProxyAdmin proxyAdmin = ProxyAdmin(PROXY_ADMIN_ADDRESS);

        // 3. Call `upgrade` on the ProxyAdmin to point the proxy to the new implementation.
        proxyAdmin.upgrade(payable(PROXY_ADDRESS), address(implementationV2));

        console.log("Upgrade complete! Proxy is now pointing to V2.");

        vm.stopBroadcast();
    }
}