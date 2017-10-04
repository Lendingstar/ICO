pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';


contract Crawdsale
{
    function isActive() external returns (bool);
}


contract LSToken is StandardToken, Ownable
{
    // Fields required by ERC20
    string public constant name = "LSToken";
    string public constant symbol = "LST";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 100000000 * (10 ** uint256(decimals));

    // Reference to the latest crawdsale contract
    Crawdsale public sale;

    // We do need this variable, since Solidity doesn't support null
    // references. In order to check whether variable sale is set, we
    // need to check wheter saleAddress != address(0)
    address internal saleAddress;

    /**
    * event for logging setCrawdsale activity
    * @param _crawdsale an addres of crawdsale contract
    */
    event SetCrawdsale(address indexed _crawdsale);

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
    * @dev Sets up ongoing crawdsale contract
    * @param _saleContractAddress address of sale contract
    */
    function setSale(address _saleContractAddress) external
        onlyOwner
    {
        require(_saleContractAddress != address(0));

        saleAddress = _saleContractAddress;
        sale = Crawdsale(saleAddress);

        SetCrawdsale(saleAddress);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to burn
     */
    function burn(uint256 _value) external
    {
        require(msg.sender != address(0));
        require(_value > 0);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        BurnTokens(msg.sender, _value);
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
        // We don't need this check since SafeMath.sub already has
        // appropriate assertion
        // require(balances[owner] >= _value);

        balances[owner] = balances[owner].sub(_value);
        balances[_to] = balances[_to].add(_value);

        ClaimTokens(_to, _value);
    }

    /**
    * @dev Returns true if there is ongoing crawdsale
    */
    function isOnSale() public constant
        returns (bool)
    {
        return saleAddress != address(0) && sale.isActive();
    }
}
