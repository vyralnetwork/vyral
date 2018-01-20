# Share

Source file [../../contracts/Share.sol](../../contracts/Share.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.17;

// BK Next 3 Ok
import "installed_contracts/tokens/contracts/HumanStandardToken.sol";
import "./math/SafeMath.sol";
import "./traits/Ownable.sol";

/**
 * SHARE token is an ERC20 token.
 */
// BK Ok
contract Share is HumanStandardToken, Ownable {
    // BK Ok
    using SafeMath for uint;

    // BK Ok
    string public constant TOKEN_NAME = "Vyral Token";

    // BK Ok
    string public constant TOKEN_SYMBOL = "SHARE";

    // BK Ok
    uint8 public constant TOKEN_DECIMALS = 18;

    // BK Ok
    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(TOKEN_DECIMALS));

    // BK Ok
    mapping (address => uint256) lockedBalances;

    // BK Ok
    mapping (address => bool) public transferrers;

    /**
     * Init this contract with the same params as a HST.
     */
    // BK Ok - Constructor
    function Share() HumanStandardToken(TOTAL_SUPPLY, TOKEN_NAME, TOKEN_DECIMALS, TOKEN_SYMBOL)
        public
    {
        // BK Ok
        transferrers[msg.sender] = true;
    }

    ///-----------------
    /// Overrides
    ///-----------------

    /// Off on deployment.
    // BK Ok
    bool isTransferable = false;

    /// Bonus tokens are locked on deployment
    // BK Ok
    bool isBonusLocked = true;

    /// Allows the owner to transfer tokens whenever, but others to only transfer after owner says so.
    // BK Ok
    modifier canBeTransferred {
        // BK Ok
        require(transferrers[msg.sender] || isTransferable);
        // BK Ok
        _;
    }

    // BK Ok
    function transferReward(
        address _to,
        uint _value
    )
        canBeTransferred
        public
        returns (bool)
    {
        // BK Ok
        require(balances[msg.sender] >= _value);

        // BK Ok
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // BK Ok
        balances[_to] = balances[_to].add(_value);

        // BK Ok
        lockedBalances[_to] = lockedBalances[_to].add(_value);

        // BK Ok - Log event
        Transfer(msg.sender, _to, _value);
        // BK Ok
        return true;
    }

    // BK Ok
    function transfer(
        address _to,
        uint _value
    )
        canBeTransferred
        public
        returns (bool)
    {
        // BK Ok
        require(balances[msg.sender] >= _value);

        /// Only transfer unlocked balance
        // BK Ok
        if(isBonusLocked) {
            // BK Ok
            require(balances[msg.sender].sub(lockedBalances[msg.sender]) >= _value);
        }

        // BK Ok
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // BK Ok
        balances[_to] = balances[_to].add(_value);
        // BK Ok - Log event
        Transfer(msg.sender, _to, _value);
        // BK Ok
        return true;
    }

    // BK Ok
    function transferFrom(
        address _from,
        address _to,
        uint _value
    )
        canBeTransferred
        public
        returns (bool)
    {
        // BK Ok
        require(balances[_from] >= _value);
        // BK Ok
        require(allowed[_from][msg.sender] >= _value);

        /// Only transfer unlocked balance
        // BK Ok
        if(isBonusLocked) {
            // BK Ok
            require(balances[_from].sub(lockedBalances[_from]) >= _value);
        }

        // BK Ok
        allowed[_from][msg.sender] = allowed[_from][_to].sub(_value);
        // BK Ok
        balances[_from] = balances[_from].sub(_value);
        // BK Ok
        balances[_to] = balances[_to].add(_value);
        // BK Ok - Log event
        Transfer(_from, _to, _value);
        // BK Ok
        return true;
    }

    // BK Ok - Constant function
    function lockedBalanceOf(
        address _owner
    )
        constant
        returns (uint)
    {
        // BK Ok
        return lockedBalances[_owner];
    }

    ///-----------------
    /// Admin
    ///-----------------

    // BK Ok - Only owner can execute, and transfers can only be enabled and never disabled after being enabled
    function enableTransfers()
        onlyOwner
        external
        returns (bool)
    {
        // BK Ok
        isTransferable = true;

        // BK Ok
        return isTransferable;
    }

    // BK Ok - Only owner can execute
    function addTransferrer(
        address _transferrer
    )
        public
        onlyOwner
    {
        // BK Ok
        transferrers[_transferrer] = true;
    }


    /**
     * @dev Allow bonus tokens to be withdrawn
     */
    // BK Ok - Only owner can execute, and bonus can only be unlocked and never locked after being unlocked
    function releaseBonus()
        public
        onlyOwner
    {
        // BK Ok
        isBonusLocked = false;
    }

}
```
