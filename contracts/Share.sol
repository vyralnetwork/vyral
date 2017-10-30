pragma solidity ^0.4.0;


import "./math/SafeMath.sol";
import "./traits/Ownable.sol";
import "./tokens/ERC20.sol";


/**
 * Vyral Token
 */
contract Share is ERC20, Ownable {

    using SafeMath for uint;

    string public constant version = "1.0";

    string public constant name = "Vyral Token";

    string public constant symbol = "SHARE";

    uint256 public constant decimals = 18;

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


    function Share() {

    }

    /**
     * @dev Retrieves token balance of `buyer`
     */
    function balanceOf (
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
    function mint (
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
