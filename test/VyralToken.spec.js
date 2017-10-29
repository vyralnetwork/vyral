/**
 * Vyral contract scenarios.
 */
let Share = artifacts.require("./Share.sol");

const {assert} = require('chai');
const ethutil  = require("ethereumjs-util");

let config = require("../config");

contract('Token API', (accounts) => {

    before(async () => {
        this.share = await Share.deployed();
    });

    describe("when working with ERC20 properties", () => {
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

});