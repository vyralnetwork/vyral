pragma solidity ^0.4.18;

import "./Referral.sol";
import '../math/SafeMath.sol';

/**

Pre-Sale Bonuses
Opens at 11 AM EDT on December 1st
Closes each day at 11:59 PM EDT
Dec 1 - First hour - 70% bonus
Dec 1 - 50%
Dec 2 - 45%
Dec 3 - 44%
Dec 4 - 43%
Dec 5 - 42%
Dec 6 - 41%
Dec 7 - 40%
Dec 8 - 39%
Dec 9 - 38%
Dec 10 - 37%
Dec 11 - 36%
Dec 12 - 35%
Dec 13 - 34%
Dec 14 - 33%
Dec 15 - 32%
Dec 16 - 31%
Dec 17 - 30%
Dec 18 - 29%
Dec 19 - 28%
Dec 20 - 27%
Dec 21 - 25%
Dec 22 - 20%
Dec 23 - 15%

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
        view
        returns (uint)
    {
        Referral.Node memory node = self.nodes[_referrer];
        uint bonusPercentage = getBonusPercentage(node.inviteeIndex.length);
        uint reward = _shares.mul(bonusPercentage).div(100);

        return reward;
    }

    /**
     * Returns bonus percentage for a given number of referrals
     * based on comments above.
     */
    function getBonusPercentage(
        uint _referrals
    )
        public
        pure
        returns (uint)
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
