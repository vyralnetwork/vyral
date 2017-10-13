pragma solidity ^0.4.15;


import "./traits/Ownable.sol";
import "./Campaign.sol";


/**
 * The driver contract.
 */
contract Vyral is Ownable {


    /// A collection of Campaigns
    Campaign[] public campaigns;

    /**
     * One of a kind.
     */
    function Vyral() {
        owner = msg.sender;
    }

    /**
     * Owner can add a campaign.
     */
    function addCampaign(Campaign campaign) onlyOwner {
        campaigns.push(campaign);
    }

    /**
     * Creates a new campaign on behalf of campaign director. Returns campaign address.
     */
    function newCampaign()
    public
    onlyOwner
    returns (address)
    {
        Campaign campaign = new Campaign();
        campaigns.push(campaign);
        return (campaign);
    }

    /**
     * Number of campaigns created so far
     */
    function campaignCount() constant returns (uint) {
        return campaigns.length;
    }

    /**
     * Retrieve campaign at a given index.
     */
    function campaignAt(uint index) constant returns (Campaign) {
        assert(index >= 0);
        return campaigns[index];
    }

}
