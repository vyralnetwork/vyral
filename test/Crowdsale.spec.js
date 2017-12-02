/**
 * Vyral contract scenarios.
 */
const Share          = artifacts.require("./Share.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require("./MultiSigWallet.sol");

const moment    = require("moment");
const BigNumber = require("bignumber.js");
const {assert}  = require("chai");

require("chai")
.use(require("chai-as-promised"))
.should();

const expect = require("chai").expect;
const config = require("../config");

let saleRate;

function timeTravel(time) {
    return new Promise((resolve, reject) => {
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_increaseTime",
            params: [time], // 86400 is num seconds in day
            id: new Date().getTime()
        }, (err, result) => {
            if(err) {
                return reject(err)
            }
            return resolve(result)
        });
    })
}

contract("Vyral Crowdsale", (accounts) => {

    const [owner, alice, bob, charlie, dave, emma, faith, grace, henry, issac] = accounts;

    before(async () => {
        this.vyralSale = await VyralSale.deployed();
        this.share     = await Share.deployed();

        let campaignAddr = await this.vyralSale.campaign.call();
        this.campaign    = Campaign.at(campaignAddr);

        await this.vyralSale.startPresale({from: owner});
        await this.vyralSale.endPresale({from: owner});

        await this.vyralSale.initSale(
        config.get("crowdsale:startTime"),
        config.get("crowdsale:endTime"),
        config.get("rate"), {from: owner});

        await this.vyralSale.startSale({from: owner});

        /// Let's take a ride in the Delorean...
        const saleStartTime = await this.vyralSale.saleStartTimestamp.call();
        timeTravel(saleStartTime.toNumber());

        saleRate = await this.vyralSale.saleRate.call();

    });

    describe("Basic sale", () => {

        it("should initialize sale", async () => {
            expect((await this.vyralSale.phase.call()).toNumber())
            .to.equal(5);

            const saleStartTime = await this.vyralSale.saleStartTimestamp.call();
            const saleEndTime   = await this.vyralSale.saleEndTimestamp.call();

            assert(saleEndTime.toNumber() != 0 && saleStartTime.toNumber() != 0);

            expect(saleStartTime.toNumber())
            .to.be.below(saleEndTime.toNumber());
        });

        it("should execute a sale and transfer tokens", async () => {
            /// Take this down really quick
            const aliceBalBefore = await this.share.balanceOf(alice);
            const saleBalBefore  = await this.share.balanceOf(this.vyralSale.address);

            /// Trigger the fallback function
            const txObj = await this.vyralSale.sendTransaction({from: alice, value: web3.toWei(1)});
            expect(txObj.receipt).to.exist;

            /// Accounting
            const aliceBalAfter = await this.share.balanceOf.call(alice);
            const saleBalAfter  = await this.share.balanceOf.call(this.vyralSale.address);

            expect(aliceBalBefore.toNumber())
            .to.equal(0);

            expect(aliceBalAfter.toNumber())
            .to.equal(web3.toWei(1) * config.get("rate"));

            expect(saleBalAfter.toNumber())
            .to.equal((saleBalBefore.sub(aliceBalAfter)).toNumber());
        });

        it("should reject contributions less than 1 ETH ", async () => {
            await this.vyralSale.buySale(grace, {from: alice, value: web3.toWei(0.5)})
            .should.be.rejectedWith('VM Exception while processing transaction: revert');
        });

        it("should reward referrer 7% bonus when 1 node is invited", async () => {
            await this.vyralSale.buySale(alice, {from: bob, value: web3.toWei(1)});
            await this.vyralSale.buySale(bob, {from: charlie, value: web3.toWei(1)});

            let bobsReferrer     = await this.campaign.getReferrer.call(bob);
            let charliesReferrer = await this.campaign.getReferrer.call(charlie);

            assert.equal(alice, bobsReferrer);
            assert.equal(bob, charliesReferrer);

            let bobBalance     = await this.share.balanceOf.call(bob);
            let charlieBalance = await this.share.balanceOf.call(charlie);

            expect(bobBalance.toNumber())
            .to.equal((new BigNumber(web3.toWei(1)).mul(saleRate).mul(1.07)).toNumber());

            expect(charlieBalance.toNumber())
            .to.equal((new BigNumber(web3.toWei(1)).mul(saleRate).mul(1)).toNumber());
        });

        it("should reward referrer 8% bonus when 2 nodes are invited", async () => {
            await this.vyralSale.buySale(alice, {from: dave, value: web3.toWei(1)});
            await this.vyralSale.buySale(dave, {from: emma, value: web3.toWei(1)});
            await this.vyralSale.buySale(dave, {from: faith, value: web3.toWei(1)});

            let davesReferrer  = await this.campaign.getReferrer.call(dave);
            let emmasReferrer  = await this.campaign.getReferrer.call(emma);
            let faithsReferrer = await this.campaign.getReferrer.call(faith);

            assert.equal(alice, davesReferrer);
            assert.equal(dave, emmasReferrer);
            assert.equal(dave, faithsReferrer);

            let aliceBalance = await this.share.balanceOf.call(alice);
            let daveBalance  = await this.share.balanceOf.call(dave);
            let emmaBalance  = await this.share.balanceOf.call(emma);
            let faithBalance = await this.share.balanceOf.call(faith);

            let tokens = new BigNumber(web3.toWei(1)).mul(saleRate);
            expect(daveBalance.toNumber())
            .to.equal(tokens.add(tokens.mul(0.08).mul(2)).toNumber());

            expect(emmaBalance.toNumber())
            .to.equal((new BigNumber(web3.toWei(1)).mul(saleRate).mul(1)).toNumber());

            expect(faithBalance.toNumber())
            .to.equal((new BigNumber(web3.toWei(1)).mul(saleRate).mul(1)).toNumber());
        });

        it("should reward referrer 9% bonus when 3 nodes are invited", async () => {
            await this.vyralSale.buySale(alice, {from: grace, value: web3.toWei(1)});

            let gracesReferrer = await this.campaign.getReferrer.call(grace);

            assert.equal(alice, gracesReferrer);

            let aliceBalance = await this.share.balanceOf.call(alice);
            let aliceRewards = await this.share.lockedBalanceOf.call(alice);
            let tokens       = new BigNumber(web3.toWei(1)).mul(saleRate);

            expect(aliceBalance.toNumber())
            .to.equal(tokens.add(tokens.mul(0.09).mul(3)).toNumber());

            expect(aliceRewards.toNumber())
            .to.equal(tokens.mul(0.09).mul(3).toNumber());
        });

        it("should prevent tokens from being transferred until transfers are enabled", async () => {
            let aliceBalance = await this.share.balanceOf.call(alice);
            let aliceRewards = await this.share.lockedBalanceOf.call(alice);

            await this.share.transfer(henry, aliceBalance.toNumber(), {from: alice})
            .should.be.rejectedWith('VM Exception while processing transaction: revert');

            await this.share.enableTransfers({from: owner});

            await this.share.transfer(henry, aliceBalance.sub(aliceRewards).toNumber(), {from: alice});
        });

        it("should lock rewards until unlocked by owner", async () => {
            let aliceRewards = await this.share.lockedBalanceOf.call(alice);

            await this.share.transfer(henry, aliceRewards.toNumber(), {from: alice})
            .should.be.rejectedWith('VM Exception while processing transaction: revert');

            await this.share.releaseBonus({from: owner});

            await this.share.transfer(henry, aliceRewards.toNumber(), {from: alice});
        });

    });
});
