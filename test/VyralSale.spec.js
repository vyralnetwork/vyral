/**
 * Vyral contract scenarios.
 */
const Share          = artifacts.require("tokens/HumanStandardToken.sol");
const TieredPayoff   = artifacts.require("./rewards/TieredPayoff.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require("multisig-wallet/MultiSigWallet.sol");

const BigNumber = require("bignumber.js");
const {assert}  = require("chai");

const config = require("../config");

contract("Vyral agreements", (accounts) => {

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
            await this.vyralSale.buyTokens(grace, {from: julia, value: 1});
            let juliaBalance = await this.share.balanceOf.call(julia);
            let saleBalance = await this.share.balanceOf.call(this.vyralSale.address);
            let campaignBalance = await this.vyralSale.THREE_SEVENTHS.call();

            assert.equal(4285, juliaBalance.toNumber());
            assert.isTrue(campaignBalance.equals(juliaBalance.plus(saleBalance)));
        });

    });
});
