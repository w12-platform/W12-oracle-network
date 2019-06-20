pragma solidity ^0.5.0;

contract IAdminRole {
    function isAdmin(address account) public view returns (bool);

    function addAdmin(address account) public;

    function renounceAdmin() public;

    function removeAdmin(address account) public;
}
