pragma solidity ^0.5.0;

import "../../openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../crowdsale/IW12Crowdsale.sol";
import "../rates/IRates.sol";
import "./Utils.sol";
import "./Percent.sol";
import "./FundAccount.sol";


library  Fund {
    using SafeMath for uint;
    using Percent for uint;
    using FundAccount for FundAccount.Account;

    bytes32 constant METHOD_ETH = bytes32('ETH');
    bytes32 constant METHOD_USD = bytes32('USD');

    struct State {
        mapping(uint => bool) completedTranches;
        uint totalTranchePercentReleased;
        FundAccount.Account totalFunded;
        mapping(bytes32 => uint) totalFundedReleased;
        uint totalTokenBought;
        uint totalTokenRefunded;
        mapping(address => uint) tokenBoughtPerInvestor;
        mapping(address => FundAccount.Account) fundedPerInvestor;
    }

    event FundsReceived(address indexed investor, uint tokenAmount, bytes32 symbol, uint cost);
    event AssetRefunded(address indexed investor, bytes32 symbol, uint amount);
    event TrancheTransferred(address indexed receiver, bytes32 symbol, uint amount);

    function transferTranche(
        State storage state,
        uint[3] memory _invoice,
        uint trancheFeePercent,
        address serviceWallet,
        IRates rates
    ) public;

    function getTrancheInvoice(
        State storage state,
        bool trancheTransferAllowed,
        IW12Crowdsale crowdsale
    ) public view returns (uint[3] memory result);

    function refundAssets(
        State storage state,
        uint tokenAmount,
        IRates rates
    ) public {
        uint ln = state.fundedPerInvestor[msg.sender].symbolsList().length;

        while (ln != 0) {
            bytes32 symbol = state.fundedPerInvestor[msg.sender].symbolsList()[--ln];
            uint amount = state.fundedPerInvestor[msg.sender].amountOf(symbol);

            if (amount == 0) continue;

            // get source amount
            uint sourceAmount = Utils.safeMulDiv(
                tokenAmount,
                amount,
                state.tokenBoughtPerInvestor[msg.sender]
            );

            require(sourceAmount > 0);

            // get released tranche amount in current currency
            uint releasedTranche = state.totalFunded
                .amountOf(symbol)
                .safePercent(state.totalTranchePercentReleased);

            // get amount minus released tranche
            amount = Utils.safeMulDiv(
                state.totalFunded.amountOf(symbol).sub(releasedTranche),
                sourceAmount,
                state.totalFunded.amountOf(symbol)
            );

            require(amount > 0);

            state.totalFundedReleased[symbol] = state.totalFundedReleased[symbol].add(amount);
            state.fundedPerInvestor[msg.sender].withdrawal(symbol, sourceAmount);

            if (symbol == METHOD_USD) continue;

            if (symbol != METHOD_ETH) {
                require(rates.isToken(symbol));
                require(IERC20(rates.getTokenAddress(symbol)).balanceOf(address(this)) >= amount);
            } else {
                require(address(this).balance >= amount);
            }

            if (symbol == METHOD_ETH) {
                msg.sender.transfer(amount);
            } else {
                require(IERC20(rates.getTokenAddress(symbol)).transfer(msg.sender, amount));
            }

            emit AssetRefunded(msg.sender, symbol, amount);
        }
    }

    function recordPurchase(
        State storage state,
        address investor,
        uint tokenAmount,
        bytes32 symbol,
        uint cost,
        uint costUSD,
        IRates rates
    )
        public
    {
        require(tokenAmount > 0);
        require(cost > 0);
        require(costUSD > 0);
        require(investor != address(0));
        require(rates.hasSymbol(symbol));

        // check payment
        if (symbol == METHOD_ETH) {
            require(msg.value >= cost);
        } else {
            require(rates.isToken(symbol));
            require(IERC20(rates.getTokenAddress(symbol)).balanceOf(address(this)) >= state.totalFunded.amountOf(symbol).add(cost));
        }

        // write to investor account
        state.tokenBoughtPerInvestor[investor] = state.tokenBoughtPerInvestor[investor].add(tokenAmount);
        state.fundedPerInvestor[investor].deposit(symbol, cost);
        state.fundedPerInvestor[investor].deposit(METHOD_USD, costUSD);

        // write to total fund
        state.totalTokenBought = state.totalTokenBought.add(tokenAmount);
        state.totalFunded.deposit(symbol, cost);
        state.totalFunded.deposit(METHOD_USD, costUSD);

        emit FundsReceived(investor, tokenAmount, symbol, cost);
    }
}
