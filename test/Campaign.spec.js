/**
 * Vyral campaign scenarios.
 */
const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');
const Campaign       = artifacts.require("./Campaign.sol");
const TieredPayoff   = artifacts.require("./rewards/TieredPayoff.sol");

const {assert} = require('chai');

contract('Campaign', function(accounts) {

    let coinbase = accounts[0];
    let owner1   = accounts[1];
    let owner2   = accounts[2];
    //
    // before(async () => {
    //     let wallet    = await MultiSigWallet.new([owner1, owner2], 2, {from: coinbase});
    //     this.strategy = await TieredPayoff.deployed();
    //     this.campaign = await Campaign.new([this.share.address, 1000, this.strategy.address]);
    // });
    //
    // it('should initialize Campaign', async () => {
    //     assert.notNull(this.campaign.address);
    // });
    //
    // it('should return campaign budget', async () => {
    //     let budget = await campaign.getBudget();
    //     assert.equal(1000, budget[1].toNumber());
    // });
    //
    // it('should return balance of campaign when it was created', async () => {
    //     let balance = await campaign.getAvailableBalance();
    //     assert.equal(1000, balance.toNumber());
    // });

});