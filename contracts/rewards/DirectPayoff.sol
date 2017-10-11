pragma solidity ^0.4.15;


import "../util/SafeMathLib.sol";
import "../ReferralTree.sol";
import "./RewardPayoffStrategy.sol";


/**
 * Interface contract to implement various reward allocation algorithms
 */
contract DirectPayoff is RewardPayoffStrategy {

    using SafeMathLib for uint;

    function payoff(address referrer, address invitee) public returns (uint) {
        return 0;
    }

}
