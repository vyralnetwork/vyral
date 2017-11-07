pragma solidity ^0.4.15;


import "../math/SafeMath.sol";
import "../referral/ReferralTree.sol";
import "./RewardPayoffStrategy.sol";


/**
 * Bonus tiers
 * 1 Vyral Referral - 7% bonus
 * 2 Vyral Referrals - 8% bonus
 * 3 Vyral Referrals - 9% bonus
 * 4 Vyral Referrals - 10% bonus
 * 5 Vyral Referrals - 11% bonus
 * 6 Vyral Referrals - 12% bonus
 * 7 Vyral Referrals - 13% bonus
 * 8 Vyral Referrals - 14% bonus
 * 9 Vyral Referrals - 15% bonus
 * 10 Vyral Referrals - 16% bonus
 * 11 Vyral Referrals - 17% bonus
 * 12 Vyral Referrals - 18% bonus
 * 13 Vyral Referrals - 19% bonus
 * 14 Vyral Referrals - 20% bonus
 * 15 Vyral Referrals - 21% bonus
 * 16 Vyral Referrals - 22% bonus
 * 17 Vyral Referrals - 23% bonus
 * 18 Vyral Referrals - 24% bonus
 * 19 Vyral Referrals - 25% bonus
 * 20 Vyral Referrals - 26% bonus
 * 21 Vyral Referrals - 27% bonus
 * 22 Vyral Referrals - 28% bonus
 * 23 Vyral Referrals - 29% bonus
 * 24 Vyral Referrals - 30% bonus
 * 25 Vyral Referrals - 31% bonus
 * 26 Vyral Referrals - 32% bonus
 * 27 Vyral Referrals - 33% bonus
 */
contract TieredPayoff is RewardPayoffStrategy {

    using SafeMath for uint256;

    mapping (uint8 => uint8) public tiers;

    function TieredPayoff() {
    }

    function payoff(
        address referrer,
        address invitee
    )
        public
        returns (uint256)
    {
        return 0;
    }

    /**
     * Returns bonus percentage for a given number of referrals
     * based on comments above.
     */
    function getBonusPercentage(
        uint8 _referrals
    )
        public
        constant
        returns (uint256)
    {
        if(_referrals == 0) return 0;
        if(_referrals >= 27) return 33;
        return _referrals + 6;
    }
}
