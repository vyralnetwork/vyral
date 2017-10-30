/**
 * Vyral contract scenarios.
 */
let VyralSale    = artifacts.require("./VyralSale.sol");
let Campaign = artifacts.require("./Campaign.sol");

const {assert}  = require('chai');

contract('Vyral agreements', function(accounts) {

    beforeEach(async () => {
    });

    it('should initialize Vyral', async () => {
        let vyral = await VyralSale.new();
    });

});