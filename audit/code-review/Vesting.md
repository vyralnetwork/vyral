# Vesting

Source file [../../contracts/Vesting.sol](../../contracts/Vesting.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.17;

// BK Next 3 Ok
import 'contracts/traits/Ownable.sol';
import 'contracts/math/SafeMath.sol';
import 'installed_contracts/tokens/contracts/Token.sol';

// BK Ok
contract Vesting is Ownable {
    // BK Ok
    using SafeMath for uint;

    // BK Ok
    Token public vestingToken;          // The address of the vesting token.

    // BK Next block Ok
    struct VestingSchedule {
        uint startTimestamp;            // Timestamp of when vesting begins.
        uint cliffTimestamp;            // Timestamp of when the cliff begins.
        uint lockPeriod;                // Amount of time in seconds between withdrawal periods. (EG. 6 months or 1 month)
        uint endTimestamp;              // Timestamp of when vesting ends and tokens are completely available.
        uint totalAmount;               // Total amount of tokens to be vested.
        uint amountWithdrawn;           // The amount that has been withdrawn.
        address depositor;              // Address of the depositor of the tokens to be vested. (Crowdsale contract)
        bool isConfirmed;               // True if the registered address has confirmed the vesting schedule.
    }

    // The vesting schedule attached to a specific address.
    // BK Ok
    mapping (address => VestingSchedule) vestingSchedules;

    /// @dev Assigns a token to be vested in this contract.
    /// @param _token Address of the token to be vested.
    // BK Ok - Constructor
    function Vesting(address _token) public {
        vestingToken = Token(_token);
    }

    // BK Ok - Only owner can execute
    function registerVestingSchedule(address _newAddress,
                                    address _depositor,
                                    uint _startTimestamp,
                                    uint _cliffTimestamp,
                                    uint _lockPeriod,
                                    uint _endTimestamp,
                                    uint _totalAmount)
        public onlyOwner
    {
        // Check that we are registering a depositor and the address we register to vest to 
        //  does not already have a depositor.
        // BK Ok
        require( _depositor != 0x0 );
        // BK Ok
        require( vestingSchedules[_newAddress].depositor == 0x0 );

        // Validate that the times make sense.
        // BK Ok
        require( _cliffTimestamp >= _startTimestamp );
        // BK Ok
        require( _endTimestamp > _cliffTimestamp );

        // Some lock period sanity checks.
        // BK Ok
        require( _lockPeriod != 0 );
        // BK Ok 
        require( _endTimestamp.sub(_startTimestamp) > _lockPeriod );

        // Register the new address.
        // BK Next block Ok
        vestingSchedules[_newAddress] = VestingSchedule({
            startTimestamp: _startTimestamp,
            cliffTimestamp: _cliffTimestamp,
            lockPeriod: _lockPeriod,
            endTimestamp: _endTimestamp,
            totalAmount: _totalAmount,
            amountWithdrawn: 0,
            depositor: _depositor,
            isConfirmed: false
        });

        // Log that we registered a new address.
        // BK Ok - Log event
        VestingScheduleRegistered(
            _newAddress,
            _depositor,
            _startTimestamp,
            _lockPeriod,
            _cliffTimestamp,
            _endTimestamp,
            _totalAmount
        );
    }

    // BK Ok - Only beneficiary can execute
    function confirmVestingSchedule(uint _startTimestamp,
                                    uint _cliffTimestamp,
                                    uint _lockPeriod,
                                    uint _endTimestamp,
                                    uint _totalAmount)
        public
    {
        // BK Ok
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        // Check that the msg.sender has been registered but not confirmed yet.
        // BK Ok
        require( vestingSchedule.depositor != 0x0 );
        // BK Ok
        require( vestingSchedule.isConfirmed == false );

        // Validate the same information was registered that is being confirmed.
        // BK Ok
        require( vestingSchedule.startTimestamp == _startTimestamp );
        // BK Ok
        require( vestingSchedule.cliffTimestamp == _cliffTimestamp );
        // BK Ok
        require( vestingSchedule.lockPeriod == _lockPeriod );
        // BK Ok
        require( vestingSchedule.endTimestamp == _endTimestamp );
        // BK Ok
        require( vestingSchedule.totalAmount == _totalAmount );

        // Confirm the schedule and move the tokens here.
        // BK Ok
        vestingSchedule.isConfirmed = true;
        // BK Ok
        require(vestingToken.transferFrom(vestingSchedule.depositor, address(this), _totalAmount));

        // Log that the vesting schedule was confirmed.
        // BK Ok - Log event
        VestingScheduleConfirmed(
            msg.sender,
            vestingSchedule.depositor,
            vestingSchedule.startTimestamp,
            vestingSchedule.cliffTimestamp,
            vestingSchedule.lockPeriod,
            vestingSchedule.endTimestamp,
            vestingSchedule.totalAmount
        );
    }

    // BK Ok - Only beneficiary can execute, after cliff
    function withdrawVestedTokens()
        public 
    {
        // BK Ok
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        // Check that the vesting schedule was registered and it's after cliff time.
        // BK Ok
        require( vestingSchedule.isConfirmed == true );
        // BK Ok
        require( vestingSchedule.cliffTimestamp <= now );

        // BK Ok
        uint totalAmountVested = calculateTotalAmountVested(vestingSchedule);
        // BK Ok
        uint amountWithdrawable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);
        // BK Ok
        vestingSchedule.amountWithdrawn = totalAmountVested;

        // BK Ok
        if (amountWithdrawable > 0) {
            // BK Ok
            canWithdraw(vestingSchedule, amountWithdrawable);
            require( vestingToken.transfer(msg.sender, amountWithdrawable) );
            Withdraw(msg.sender, amountWithdrawable);
        }
    }

    // BK Ok - Internal view function
    function calculateTotalAmountVested(VestingSchedule _vestingSchedule)
        internal view returns (uint _amountVested)
    {
        // If it's past the end time, the whole amount is available.
        // BK Ok
        if (now >= _vestingSchedule.endTimestamp) {
            // BK Ok
            return _vestingSchedule.totalAmount;
        }

        // Otherwise, math
        // BK Ok
        uint durationSinceStart = now.sub(_vestingSchedule.startTimestamp);
        // BK Ok
        uint totalVestingTime = SafeMath.sub(_vestingSchedule.endTimestamp, _vestingSchedule.startTimestamp);
        // BK Ok
        uint vestedAmount = SafeMath.div(
            SafeMath.mul(durationSinceStart, _vestingSchedule.totalAmount),
            totalVestingTime
        );

        // BK Ok
        return vestedAmount;
    }

    /// @dev Checks to see if the amount is greater than the total amount divided by the lock periods.
    // BK Ok - Internal view function
    function canWithdraw(VestingSchedule _vestingSchedule, uint _amountWithdrawable)
        internal view
    {
        // BK Ok
        uint lockPeriods = (_vestingSchedule.endTimestamp.sub(_vestingSchedule.startTimestamp))
                                                         .div(_vestingSchedule.lockPeriod);

        // BK Ok
        if (now < _vestingSchedule.endTimestamp) {
            // BK Ok
            require( _amountWithdrawable >= _vestingSchedule.totalAmount.div(lockPeriods) );
        }
    }

    /** ADMIN FUNCTIONS */

    // BK Ok - Only owner can execute
    function revokeSchedule(address _addressToRevoke, address _addressToRefund)
        public onlyOwner
    {
        // BK Ok
        VestingSchedule storage vestingSchedule = vestingSchedules[_addressToRevoke];

        // BK Ok
        require( vestingSchedule.isConfirmed == true );
        // BK Ok
        require( _addressToRefund != 0x0 );

        // BK Next 2 Ok
        uint amountWithdrawable;
        uint amountRefundable;

        // BK Ok
        if (now < vestingSchedule.cliffTimestamp) {
            // Vesting hasn't started yet, return the whole amount
            // BK Ok
            amountRefundable = vestingSchedule.totalAmount;

            // BK Ok
            delete vestingSchedules[_addressToRevoke];
            // BK Ok
            require( vestingToken.transfer(_addressToRefund, amountRefundable) );
        // BK Ok
        } else {
            // Vesting has started, need to figure out how much hasn't been vested yet
            // BK Ok
            uint totalAmountVested = calculateTotalAmountVested(vestingSchedule);
            // BK Ok
            amountWithdrawable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);
            // BK Ok
            amountRefundable = vestingSchedule.totalAmount.sub(totalAmountVested);

            // BK Ok
            delete vestingSchedules[_addressToRevoke];
            // BK Ok
            require( vestingToken.transfer(_addressToRevoke, amountWithdrawable) );
            // BK Ok
            require( vestingToken.transfer(_addressToRefund, amountRefundable) );
        }

        // BK Ok - Log event
        VestingRevoked(_addressToRevoke, amountWithdrawable, amountRefundable);
    }

    /// @dev Changes the address for a schedule in the case of lost keys or other emergency events.
    // BK Ok - Only owner can execute
    function changeVestingAddress(address _oldAddress, address _newAddress)
        public onlyOwner
    {
        // BK Ok
        VestingSchedule storage vestingSchedule = vestingSchedules[_oldAddress];

        // BK Ok
        require( vestingSchedule.isConfirmed == true );
        // BK Ok
        require( _newAddress != 0x0 );
        // BK Ok
        require( vestingSchedules[_newAddress].depositor == 0x0 );

        // BK Ok
        VestingSchedule memory newVestingSchedule = vestingSchedule;
        // BK Ok
        delete vestingSchedules[_oldAddress];
        // BK Ok
        vestingSchedules[_newAddress] = newVestingSchedule;

        // BK Ok - Log event
        VestingAddressChanged(_oldAddress, _newAddress);
    }

    // BK Ok
    event VestingScheduleRegistered(
        address registeredAddress,
        address depositor,
        uint startTimestamp,
        uint cliffTimestamp,
        uint lockPeriod,
        uint endTimestamp,
        uint totalAmount
    );
    // BK Ok
    event VestingScheduleConfirmed(
        address registeredAddress,
        address depositor,
        uint startTimestamp,
        uint cliffTimestamp,
        uint lockPeriod,
        uint endTimestamp,
        uint totalAmount
    );
    // BK Next 3 Ok
    event Withdraw(address registeredAddress, uint amountWithdrawn);
    event VestingRevoked(address revokedAddress, uint amountWithdrawn, uint amountRefunded);
    event VestingAddressChanged(address oldAddress, address newAddress);
}


// Vesting Schedules
// ...................
// Team tokens will be vested over 18 months with a 1/3 vested after 6 months, 1/3 vested after 12 months and 1/3 vested 
// after 18 months. 
// Partnership and Development + Sharing Bounties + Reserves tokens will be vested over two years with 1/24 
// available upfront and 1/24 available each month after
```
