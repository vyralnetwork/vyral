pragma solidity ^0.4.17;

import "tokens/HumanStandardToken.sol";
import "./math/SafeMath.sol";
import "./traits/Ownable.sol";

/**
 * SHARE token is an ERC20 token.
 */
contract Share is HumanStandardToken, Ownable {
    using SafeMath for uint;

    string public constant TOKEN_NAME = "Vyral Token";

    string public constant TOKEN_SYMBOL = "SHARE";

    uint8 public constant TOKEN_DECIMALS = 18;

    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(TOKEN_DECIMALS));

    mapping (address => bool) public transferrers;

    /**
     * Init this contract with the same params as a HST.
     */
    function Share() HumanStandardToken(TOTAL_SUPPLY, TOKEN_NAME, TOKEN_DECIMALS, TOKEN_SYMBOL)
    {
        transferrers[msg.sender] = true;
    }

    ///-----------------
    /// Overrides
    ///-----------------

    /// Off on deployment.
    bool isTransferable = false;

    /// Allows the owner to transfer tokens whenever, but others to only transfer after owner says so.
    modifier canBeTransfered {
        require(transferrers[msg.sender] || isTransferable);
        _;
    }
//
//    function transfer(
//        address _to,
//        uint _value
//    )
//        canBeTransfered
//        public
//        returns (bool)
//    {
//        require(balances[msg.sender] >= _value);
//
//        balances[msg.sender] = balances[msg.sender].sub(_value);
//        balances[_to] = balances[_to].add(_value);
//        Transfer(msg.sender, _to, _value);
//        return true;
//    }
//
//    function transferFrom(
//        address _from,
//        address _to,
//        uint _value
//    )
//        canBeTransfered
//        public
//        returns (bool)
//    {
//        require(balances[_from] >= _value);
//        require(allowed[_from][msg.sender] >= _value);
//
//        allowed[_from][msg.sender] = allowed[_from][_to].sub(_value);
//        balances[_from] = balances[_from].sub(_value);
//        balances[_to] = balances[_to].add(_value);
//        Transfer(_from, _to, _value);
//        return true;
//    }

    ///-----------------
    /// Admin
    ///-----------------

    function enableTransfers()
        onlyOwner
        external
        returns (bool)
    {
        isTransferable = true;

        return isTransferable;
    }

    function addTransferrer(
        address _transferrer
    )
        public
//        onlyOwner
    {
        transferrers[_transferrer] = true;
    }
}