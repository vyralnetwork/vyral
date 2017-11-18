/**
 * MultiSigWallet usage
 */
const MultiSigWallet = artifacts.require('./MultiSigWallet.sol');

const {assert} = require('chai');

contract('MultiSigWallet usage', function(accounts) {

    const [owner1, owner2, owner3] = accounts;

    it('should create a new wallet', async () => {
        let wallet = await MultiSigWallet.deployed();
    });
});
