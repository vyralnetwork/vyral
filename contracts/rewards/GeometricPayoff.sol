pragma solidity ^0.4.15;


import "../ReferralTree.sol";


/**
 * Interface contract to implement various reward allocation algorithms
 */
contract GeometricPayoff {

    function payoff(address referrer, address invitee) public returns (uint256);

}
