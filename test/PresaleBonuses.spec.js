require('chai')
    .use(require('chai-as-promised'))
    .should()

const expect = require('chai').expect 

/// Contracts
const Share = artifacts.require('./Share.sol')
const Vesting = artifacts.require('./Vesting.sol')
const VyralSale = artifacts.require('./VyralSale.sol')

contract('Presale simulation', async function() {

    /// Local accounts for testing purposes
    const [ Owner, Anna, Ben, Cindy, Dave, Emily ] = accounts

    it('Gathers the contracts and asserts they are correct', async function() {
        console.log(accounts)
        console.log(Cindy)
    })
})