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

    before(async () => {
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
            await this.vyralSale.buyTokens(grace, {from: julia, value: 1});
            let juliaBalance    = await this.share.balanceOf.call(julia);
            let saleBalance     = await this.share.balanceOf.call(this.vyralSale.address);
            let campaignBalance = await this.vyralSale.THREE_SEVENTHS.call();

            assert.equal(4285, juliaBalance.toNumber());
            assert.isTrue(campaignBalance.equals(juliaBalance.plus(saleBalance)));
        });

        it("should reject contributions less than 1 ETH ", async () => {
            try {
                await this.vyralSale.buyTokens(grace, {from: julia, value: 0.5});
            } catch(err) {
                assert(isReverted(err), err.toString());
            }
        });
    });
});
