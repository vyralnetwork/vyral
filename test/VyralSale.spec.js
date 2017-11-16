/**
 * Vyral contract scenarios.
 */
const Share          = artifacts.require("tokens/HumanStandardToken.sol");
const TieredPayoff   = artifacts.require("./rewards/TieredPayoff.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const Web3     = require('web3');
const {assert} = require('chai');

let web3 = new Web3();

contract('Vyral agreements', (accounts) => {

    const [owner, team, partnerships, grace, julia, kevin] = accounts;

    before(async () => {
        this.wallet = await MultiSigWallet.new([owner], 1, {from: owner});

        this.strategy  = await TieredPayoff.deployed();
        this.vyralSale = await VyralSale.new([
            this.wallet.address,
            this.strategy.address,
            team,
            partnerships
        ]);

        let tokenAddr = await this.vyralSale.token.call();
        this.share    = Share.at(tokenAddr);

        let campaignAddr = await this.vyralSale.campaign.call();
        this.campaign    = Campaign.at(campaignAddr);
    });

    describe("Basic sale", () => {

        it("should execute a sale and transfer tokens", async () => {
            await this.vyralSale.buyTokens(grace, {from: julia, value: 1000000000000000});
            let juliaBalance = await this.share.balanceOf.call(julia);
            console.log(juliaBalance.toNumber())
            assert.equal(4825, web3.fromWei(juliaBalance, "ether"));
        });

    });
});
