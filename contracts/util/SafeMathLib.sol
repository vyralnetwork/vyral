pragma solidity ^0.4.0;


/**
 * From https://raw.githubusercontent.com/AragonOne/zeppelin-solidity/master/contracts/SafeMathLib.sol
 */
library SafeMathLib {

    function times(uint a, uint b) returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function minus(uint a, uint b) returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function plus(uint a, uint b) returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}
