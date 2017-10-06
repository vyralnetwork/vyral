pragma solidity ^0.4.15;

import "./rewards/Reward.sol";

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
    function degreeOf(Tree storage tree, address nodeid) constant returns (uint) {
        return tree.nodes[nodeid].inviteeids.length;
    }

    /**
     * @dev Creates a new node representing an invitee and adds to a node's list of invitees.
     */
    function addInvitee (
        Tree storage tree,
        address referrerid,
        address inviteeid,
        bytes32 referralKey,
        Reward.Payment memory payment
    )
        internal
    {
        VyralNode memory inviteeNode;
        inviteeNode.nodeid = inviteeid;
        inviteeNode.referrerid = referrerid;
        inviteeNode.referralKey = referralKey;
        inviteeNode.payment = payment;

        VyralNode storage referrerNode = tree.nodes[referrerid];
        referrerNode.inviteeids[referrerNode.inviteeids.length] = inviteeid;
    }

}
