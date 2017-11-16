/**
 * SHARE token scenarios.
 */
const Share          = artifacts.require("tokens/HumanStandardToken.sol");
const TieredPayoff   = artifacts.require("./rewards/TieredPayoff.sol");
const Campaign       = artifacts.require("./Campaign.sol");
const VyralSale      = artifacts.require("./VyralSale.sol");
const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const Web3     = require('web3');
const {assert} = require('chai');

let web3 = new Web3();

contract('Token API', (accounts) => {

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
            let total = await this.share.totalSupply.call();
            assert.equal(777777777, web3.fromWei(total, "ether"));
        });

        it('should allocate 111,111,111 SHARE to team', async () => {
            let teamBalance = await this.share.balanceOf.call(team);
            assert.equal(111111111, web3.fromWei(teamBalance, "ether"));
        });

        it('should allocate 111,111,111 SHARE to partnerships', async () => {
            let partnershipsAddr = await this.vyralSale.partnerships.call();
            console.log(partnershipsAddr);
            let partnershipsBalance = await this.share.balanceOf.call(partnerships);
            assert.equal(111111111, web3.fromWei(partnershipsBalance, "ether"));
        });

        it('should transfer 222,222,222 SHARE to campaign rewards', async () => {
            let campaignBalance = await this.share.balanceOf.call(this.campaign.address);
            assert.equal(222222222, web3.fromWei(campaignBalance, "ether"));
        });

        it('should allocate 333,333,333 SHARE to crowdsale', async () => {
            let saleBalance = await this.share.balanceOf.call(this.vyralSale.address);
            assert.equal(333333333, web3.fromWei(saleBalance, "ether"));
        });
    });
});