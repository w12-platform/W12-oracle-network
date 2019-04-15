pragma solidity ^0.5.0;

contract Versionable {
    uint public version;

    constructor(uint _version) public {
        version = _version;
    }
}
