pragma solidity ^0.5.0;

import "../IW12Fund.sol";


interface IW12FundFactory {
    function createFund(address swap, address serviceWallet, uint trancheFeePercent) external returns (IW12Fund);
}
