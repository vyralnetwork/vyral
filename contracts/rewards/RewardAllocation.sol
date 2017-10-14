pragma solidity ^0.4.15;


/**
 * A library contract for implementing payoff vectors.
 */
library RewardAllocation {


    /**
     *
     */
    enum Characteristic {
        /// Node is rewarded only for direct referrals but not for its children
        Direct,
        /// Node's ancestors are rewarded (indirect referrals) but invitees are not rewarded at the time of joining
        Geometric,
        /// Reward is distributed equally among the invitee and all of node's ancestors
        Shapley
    }


    function allocate(address rewardCharacteristic) {

    }
}