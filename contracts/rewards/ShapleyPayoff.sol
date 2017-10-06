pragma solidity ^0.4.15;


import "../ReferralTree.sol";


/**
 * Interface contract to implement various reward allocation algorithms
 */
contract ShapleyPayoff {

    function payoff(address referrer, address invitee) public returns (uint256);

}
