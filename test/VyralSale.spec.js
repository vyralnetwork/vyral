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
    .should()

const expect    = require("chai").expect

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

    const [owner, grace, julia, kevin] = accounts;

    before(async () => {
        this.vyralSale = await VyralSale.deployed();
        this.share     = await Share.deployed();

        let campaignAddr = await this.vyralSale.campaign.call();
        this.campaign    = Campaign.at(campaignAddr);

        let phase = await this.vyralSale.phase.call();
        console.log("phase", phase)

        await this.vyralSale.startPresale({from: owner});

        phase = await this.vyralSale.phase.call();
        console.log("phase", phase)

        await this.vyralSale.endPresale({from: owner});
        phase = await this.vyralSale.phase.call();
        console.log("phase", phase)

        await this.vyralSale.initSale(
        moment().day(1).unix(),
        moment().day(2).unix(),
        config.get("rate"), {from: owner});

        phase = await this.vyralSale.phase.call();
        console.log("phase", phase)

        await this.vyralSale.startSale({from: owner});

        phase = await this.vyralSale.phase.call();
        console.log("phase", phase)


    });

    describe("Basic sale", () => {

        it("should initialize sale", async () => {
            expect((await this.vyralSale.phase.call()).toNumber())
                .to.equal(5)

            const saleStartTime = await this.vyralSale.saleStartTimestamp.call();
            const saleEndTime   = await this.vyralSale.saleEndTimestamp.call();

            assert(saleEndTime.toNumber() != 0 && saleStartTime.toNumber() != 0)

            expect(saleStartTime.toNumber())
                .to.be.below(saleEndTime.toNumber())
        });

        it("should execute a sale and transfer tokens", async () => {
            /// Let's take a ride in the Delorean...
            const saleStartTime = await this.vyralSale.saleStartTimestamp.call();            
            timeTravel(saleStartTime.toNumber())

            /// Take this down really quick
            const graceBalBefore = await this.share.balanceOf(grace)
            const saleBalBefore = await this.share.balanceOf(this.vyralSale.address)

            /// Trigger the fallback function
            const txObj = await this.vyralSale.sendTransaction({ from: grace, value: web3.toWei(1) });
            expect(txObj.receipt).to.exist

            /// Accounting
            const graceBalAfter = await this.share.balanceOf.call(grace);
            const saleBalAfter = await this.share.balanceOf.call(this.vyralSale.address);

            assert(graceBalBefore.toNumber() == 0)
            expect(graceBalAfter.toNumber())
                .to.equal(web3.toWei(1) * config.get("rate"))

            expect(saleBalAfter.toNumber())
                .to.equal((saleBalBefore.sub(graceBalAfter)).toNumber())
            
        });

        it("should reject contributions less than 1 ETH ", async () => {
            await this.vyralSale.buySale(grace, { from: julia, value: web3.toWei(0.5) })
                .should.be.rejectedWith('VM Exception while processing transaction: revert')

            console.log('Booyah!')
        });

        // it("should reward referrer 7% bonus when a new node joins", async () => {
        //     await this.vyralSale.buySale(grace, {from: julia, value: 1});

        //     let gracesReferrer = await this.campaign.getReferrer.call(grace);
        //     let juliasReferrer = await this.campaign.getReferrer.call(julia);
        //     assert.equal("0x0000000000000000000000000000000000000000", gracesReferrer);
        //     assert.equal(grace, juliasReferrer);

        //     let graceBalance    = await this.share.balanceOf.call(grace);
        //     let juliaBalance    = await this.share.balanceOf.call(julia);
        //     let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
        //     let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
        //     let lostBalance     = await this.share.balanceOf.call("0x0");

        //     assert.equal(4584, graceBalance.toNumber());
        //     assert.equal(4285, juliaBalance.toNumber());
        //     assert.isTrue(saleBalance.equals(new BigNumber("333333332999999999999991430")));
        //     assert.isTrue(campaignBalance.equals(new BigNumber("222222221999999999999999701")));
        //     assert.isTrue(lostBalance.equals(new BigNumber("0")));
        // });

        // it("should reward referrer 8% bonus when a new node joins", async () => {
        //     await this.vyralSale.buySale(grace, {from: julia, value: 1});

        //     let gracesReferrer = await this.campaign.getReferrer.call(grace);
        //     let juliasReferrer = await this.campaign.getReferrer.call(julia);
        //     let kevinsReferrer = await this.campaign.getReferrer.call(kevin);
        //     assert.equal("0x0000000000000000000000000000000000000000", gracesReferrer);
        //     assert.equal(grace, juliasReferrer);
        //     assert.equal(grace, kevinsReferrer);

        //     let graceBalance    = await this.share.balanceOf.call(grace);
        //     let juliaBalance    = await this.share.balanceOf.call(julia);
        //     let kevinBalance    = await this.share.balanceOf.call(kevin);
        //     let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
        //     let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
        //     let lostBalance     = await this.share.balanceOf.call("0x0");

        //     assert.equal(4584, graceBalance.toNumber());
        //     assert.equal(4285, juliaBalance.toNumber());
        //     assert.equal(4285, juliaBalance.toNumber());
        //     assert.isTrue(saleBalance.equals(new BigNumber("333333332999999999999982860")));
        //     assert.isTrue(campaignBalance.equals(new BigNumber("222222221999999999999998974")));
        //     assert.isTrue(lostBalance.equals(new BigNumber("0")));
        // });

        // it("should reward referrer 8% bonus when a new node joins", async () => {
        //     let treeSize = await this.campaign.getTreeSize.call();
        //     console.log("treeSize", treeSize.toString(10))

        //     let result1 = await this.vyralSale.buySale(grace, {from: julia, value: 1});
        //     treeSize    = await this.campaign.getTreeSize.call();
        //     console.log("treeSize", treeSize.toString(10))

        //     console.log(result1.logs)

        //     let result2 = await this.vyralSale.buySale(grace, {from: kevin, value: 1});
        //     treeSize    = await this.campaign.getTreeSize.call();
        //     console.log("treeSize", treeSize.toString(10))

        //     console.log(result2.logs)


        //     let gracesReferrer = await this.campaign.getReferrer.call(grace);
        //     let juliasReferrer = await this.campaign.getReferrer.call(julia);
        //     let kevinsReferrer = await this.campaign.getReferrer.call(kevin);

        //     console.log("gracesReferrer", gracesReferrer)
        //     console.log("juliasReferrer", juliasReferrer)
        //     console.log("kevinsReferrer", kevinsReferrer)

        //     let graceBalance    = await this.share.balanceOf.call(grace);
        //     let juliaBalance    = await this.share.balanceOf.call(julia);
        //     let kevinBalance    = await this.share.balanceOf.call(kevin);
        //     let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
        //     let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
        //     let lostBalance     = await this.share.balanceOf.call("0x0");

        //     console.log("graceBalance", graceBalance.toString(10))
        //     console.log("juliaBalance", juliaBalance.toString(10))
        //     console.log("kevinBalance", kevinBalance.toString(10))
        //     console.log("saleBalance", saleBalance.toString(10))
        //     console.log("campaignBalance", campaignBalance.toString(10))
        //     console.log("lostBalance", lostBalance.toString(10))


        //     assert.equal(4285, juliaBalance.toNumber());
        // });

    });
});
