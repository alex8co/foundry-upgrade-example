// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployScript is Script {
    function run() external returns (address proxyAddress) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);
        uint256 initialValue = vm.envUint("INITIAL_VALUE");

        vm.startBroadcast();

        // 1. Deploy the ProxyAdmin: This contract will be the owner of the proxy.
        ProxyAdmin proxyAdmin = new ProxyAdmin(owner);
        console.log("ProxyAdmin deployed at:", address(proxyAdmin));

        // 2. Deploy the implementation contract (BoxV1)
        BoxV1 implementationV1 = new BoxV1();
        console.log("Implementation V1 (BoxV1) deployed at:", address(implementationV1));

        // 3. Prepare the initialization call.
        // We need to tell the proxy to call `initialize(42)` on BoxV1.
        // This is done by encoding the function selector and its arguments.
        bytes memory data = abi.encodeWithSelector(BoxV1.initialize.selector, initialValue, owner);

        // 4. Deploy the TransparentUpgradeableProxy.
        // It takes the implementation address, the admin address, and the initialization data.
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementationV1),
            address(proxyAdmin),
            data
        );
        console.log("Proxy for BoxV1 deployed at:", address(proxy));

        vm.stopBroadcast();
        return address(proxy);
    }
}