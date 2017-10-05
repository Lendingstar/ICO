pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

/**
* Interface to a crowdsale contract. LSToken takes care on isActive()
* method only
*/
contract Crowdsale
{
    function isActive() external returns (bool);
}


/**
* @title Lending Star Token
* @author LendingStar Malaysia Sdn Bhd.
* 
* This is a ERC20 Token with 100,000,000,000 (one hundred million) tokens as initial
* supply. Token supports 18 decimal digits hence smallest token particle
* is 0.000000000000000001
*
* During contract construction all tokens are put on contract's owner account.
*
* Token holds an address of Lending Star crowdsale contract which can be set
* using setSale() method. For each ERC20 token transfer operation (transfer,
* transferFrom, allowance and approve) as well as increaseApproval and
* decreaseApproval methods, the token prevents the operations mentioned above
* if specified crowdsale contract is in Active state (in other words:
* transferring tokens between accounts is prohibited during Lending Star
* crowdsale event.
*
* Crowdsale contract can claim some amount of tokens to be moved on particular
* account, using claimTokensFor method. The method can be called by active 
* Lending Star crowdsale contract only.
*/
contract LSToken is StandardToken, Ownable
{
    // Fields required by ERC20
    string public constant name = "LSToken";
    string public constant symbol = "LST";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 100000000000 * (10 ** uint256(decimals));

    // Reference to the latest crowdsale contract
    Crowdsale public sale;

    // We do need this variable, since Solidity doesn't support null
    // references. In order to check whether variable sale is set,we
    // need to check wheter saleAddress != address(0)
    address internal saleAddress;

    // Wallet address that will be used to hold wasted tokens
    // The address will be able to call burn() function to
    // destroy some or all tokens from its account
    address internal garbageTokensAccount;

    /**
    * event for logging setCrowdsale activity
    * @param _crowdsale an addres of crowdsale contract
    */
    event SetCrowdsale(address indexed _crowdsale);

    /**
    * event for tokens claim logging
    * @param claimFor whom tokens would be claimed for
    * @param value an amount of tokens to be claimed
    */
    event ClaimTokens(address indexed claimFor, uint256 value);

    /**
    * event for burning tokens logging
    * @param burner tokens owner address
    * @param value an amount of tokens to burn
    */
    event BurnTokens(address indexed burner, uint256 value);

    /**
    * @dev Modifier to make a function callable only when the contract is not
    * on active sale.
    */
    modifier whenNotOnSale()
    {
        require(!isOnSale());

        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is on
    * sale.
    */
    modifier whenOnSale()
    {
        require(isOnSale());

        _;
    }

    function LSToken() public
        StandardToken()
        Ownable()
    {
        totalSupply = INITIAL_SUPPLY;
        balances[owner] = totalSupply;
    }

    /**
    * @dev Sets up ongoing crowdsale contract
    * @param _saleContractAddress address of sale contract
    */
    function setSale(address _saleContractAddress) external
        onlyOwner
    {
        require(_saleContractAddress != address(0));

        saleAddress = _saleContractAddress;
        sale = Crowdsale(saleAddress);

        SetCrowdsale(saleAddress);
    }

    /**
    * @dev Sets up an account address that holds wasted tokens
    * @param _garbageTokensAccount address of account
    */
    function setGarbageTokensAccount(address _garbageTokensAccount) external
        onlyOwner
    {
        require(_garbageTokensAccount != address(0));

        garbageTokensAccount = _garbageTokensAccount;
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to burn
     */
    function burn(uint256 _value) external
        returns (bool success)
    {
        require(msg.sender == garbageTokensAccount);
        require(_value > 0);

        // No need to make this check here since Math.sub already
        // has appropriate assertion
        // require(balances[msg.sender] >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        BurnTokens(msg.sender, _value);

        return true;
    }

    // We wnat these actions allowed ONLY when Tokens are not on sale
    // i.e. there is no active Sale smart contract
    function transfer(address _to, uint256 _value) public
        whenNotOnSale
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public
        whenNotOnSale
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public
        whenNotOnSale
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public
        whenNotOnSale
        returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public
        whenNotOnSale
        returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    /**
    * @dev Claims tokens for address. This function should be called by
    * sale contract only. Tokens are claimed from owner address
    * @param _to address The address tokens to be claimed for
    * @param _value uint256 The amount of tokens to be claimed
    */
    function claimTokensFor(address _to, uint256 _value) external
        whenOnSale
    {
        require(msg.sender == saleAddress);
        require(_to != address(0));
        require(_value > 0);
        // We don't need the following check since SafeMath.sub already has
        // appropriate assertion
        // require(balances[owner] >= _value);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);

        ClaimTokens(_to, _value);
    }

    /**
    * @dev Returns true if there is ongoing crowdsale
    */
    function isOnSale() public constant
        returns (bool)
    {
        return saleAddress != address(0) && sale.isActive();
    }
}
