pragma solidity ^0.4.18;

import '../node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';
import '../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * Vyral Token
 */
contract Share is StandardToken, Ownable {
    using SafeMath for uint;

    string public constant name = "Vyral Token";
    string public constant symbol = "SHARE";
    uint256 public constant decimals = 18;
    string public constant version = "1.0";

    bool public mintingFinished = false;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    /*
     * Modifiers
     */
    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * Create SHARE token with given amount as totalSupply.
     */
    function Share(
        uint _amount
    ) {
        // Give the creator all initial tokens
        balances[msg.sender] = _amount;

        // Update total supply
        totalSupply = _amount;
    }

    /**
     * @dev Retrieves token balance of `buyer`
     */
    function balanceOf(
        address buyer
    )
        constant
        returns (uint256)
    {
        return balances[buyer];
    }

    /**
     * Owner can mint and assign `amount` tokens to a `buyer` address.
     */
    function mint(
        uint amount,
        address buyer
    )
        onlyOwner
        canMint
        returns (bool)
    {
        totalSupply = totalSupply.add(amount);

        balances[buyer] = balances[buyer].add(amount);
        return true;
    }

}
