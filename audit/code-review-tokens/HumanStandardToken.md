# HumanStandardToken

Source file [../../installed_contracts/tokens/contracts/HumanStandardToken.sol](../../installed_contracts/tokens/contracts/HumanStandardToken.sol).

<br />

<hr />

```javascript
/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/

// BK Ok - Could increase the version number, but this may not be required with the flattening of the files
pragma solidity ^0.4.8;

// BK Ok
import "installed_contracts/tokens/contracts/StandardToken.sol";

// BK Ok
contract HumanStandardToken is StandardToken {

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    // BK Ok
    string public name;                   //fancy name: eg Simon Bucks
    // BK Ok
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    // BK Ok
    string public symbol;                 //An identifier: eg SBX
    // BK Ok
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.

    // BK Ok - Constructor
    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        // BK Ok
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        // BK Ok
        totalSupply = _initialAmount;                        // Update total supply
        // BK NOTE - Should have a `Transfer(address(0), msg.sender, _initialAmount)` here
        // BK Ok
        name = _tokenName;                                   // Set the name for display purposes
        // BK Ok
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        // BK Ok
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    // BK Ok
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        // BK Ok
        allowed[msg.sender][_spender] = _value;
        // BK Ok - Log event
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        // BK Ok
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        // BK Ok
        return true;
    }
}

```
