pragma solidity ^0.4.17;

import 'contracts/Ownable.sol';
import 'contracts/math/SafeMath.sol';
import 'tokens/contracts/Token.sol';

contract Vesting is Ownable {
    using SafeMath for uint;

    Token public vestingToken;          // The address of the vesting token.

    struct VestingSchedule {
        uint startTimestamp;            // Timestamp of when vesting begins.
        uint cliffTimestamp;            // Timestamp of when the cliff begins.
        uint endTimestamp;              // Timestamp of when vesting ends and tokens are completely available.
        uint totalAmount;               // Total amount of tokens to be vested.
        uint amountWithdrawn;           // The amount that has been withdrawn.
        address depositor;              // Address of the depositor of the tokens to be vested. (Crowdsale contract)
        bool isConfirmed;               // True if the registered address has confirmed the vesting schedule.
    }

    // The vesting schedule attached to a specific address.
    mapping (address => VestingSchedule) vestingSchedules;

    /// @dev Assigns a token to be vested in this contract.
    /// @param _token Address of the token to be vested.
    function Vesting(address _token) public {
        vestingToken = Token(_token);
    }

    function registerVestingSchedule(address _newAddress,
                                    address _depositor,
                                    uint _startTimestamp,
                                    uint _cliffTimestamp,
                                    uint _endTimestamp,
                                    uint _totalAmount)
        public onlyOwner
    {
        // Check that we are registering a depositor and the address we register to vest to 
        //  does not already have a depositor.
        require( _depositor != 0x0 );
        require( vestingSchedules[_newAddress].depositor == 0x0 );

        // Validate that the times make sense.
        require( _cliffTimestamp > _startTimestamp );
        require( _endTimestamp > _cliffTimestamp );

        // Register the new address.
        vestingSchedules[_newAddress] = VestingSchedule({
            startTimestamp: _startTimestamp,
            cliffTimestamp: _cliffTimestamp,
            endTimestamp: _endTimestamp,
            totalAmount: _totalAmount,
            amountWithdrawn: 0,
            depositor: _depositor,
            isConfirmed: false
        });

        // Log that we registered a new address.
        VestingScheduleRegistered(
            _newAddress,
            _depositor,
            _startTimestamp,
            _cliffTimestamp,
            _endTimestamp,
            _totalAmount
        );
    }

    function confirmVestingSchedule(uint _startTimestamp,
                                    uint _cliffTimestamp,
                                    uint _endTimestamp,
                                    uint _totalAmount)
        public
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        // Check that the msg.sender has been registered but not confirmed yet.
        require( vestingSchedule.depositor != 0x0 );
        require( vestingSchedule.isConfirmed == false );

        // Validate the same information was registered that is being confirmed.
        require( vestingSchedule.startTimestamp == _startTimestamp );
        require( vestingSchedule.cliffTimestamp == _cliffTimestamp );
        require( vestingSchedule.endTimestamp == _endTimestamp );
        require( vestingSchedule.totalAmount == _totalAmount );

        // Confirm the schedule and move the tokens here.
        vestingSchedule.isConfirmed = true;
        require(vestingToken.transferFrom(vestingSchedule.depositor, address(this), _totalAmount));

        // Log that the vesting schedule was confirmed.
        VestingScheduleConfirmed(
            msg.sender,
            vestingSchedule.depositor,
            vestingSchedule.startTimestamp,
            vestingSchedule.cliffTimestamp,
            vestingSchedule.endTimestamp,
            vestingSchedule.totalAmount
        );
    }

    function withdrawVestedTokens()
        public 
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[msg.sender];

        // Check that the vesting schedule was registered and it's after cliff time.
        require( vestingSchedule.isConfirmed == true );
        require( vestingSchedule.cliffTimestamp <= now );

        uint totalAmountVested = calculateTotalAmountVested(vestingSchedule);
        uint amountWithdrawable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);
        vestingSchedule.amountWithdrawn = totalAmountVested;

        if (amountWithdrawable > 0) {
            require( vestingToken.transfer(msg.sender, amountWithdrawable) );
            Withdraw(msg.sender, amountWithdrawable);
        }
    }

    function calculateTotalAmountVested(VestingSchedule _vestingSchedule)
        internal view returns (uint _amountVested)
    {
        // If it's past the end time, the whole amount is available.
        if (now >= _vestingSchedule.endTimestamp) {
            return _vestingSchedule.totalAmount;
        }

        // Otherwise, math
        uint durationSinceStart = now.sub(_vestingSchedule.startTimestamp);
        uint totalVestingTime = SafeMath.sub(_vestingSchedule.endTimestamp, _vestingSchedule.startTimestamp);
        uint vestedAmount = SafeMath.div(
            SafeMath.mul(durationSinceStart, _vestingSchedule.totalAmount),
            totalVestingTime
        );

        return vestedAmount;
    }

    /** ADMIN FUNCTIONS */

    function revokeSchedule(address _addressToRevoke, address _addressToRefund)
        public onlyOwner
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[_addressToRevoke];

        require( vestingSchedule.isConfirmed == true );
        require( _addressToRefund != 0x0 );

        uint amountWithdrawable;
        uint amountRefundable;

        if (now < vestingSchedule.cliffTimestamp) {
            // Vesting hasn't started yet, return the whole amount
            amountRefundable = vestingSchedule.totalAmount;

            delete vestingSchedules[_addressToRevoke];
            require( vestingToken.transfer(_addressToRefund, amountRefundable) );
        } else {
            // Vesting has started, need to figure out how much hasn't been vested yet
            uint totalAmountVested = calculateTotalAmountVested(vestingSchedule);
            amountWithdrawable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);
            amountRefundable = totalAmountVested.sub(vestingSchedule.amountWithdrawn);

            delete vestingSchedules[_addressToRevoke];
            require( vestingToken.transfer(_addressToRevoke, amountWithdrawable) );
            require( vestingToken.transfer(_addressToRefund, amountRefundable) );
        }

        VestingRevoked(_addressToRevoke, amountWithdrawable, amountRefundable);
    }

    /// @dev Changes the address for a schedule in the case of lost keys or other emergency events.
    function changeVestingAddress(address _oldAddress, address _newAddress)
        public onlyOwner
    {
        VestingSchedule storage vestingSchedule = vestingSchedules[_oldAddress];

        require( vestingSchedule.isConfirmed == true );
        require( _newAddress != 0x0 );

        VestingSchedule memory newVestingSchedule = vestingSchedule;
        delete vestingSchedules[_oldAddress];
        vestingSchedules[_newAddress] = newVestingSchedule;

        VestingAddressChanged(_oldAddress, _newAddress);
    }

    event VestingScheduleRegistered(
        address registeredAddress,
        address depositor,
        uint startTimestamp,
        uint cliffTimestamp,
        uint endTimestamp,
        uint totalAmount
    );
    event VestingScheduleConfirmed(
        address registeredAddress,
        address depositor,
        uint startTimestamp,
        uint cliffTimestamp,
        uint endTimestamp,
        uint totalAmount
    );
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