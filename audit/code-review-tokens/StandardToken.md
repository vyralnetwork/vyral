# StandardToken

Source file [../../installed_contracts/tokens/contracts/StandardToken.sol](../../installed_contracts/tokens/contracts/StandardToken.sol).

<br />

<hr />

```javascript
/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won't have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/
// BK Ok - Could increase the version number, but this may not be required with the flattening of the files
pragma solidity ^0.4.8;

// BK Ok
import "installed_contracts/tokens/contracts/Token.sol";

// BK Ok
contract StandardToken is Token {

    // BK Ok
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        // BK Ok
        require(balances[msg.sender] >= _value);
        // BK Ok
        balances[msg.sender] -= _value;
        // BK Ok
        balances[_to] += _value;
        // BK Ok - Log event
        Transfer(msg.sender, _to, _value);
        // BK Ok
        return true;
    }

    // BK Ok
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        // BK Ok
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        // BK NOTE - Better practice to have the 2 subtractions before the addition
        // BK Ok
        balances[_to] += _value;
        // BK Ok
        balances[_from] -= _value;
        // BK Ok
        allowed[_from][msg.sender] -= _value;
        // BK Ok - Log event
        Transfer(_from, _to, _value);
        // BK Ok
        return true;
    }

    // BK Ok - Constant function
    function balanceOf(address _owner) constant returns (uint256 balance) {
        // BK Ok
        return balances[_owner];
    }

    // BK Ok
    function approve(address _spender, uint256 _value) returns (bool success) {
        // BK Ok
        allowed[msg.sender][_spender] = _value;
        // BK Ok - Log event
        Approval(msg.sender, _spender, _value);
        // BK Ok
        return true;
    }

    // BK Ok - Constant function
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      // BK Ok
      return allowed[_owner][_spender];
    }

    // BK Next 2 Ok
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

```
