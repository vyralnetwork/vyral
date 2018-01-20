# TieredPayoff

Source file [../../../contracts/referral/TieredPayoff.sol](../../../contracts/referral/TieredPayoff.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Next 2 Ok
import "./Referral.sol";
import '../math/SafeMath.sol';

/**
 * Bonus tiers
 *  1 Vyral Referral - 7% bonus
 *  2 Vyral Referrals - 8% bonus
 *  3 Vyral Referrals - 9% bonus
 *  4 Vyral Referrals - 10% bonus
 *  5 Vyral Referrals - 11% bonus
 *  6 Vyral Referrals - 12% bonus
 *  7 Vyral Referrals - 13% bonus
 *  8 Vyral Referrals - 14% bonus
 *  9 Vyral Referrals - 15% bonus
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
// BK Ok
library TieredPayoff {
    // BK Ok
    using SafeMath for uint;

    /**
     * Tiered payoff computes reward based on number of invitees a referrer has brought in.
     * Returns the reward or the number of tokens referrer should be awarded.
     *
     * For degree == 1:
     * tier% of shares of newly joined node
     *
     * For 2 <= degree < 27:
     *   k-1
     * (  ∑  1% of shares(node_i) )  + tier% of shares of node_k
     *   i=1
     *
     * For degree > 27:
     * tier% of shares of newly joined node
     */
    // BK Ok - View function
    function payoff(
        Referral.Tree storage self,
        address _referrer
    )
        public
        view
        returns (uint)
    {
        // BK Ok
        Referral.Node node = self.nodes[_referrer];

        // BK Ok
        if(!node.exists) {
            // BK Ok
            return 0;
        }

        // BK Next 2 Ok
        uint reward = 0;
        uint shares = 0;
        // BK Ok
        uint degree = node.inviteeIndex.length;
        // BK Ok
        uint tierPercentage = getBonusPercentage(node.inviteeIndex.length);

        // No bonus if there are no invitees
        // BK Ok
        if(degree == 0) {
            // BK Ok
            return 0;
        }

        // BK Ok
        assert(tierPercentage > 0);

        // BK Ok
        if(degree == 1) {
            // BK Ok
            shares = node.invitees[node.inviteeIndex[0]];
            // BK Ok
            reward = reward.add(shares.mul(tierPercentage).div(100));
            // BK Ok
            return reward;
        }


        // For 2 <= degree <= 27
        //    add 1% from the first k-1 nodes
        //    add tier% from the last node
        // BK Ok
        if(degree >= 2 && degree <= 27) {
            // BK Ok
            for (uint i = 0; i < (degree - 1); i++) {
                // BK Ok
                shares = node.invitees[node.inviteeIndex[i]];
                // BK Ok
                reward = reward.add(shares.mul(1).div(100));
            }
        }

        // For degree > 27, referrer bonus remains constant at tier%
        // BK Ok
        shares = node.invitees[node.inviteeIndex[degree - 1]];
        // BK Ok
        reward = reward.add(shares.mul(tierPercentage).div(100));

        // BK Ok
        return reward;
    }

    /**
     * Returns bonus percentage for a given number of referrals
     * based on comments above.
     */
    // BK Ok - Pure function
    function getBonusPercentage(
        uint _referrals
    )
        public
        pure
        returns (uint)
    {
        // BK Ok
        if (_referrals == 0) {
            // BK Ok
            return 0;
        }
        // BK Ok
        if (_referrals >= 27) {
            // BK Ok
            return 33;
        }
        // BK Ok
        return _referrals + 6;
    }
}

```
