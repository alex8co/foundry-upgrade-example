// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// By inheriting from Initializable, we gain access to the _disableInitializers function.
// This is a security best practice for all implementation contracts in a proxy pattern.
contract BoxV2 is Initializable, OwnableUpgradeable {
    uint256 public value; // MUST be the first state variable, same as V1

    event ValueStored(uint256 newValue);
    event ValueIncremented(uint256 newValue);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // This ensures that the implementation contract cannot be initialized directly.
        _disableInitializers();
    }

    // Note: We do not include an `initialize` function here because the contract's
    // state is intended to be carried over from V1.

    function store(uint256 _newValue) public onlyOwner {
        value = _newValue;
        emit ValueStored(_newValue);
    }

    function retrieve() public view returns (uint256) {
        return value;
    }

    // New function in V2
    function increment() public onlyOwner {
        value++;
        emit ValueIncremented(value);
    }
}
