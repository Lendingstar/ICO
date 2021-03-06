pragma solidity ^0.4.15;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract Token
{
    function claimTokensFor(address _to, uint256 _value) public returns (bool);
}


/**
* @title Lending Star Crowdsale
* @author LendingStar Malaysia Sdn Bhd.
*
* A crowdsale smart contract that allows investors to buy Lending Star
* tokens during limited period of time. A period of time while crowdsale's
* running as well as LST price are fixed and defined during contract creation.
*
* The contract has a cap - total amount of funds that could be raised by
* crowdsale.
*
* The contract holds all investments till crowdsale owner withdraws them by
* withdraw() method. The funds will be transferred to the 'wallet' address,
* specified during contract creation.
*
* Investor should use buyTokens() method in order to buy some LSTs. The method
* will forward appropriate amount of LSTs to sender's address.
*/
contract LSSale is Ownable
{
    using SafeMath for uint256;

    // The token being sold
    Token public token;

    // start and end timestamps when investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // How many Wei does investor need to buy 0.000000000000000001 LST
    uint256 public rate;

    // how much funds in Wei do we want to raise during crowdsale
    uint256 public weiGoal;

    // smallest investment that will be allowed by contract
    uint256 public weiMinimalInvestment;

    // amount of funds (in Wei) been raised
    uint256 public weiRaised = 0;

    /**
    * event for token purchase logging
    * @param investor who paid for the tokens
    * @param value amount of funds (in Wei) invested
    * @param tokens amount of tokens purchased
    */
    event TokenPurchase(address indexed investor, uint256 value, uint256 tokens);

    /**
    * event for funds withdrawal logging
    * @param value amount of funds (in Wei) been transferred
    */
    event FundsWithdrawal(uint256 value);

    /**
    * @dev Modifier to check incoming transactions
    */
    modifier validPurchase()
    {
        require(msg.sender != address(0));
        require(isActive());
        require(msg.value > 0);
        require(msg.value >= weiMinimalInvestment);
        require(weiRaised.add(msg.value) <= weiGoal);

        _;
    }

    /**
    * @dev Lending Star crowdsale constructor
    * @param _rate uint256 value specifies how many Wei do you need to buy
    * 0.000000000000000001 LST
    * @param _goal uint256 value specifies what is the goal in Wei of crowdsale
    * @param _weiMinimalInvestment uint256 value that represents smallest
    * investment that will be allowed by contract
    * @param _startTime time when crowdsale begins
    * @param _endTime time when crowdsale ends
    * @param _tokenAddress address of LST contract
    * @param _wallet address that will be used for funds withdrawal
    */
    function LSSale(
        uint256 _rate,
        uint256 _goal,
        uint256 _weiMinimalInvestment,
        uint256 _startTime,
        uint256 _endTime,
        address _tokenAddress,
        address _wallet
    ) public
        Ownable()
    {
        require(_startTime >= now);
        require(_endTime > _startTime);
        require(_rate > 0);
        require(_goal > 0);
        require(_wallet != 0x0);
        require(_tokenAddress != 0x0);

        rate = _rate;
        weiGoal = _goal;
        weiMinimalInvestment = _weiMinimalInvestment;
        startTime = _startTime;
        endTime = _endTime;
        token = Token(_tokenAddress);
        wallet = _wallet;
    }

    function () public
        validPurchase
        payable
    {
        buyTokens(msg.sender, msg.value);
    }

    /**
    * @notice The function forwards appropriate amount of LSTs to investor.
    * Current ETH/LST ratio preserved in 'rate' variable of the contract.
    * Make sure that the contract is in Actice state (you're
    * makeing transaction in valid time period AND crowdsale has not reach
    * the cap yet).
    */
    function buyTokens(address _beneficiry, uint256 _investments) internal
    {
        // Updating raised funds status
        weiRaised = weiRaised.add(_investments);

        // Calculating an amount of tokens to be sold
        uint256 _tokens = weiToTokens(_investments);

        // Claim tokens for _beneficiry from Coin contract
        token.claimTokensFor(_beneficiry, _tokens);
        TokenPurchase(_beneficiry, _investments, _tokens);
    }

    /**
    * @dev calculates amount of tokens that can be baught for _investments
    * @param _investments uint256 represents amount of investments in Wei
    * @return amount of tokens that can be bought for _investments
    */
    function weiToTokens(uint256 _investments) internal constant
        returns (uint256)
    {
        return _investments.mul(rate);
    }

    /**
    * @dev Transfers contract's balance to wallet address
    */
    function withdraw() external
        onlyOwner 
    {
        require(wallet != address(0));
        require(this.balance > 0);

        uint256 _value = this.balance;
        wallet.transfer(_value);

        FundsWithdrawal(_value);
    }

    /**
    * @dev Checks whether crowdsale contract is in active state (can accept
    * funds)
    * @return true if now is within specified time period and crowdsale
    */
    function isActive() public constant
        returns (bool)
    {
        return now >= startTime && now <= endTime && weiRaised < weiGoal;
    }
}
