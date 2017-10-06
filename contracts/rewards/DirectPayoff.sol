pragma solidity ^0.4.15;


import "../ReferralTree.sol";


/**
 * Interface contract to implement various reward allocation algorithms
 */
contract DirectPayoff {

    function payoff(address referrer, address invitee) public returns (uint256) {
        return 0;
    }

}
