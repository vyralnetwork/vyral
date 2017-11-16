/**
 * MultiSigWallet usage
 */
const MultiSigWallet = artifacts.require('multisig-wallet/MultiSigWallet.sol');

const {assert} = require('chai');

contract('MultiSigWallet usage', function(accounts) {

    const [owner1, owner2, owner3] = accounts;

    it('should create a new token and transfer ownership', async () => {
        let wallet = await MultiSigWallet.new([owner2, owner3], 2, {from: owner1});
        console.log("wallet.address", wallet.address)
    });
});
