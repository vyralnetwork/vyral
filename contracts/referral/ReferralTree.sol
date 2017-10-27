pragma solidity ^0.4.15;

import "./rewards/Reward.sol";
//import "./rewards/RewardPayoffStrategy.sol";

/**
 * A ReferralTree is a diffusion graph of all nodes representing campaign participants.
 * Each invitee is assigned a referral tree after accepting an invitation. Following is
 * an example difussion graph.
 *
 *                                                                  +---+
 *                                                             +--> | 9 |
 *                                                             |    +---+
 *                                                             |
 *                                                             |    +---+
 *                                                 +---+       +--> |10 |
 *                                            +--> | 4 |       |    +---+
 *                                            |    +---+    +--+
 *                                            |  (inactive) |  |    +---+
 *                                            |             |  +--> |11 |
 *                                            |    +---+    |  |    +---+
 *                                       +-------> | 5 +----+  |
 *                                       |    |    +---+       |    +---+
 *                              +----    |    |                +--> |12 |
 *                        +-->  | 1 +----+    |                     +---+
 *                        |     +---+         |    +---+
 *                        |                   +--> | 6 | +------------------>
 *                        |                        +---+
 *               +---+    |     +---+
 *               | 0 | +----->  | 2 |
 *               +---+    |     +---+
 *                        |   (inactive)
 *                        |                        +---+
 *                        |     +---+         +--> | 7 |
 *                        +-->  | 3 +---------+    +---+
 *                              +---+         |
 *                                            |    +---+
 *                                            +--> | 8 |
 *                                                 +---+
 *
 */
library ReferralTree {

    using Reward for Reward.Payment;

    /**
     * A user in a referral graph
     */
    struct VyralNode {
        /// Current user's address
        address node;
        /// This node was referred by...
        address referrer;
        /// Invitees of this node
        address[] invitees;
        /// Reward accumulated
        Reward.Payment payment;
    }

    /**
     * A collection of seed nodes. These are nodes that don't have a referrer.
     */
    struct Tree {
        mapping (address => VyralNode) nodes;
    }

    /**
     * Returns the degree of a node
     */
    function degreeOf (
        Tree storage self,
        address node
    )
        constant
        returns (uint)
    {
        return self.nodes[node].invitees.length;
    }

    /**
     * @dev Creates a new node representing an invitee and adds to a node's list of invitees.
     */
    function addInvitee (
        Tree storage self,
        address _invitee,
        bytes32 _referralKey,
        Reward.Payment memory _payment,
        address _payoffStrategy
    )
        internal
    {
        address _referrer = self.keys[_referralKey];

        VyralNode memory inviteeNode;
        inviteeNode.node = _invitee;
        inviteeNode.referrer = _referrer;
        inviteeNode.referralKey = _referralKey;
        inviteeNode.payment = _payment;

        VyralNode memory referrerNode = self.nodes[_referrer];
        referrerNode.invitees[referrerNode.invitees.length] = _invitee;

        RewardPayoffStrategy rps = RewardPayoffStrategy(_payoffStrategy);
        rps.payoff(_referrer, _invitee);
    }

    /**
     * Find a referral key by an address.
     */
    function splitRewardWithReferrer (
        Tree storage self,
        address _address,
        uint256 _referrerReward,
        uint256 _inviteeReward
    )
        internal
        returns (bytes32 _referralKey)
    {
        VyralNode storage inviteeNode = self.nodes[_address];
        inviteeNode.payment.add(_address, _inviteeReward);

        VyralNode storage referrerNode = self.nodes[inviteeNode.referrer];
        referrerNode.payment.add(_address, _referrerReward);
    }

    /**
     * Find referrer of the given invitee.
     */
    function getReferrerAddress (
        Tree storage self,
        address _inviteeAddress
    )
        constant
        returns (address _referrerAddress)
    {
        VyralNode memory node = self.nodes[_inviteeAddress];
        _referrerAddress = node.referrer;
    }



}
