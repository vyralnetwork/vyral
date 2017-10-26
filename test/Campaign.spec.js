/**
 * Vyral contract scenarios.
 */
let Vyral    = artifacts.require("./Vyral.sol");
let Campaign = artifacts.require("./Campaign.sol");

let ethutil = require("ethereumjs-util");
let config  = require("../config");

const {assert} = require('chai');

contract('Campaign ', function(accounts) {

    it('should initialize Vyral', async () => {
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