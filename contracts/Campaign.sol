pragma solidity ^0.4.18;

import "./traits/Ownable.sol";
import "./referral/TieredPayoff.sol";
import "./referral/Referral.sol";
import "tokens/HumanStandardToken.sol";


/**
 * A {Campaign} represents an advertising campaign.
 */
contract Campaign is Ownable {
    using Referral for Referral.Tree;
    using TieredPayoff for Referral.Tree;

    /// The referral tree (k-ary tree)
    Referral.Tree vyralTree;

    /// Token in use
    HumanStandardToken public token;

    /// Token in use
    uint public budget;

    /// Campaign is always in one of the following states
    enum CampaignState {
        Ready,
        Started,
        Stopped,
        Canceled,
        Completed
    }

    // Current state of the contract
    CampaignState public state;


    /*
     * Modifiers
     */

    modifier inState(CampaignState _state) {
        require(state == _state);
        _;
    }

    modifier notInState(CampaignState _state) {
        require(state != _state);
        _;
    }

    modifier onlyNonZeroAddress(address _a) {
        require(_a != 0);
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

    /// A campaign's state changed
    event LogCampaignStateChanged(address campaign, CampaignState previousState, CampaignState currentState);

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
        token = HumanStandardToken(_token);
        budget = _budgetAmount;

        state = CampaignState.Ready;
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
//        inState(CampaignState.Started)
        onlyNonZeroAddress(_invitee)
//        onlyOnReferral(_invitee)
        onlyIfFundsAvailable()
        returns(uint reward)
    {
        address referrer = vyralTree.getReferrerAddress(_invitee);

        // Referrer was not found, add referrer as a new node
        if(referrer != _referrer) {
            vyralTree.addInvitee(_referrer, owner, 0);
        }

        // Add invitee to the tree
        vyralTree.addInvitee(referrer, _invitee, _shares);

        if(referrer != 0x0) {
            // Referrer exists in the tree
            reward = vyralTree.payoff(referrer, _shares);

            // Transfer reward
            token.transfer(referrer, reward);

            // Log event
            LogRewardAllocated(referrer, _shares, reward);
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
        _referrer = vyralTree.getReferrerAddress(_invitee);
    }

    // Update budget

    /**
     * @dev Returns Reward as a tuple.
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
        _balance = token.balanceOf(this);
    }

    /**
     * Fallback. Don't send ETH to a campaign.
     */
    function() public {
    }
}
