pragma solidity ^0.4.15;


import "../math/SafeMath.sol";
import "../ReferralTree.sol";
import "./RewardPayoffStrategy.sol";


/**
 * Interface contract to implement various reward allocation algorithms
 */
contract DirectPayoff is RewardPayoffStrategy {

    using SafeMath for uint256;

    function payoff (
        address referrer,
        address invitee
    )
        public
        returns (uint256)
    {
        return 0;
    }

}
