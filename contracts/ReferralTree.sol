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


/*

1) incentive strategies which we are working on
2) campaign analytics or metrics to show/predict effectiveness of a campaign
3) cost analysis of marketing - e.g. is giving away GBs helping or hurting you?
4) governance of a campaign - wallets to receive funds raised from campaign, who can receive funds raised, who can be delegated to run the campaign
5) campaign lifecycle - when does a campaign start? Immediately, at a certain block, at a certain time? Can it be stopped? Can it resume? I've added a "stoppable" contract to suspend campaign in an emergency
6) we need measures to be able to suspend a campaign and revert funds if we suspect a campaign is illegal or somehow morally/ethically wrong
7) Proof or game theoretical analysis of any strategy we propose


*/


