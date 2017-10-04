pragma solidity ^0.4.15;


import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract Token
{
    function claimTokensFor(address _to, uint256 _value) public returns (bool);
}


/**
* @title LS Crowdsale event
* @author LS Inc
*/
contract LSSale is Ownable
{
    using SafeMath for uint256;

    // The token being sold
    Token public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // 1 token == weiPrice wei
    // rate = 1/weiPrice token to wei
    uint256 public rate;

    // how much Ethers in wei we want to raise
    uint256 public weiGoal;

    // amount of raised money in wei
    uint256 public weiRaised = 0;

    /**
    * event for token purchase logging
    * @param investor who paid for the tokens
    * @param value amount of funds (in wei) invested
    * @param tokens amount of tokens purchased
    */
    event TokenPurchase(address indexed investor, uint256 value, uint256 tokens);

    /**
    * event for funds withdrawal logging
    * @param value amount of funds (in wei) been transferred
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
        require(weiRaised.add(msg.value) <= weiGoal);

        _;
    }

    function LSSale(
        uint256 _rate,
        uint256 _goal,
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
        startTime = _startTime;
        endTime = _endTime;
        token = Token(_tokenAddress);
        wallet = _wallet;
    }

    /**
    * @notice The function forwards appropriate amount of LST tokens back
    * to investor. Current ETH/LST ratio preserved in 'rate' variable of
    * this contract. Make sure that the contract is in Actice state (you're
    * makeing transaction in correct time period AND contract has not run out
    * of funds yet).
    */
    function buyTokens() public
        validPurchase
        payable
    {
        address _beneficiry = msg.sender;
        uint256 _investments = msg.value;

        // Updating raised funds status
        weiRaised = weiRaised.add(_investments);

        // Calculating an amount of tokens to be sold
        uint256 _tokens = _investments.mul(rate);

        // Claim tokens for _beneficiry from Coin contract
        token.claimTokensFor(_beneficiry, _tokens);
        TokenPurchase(_beneficiry, _investments, _tokens);
    }

    /**
    * @dev The function allows owner to buy tokens in favour of _beneficiry
    * @param _beneficiary address that will recieve tokens
    */
    function buyTokensFor(address _beneficiary) external
        validPurchase
        onlyOwner
        payable 
    {
        require(_beneficiary != address(0));

        uint256 _investments = msg.value;

        // Updating raised funds status
        weiRaised = weiRaised.add(_investments);

        // Calculating an amount of tokens to be sold
        uint256 _tokens = _investments.mul(rate);

        // Claim tokens for _beneficiary from Coin contract
        token.claimTokensFor(_beneficiary, _tokens);
        TokenPurchase(_beneficiary, _investments, _tokens);
    }

    /**
    * @dev Transfers contract's balance to wallet
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
