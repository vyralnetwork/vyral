pragma solidity ^0.4.18;

import "./rewards/Reward.sol";

import '../node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol';
import '../node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';

//import "./rewards/RewardPayoffStrategy.sol";
import "./referral/ReferralTree.sol";

/**
 * A {Campaign} represents an advertising campaign.
 */
contract Campaign is Pausable {
    using Reward for Reward.Payment;
    using ReferralTree for ReferralTree.Tree;

    /// Budget from which rewards are paid out
    Reward.Payment budget;

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
        require(getAvailableBalance() >= 0);
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
    function Campaign(
        address _token,
        uint256 _budgetAmount,
        address _payoffStrategy
    )
        public
    {
        budget = Reward.Payment({
        token : StandardToken(_token),
        amount : _budgetAmount
        });

        payoffStrategy = _payoffStrategy;

        state = CampaignState.Ready;
    }

    /**
     * Accept invitation and join contract.
     */
    function join(
        address _referrer
    )
        public
        inState(CampaignState.Started)
        onlyNonZeroAddress(_referrer)
        onlyOnReferral(_referrer)
        onlyIfFundsAvailable()
    {
        vyralTree.addInvitee(msg.sender, _referrer, payoffStrategy);
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

    /**
     * @dev Returns Reward as a tuple.
     */
    function getBudget()
        constant
        returns (address _token, uint _amount)
    {
        _token = address(budget.token);
        _amount = budget.amount;
    }

    /**
     * @dev Return (budget - cost)
     */
    function getAvailableBalance()
        constant
        returns (uint _balance)
    {
        _balance = 56789;
    }

    /**
     * Fallback. Don't send ETH to a campaign.
     */
    function() {
    }
}
