// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract Upgrade is Script {
    function run(address proxyAddress, address proxyAdminAddress) external {
        // When called from a test, vm.prank should be used to set the caller to the owner.
        // We don't use broadcast here because the test handles the transaction.

        BoxV2 implementationV2 = new BoxV2();
        console.log("Implementation V2 (BoxV2) deployed at:", address(implementationV2));

        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // The actual upgrade call.
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(payable(proxyAddress)), address(implementationV2), new bytes(0));

        console.log("Upgrade complete! Proxy is now pointing to V2.");
    }
}
