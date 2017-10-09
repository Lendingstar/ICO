pragma solidity ^0.4.15;


import './LSSale.sol';


/**
* @title Lending Star Crowdsale
* @author LendingStar Malaysia Sdn Bhd.
* 
* Lending Star crowdsale smart contract with bonuses
*/
contract LSSaleWithBonus is LSSale
{
    using SafeMath for uint256;

    function LSSaleWithBonus(
        uint256 _rate,
        uint256 _goal,
        uint256 _weiMinimalInvestment,
        uint256 _startTime,
        uint256 _endTime,
        address _tokenAddress,
        address _wallet
    ) public
        LSSale(
            _rate,
            _goal,
            _weiMinimalInvestment,
            _startTime,
            _endTime,
            _tokenAddress,
            _wallet
        )
    {
    }

    /**
    * @dev calculates amount of tokens that can be baught for _investments
    * @param _investments uint256 represents amount of investments in Wei
    * @return amount of tokens that can be bought for _investments
    */
    function weiToTokens(uint256 _investments) internal constant
        returns (uint256)
    {
        // Follow bonus calculation logic for transactions larger than
        // particular amount
        if (_investments >= 100 ether) {
            uint256 _bonus_percent = 0;

            if (_investments < 300 ether) {
                _bonus_percent = 15;
            } else if (_investments >= 300 ether && _investments < 500 ether) {
                _bonus_percent = 20;
            } else if (_investments >= 500 ether && _investments < 700 ether) {
                _bonus_percent = 25;
            } else { // if _investments >= 700 ether
                _bonus_percent = 30;
            }

            // Add bonuses (in Wei) to the origianl _investments:
            // If original _investments - 100%
            // recalculate how much Wei would (100 + _bonus_percent)% be
            _investments = _investments.mul(100 + _bonus_percent).div(100);
        }

        // Calculate amount of tokens, using base class formula
        return super.weiToTokens(_investments);
    }
}
