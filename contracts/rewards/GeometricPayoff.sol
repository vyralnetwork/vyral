pragma solidity ^0.4.15;


import "../ReferralTree.sol";
import "./RewardPayoffStrategy.sol";


/**
 * Interface contract to implement various reward allocation algorithms
 */
contract GeometricPayoff is RewardPayoffStrategy {

    function payoff(address referrer, address invitee) public returns (uint256) {
        return 0;
    }

}
