// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
// Note: The proxy contracts themselves are not "upgradeable" and are imported from the standard OZ contracts.
import {TransparentUpgradeableProxy, ITransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {BoxV3} from "../src/BoxV3.sol";



contract BoxTest is Test {
    ProxyAdmin internal proxyAdmin;
    address internal proxyAddress;

    // We will cast the proxy address to the interface of the contract version we are testing.
    BoxV1 internal boxV1;
    BoxV2 internal boxV2;
    BoxV3 internal boxV3;

    uint256 internal constant INITIAL_VALUE = 42;
    string internal constant V2_NAME = "MyBoxV2";
    string internal constant V3_DESCRIPTION = "This is a V3 box.";

    /// @notice Deploy V1 of the Box contract behind a proxy for each test.
    function setUp() public {
        // Use the msg.sender from the `--private-key` as the owner
        address owner = msg.sender;
        console.log("msg.sender:", msg.sender);
        // 1. Deploy the ProxyAdmin. This contract is the owner of the proxy and manages upgrades.
        // The owner of ProxyAdmin will be this test contract (address(this)).
        proxyAdmin = new ProxyAdmin(owner);

        // 2. Deploy the V1 implementation contract.
        BoxV1 implementationV1 = new BoxV1();

        // 3. Prepare the initialization data. This is the encoded function call to `initialize(uint256, address)`
        //    that will be delegated from the proxy to the implementation contract.
        bytes memory data = abi.encodeWithSelector(
            BoxV1.initialize.selector,
            INITIAL_VALUE,
            address(this) // The test contract will be the owner.
        );

        // 4. Deploy the proxy contract, linking it to the V1 implementation and initializing it.
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementationV1),
            address(proxyAdmin),
            data
        );
        proxyAddress = address(proxy);

        // 5. Create a contract instance at the proxy address to interact with V1 functions.
        boxV1 = BoxV1(proxyAddress);
    }

    /// @notice Tests that the initial state of BoxV1 is set correctly after deployment.
    function test_V1_InitialState() public view {
        assertEq(boxV1.retrieve(), INITIAL_VALUE, "V1 initial value should be set");
        assertEq(boxV1.owner(), address(this), "V1 owner should be this contract");
    }

    /// @notice Tests the `store` function of BoxV1.
    function test_V1_Store() public {
        uint256 newValue = 100;
        boxV1.store(newValue);
        assertEq(boxV1.retrieve(), newValue, "V1 store should update value");
    }

    /// @notice Tests the upgrade process from V1 to V2 and verifies state.
    function test_UpgradeToV2_And_CheckState() public {
        // 1. Deploy the V2 implementation contract.
        BoxV2 implementationV2 = new BoxV2();

        // 2. Prepare the initialization data for V2's new state variables.
        bytes memory data = abi.encodeWithSelector(BoxV2.initializeV2.selector, V2_NAME);

        // 3. Upgrade the proxy to V2 and call initializeV2 in a single transaction.
        // This is done by the ProxyAdmin, which is the admin of the proxy.
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(proxyAddress), address(implementationV2), data);

        // 4. Create a contract instance at the proxy address to interact with V2 functions.
        boxV2 = BoxV2(proxyAddress);

        // 5. Assert that V1 state is preserved.
        assertEq(boxV2.retrieve(), INITIAL_VALUE, "V1 value should be preserved after V2 upgrade");
        assertEq(boxV2.owner(), address(this), "V1 owner should be preserved after V2 upgrade");

        // 6. Assert that V2 state is initialized correctly.
        assertEq(boxV2.name(), V2_NAME, "V2 name should be initialized");
    }

    /// @notice Tests the new functionality introduced in BoxV2.
    function test_V2_Functionality() public {
        // --- Setup: Upgrade to V2 first ---
        BoxV2 implementationV2 = new BoxV2();
        bytes memory data = abi.encodeWithSelector(BoxV2.initializeV2.selector, V2_NAME);
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(proxyAddress), address(implementationV2), data);
        boxV2 = BoxV2(proxyAddress);
        // --- End Setup ---

        // Test the new `increment` function.
        uint256 currentValue = boxV2.retrieve();
        boxV2.increment();
        assertEq(boxV2.retrieve(), currentValue + 1, "V2 increment should increase value by 1");

        // Test the new `setName` function.
        string memory newName = "A New Name";
        boxV2.setName(newName);
        assertEq(boxV2.name(), newName, "V2 setName should update the name");
    }

    /// @notice Tests the upgrade process from V2 to V3 and verifies state.
    function test_UpgradeToV3_And_CheckState() public {
        // --- Action: Upgrade to V3 ---
        _upgradeToV3();

        // Create a contract instance at the proxy address to interact with V3 functions.
        boxV3 = BoxV3(proxyAddress);

        // Assert that V1 and V2 state is preserved.
        assertEq(boxV3.retrieve(), INITIAL_VALUE, "V1 value should be preserved after V3 upgrade");
        assertEq(boxV3.owner(), address(this), "V1 owner should be preserved after V3 upgrade");
        assertEq(boxV3.name(), V2_NAME, "V2 name should be preserved after V3 upgrade");

        // Assert that V3 state is initialized correctly.
        assertEq(boxV3.description(), V3_DESCRIPTION, "V3 description should be initialized");
    }

    /// @notice Tests the new functionality in V3 and ensures old functionality still works.
    function test_V3_Functionality() public {
        // --- Setup: Upgrade to V3 (via V2) ---
        _upgradeToV3();
        boxV3 = BoxV3(proxyAddress);
        // --- End Setup ---

        // Test the new V3 `setDescription` function.
        string memory newDescription = "A new description for V3";
        boxV3.setDescription(newDescription);
        assertEq(boxV3.description(), newDescription, "V3 setDescription should update the description");

        // Test that a V2 function (`increment`) still works correctly.
        uint256 currentValue = boxV3.retrieve();
        boxV3.increment();
        assertEq(boxV3.retrieve(), currentValue + 1, "V2 increment should still work in V3");

        // Test that a V1 function (`store`) still works correctly.
        uint256 newValue = 999;
        boxV3.store(newValue);
        assertEq(boxV3.retrieve(), newValue, "V1 store should still work in V3");
    }

    // --- Internal Helper Functions ---

    /// @notice Helper function to perform the full upgrade path from V1 to V3.
    function _upgradeToV3() internal {
        // First, upgrade from V1 to V2
        BoxV2 implementationV2 = new BoxV2();
        bytes memory dataV2 = abi.encodeWithSelector(BoxV2.initializeV2.selector, V2_NAME);
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(proxyAddress), address(implementationV2), dataV2);

        // Then, upgrade from V2 to V3
        BoxV3 implementationV3 = new BoxV3();
        bytes memory dataV3 = abi.encodeWithSelector(BoxV3.initializeV3.selector, V3_DESCRIPTION);
        proxyAdmin.upgradeAndCall(ITransparentUpgradeableProxy(proxyAddress), address(implementationV3), dataV3);
    }
}