// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// By inheriting from Initializable, we gain access to the _disableInitializers function.
// This is a security best practice for all implementation contracts in a proxy pattern.
contract BoxV2 is Initializable, OwnableUpgradeable {
    uint256 public value; // MUST be the first state variable, same as V1
    string public name; // CORRECT: New state variables are appended at the end.

    event ValueStored(uint256 newValue);
    event ValueIncremented(uint256 newValue);
    event NameSet(string newName);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // This ensures that the implementation contract cannot be initialized directly.
        _disableInitializers();
    }

    // This is our replacement for the constructor.
    // The `initializer` modifier ensures it can only be called once.
    function initialize(uint256 _initialValue, address _owner) public initializer {
        __Ownable_init(_owner);
        value = _initialValue;
    }

    // This is a new initializer for V2. It can be called during the upgrade
    // using `upgradeAndCall` to set the values for new state variables.
    // The `reinitializer(2)` modifier ensures this can only be called once for version 2.
    function initializeV2(string memory _name) public reinitializer(2) {
        name = _name;
        emit NameSet(_name);
    }

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

    // New function in V2 to allow the owner to change the name after initialization.
    function setName(string memory _newName) public onlyOwner {
        name = _newName;
        emit NameSet(_newName);
    }
}
