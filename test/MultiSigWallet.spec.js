/**
 * MultiSigWallet usage
 */
const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const {assert} = require('chai');

contract('MultiSigWallet usage', function(accounts) {

    let coinbase = accounts[0];
    let owner1   = accounts[1];
    let owner2   = accounts[2];

    it('should create a new token and transfer ownership', async () => {
        let wallet = await MultiSigWallet.new([owner1, owner2], 2, {from: coinbase});
    });
});
