// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Note: We don't need Initializable here again because the contract is already initialized.
// We just need to make sure the storage layout is compatible.

contract BoxV2 {
    uint256 public value; // MUST be the first state variable, same as V1

    // We don't need an initialize function here because the state is already set.

    function store(uint256 _newValue) public {
        value = _newValue;
    }

    function retrieve() public view returns (uint256) {
        return value;
    }

    // New function in V2
    function increment() public {
        value++;
    }
}