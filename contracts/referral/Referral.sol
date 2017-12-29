pragma solidity ^0.4.18;

/**
 * A referral tree is a diffusion graph of all nodes representing campaign participants.
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
library Referral {

    /**
     * @dev A user in a referral graph
     */
    struct Node {
        /// This node was referred by...
        address referrer;
        /// Invitees (and their shares) of this node
        mapping (address => uint) invitees;
        /// Store keys separately
        address[] inviteeIndex;
        /// Reward accumulated
        uint shares;
        /// Used for membership check
        bool exists;
    }

    /**
     * @dev A referral tree is a collection of Nodes.
     */
    struct Tree {
        /// Nodes
        mapping (address => Referral.Node) nodes;
        /// stores keys separately
        address[] treeIndex;
    }

    /**
     * @dev Find referrer of the given invitee.
     */
    function getReferrer (
        Tree storage self,
        address _invitee
    )
        public
        constant
        returns (address _referrer)
    {
        _referrer = self.nodes[_invitee].referrer;
    }

    /**
     * @dev Number of entries in referral tree.
     */
    function getTreeSize (
        Tree storage self
    )
        public
        constant
        returns (uint _size)
    {
        _size = self.treeIndex.length;
    }

    /**
     * @dev Creates a new node representing an invitee and adds to a node's list of invitees.
     */
    function addInvitee (
        Tree storage self,
        address _referrer,
        address _invitee,
        uint _shares
    )
        internal
    {
        Node memory inviteeNode;
        inviteeNode.referrer = _referrer;
        inviteeNode.shares = _shares;
        inviteeNode.exists = true;
        self.nodes[_invitee] = inviteeNode;
        self.treeIndex.push(_invitee);

        if (self.nodes[_referrer].exists == true) {
            self.nodes[_referrer].invitees[_invitee] = _shares;
            self.nodes[_referrer].inviteeIndex.push(_invitee);
        }
    }
}
