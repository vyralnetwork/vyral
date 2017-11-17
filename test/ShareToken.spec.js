/**
 * SHARE token scenarios.
 */
const Share          = artifacts.require("tokens/HumanStandardToken.sol");
const TieredPayoff   = artifacts.require("./rewards/TieredPayoff.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const BigNumber = require("bignumber.js");
const {assert}  = require("chai");

const config = require("../config");

contract('Token API', (accounts) => {

    const [grace, julia, kevin] = accounts;

    before(async () => {
        this.wallet = await MultiSigWallet.new([owner], 1, {from: owner});

        this.strategy  = await TieredPayoff.deployed();
        this.vyralSale = await VyralSale.new([
            this.wallet.address,
            this.strategy.address,
            config.get("crowdsale:team"),
            config.get("crowdsale:partnerships")
        ]);

        let tokenAddr = await this.vyralSale.token.call();
        this.share    = Share.at(tokenAddr);

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

        it('should allocate 111,111,111 SHARE to team', async () => {
            let teamBalance = await this.share.balanceOf.call(config.get("crowdsale:team"));
            let ONE_SEVENTH = await this.vyralSale.ONE_SEVENTH.call();

            assert.isTrue(teamBalance.equals(ONE_SEVENTH));
        });

        it('should allocate 111,111,111 SHARE to partnerships', async () => {
            let partnersBalance = await this.share.balanceOf.call(config.get("crowdsale:partnerships"));
            let ONE_SEVENTH     = await this.vyralSale.ONE_SEVENTH.call();

            let teamAddress = await this.vyralSale.wallet.call();

            console.log(teamAddress)
            console.log(ONE_SEVENTH.toString(10))
            console.log(partnersBalance.toString(10))
            assert.isTrue(partnersBalance.equals(ONE_SEVENTH));
        });

        it('should transfer 222,222,222 SHARE to campaign rewards', async () => {
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            let TWO_SEVENTHS    = await this.vyralSale.TWO_SEVENTHS.call();

            assert.isTrue(campaignBalance.equals(TWO_SEVENTHS));
        });

        it('should allocate 333,333,333 SHARE to crowdsale', async () => {
            let saleBalance    = await this.share.balanceOf.call(this.vyralSale.address);
            let THREE_SEVENTHS = await this.vyralSale.THREE_SEVENTHS.call();

            assert.isTrue(saleBalance.equals(THREE_SEVENTHS));
        });
    });
});