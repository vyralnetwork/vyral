pragma solidity ^0.4.15;

import "./RewardAllocation.sol";

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
    
    
    /**
     * A user in a referral graph
     */
    struct VyralNode {
        /// Current user's address
        address nodeid;
        /// This node was referred by...
        address referrerid;
        /// Invitees of this node
        address[] inviteeids;
        /// The key to be shared to receive rewards
        bytes32 referralKey;
        /// Reward accumulated
        RewardAllocation.Reward reward;
    }

    /**
     * A collection of seed nodes. These are nodes that don't have a referrer.
     */
    struct Tree {
        mapping (address => VyralNode) nodes;
    }


    /**
     * @dev Creates a new node representing an invitee and adds to a node's list of invitees.
     */
    function addInvitee (
        Tree storage tree,
        address referrerid,
        address inviteeid,
        bytes32 referralKey,
        RewardAllocation.Reward memory reward
    )
        internal
    {
        VyralNode memory inviteeNode;
        inviteeNode.nodeid = inviteeid;
        inviteeNode.referrerid = referrerid;
        inviteeNode.referralKey = referralKey;
        inviteeNode.reward = reward;

        VyralNode referrerNode = tree.nodes[referrerid];
        referrerNode.inviteeids[inviteeids.length] = inviteeid;
    }

}
