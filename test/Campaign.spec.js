/**
 * Vyral campaign scenarios.
 */
const VyralSale = artifacts.require("./VyralSale.sol");
const Campaign  = artifacts.require("./Campaign.sol");
const Share     = artifacts.require("./Share.sol");

let ethutil = require("ethereumjs-util");
let config  = require("../config");

const {assert} = require('chai');

contract('Campaign', function(accounts) {

    before(async () => {
        this.share  = await Share.deployed();
    });

    it('should initialize Campaign', async () => {
        let vyral = await Vyral.new();
        assert.equal(await vyral.campaignCount(), 0);
    });


    it('should create a new campaign', async () => {
        let vyral    = await Vyral.new({from: accounts[0]});
        let campaign = await Campaign.new();

        assert.equal(await vyral.campaignCount(), 0);

        await vyral.addCampaign(campaign.address);

        assert.equal(await vyral.campaignCount(), 1);
    });

    it('should join a campaign', async () => {
        let campaign    = await Campaign.new();
        let campaignAbi = require("../build/contracts/Campaign.json");

        // var encoded     = abi.encode(campaignAbi, "join(bytes32 _referralKey)", [""]);
        let referralKey = ethutil.bufferToHex(new Buffer('TESTONLY-TESTONLY'));
        let encoded     = config.web3.eth.abi.encodeFunctionCall({
            name: 'join',
            type: 'function',
            inputs: [{
                type: 'bytes32',
                name: '_referralKey'
            }]
        }, [referralKey]);

        console.log(encoded);


        let decoded = config.web3.eth.abi.decodeParameters([{
            type: 'bytes32',
            name: '_referralKey'
        }], encoded);
        console.log(decoded);
    });
});