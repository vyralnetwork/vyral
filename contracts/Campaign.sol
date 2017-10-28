pragma solidity ^0.4.15;


import "./traits/Stoppable.sol";
import "./tokens/ERC20.sol";
import "./rewards/Reward.sol";
//import "./rewards/RewardPayoffStrategy.sol";
//import "./rewards/RewardAllocation.sol";
import "./referral/ReferralTree.sol";


/**
 * A {Campaign} represents an advertising campaign.
 */
contract Campaign is Stoppable {

    using Reward for Reward.Payment;

    using ReferralTree for ReferralTree.Tree;

    /// Budget from which rewards are paid out
    Reward.Payment budget;

    /// Incentive offered for joining the campaign
    Reward.Payment reward;

    /// The referral tree (k-ary tree)
    ReferralTree.Tree vyralTree;

    /// Which payoff method to use?
    address payoffStrategy;

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

    modifier onlyOnReferral(address _referrer) {
        require(getReferrer() != 0x0);
        _;
    }

    modifier onlyIfFundsAvailable() {
        require(budget.amount >= reward.amount);
        _;
    }


    /*
     * Events
     */

    /// A new campaign was created
    event CampaignCreated(address campaign);

    /// A campaign's state changed
    event CampaignStateChanged(address campaign, CampaignState previousState, CampaignState currentState);


    /**
     * Create a new campaign.
     */
    function Campaign (
        address _token,
        uint256 _budgetAmount,
        uint256 _rewardAmount,
        address _payoffStrategy
    )
        public
    {
        budget = Reward.Payment({
            token: ERC20(_token),
            amount: _budgetAmount
        });

        reward = Reward.Payment({
            token: ERC20(_token),
            amount: _rewardAmount
        });

        payoffStrategy = _payoffStrategy;

        state = CampaignState.Ready;
    }

    /**
     * Accept invitation and join contract.
     */
    function join (
        address _referrer
    )
        public
        inState(CampaignState.Started)
        onlyNonZeroAddress(_referrer)
        onlyOnReferral(_referrer)
        onlyIfFundsAvailable()
    {
        vyralTree.addInvitee(msg.sender, _referrer, reward, payoffStrategy);
    }

    /**
     * Return referral key of caller.
     */
    function getReferrer()
        constant
        returns (address _referrer)
    {
        _referrer = vyralTree.getReferrerAddress(msg.sender);
    }

    // Update budget

    // Compute key in the contract

    /**
     * Fallback. Don't send ETH to a campaign.
     */
    function() {
    }
}
