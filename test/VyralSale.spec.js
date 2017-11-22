/**
 * Vyral contract scenarios.
 */
const Share          = artifacts.require("./HumanStandardToken.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require("./MultiSigWallet.sol");

const moment    = require("moment");
const BigNumber = require("bignumber.js");
const {assert}  = require("chai");

const config = require("../config");

function isReverted(err) {
    return err.toString().includes('revert');
}

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

contract("Vyral Presale Agreements", (accounts) => {

    const [grace, julia, kevin] = accounts;

    beforeEach(async () => {
        this.vyralSale = await VyralSale.deployed();

        let tokenAddr = await this.vyralSale.token.call();
        this.share    = Share.at(tokenAddr);

        let campaignAddr = await this.vyralSale.campaign.call();
        this.campaign    = Campaign.at(campaignAddr);
    });

    describe("Basic sale", () => {

        it("should initialize sale", async () => {
            let saleStartTime = await this.vyralSale.saleStartTime.call();
            let saleEndTime   = await this.vyralSale.saleEndTime.call();
            let saleDuration  = await this.vyralSale.saleDuration.call();
        });

        it("should execute a sale and transfer tokens", async () => {
            await this.vyralSale.sendTransaction({from: grace, value: 1});
            let graceBalance    = await this.share.balanceOf.call(grace);
            let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            let campaignBudget  = await this.vyralSale.THREE_SEVENTHS.call();

            assert.equal(4285, graceBalance.toNumber());
            assert.isTrue(campaignBudget.equals(graceBalance.plus(saleBalance)));
        });

        // it("should reject contributions less than 1 ETH ", async () => {
        //     try {
        //         await this.vyralSale.buyTokens(grace, {from: julia, value: 0.5});
        //     } catch(err) {
        //         assert(isReverted(err), err.toString());
        //     }
        // });

        it("should reward referrer 7% bonus when a new node joins", async () => {
            await this.vyralSale.buyTokens(grace, {from: julia, value: 1});

            let gracesReferrer = await this.campaign.getReferrer.call(grace);
            let juliasReferrer = await this.campaign.getReferrer.call(julia);
            assert.equal("0x0000000000000000000000000000000000000000", gracesReferrer);
            assert.equal(grace, juliasReferrer);

            let graceBalance    = await this.share.balanceOf.call(grace);
            let juliaBalance    = await this.share.balanceOf.call(julia);
            let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            let lostBalance     = await this.share.balanceOf.call("0x0");

            assert.equal(4584, graceBalance.toNumber());
            assert.equal(4285, juliaBalance.toNumber());
            assert.isTrue(saleBalance.equals(new BigNumber("333333332999999999999991430")));
            assert.isTrue(campaignBalance.equals(new BigNumber("222222221999999999999999701")));
            assert.isTrue(lostBalance.equals(new BigNumber("0")));
        });

        it("should reward referrer 8% bonus when a new node joins", async () => {
            await this.vyralSale.buyTokens(grace, {from: julia, value: 1});

            let gracesReferrer = await this.campaign.getReferrer.call(grace);
            let juliasReferrer = await this.campaign.getReferrer.call(julia);
            let kevinsReferrer = await this.campaign.getReferrer.call(kevin);
            assert.equal("0x0000000000000000000000000000000000000000", gracesReferrer);
            assert.equal(grace, juliasReferrer);
            assert.equal(grace, kevinsReferrer);

            let graceBalance    = await this.share.balanceOf.call(grace);
            let juliaBalance    = await this.share.balanceOf.call(julia);
            let kevinBalance    = await this.share.balanceOf.call(kevin);
            let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            let lostBalance     = await this.share.balanceOf.call("0x0");

            assert.equal(4584, graceBalance.toNumber());
            assert.equal(4285, juliaBalance.toNumber());
            assert.equal(4285, juliaBalance.toNumber());
            assert.isTrue(saleBalance.equals(new BigNumber("333333332999999999999982860")));
            assert.isTrue(campaignBalance.equals(new BigNumber("222222221999999999999998974")));
            assert.isTrue(lostBalance.equals(new BigNumber("0")));
        });

        it("should reward referrer 8% bonus when a new node joins", async () => {
            let treeSize = await this.campaign.getTreeSize.call();
            console.log("treeSize", treeSize.toString(10))

            let result1 = await this.vyralSale.buyTokens(grace, {from: julia, value: 1});
            treeSize    = await this.campaign.getTreeSize.call();
            console.log("treeSize", treeSize.toString(10))

            console.log(result1.logs)

            let result2 = await this.vyralSale.buyTokens(grace, {from: kevin, value: 1});
            treeSize    = await this.campaign.getTreeSize.call();
            console.log("treeSize", treeSize.toString(10))

            console.log(result2.logs)


            let gracesReferrer = await this.campaign.getReferrer.call(grace);
            let juliasReferrer = await this.campaign.getReferrer.call(julia);
            let kevinsReferrer = await this.campaign.getReferrer.call(kevin);

            console.log("gracesReferrer", gracesReferrer)
            console.log("juliasReferrer", juliasReferrer)
            console.log("kevinsReferrer", kevinsReferrer)

            let graceBalance    = await this.share.balanceOf.call(grace);
            let juliaBalance    = await this.share.balanceOf.call(julia);
            let kevinBalance    = await this.share.balanceOf.call(kevin);
            let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            let lostBalance     = await this.share.balanceOf.call("0x0");

            console.log("graceBalance", graceBalance.toString(10))
            console.log("juliaBalance", juliaBalance.toString(10))
            console.log("kevinBalance", kevinBalance.toString(10))
            console.log("saleBalance", saleBalance.toString(10))
            console.log("campaignBalance", campaignBalance.toString(10))
            console.log("lostBalance", lostBalance.toString(10))


            assert.equal(4285, juliaBalance.toNumber());
        });

    });
});
