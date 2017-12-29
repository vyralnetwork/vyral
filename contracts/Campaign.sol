pragma solidity ^0.4.18;

import "./math/SafeMath.sol";
import "./traits/Ownable.sol";
import "./referral/TieredPayoff.sol";
import "./referral/Referral.sol";
import "./Share.sol";


/**
 * A {Campaign} represents an advertising campaign.
 */
contract Campaign is Ownable {
    using SafeMath for uint;
    using Referral for Referral.Tree;
    using TieredPayoff for Referral.Tree;

    /// The referral tree (k-ary tree)
    Referral.Tree vyralTree;

    /// Token in use
    Share public token;

    /// Budget of the campaign
    uint public budget;

    /// Tokens spent
    uint public cost;

    /*
     * Modifiers
     */

    modifier onlyNonZeroAddress(address _a) {
        require(_a != 0);
        _;
    }

    modifier onlyNonSelfReferral(address _referrer, address _invitee) {
        require(_referrer != _invitee);
        _;
    }

    modifier onlyOnReferral(address _invitee) {
        require(getReferrer(_invitee) != 0x0);
        _;
    }

    modifier onlyIfFundsAvailable() {
        require(getAvailableBalance() >= 0);
        _;
    }


    /*
     * Events
     */

    /// A new campaign was created
    event LogCampaignCreated(address campaign);

    /// Reward allocated
    event LogRewardAllocated(address referrer, uint inviteeShares, uint referralReward);


    /**
     * Create a new campaign.
     */
    function Campaign(
        address _token,
        uint256 _budgetAmount
    )
        public
    {
        token = Share(_token);
        budget = _budgetAmount;
    }

    /**
     * @dev Accept invitation and join contract. If referrer address is non-zero,
     * calculate reward and transfer tokens to referrer. Referrer address will be
     * zero if referrer is not found in the referral tree. Don't throw in such a
     * scenario.
     */
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
        Referral.Node memory referrerNode = vyralTree.nodes[_referrer];

        // Referrer was not found, add referrer as a new node
        if(referrerNode.exists == false) {
            vyralTree.addInvitee(owner, _referrer, 0);
        }

        // Add invitee to the tree
        vyralTree.addInvitee(_referrer, _invitee, _shares);

        // Calculate referrer's reward
        reward = vyralTree.payoff(_referrer);

        // Log event
        LogRewardAllocated(_referrer, _shares, reward);
    }

    /**
     * VyralSale (owner) transfers rewards on behalf of this contract.
     */
    function sendReward(address _who, uint _amount)
        onlyOwner //(ie, VyralSale)
        external returns (bool)
    {
        if(getAvailableBalance() >= _amount) {
            token.transferReward(_who, _amount);
            cost = cost.add(_amount);
            return true;
        } else {
            return false;
        }
    }

    /**
     * Return referral key of caller.
     */
    function getReferrer(
        address _invitee
    )
        public
        constant
        returns (address _referrer)
    {
        _referrer = vyralTree.getReferrer(_invitee);
    }

    /**
     * @dev Returns the size of the Referral Tree.
     */
    function getTreeSize()
        public
        constant
        returns (uint _size)
    {
        _size = vyralTree.getTreeSize();
    }

    /**
     * @dev Returns the budget as a tuple, (token address, amount)
     */
    function getBudget()
        public
        constant
        returns (address _token, uint _amount)
    {
        _token = token;
        _amount = budget;
    }

    /**
     * @dev Return (budget - cost)
     */
    function getAvailableBalance()
        public
        constant
        returns (uint _balance)
    {
        _balance = (budget - cost);
    }

    /**
     * Fallback. Don't send ETH to a campaign.
     */
    function() public {
        revert();
    }
}
