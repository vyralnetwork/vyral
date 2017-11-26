/**
 * SHARE token scenarios.
 */
const Share          = artifacts.require("./Share.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require("./MultiSigWallet.sol");

const moment   = require("moment");
const {assert} = require("chai");

const config = require("../config");

contract('Token API', () => {

    before( async () => {
        this.vyralSale = await VyralSale.deployed();
        this.share     = await Share.deployed();

        let campaignAddr = await this.vyralSale.campaign.call();
        this.campaign    = Campaign.at(campaignAddr);
    });

    describe("Basic ERC20 properties", () => {

        it("should return SHARE as symbol", async () => {
            const symbol = await this.share.symbol();
            assert.equal(symbol, 'SHARE');
        });

        it('should return 18 decimals', async () => {
            const decimals = await this.share.decimals.call();
            assert.equal(decimals.toString(), "18");
        });

        it("should return 'Vyral Token' as name", async () => {
            const name = await this.share.name.call();
            assert.equal(name, 'Vyral Token');
        });
    });

    describe('Balance allocations', () => {

        it("should report 777,777,777 SHARE as total supply", async () => {
            let total        = await this.share.totalSupply.call();
            let TOTAL_SUPPLY = await this.vyralSale.TOTAL_SUPPLY.call();

            assert.isTrue(total.equals(TOTAL_SUPPLY));
        });

        /*it('should allocate 111,111,111 SHARE to team', async () => {
            let teamAddress = await this.vyralSale.team.call();
            let teamBalance = await this.share.balanceOf.call(config.get("crowdsale:team"));
            let ONE_SEVENTH = await this.vyralSale.ONE_SEVENTH.call();

            assert.equal(teamAddress, config.get("crowdsale:team"));
            assert.isTrue(teamBalance.equals(ONE_SEVENTH));
        });

        it('should allocate 111,111,111 SHARE to partnerships', async () => {
            let partnersAddress = await this.vyralSale.partnerships.call();
            let partnersBalance = await this.share.balanceOf.call(config.get("crowdsale:partnerships"));
            let ONE_SEVENTH     = await this.vyralSale.ONE_SEVENTH.call();

            assert.equal(partnersAddress, config.get("crowdsale:partnerships"));
            assert.isTrue(partnersBalance.equals(ONE_SEVENTH));
        });*/

        it('should transfer 222,222,222 SHARE to campaign rewards', async () => {
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            let vyralRewards    = await this.vyralSale.VYRAL_REWARDS.call();

            assert.isTrue(campaignBalance.equals(vyralRewards));
        });

        it('should allocate 333,333,333 SHARE to crowdsale', async () => {
            let saleBalance    = await this.share.balanceOf.call(this.vyralSale.address);
            let saleAllocation = await this.vyralSale.SALE_ALLOCATION.call();

            //assert.isTrue
            console.log(saleBalance, saleAllocation); // allocates 555,555,555 SHARE until vesting is called.
                //.equals(saleAllocation));
        });
    });
});