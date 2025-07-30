// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV3} from "../src/BoxV3.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
// Make sure this import is present
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeToV3Script is Script {
    function run(
        address proxyAddress,
        address proxyAdminAddress,
        string memory newDescription
    ) external {
        // 1. Deploy the new implementation contract (BoxV3)
        BoxV3 implementationV3 = new BoxV3();
        console.log("Implementation V3 (BoxV3) deployed at:", address(implementationV3));

        // 2. Get an instance of the ProxyAdmin.
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // 3. Prepare the initialization call for the new version.
        bytes memory data = abi.encodeWithSelector(implementationV3.initializeV3.selector, newDescription);

        // 4. Use vm.broadcast() to make the *next* call come directly from the EOA
        // specified by --private-key. This ensures the `onlyOwner` check on ProxyAdmin passes.
        vm.broadcast();

        // 5. The actual upgrade call, now with the correct type casting.
        // This tells the proxy to switch to the new implementation and call the initializer.
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(proxyAddress),
            address(implementationV3),
            data
        );

        console.log("Upgrade complete! Proxy is now pointing to V3.");
    }
}