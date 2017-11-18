pragma solidity ^0.4.18;

import "./Referral.sol";
import '../math/SafeMath.sol';

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
library TieredPayoff {
    using SafeMath for uint;

    /**
     * Tiered payoff computes reward based on number of invitees a referrer has brought in.
     * Returns the reward or the number of tokens referrer should be awarded.
     */
    function payoff(
        Referral.Tree storage self,
        address _referrer,
        uint _shares
    )
        public
        returns (uint)
    {
        Referral.Node memory node = self.nodes[_referrer];
        uint16 bonusPercentage = getBonusPercentage(node.degree);
        uint reward = _shares.mul(bonusPercentage).div(100);

        return reward;
    }

    /**
     * Returns bonus percentage for a given number of referrals
     * based on comments above.
     */
    function getBonusPercentage(
        uint16 _referrals
    )
        public
        pure
        returns (uint16)
    {
        if (_referrals == 0) {
            return 0;
        }
        if (_referrals >= 27) {
            return 33;
        }
        return _referrals + 6;
    }
}
