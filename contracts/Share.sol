pragma solidity ^0.4.17;

import "installed_contracts/tokens/contracts/HumanStandardToken.sol";
import "./math/SafeMath.sol";
import "./traits/Ownable.sol";

contract Share is HumanStandardToken, Ownable {
    using SafeMath for uint;

    /**
     * Init this contract with the same params as a HST.
     */
    function Share(uint _initAmount,
                   string _tokenName,
                   uint8 _decimals,
                   string _tokenSymbol)
        HumanStandardToken(_initAmount,
                           _tokenName,
                           _decimals,
                           _tokenSymbol)
    {}

    ///-----------------
    /// Overrides
    ///-----------------

    /// Off on deployment.
    bool isTransferable = false;

    /// Allows the owner to transfer tokens whenever, but others to only transfer after owner says so.
    modifier canBeTransfered {
        require( (msg.sender == owner) || isTransferable );
        _;
    }

    function transfer(address _to, uint _value)
        canBeTransfered
        public returns (bool)
    {
        require( balances[msg.sender] >= _value );

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value)
        canBeTransfered
        public returns (bool)
    {
        require( balances[_from] >= _value );
        require( allowed[_from][msg.sender] >= _value );

        allowed[_from][msg.sender] = allowed[_from][_to].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    ///-----------------
    /// Admin
    ///-----------------

    function enableTransfers()
        onlyOwner
        external returns (bool)
    {
        isTransferable = true;
        
        return isTransferable;
    }

}