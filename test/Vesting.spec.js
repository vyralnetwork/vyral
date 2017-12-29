require('chai')
    .use(require('chai-as-promised'))
    .should()

const expect = require('chai').expect
const moment = require("moment");
const config = require('../config')
const { wait, waitUntilBlock } = require('@digix/tempo')(web3);

/// Contracts
const Share = artifacts.require('./Share.sol')
const Vesting = artifacts.require('./Vesting.sol')
const VyralSale = artifacts.require('./VyralSale.sol')

contract('Vesting implementation', async function(accounts) {

    it('$', async function() {
        
        /// Just set these as local accounts for testing
        const Owner = accounts[0]
        const Team = accounts[3]
        const Partnerships = accounts[6]

        const curBlock = await web3.eth.getBlock('latest')
        const now = curBlock.timestamp

        const MINUTE = 60 //seconds
        const HOUR = 60*MINUTE//s
        const DAY = 24*HOUR//s
        const MONTH = 2629743//seconds

        const vestingStart = config.get("vesting:teamSchedule:startTime")
        const amount = web3.toWei(111111111)

        const EighteenMonthVest = {
            startTimestamp: config.get("vesting:teamSchedule:startTime"),
            cliffTimestamp: config.get("vesting:teamSchedule:cliffTime"),
            lockPeriod: config.get("vesting:teamSchedule:lockPeriod"),
            endTimestamp: config.get("vesting:teamSchedule:endTime"),
            totalAmount: amount,
            amountWithdrawn: 0,
            depositor: '',
            isConfirmed: false,
        }

        const TwoYearVest = {
            startTimestamp: config.get("vesting:partnershipsSchedule:startTime"),
            cliffTimestamp: config.get("vesting:partnershipsSchedule:cliffTime"),
            lockPeriod: config.get("vesting:partnershipsSchedule:lockPeriod"),
            endTimestamp: config.get("vesting:partnershipsSchedule:endTime"),
            totalAmount: amount,
            amountWithdrawn: 0,
            depositor: '',
            isConfirmed: false, 
        }

        const shareToken = await Share.new()
        expect(shareToken.address).to.exist 

        const vesting = await Vesting.new(shareToken.address)
        expect(vesting.address).to.exist
            
        const vyralSale = await VyralSale.new(
            shareToken.address,
            vesting.address,
            Owner
        )
        expect(vyralSale.address).to.exist

        /// Create the vesting schedules
        const teamVestTx = await vesting.registerVestingSchedule(
            Team,
            vyralSale.address, //depositor
            EighteenMonthVest.startTimestamp,
            EighteenMonthVest.cliffTimestamp,
            EighteenMonthVest.lockPeriod,
            EighteenMonthVest.endTimestamp,
            EighteenMonthVest.totalAmount
        )
        
        expect(teamVestTx.receipt).to.exist

        const partnershipsVestTx = await vesting.registerVestingSchedule(
            Partnerships,
            vyralSale.address, //depositor
            TwoYearVest.startTimestamp,
            TwoYearVest.cliffTimestamp,
            TwoYearVest.lockPeriod,
            TwoYearVest.endTimestamp,
            TwoYearVest.totalAmount
        )
        
        expect(partnershipsVestTx.receipt).to.exist

        /// Fund the sale and authorize addresses
        const totalSupply = await shareToken.TOTAL_SUPPLY.call();

        await shareToken.transfer(vyralSale.address, totalSupply.toNumber())
        await shareToken.addTransferrer(vyralSale.address)
        await shareToken.addTransferrer(vesting.address)

        /// Accounting
        const balance = await shareToken.balanceOf(vyralSale.address)
        expect(balance.toNumber())
            .to.equal(totalSupply.toNumber())

        /// Call initPresale to approve the vesting schedule.
        const txn = await vyralSale.initPresale(
            Owner,
            config.get("presale:startTime"),
            config.get("presale:endTime"),
            web3.toWei(config.get("presale:cap")),
            config.get("rate")
        )

        /// Accounting (Sends amount*2 to campaign)
        const balance2 = await shareToken.balanceOf(vyralSale.address)
        expect(balance2.toNumber())
            .to.equal(amount*5)

        /// Confirm the vesting schedules this should move the tokens
        const teamConfirmTx = await vesting.confirmVestingSchedule(
            EighteenMonthVest.startTimestamp,
            EighteenMonthVest.cliffTimestamp,
            EighteenMonthVest.lockPeriod,
            EighteenMonthVest.endTimestamp,
            EighteenMonthVest.totalAmount,
            {from: Team}
        )

        expect(teamConfirmTx.receipt).to.exist

        const partnersConfirmTx = await vesting.confirmVestingSchedule(
            TwoYearVest.startTimestamp,
            TwoYearVest.cliffTimestamp,
            TwoYearVest.lockPeriod,
            TwoYearVest.endTimestamp,
            TwoYearVest.totalAmount,
            {from: Partnerships}
        )

        expect(partnersConfirmTx.receipt).to.exist

        /// Accounting
        const balance3 = await shareToken.balanceOf(vyralSale.address)
        expect(balance3.toNumber())
            .to.equal(web3.toBigNumber(amount).mul(3).toNumber())

        const vestingBal = await shareToken.balanceOf(vesting.address)
        expect(vestingBal.toNumber())
            .to.equal(web3.toBigNumber(amount).mul(2).toNumber())
        
        /// Wait until the beginning of the vesting period.
        const secondsToWait = vestingStart - now
        await waitUntilBlock(secondsToWait, 1)

        /// The Partnerships should be able to make their first withdraw.
        const withdrawTx1 = await vesting.withdrawVestedTokens({from: Partnerships})
        expect(withdrawTx1.receipt).to.exist 

        const partnersBalThree = await shareToken.balanceOf(Partnerships)
        assert(partnersBalThree.toNumber() > web3.toBigNumber(amount).div(24).toNumber())

        /// Wait six months
        await waitUntilBlock(6*MONTH, 1)
        // await waitUntilBlock(15778458, 0)

        /// Team should withdraw
        const withdrawTx2 = await vesting.withdrawVestedTokens({from: Team})
        expect(withdrawTx2.receipt).to.exist 

        const teamBalThree = await shareToken.balanceOf(Team)
        assert(teamBalThree.toNumber() > web3.toBigNumber(amount).div(3).toNumber())

        /// Wait a month
        await waitUntilBlock(MONTH, 1)

        /// Partners withdraw, team cannot
        const withdrawTx3 = await vesting.withdrawVestedTokens({from: Partnerships})
        expect(withdrawTx3.receipt).to.exist 

        /// Fails with invalid opcode since it fails the `canWithdraw()` check
        const withdrawTx4 = await vesting.withdrawVestedTokens({from: Team})
            .should.be.rejectedWith('VM Exception while processing transaction: revert')

        /// Wait five more months and team can withdraw
        await waitUntilBlock(5*MONTH, 1)

        const withdrawTx5 = await vesting.withdrawVestedTokens({from: Team})
        expect(withdrawTx5.receipt).to.exist
    })


})