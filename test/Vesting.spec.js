require('chai')
    .use(require('chai-as-promised'))
    .should()

const expect = require('chai').expect
const config = require('../config')
const { wait, waitUntilBlock } = require('@digix/tempo')(web3);

/// Contracts
const StandardToken = artifacts.require('./StandardToken.sol')
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
        const MONTH = 30*DAY//s (approx.)

        const vestingStart = now + 2*DAY
        const amount = web3.toWei(111111111)

        const EighteenMonthVest = {
            startTimestamp: vestingStart,
            cliffTimestamp: vestingStart + 6*MONTH,
            lockPeriod: 6*MONTH,
            endTimestamp: vestingStart + 18*MONTH,
            totalAmount: amount,
            amountWithdrawn: 0,
            depositor: '',
            isConfirmed: false,
        }

        const TwoYearVest = {
            startTimestamp: vestingStart - MONTH,
            cliffTimestamp: vestingStart,
            lockPeriod: MONTH,
            endTimestamp: vestingStart + 23*MONTH,
            totalAmount: amount,
            amountWithdrawn: 0,
            depositor: '',
            isConfirmed: false, 
        }
            
        const crowdsale = await VyralSale.new(
            Owner,
            Team,
            Partnerships,
            now,
            now
        )
        
        expect(crowdsale.address).to.exist
        
        const tokenAddr = await crowdsale.token()
        const token = StandardToken.at(tokenAddr)

        const vesting = await Vesting.new(token.address)
        expect(vesting.address).to.exist

        /// Approve the vesting wallets of the correct amounts
        await token.approve(vesting.address, amount, {from: Team})
        await token.approve(vesting.address, amount, {from: Partnerships})

        /// Create the vesting schedules
        const teamVestTx = await vesting.registerVestingSchedule(
            Team,
            Team,
            EighteenMonthVest.startTimestamp,
            EighteenMonthVest.cliffTimestamp,
            EighteenMonthVest.lockPeriod,
            EighteenMonthVest.endTimestamp,
            EighteenMonthVest.totalAmount
        )
        
        expect(teamVestTx.receipt).to.exist

        const partnershipsVestTx = await vesting.registerVestingSchedule(
            Partnerships,
            Partnerships,
            TwoYearVest.startTimestamp,
            TwoYearVest.cliffTimestamp,
            TwoYearVest.lockPeriod,
            TwoYearVest.endTimestamp,
            TwoYearVest.totalAmount
        )
        
        expect(partnershipsVestTx.receipt).to.exist

        /// Check the balances before
        const teamBalOne = await token.balanceOf(Team)
        expect(teamBalOne.toNumber()).to.equal(web3.toBigNumber(amount).toNumber())
        const partnersBalOne = await token.balanceOf(Partnerships)
        expect(partnersBalOne.toNumber()).to.equal(web3.toBigNumber(amount).toNumber())

        /// Confirm the vesting schedules this should move the tokens
        const teamConfirmTx = await vesting.confirmVestingSchedule(
            EighteenMonthVest.startTimestamp,EighteenMonthVest.cliffTimestamp,
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

        /// Check that the tokens were transferred to the Vesting wallet.
        const teamBalTwo = await token.balanceOf(Team)
        expect(teamBalTwo.toNumber()).to.equal(0) 
        const partnersBalTwo = await token.balanceOf(Partnerships)
        expect(partnersBalTwo.toNumber()).to.equal(0)

        const vestingBal = await token.balanceOf(vesting.address)
        expect(vestingBal.toNumber()).to.equal(web3.toBigNumber(amount).mul(2).toNumber())
        
        /// Wait until the beginning of the vesting period.
        const secondsToWait = vestingStart - now
        await waitUntilBlock(secondsToWait, 1)

        /// The Partnerships should be able to make their first withdraw.
        const withdrawTx1 = await vesting.withdrawVestedTokens({from: Partnerships})
        expect(withdrawTx1.receipt).to.exist 

        const partnersBalThree = await token.balanceOf(Partnerships)
        assert(partnersBalThree.toNumber() > web3.toBigNumber(amount).div(24).toNumber())

        /// Wait six months
        await waitUntilBlock(6*MONTH, 1)

        /// Team should withdraw
        const withdrawTx2 = await vesting.withdrawVestedTokens({from: Team})
        expect(withdrawTx2.receipt).to.exist 

        const teamBalThree = await token.balanceOf(Team)
        assert(teamBalThree.toNumber() > web3.toBigNumber(amount).div(3).toNumber())

        /// Wait a month
        await waitUntilBlock(MONTH, 1)

        /// Partners withdraw, team cannot
        const withdrawTx3 = await vesting.withdrawVestedTokens({from: Partnerships})
        expect(withdrawTx3.receipt).to.exist 

        /// Fails with invalid opcode since it fails the `canWithdraw()` check
        const withdrawTx4 = await vesting.withdrawVestedTokens({from: Team})
            .should.be.rejectedWith('VM Exception while processing transaction: invalid opcode')

        /// Wait five more months and team can withdraw
        await waitUntilBlock(5*MONTH, 1)

        const withdrawTx5 = await vesting.withdrawVestedTokens({from: Team})
        expect(withdrawTx5.receipt).to.exist
    })


})