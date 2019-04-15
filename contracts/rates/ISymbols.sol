pragma solidity ^0.5.0;

contract ISymbols {
    bytes32[] public symbolsList;

    function addSymbol(bytes32 symbol) public;

    function removeSymbol(bytes32 symbol) public;

    function hasSymbol(bytes32 symbol) public view returns (bool);

    function getSymbolsList() public view returns (bytes32[] memory);
}
