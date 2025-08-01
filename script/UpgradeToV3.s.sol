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
        string memory description
    ) external {
        console.log("msg.sender:", msg.sender);
        console.log("proxyAddress:", proxyAddress);
        console.log("proxyAdminAddress:", proxyAdminAddress);
        console.log("description:", description);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");        
        address owner = vm.addr(deployerPrivateKey);
        console.log("owner:", owner);

        // 1. Deploy the new implementation contract (BoxV3)
        vm.startBroadcast(owner);
        BoxV3 implementationV3 = new BoxV3();
        console.log("Implementation V3 (BoxV3) deployed at:", address(implementationV3));
        vm.stopBroadcast();

        // 2. Get an instance of the ProxyAdmin.
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);

        // 3. Prepare the initialization call for the new version.
        bytes memory data = abi.encodeCall(BoxV3.initializeV3, (description));

        // 4. Use vm.broadcast() to make the *next* call come directly from the EOA
        // specified by --private-key. This ensures the `onlyOwner` check on ProxyAdmin passes.
        vm.broadcast(owner);

        // 5. The actual upgrade call, now with the correct type casting.
        // This tells the proxy to switch to the new implementation and call the initializer.
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(payable(proxyAddress)),
            address(implementationV3),
            data
        );

        console.log("Upgrade complete! Proxy is now pointing to V3.");
    }
}