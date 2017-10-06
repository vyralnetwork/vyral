pragma solidity ^0.4.15;


/**
 * A library contract for implementing payoff vectors.
 */
library RewardAllocation {
    
    
    /**
     *
     */
    enum RewardCharacteristic {
        /// Node is rewarded only for direct referrals but not for its children
        Direct,
        /// Node's ancestors are rewarded (indirect referrals) but invitees are not rewarded at the time of joining
        Geometric,
        /// Reward is distributed equally among the invitee and all of node's ancestors
        Shapley
    }
    
    /**
     * A {Reward} represents the value of a referral. This is the incentive offered by a campaign to both.
     */
    struct Reward {
        /// Unique id of the reward
        bytes32 id;
        /// GigaBytes, Fiat Currency (USD), Tokens etc.
        string units;
        /// The amount being offered
        uint amount;
    }
    
}