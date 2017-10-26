pragma solidity ^0.4.0;


import "./math/SafeMath.sol";
import "./tokens/ERC20.sol";


/**
 * Vyral Token
 */
contract Share is ERC20 {

    using SafeMath for uint;

    string public constant version = "1.0";

    string public constant name = "Vyral Token";

    string public constant symbol = "SHARE";

    uint256 public constant decimals = 18;

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowances;

    function Share() {

    }
}
