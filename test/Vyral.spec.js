/**
 * Vyral contract scenarios.
 */
let Vyral    = artifacts.require("./Vyral.sol");
let Campaign = artifacts.require("./Campaign.sol");

const {assert}  = require('chai');

contract('Vyral agreements', function(accounts) {

    beforeEach(async () => {
    });

    it('should initialize Vyral', async () => {
        let vyral = await Vyral.new();
        assert.equal(await vyral.campaignCount(), 0);
    });


    it('should create a new campaign', async () => {
        let vyral    = await Vyral.new({ from: accounts[0] });
        let campaign = await Campaign.new();

        assert.equal(await vyral.campaignCount(), 0);

        await vyral.addCampaign(campaign.address);

        assert.equal(await vyral.campaignCount(), 1);
    });
});