# Referral

Source file [../../../contracts/referral/Referral.sol](../../../contracts/referral/Referral.sol).

<br />

<hr />

```javascript
// BK Ok
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
// BK Ok
library Referral {

    /**
     * @dev A user in a referral graph
     */
    // BK Next block Ok
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
    // BK Next block Ok
    struct Tree {
        /// Nodes
        mapping (address => Referral.Node) nodes;
        /// stores keys separately
        address[] treeIndex;
    }

    /**
     * @dev Find referrer of the given invitee.
     */
    // BK Ok - Constant function
    function getReferrer (
        Tree storage self,
        address _invitee
    )
        public
        constant
        returns (address _referrer)
    {
        // BK Ok
        _referrer = self.nodes[_invitee].referrer;
    }

    /**
     * @dev Number of entries in referral tree.
     */
    // BK Ok - Constant function
    function getTreeSize (
        Tree storage self
    )
        public
        constant
        returns (uint _size)
    {
        // BK Ok
        _size = self.treeIndex.length;
    }

    /**
     * @dev Creates a new node representing an invitee and adds to a node's list of invitees.
     */
    // BK Ok - Internal function
    function addInvitee (
        Tree storage self,
        address _referrer,
        address _invitee,
        uint _shares
    )
        internal
    {
        // BK Ok
        Node memory inviteeNode;
        // BK Next 3 Ok
        inviteeNode.referrer = _referrer;
        inviteeNode.shares = _shares;
        inviteeNode.exists = true;
        // BK Ok
        self.nodes[_invitee] = inviteeNode;
        // BK Ok
        self.treeIndex.push(_invitee);

        // BK Ok
        if (self.nodes[_referrer].exists == true) {
            // BK Ok
            self.nodes[_referrer].invitees[_invitee] = _shares;
            // BK Ok
            self.nodes[_referrer].inviteeIndex.push(_invitee);
        }
    }
}

```
