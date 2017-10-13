pragma solidity ^0.4.15;


import "./traits/Stoppable.sol";
import "./rewards/Reward.sol";
import "./ReferralTree.sol";


/**
 * A {Campaign} represents an advertising campaign.
 */
contract Campaign is Stoppable {

    using Reward for Reward.Payment;

    using ReferralTree for ReferralTree.Tree;

    Reward.Payment budget;

    Reward.Payment reward;

    ReferralTree.Tree vyralTree;

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

    modifier onlyOnReferral(bytes32 referralKey) {
        require(vyralTree.keys[referralKey] != 0x0);
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
    function Campaign(string _units, uint256 _amount, uint256 _reward) {
        owner = msg.sender;

        budget = Reward.Payment({
            units: _units,
            amount: _amount
        });

        budget = Reward.Payment({
            units: _units,
            amount: _reward
        });
    }

    /**
     * Accept invitation and join contract.
     */
    function join (
        bytes32 referralKey
    )
    public
    payable
    inState(CampaignState.Started)
    onlyOnReferral(referralKey)
    onlyIfFundsAvailable()
    {
        vyralTree.addInvitee(msg.sender, referralKey, reward);
    }


    /**
     * Fallback. Don't send ETH to a campaign.
     */
    function() {
    }
}
