pragma solidity ^0.5.0;

import "../../openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../../openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "./Percent.sol";
import "../token/IWToken.sol";

library PurchaseProcessing {
    using SafeMath for uint;
    using Percent for uint;

    function METHOD_ETH() internal pure returns (bytes32) {return bytes32('ETH');}

    function checkInvoiceInput(
        bytes32 method,
        uint amount,
        uint methodUSDRate,
        uint tokenUSDRate,
        uint currentBalanceInTokens,
        uint tokenDecimals,
        uint methodDecimals
    ) public pure returns(bool result) {
        result = amount > 0
            && methodUSDRate > 0
            && tokenUSDRate > 0
            && currentBalanceInTokens >= 10 ** tokenDecimals;

        if (method == METHOD_ETH()) {
            result = result && methodDecimals == 18;
        }
    }

    /**
     * @notice Generate invoice
     * @dev 1 USD = 10^8. In this case precision will be up to 10^8 decimals after point
     * @param method Payment method
     * @param paymentAmount Payment amount
     * @param discount Discount percent
     * @param volumeBoundaries Volume boundaries to calculate bonus
     * @param volumeBonuses List of bonuses bound to boundaries
     * @param methodUSDRate Payment method rate in USD
     * @param tokenUSDRate Token rate in USD
     * @param tokenDecimals Token decimal
     * @param methodDecimals Method decimal. N for token, 18 for ETH
     * @param currentBalanceInTokens Current balance in tokens
     * @return uint[5] result Invoice calculation result:
     *
     * [tokenAmount, cost, costUSD, change, actualTokenPriceUSD]
     *
     * [0] tokenAmount - amount of token to buy
     * [1] cost - cost in method currency
     * [2] costUSD cost in USD
     * [3] change - change in method currency
     * [4] actualTokenPriceUSD - actual token price in USD(with discount)
     */
    function invoice(
        bytes32 method,
        uint paymentAmount,
        uint discount,
        uint[] memory volumeBoundaries,
        uint[] memory volumeBonuses,
        uint methodUSDRate,
        uint tokenUSDRate,
        uint tokenDecimals,
        uint methodDecimals,
        uint currentBalanceInTokens
    )
        public view returns(uint[5] memory result)
    {
        require(checkInvoiceInput(
            method,
            paymentAmount,
            methodUSDRate,
            tokenUSDRate,
            currentBalanceInTokens,
            tokenDecimals,
            methodDecimals
        ));

        // costUSD
        result[2] = Utils.safeConversionByRate(
            paymentAmount,
            methodDecimals,
            methodUSDRate
        );

        // min costUSD = tokenUSDRate
        require(result[2] >= tokenUSDRate);

        uint bonus = getBonus(result[2], volumeBoundaries, volumeBonuses);

        // priceUSD
        result[4] = discount > 0
            ? tokenUSDRate.percent(Percent.MAX() - discount)
            : tokenUSDRate;

        // tokens
        result[0] = Utils.safeReverseConversionByRate(
            result[2].safePercent(Percent.MAX().add(bonus)),
            tokenDecimals,
            result[4]
        );

        // if current balance is not enough
        if (currentBalanceInTokens < result[0]) {
            result[2] = Utils.safeConversionByRate(
                currentBalanceInTokens,
                tokenDecimals,
                result[4]
            );
            result[0] = currentBalanceInTokens;
        }

        // cost
        result[1] = Utils.safeReverseConversionByRate(
            result[2],
            methodDecimals,
            methodUSDRate
        );

        // reset if cost is zero
        if (result[1] == 0 || result[0] == 0) {
            result[0] = 0;
            result[1] = 0;
            result[2] = 0;
        }

        // change
        result[3] = paymentAmount.sub(result[1]);
    }

    /**
     * @notice Generate invoice by token amount
     * @dev 1 USD = 10^8. In this case precision will be up to 10^8 decimals after point
     * @param method Payment method
     * @param tokenAmount Token amount
     * @param discount Discount percent
     * @param volumeBoundaries Volume boundaries to calculate bonus
     * @param volumeBonuses List of bonuses bound to boundaries
     * @param methodUSDRate Payment method rate in USD
     * @param tokenUSDRate Token rate in USD
     * @param tokenDecimals Token decimal
     * @param methodDecimals Method decimal. N for token, 18 for ETH
     * @param currentBalanceInTokens Current balance in tokens
     * @return uint[4] result Invoice calculation result:
     *
     * [tokenAmount, cost, costUSD, change, actualTokenPriceUSD]
     *
     * [0] tokenAmount - amount of token to buy
     * [1] cost - cost in method currency
     * [2] costUSD cost in USD
     * [3] actualTokenPriceUSD - actual token price in USD(with discount)
     */
    function invoiceByTokenAmount(
        bytes32 method,
        uint tokenAmount,
        uint discount,
        uint[] memory volumeBoundaries,
        uint[] memory volumeBonuses,
        uint methodUSDRate,
        uint tokenUSDRate,
        uint tokenDecimals,
        uint methodDecimals,
        uint currentBalanceInTokens
    )
        public view returns (uint[4] memory result)
    {
        require(checkInvoiceInput(
            method,
            tokenAmount,
            methodUSDRate,
            tokenUSDRate,
            currentBalanceInTokens,
            tokenDecimals,
            methodDecimals
        ));

        if (currentBalanceInTokens < tokenAmount) {
            tokenAmount = currentBalanceInTokens;
        }

        // tokens
        result[0] = tokenAmount;

        // priceUSD
        result[3] = discount > 0
            ? tokenUSDRate.percent(Percent.MAX() - discount)
            : tokenUSDRate;

        // costUSD
        result[2] = Utils.safeConversionByRate(
            tokenAmount,
            tokenDecimals,
            result[3]
        );

        // min costUSD = tokenUSDRate
        require(result[2] >= tokenUSDRate);

        uint bonus = getBonus(result[2], volumeBoundaries, volumeBonuses);

        result[1] = Utils.safeReverseConversionByRate(
            result[2],
            methodDecimals,
            methodUSDRate.safePercent(Percent.MAX().add(bonus))
        );

        // reset if cost is zero
        if (result[1] == 0) {
            result[0] = 0;
            result[1] = 0;
            result[2] = 0;
        }
    }

    function fee(uint tokenAmount, uint cost, uint tokenFee, uint purchaseFee) public pure returns(uint[2] memory result) {
        if (tokenFee > 0) result[0] = tokenAmount.safePercent(tokenFee);
        if (purchaseFee > 0) result[1] = cost.safePercent(purchaseFee);
    }

    function transferFee(
        uint[2] memory _fee,
        bytes32 method,
        address methodToken,
        address token,
        address originToken,
        address exchanger,
        address serviceWallet
    ) public {
    }

    function transferPurchase(
        uint[5] memory _invoice,
        uint[2] memory _fee,
        uint32 vesting,
        bytes32 method,
        address methodToken,
        address token
    ) public {
        require(token != address(0));
        require(_invoice[0] != 0);
        require(_invoice[1] != 0);
        require(_invoice[0] > _fee[0]);
        require(_invoice[1] > _fee[1]);

        if (method == METHOD_ETH()) {
            require(msg.value >= _invoice[1]);
        }

        if (method != METHOD_ETH()) {
            require(methodToken != address(0));
            require(IERC20(methodToken).allowance(msg.sender, address(this)) >= _invoice[1].sub(_fee[1]));
            require(IERC20(methodToken).transferFrom(msg.sender, address(this), _invoice[1].sub(_fee[1])));
        }

        require(IWToken(token).vestingTransfer(msg.sender, _invoice[0], vesting));

        if (_invoice[3] > 0) {
            if (method == METHOD_ETH()) {
                msg.sender.transfer(_invoice[3]);
            }
        }
    }

    function getBonus(uint value, uint[] memory volumeBoundaries, uint[] memory volumeBonuses) public view returns(uint bonus) {
        for (uint i = 0; i < volumeBoundaries.length; i++) {
            if (value >= volumeBoundaries[i]) {
                bonus = volumeBonuses[i];
            } else {
                break;
            }
        }
    }
}
