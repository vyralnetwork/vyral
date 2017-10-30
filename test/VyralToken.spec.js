/**
 * Vyral contract scenarios.
 */
const Share          = artifacts.require("./Share.sol");
const MultiSigWallet = artifacts.require('./MultiSigWallet.sol');


const {assert} = require('chai');
const ethutil  = require("ethereumjs-util");

let config = require("../config");

contract('Token API', (accounts) => {

    before(async () => {
        this.share = await Share.deployed();
        this.wallet = await MultiSigWallet.deployed();
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

    describe('Minting and balances', function() {
        beforeEach("mint 777777777 tokens", async () => {
            await this.share.mint(777777777);
        });

        it("should report 777777777 as total supply", async function() {
            let total = await this.share.totalSupply.call();
            assert.equal(777777777, total.toNumber());
        });

        // it('should be able to get token balance', async function() {
        //     var balance = await token.balanceOf.call(COINBASE_ACCOUNT);
        //     assert.equal(1500000, balance.toNumber());
        // });
        //
        // it('should be able to get allowance for address', async function() {
        //     await token.approve(ACCOUNT_TWO, 200000);
        //     var allowance = await token.allowance.call(COINBASE_ACCOUNT, ACCOUNT_TWO);
        //     assert.equal(200000, allowance.toNumber());
        // });

    });
});