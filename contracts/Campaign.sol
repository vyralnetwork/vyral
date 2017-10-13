pragma solidity ^0.4.15;


import "./traits/Stoppable.sol";
import "./ReferralTree.sol";


/**
 * A {Campaign} represents an advertising campaign.
 */
contract Campaign is Stoppable {

    using ReferralTree for ReferralTree.Tree;

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
    function Campaign() {
        owner = msg.sender;
    }

    // No reward for joining directly.

    /**
     * Fallback. Don't send ETH to a campaign.
     */
    function() {
    }
}
