// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BoxV1 is Initializable {
    uint256 public value;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // This is required by the Initializable contract to prevent
        // anyone from calling initialize on the implementation contract itself.
        _disableInitializers();
    }

    // This is our replacement for the constructor.
    // The `initializer` modifier ensures it can only be called once.
    function initialize(uint256 _initialValue) public initializer {
        value = _initialValue;
    }

    function store(uint256 _newValue) public {
        value = _newValue;
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}