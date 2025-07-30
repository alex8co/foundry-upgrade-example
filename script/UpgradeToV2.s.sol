// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeToV2Script is Script {
    function run(address proxyAddress, address proxyAdminAddress, string memory newName) external {
        // The private key of the ProxyAdmin owner must be used to broadcast this transaction.
        vm.startBroadcast();

        // 1. Deploy the new implementation contract (BoxV2)
        BoxV2 implementationV2 = new BoxV2();
        console.log("Implementation V2 (BoxV2) deployed at:", address(implementationV2));

        // 2. Get an instance of the ProxyAdmin.
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // 3. Prepare the initialization call for the new version.
        // We encode the function selector and arguments for `initializeV2(string)`.
        bytes memory data = abi.encodeWithSelector(implementationV2.initializeV2.selector, newName);

        // 4. The actual upgrade call. This tells the proxy to switch to the new implementation
        // and immediately call the function specified in `data`.
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(payable(proxyAddress)), address(implementationV2), data);

        console.log("Upgrade complete! Proxy is now pointing to V2.");

        vm.stopBroadcast();
    }
}
