// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import "forge-std/Script.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract BoxV1 is Initializable, OwnableUpgradeable {
    uint256 public value;

    event ValueStored(uint256 newValue);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // This is required by the Initializable contract to prevent
        // anyone from calling initialize on the implementation contract itself.
        _disableInitializers();
    }

    // This is our replacement for the constructor.
    // The `initializer` modifier ensures it can only be called once.
    function initialize(uint256 _initialValue, address _owner) public initializer {
        //console.log("owner:", _owner);
        __Ownable_init(_owner);
        value = _initialValue;
    }

    function store(uint256 _newValue) public onlyOwner {
        value = _newValue;
        emit ValueStored(_newValue);
    }

    function retrieve() public view returns (uint256) {
        return value;
    }
}