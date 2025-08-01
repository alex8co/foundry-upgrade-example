// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
// Make sure this import is present
import {ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract UpgradeToV2Script is Script {
    function run(address proxyAddress, address proxyAdminAddress, string memory newName) external {
        console.log("msg.sender:", msg.sender);
        console.log("proxyAddress:", proxyAddress);
        console.log("proxyAdminAddress:", proxyAdminAddress);
        console.log("newName:", newName);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");        
        address owner = vm.addr(deployerPrivateKey);
        console.log("owner:", owner);

        // 1. Deploy the new implementation contract (BoxV2)
        // This deployment doesn't need to be broadcasted from the owner's EOA
        // Note: We use vm.startBroadcast/stopBroadcast here to ensure the deployer
        // is the `owner` EOA, even though anyone could deploy the implementation.
        vm.startBroadcast(owner);
        BoxV2 implementationV2 = new BoxV2();
        console.log("Implementation V2 (BoxV2) deployed at:", address(implementationV2));
        vm.stopBroadcast();

        // 2. Get an instance of the ProxyAdmin contract
        ProxyAdmin proxyAdmin = ProxyAdmin(proxyAdminAddress);
        //ProxyAdmin proxyAdmin = ProxyAdmin(owner);

        // 3. Prepare the initialization call for the new version using the safer abi.encodeCall.
        bytes memory data = abi.encodeCall(BoxV2.initializeV2, (newName));

        // 4. Use vm.broadcast() to make the *next* call come directly from the EOA
        // specified by --private-key. This is crucial for the `onlyOwner` check.
        vm.broadcast(owner);

        // 5. The actual upgrade call, now with the correct type casting.
        // This tells the proxy to switch to the new implementation and call the initializer.
        proxyAdmin.upgradeAndCall(
            ITransparentUpgradeableProxy(payable(proxyAddress)),
            address(implementationV2),
            data
        );

        console.log("Upgrade complete! Proxy is now pointing to V2.");
    }
}