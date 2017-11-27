require('chai')
    .use(require('chai-as-promised'))
    .should()

const expect = require('chai').expect 
const BigNumber = require('bignumber.js')
const { wait, waitUntilBlock } = require('@digix/tempo')(web3);

/// Contracts
const Share = artifacts.require('./Share.sol')
const VyralSale = artifacts.require('./VyralSale.sol')

contract('Presale simulation', async function(accounts) {

    /// Local accounts for testing purposes
    const [ Owner, Anna, Ben, Cindy, Dave, Emily ] = accounts

    /// Contract instances shared between each test
    let shareToken
    let vyralSale

    /// VyralSale params
    let presaleStartTimestamp
    let presaleEndTimestamp
    let presaleRate
    let presaleCap

    it('gathers the contracts and expects they are correct', async function() {
        
        shareToken = await Share.deployed()
        vyralSale = await VyralSale.deployed()

        /// VyralSale should be in phase 1 (initialized)
        expect((await vyralSale.phase.call()).toNumber())
            .to.equal(1)

        /// VyralSale should have 555,555,555 shares allocated
        expect((await shareToken.balanceOf(vyralSale.address)).toNumber())
            .to.equal(5.55555555e+26)

        /// Take in all the data
        presaleStartTimestamp = await vyralSale.presaleStartTimestamp.call()
        presaleEndTimestamp = await vyralSale.presaleEndTimestamp.call()
        presaleRate = await vyralSale.presaleRate.call()
        presaleCap = await vyralSale.presaleCap.call()

        const block = await web3.eth.getBlock('latest')
        const now = block.timestamp

        /// Make sure all the numbers make sense
        expect(presaleStartTimestamp.toNumber())
            .to.be.above(now)
        expect(presaleEndTimestamp.toNumber())
            .to.be.above(presaleStartTimestamp.toNumber())
        expect(presaleRate.toNumber())
            .to.equal(7000)
        expect(presaleCap.toNumber())
            .to.equal(4e+22)        
    })

    it('moves VyralSale into phase 2', async function() {

        await vyralSale.startPresale()

        expect((await vyralSale.phase.call()).toNumber(), 'vyralSale should now return 2 as its phase')
            .to.equal(2)
        
        /// Can no longer set any of the presale params
        await vyralSale.setPresaleParams(
            0,
            0,
            0,
            0
        ).should.be.rejectedWith('VM Exception while processing transaction: revert')

        /// And can not send a payment until the start time
        await vyralSale.sendTransaction({from: Anna, value: web3.toWei(20)})
            .should.be.rejectedWith('VM Exception while processing transaction: revert')
    })

    it('should accept a valid contribution at start of sale and return proper bonus', async function() {

        /// Time travellin'
        const block_ = await web3.eth.getBlock('latest')
        const now_ = await block_.timestamp 
        const secondsToWait = presaleStartTimestamp.toNumber() - now_ 
        await waitUntilBlock(secondsToWait, 0)

        /// Check that we're in the future now
        const block = await web3.eth.getBlock('latest')
        const now = block.timestamp
        expect(now)
            .to.equal(presaleStartTimestamp.toNumber())

        /// Dave and Emily would like to contribute
        ///-----------------------------------------
        // 1) Get their token balances
        const daveBefore = await shareToken.balanceOf(Dave)
        const emilyBefore = await shareToken.balanceOf(Emily)
        assert(daveBefore.toNumber() == emilyBefore.toNumber() && daveBefore.toNumber() == 0)
        // 2) Send the transactions
        const tx1 = await vyralSale.sendTransaction({from: Dave, value: web3.toWei(10)})
        const tx2 = await vyralSale.sendTransaction({from: Emily, value:web3.toWei(11)})
        expect(tx1.receipt)
            .to.exist 
        expect(tx2.receipt)
            .to.exist 
        // Woah! Thanks Dave and Emily
        // 3) Check that Dave and Emily were both awarded with the proper presale bonus
        //     of 70% in the first hour.
        const daveAfter = await shareToken.balanceOf(Dave) 
        const emilyAfter = await shareToken.balanceOf(Emily)
        expect(daveAfter.toNumber())
            .to.be.above(daveBefore.toNumber())
        expect(emilyAfter.toNumber())
            .to.be.above(emilyBefore.toNumber())

        expect(daveAfter.toNumber())
            .to.equal(
                (new BigNumber(web3.toWei(10))
                .mul(presaleRate)
                .mul(1.7))
                .toNumber()
            )

        expect(emilyAfter.toNumber())    
            .to.equal(
                (new BigNumber(web3.toWei(11))
                .mul(presaleRate)
                .mul(1.7))
                .toNumber()
            )
    })

    
})