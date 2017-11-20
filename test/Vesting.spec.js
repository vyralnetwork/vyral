require('chai')
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

        const EighteenMonthVest = {
            startTimestamp: vestingStart,
            cliffTimestamp: vestingStart + 6*MONTH,
            lockPeriod: 6*MONTH,
            endTimestamp: vestingStart + 18*MONTH,
            totalAmount: 111111111,
            amountWithdrawn: 0,
            depositor: '',
            isConfirmed: false,
        }

        const TwoYearVest = {
            startTimestamp: vestingStart - MONTH,
            cliffTimestamp: vestingStart,
            lockPeriod: MONTH,
            endTimestamp: vestingStart + 24*MONTH,
            totalAmount: 111111111,
            amountWithdrawn: 0,
            depositor: '',
            isConfirmed: false, 
        }
            
        const crowdsale = await VyralSale.new(Owner,
                                  Team,
                                  Partnerships,
                                  now,
                                  now)
        
        expect(crowdsale.address).to.exist
        
        const tokenAddr = await crowdsale.token()
        const token = StandardToken.at(tokenAddr)

        const vesting = await Vesting.new(token.address)
        expect(vesting.address).to.exist

        // console.log(token)
        /// Approve the vesting wallets of the correct amounts
        await token.approve(vesting.address, 111111111, {from: Team})
        await token.approve(vesting.address, 111111111, {from: Partnerships})

        /// Create the vesting schedules
        const teamVestTx = await vesting.registerVestingSchedule(Team,
                                                Team,
                                                EighteenMonthVest.startTimestamp,
                                                EighteenMonthVest.cliffTimestamp,
                                                EighteenMonthVest.lockPeriod,
                                                EighteenMonthVest.endTimestamp,
                                                EighteenMonthVest.totalAmount)
        
        expect(teamVestTx.receipt).to.exist

        const partnershipsVestTx = await vesting.registerVestingSchedule(Partnerships,
                                                Partnerships,
                                                TwoYearVest.startTimestamp,
                                                TwoYearVest.cliffTimestamp,
                                                TwoYearVest.lockPeriod,
                                                TwoYearVest.endTimestamp,
                                                TwoYearVest.totalAmount)
        
        expect(partnershipsVestTx.receipt).to.exist

        /// Confirm the vesting schedules
        const tx1 = await vesting.confirmVestingSchedule(EighteenMonthVest.startTimestamp,EighteenMonthVest.cliffTimestamp,
                                            EighteenMonthVest.lockPeriod,
                                            EighteenMonthVest.endTimestamp,
                                            EighteenMonthVest.totalAmount,
                                            {from: Team})

        expect(tx1.receipt).to.exist

        const tx2 = await vesting.confirmVestingSchedule(TwoYearVest.startTimestamp,
                                            TwoYearVest.cliffTimestamp,
                                            TwoYearVest.lockPeriod,
                                            TwoYearVest.endTimestamp,
                                            TwoYearVest.totalAmount,
                                            {from: Partnerships})
        
        expect(tx2.receipt).to.exist

        const balBeforeItAll = await token.balanceOf(Team)
        console.log(balBeforeItAll)
    })


})