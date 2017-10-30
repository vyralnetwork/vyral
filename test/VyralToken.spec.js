/**
 * Vyral contract scenarios.
 */
const Share          = artifacts.require("./Share.sol");
const MultiSigWallet = artifacts.require('./MultiSigWallet.sol');

const {assert} = require('chai');
const ethutil  = require("ethereumjs-util");

contract('Token API', (accounts) => {

    let coinbase = accounts[0];
    let owner1   = accounts[1];
    let owner2   = accounts[2];

    describe("Basic ERC20 properties", () => {
        before(async () => {
            this.share = await Share.deployed();
        });

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

    describe('Minting and balances', () => {
        before(async () => {
            this.share = await Share.deployed();
            await this.share.mint(777777777, coinbase);

            let wallet = await MultiSigWallet.new([owner1, owner2], 2, {from: coinbase});
        });

        it("should report 777777777 as total supply", async () => {
            let total = await this.share.totalSupply.call();
            assert.equal(777777777, total.toNumber());
        });

        it('should be able to get token balance', async () => {
            let balance = await this.share.balanceOf.call(coinbase);
            assert.equal(777777777, balance.toNumber());
        });

        // it('should be able to get allowance for address', async function() {
        //     await token.approve(ACCOUNT_TWO, 200000);
        //     var allowance = await token.allowance.call(COINBASE_ACCOUNT, ACCOUNT_TWO);
        //     assert.equal(200000, allowance.toNumber());
        // });

    });
});