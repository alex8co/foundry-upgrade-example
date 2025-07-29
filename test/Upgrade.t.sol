// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract UpgradeTest is Test {
    ProxyAdmin public proxyAdmin;
    address public proxyAddress;
    BoxV1 public boxV1;
    BoxV2 public boxV2;

    address public admin; // Owner of ProxyAdmin
    address public owner; // Owner of Box logic
    uint256 public initialValue;

    error OwnableUnauthorizedAccount(address account);

    event ValueStored(uint256 newValue);
    event ValueIncremented(uint256 newValue);

    function setUp() public {
        admin = makeAddr("admin");
        owner = makeAddr("owner");
        initialValue = 42;

        // 1. Deploy ProxyAdmin, owned by 'admin'
        vm.startPrank(admin);
        proxyAdmin = new ProxyAdmin(admin);
        vm.stopPrank();

        // 2. Deploy BoxV1 implementation
        BoxV1 implementationV1 = new BoxV1();

        // 3. Encode initialization data.
        bytes memory data = abi.encodeWithSelector(BoxV1.initialize.selector, initialValue, owner);

        // 4. Deploy the proxy, setting the admin to 'proxyAdmin'.
        vm.startPrank(admin);
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementationV1),
            address(proxyAdmin),
            data
        );
        vm.stopPrank();

        proxyAddress = address(proxy);
        boxV1 = BoxV1(proxyAddress);

        
    }

    function test_InitialState() public view {
        assertEq(boxV1.retrieve(), initialValue, "Initial value should be correct");
        assertEq(boxV1.owner(), owner, "Owner should be correct");
    }

    function test_ProxyAdminIsSetCorrectly() public view {
        // EIP-1967 admin slot: keccak256('eip1967.proxy.admin') - 1
        bytes32 adminSlot = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
        address proxyAdminFromStorage = address(uint160(uint256(vm.load(proxyAddress, adminSlot))));
        assertEq(proxyAdminFromStorage, address(proxyAdmin), "Proxy admin should be set correctly in storage");
    }

    function test_Upgrade() public {
        uint256 valueToPreserve = 999;
        vm.startPrank(owner);
        boxV1.store(valueToPreserve);
        vm.stopPrank();

        BoxV2 newImplementation = new BoxV2();

        vm.startPrank(admin);
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(payable(proxyAddress)), address(newImplementation), new bytes(0));
        vm.stopPrank();

        boxV2 = BoxV2(proxyAddress);

        assertEq(boxV2.retrieve(), valueToPreserve, "State should be preserved after upgrade");
        assertEq(boxV2.owner(), owner, "Owner should be preserved after upgrade");

        vm.startPrank(owner);
        boxV2.increment();
        vm.stopPrank();

        assertEq(boxV2.retrieve(), valueToPreserve + 1, "Increment should work after upgrade");
    }

    function test_RevertWhen_NonAdminUpgrades() public {
        address notAnAdmin = makeAddr("not_an_admin");
        BoxV2 newImplementation = new BoxV2();

        vm.startPrank(notAnAdmin);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, notAnAdmin));
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(payable(proxyAddress)), address(newImplementation), new bytes(0));
        vm.stopPrank();
    }

    function test_RevertWhen_NonOwnerStores() public {
        address notTheOwner = makeAddr("not_the_owner");
        vm.startPrank(notTheOwner);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, notTheOwner));
        boxV1.store(100);
        vm.stopPrank();
    }

    function test_EventEmittedOnStore() public {
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, true);
        emit ValueStored(100);
        boxV1.store(100);
        vm.stopPrank();
    }

    function test_EventEmittedOnIncrement() public {
        BoxV2 newImplementation = new BoxV2();
        vm.startPrank(admin);
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(payable(proxyAddress)), address(newImplementation), new bytes(0));
        vm.stopPrank();
        boxV2 = BoxV2(proxyAddress);

        uint256 currentValue = boxV2.retrieve();
        vm.startPrank(owner);
        vm.expectEmit(true, false, false, true);
        emit ValueIncremented(currentValue + 1);
        boxV2.increment();
        vm.stopPrank();
    }
}
