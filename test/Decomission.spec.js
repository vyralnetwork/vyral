require('chai')
.use(require('chai-as-promised'))
.should();

const expect                 = require('chai').expect;
const BigNumber              = require('bignumber.js');
const {wait, waitUntilBlock} = require('@digix/tempo')(web3);

/// Contracts
const Campaign  = artifacts.require('./Campaign.sol')
const Share     = artifacts.require('./Share.sol');
const VyralSale = artifacts.require('./VyralSale.sol');

const MINUTE = 60; // in seconds
const HOUR   = 60 * MINUTE; // in seconds
const DAY    = 24 * HOUR; // in seconds

contract('Decomission the VyralSale under different circumstances', async function(accounts) {
    const [Owner, Jim, Pam, Dwight, Michael] = accounts;

    let campaign
    let dateTime;
    let shareToken;
    let vyralSale;

    let presaleStartTimestamp;
    let presaleEndTimestamp;
    let presaleRate;
    let presaleCap;

    it('decomissions the vyralSale before Presale and switches contracts', async function() {
        shareToken = await Share.deployed();
        vyralSale = await VyralSale.deployed();
        dateTime = await vyralSale.dateTime.call()
        
        // console.log(dateTime)
        expect((await vyralSale.phase.call()).toNumber())
        .to.equal(1)

        /// Take down this data so we have it for tests
        presaleStartTimestamp = await vyralSale.presaleStartTimestamp.call();
        presaleEndTimestamp   = await vyralSale.presaleEndTimestamp.call();
        presaleRate           = await vyralSale.presaleRate.call();
        presaleCap            = await vyralSale.presaleCap.call();

        /// Take the sale all the way to decomissioned.
        await vyralSale.decomission()

        expect((await vyralSale.phase.call()).toNumber())
        .to.equal(7)

        /// Replace vyralSale with a different instance.
        const newVyralSale = await VyralSale.new(shareToken.address, dateTime)

        const oldSaleBalBefore = await shareToken.balanceOf(vyralSale.address)

        await vyralSale.replaceDecomissioned(newVyralSale.address)

        const oldSaleBalAfter = await shareToken.balanceOf(vyralSale.address)
        const newSaleBal = await shareToken.balanceOf(newVyralSale.address)

        expect(oldSaleBalAfter.toNumber())
        .to.equal(0)

        expect(oldSaleBalBefore.toNumber())
        .to.equal(newSaleBal.toNumber())

        // console.log(newSaleBal.toNumber())

        campaign = await Campaign.at(await vyralSale.campaign.call()) 
        const newOwner = await campaign.owner.call()

        expect(newOwner)
        .to.equal(newVyralSale.address)

        vyralSale = newVyralSale
    })

    it('decomissions the contract after Presale and switches to a new contract', async function() {
        expect((await vyralSale.phase.call()).toNumber())
        .to.equal(0) // not yet initiliazed

        await shareToken.addTransferrer(vyralSale.address)

        await vyralSale.setCampaign(campaign.address)

        const txn = await vyralSale.initPresale(
            Owner,
            presaleStartTimestamp,
            presaleEndTimestamp,
            presaleCap,
            presaleRate
        )

        expect(txn.receipt)
        .to.exist 
        
        await vyralSale.startPresale()

        const block = await web3.eth.getBlock('latest')
        const now = block.timestamp
        const secondsToWait = presaleStartTimestamp - now 
        await waitUntilBlock(secondsToWait, 1)

        // / Send some transactions
        let sending = true
        let i = 0
        while (sending) {
            await vyralSale.sendTransaction({from: Jim, value: web3.toWei('1', 'ether')})
            i++
            if (i > 24) {
                sending = false
            }
        }

        //decomission
        await vyralSale.decomission()

        expect((await vyralSale.phase.call()).toNumber())
        .to.equal(7)

        // can't send more transactions
        vyralSale.sendTransaction({from: Owner, value: web3.toWei('0.5', 'ether')})
        .should.be.rejectedWith('VM Exception while processing transaction: revert')
    })
})