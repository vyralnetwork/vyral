# Campaign

Source file [../../contracts/Campaign.sol](../../contracts/Campaign.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Next 5 Ok
import "./math/SafeMath.sol";
import "./traits/Ownable.sol";
import "./referral/TieredPayoff.sol";
import "./referral/Referral.sol";
import "./Share.sol";


/**
 * A {Campaign} represents an advertising campaign.
 */
// BK Ok
contract Campaign is Ownable {
    // BK Ok
    using SafeMath for uint;
    // BK Ok
    using Referral for Referral.Tree;
    // BK Ok
    using TieredPayoff for Referral.Tree;

    /// The referral tree (k-ary tree)
    // BK Ok
    Referral.Tree vyralTree;

    /// Token in use
    // BK Ok
    Share public token;

    /// Budget of the campaign
    // BK Ok
    uint public budget;

    /// Tokens spent
    // BK Ok
    uint public cost;

    /*
     * Modifiers
     */

    // BK Ok
    modifier onlyNonZeroAddress(address _a) {
        // BK Ok
        require(_a != 0);
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyNonSelfReferral(address _referrer, address _invitee) {
        // BK Ok
        require(_referrer != _invitee);
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyOnReferral(address _invitee) {
        // BK Ok
        require(getReferrer(_invitee) != 0x0);
        // BK Ok
        _;
    }

    // BK Ok
    modifier onlyIfFundsAvailable() {
        // BK Ok
        require(getAvailableBalance() >= 0);
        // BK Ok
        _;
    }


    /*
     * Events
     */

    /// A new campaign was created
    // BK Ok - Event
    event LogCampaignCreated(address campaign);

    /// Reward allocated
    // BK Ok - Event
    event LogRewardAllocated(address referrer, uint inviteeShares, uint referralReward);


    /**
     * Create a new campaign.
     */
    // BK Ok - Constructor
    function Campaign(
        address _token,
        uint256 _budgetAmount
    )
        public
    {
        // BK Ok
        token = Share(_token);
        // BK Ok
        budget = _budgetAmount;
    }

    /**
     * @dev Accept invitation and join contract. If referrer address is non-zero,
     * calculate reward and transfer tokens to referrer. Referrer address will be
     * zero if referrer is not found in the referral tree. Don't throw in such a
     * scenario.
     */
    // BK Ok - Only owner (VyralSale) can execute
    function join(
        address _referrer,
        address _invitee,
        uint _shares
    )
        public
        onlyOwner
        onlyNonZeroAddress(_invitee)
        onlyNonSelfReferral(_referrer, _invitee)
        onlyIfFundsAvailable()
        returns(uint reward)
    {
        // BK Ok
        Referral.Node memory referrerNode = vyralTree.nodes[_referrer];

        // Referrer was not found, add referrer as a new node
        // BK Ok
        if(referrerNode.exists == false) {
            // BK Ok
            vyralTree.addInvitee(owner, _referrer, 0);
        }

        // Add invitee to the tree
        // BK Ok
        vyralTree.addInvitee(_referrer, _invitee, _shares);

        // Calculate referrer's reward
        // BK Ok
        reward = vyralTree.payoff(_referrer);

        // Log event
        // BK Ok - Log event
        LogRewardAllocated(_referrer, _shares, reward);
    }

    /**
     * VyralSale (owner) transfers rewards on behalf of this contract.
     */
    // BK Ok - Only owner (VyralSale) can execute
    function sendReward(address _who, uint _amount)
        onlyOwner //(ie, VyralSale)
        external returns (bool)
    {
        // BK Ok
        if(getAvailableBalance() >= _amount) {
            // BK Ok
            token.transferReward(_who, _amount);
            // BK Ok
            cost = cost.add(_amount);
            // BK Ok
            return true;
        // BK Ok
        } else {
            // BK Ok
            return false;
        }
    }

    /**
     * Return referral key of caller.
     */
    // BK Ok - Constant function
    function getReferrer(
        address _invitee
    )
        public
        constant
        returns (address _referrer)
    {
        // BK Ok
        _referrer = vyralTree.getReferrer(_invitee);
    }

    /**
     * @dev Returns the size of the Referral Tree.
     */
    // BK Ok - Constant function
    function getTreeSize()
        public
        constant
        returns (uint _size)
    {
        // BK Ok
        _size = vyralTree.getTreeSize();
    }

    /**
     * @dev Returns the budget as a tuple, (token address, amount)
     */
    // BK Ok - Constant function
    function getBudget()
        public
        constant
        returns (address _token, uint _amount)
    {
        // BK Ok
        _token = token;
        // BK Ok
        _amount = budget;
    }

    /**
     * @dev Return (budget - cost)
     */
    // BK Ok - Constant function
    function getAvailableBalance()
        public
        constant
        returns (uint _balance)
    {
        // BK Ok
        _balance = (budget - cost);
    }

    /**
     * Fallback. Don't send ETH to a campaign.
     */
    // BK Ok - Don't accept ETH
    function() public {
        // BK Ok
        revert();
    }
}

```
