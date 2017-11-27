pragma solidity ^0.4.18;

import "./math/SafeMath.sol";

library PresaleBonuses {
    using SafeMath for uint;

    function presaleBonusApplicator(uint _purchased, uint _presaleStartTimestamp)
        internal view returns (uint reward)
    {
        /// First hour bonus
        if (block.timestamp <= _presaleStartTimestamp.add(1 hours)) {
            return applyPercentage(_purchased, 70);
        }
        /// First day bonus
        if (block.timestamp <= _presaleStartTimestamp.add(12 hours)) {
            return applyPercentage(_purchased, 50);
        }
        /// Second day bonus
        if (block.timestamp <= _presaleStartTimestamp.add(12 hours).add(1 days)) {
            return applyPercentage(_purchased, 45);
        }
        /// Days 3 - 20 bonus
        if (block.timestamp <= _presaleStartTimestamp.add(12 hours).add(19 days)) {
            uint numDays = (block.timestamp.sub(_presaleStartTimestamp))
                                        .div(1 days);
            numDays = numDays.sub(2);
            return applyPercentage(_purchased, (45 - numDays));
        }
        /// Day 21 bonus
        if (block.timestamp <= _presaleStartTimestamp.add(12 hours).add(20 days)) {
            return applyPercentage(_purchased, 25);
        }
        /// Day 22 bonus
        if (block.timestamp <= _presaleStartTimestamp.add(12 hours).add(21 days)) {
            return applyPercentage(_purchased, 20);
        }
        /// Day 23 bonus
        if (block.timestamp <= _presaleStartTimestamp.add(12 hours).add(22 days)) {
            return applyPercentage(_purchased, 15);
        }
        //else
        revert();
    }

    /// Internal function to apply a specified percentage amount to an integer.
    function applyPercentage(uint _base, uint _percentage)
        internal pure returns (uint num)
    {
        num = _base.mul(_percentage).div(100);
    }
    
}