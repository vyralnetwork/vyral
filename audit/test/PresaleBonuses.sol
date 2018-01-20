pragma solidity ^0.4.18;

import "./math/SafeMath.sol";
import "./api.sol";

library PresaleBonuses {
    using SafeMath for uint;

    function presaleBonusApplicator(uint _purchased, address _dateTimeLib)
        internal view returns (uint reward)
    {
        DateTimeAPI dateTime = DateTimeAPI(_dateTimeLib);
        uint hour = dateTime.getHour(block.timestamp);
        uint day = dateTime.getDay(block.timestamp);

        return applyPercentage(_purchased, 0);
        /*
        /// First 4 hours bonus
        if (day == 2 && hour >= 16 && hour < 20) {
            return applyPercentage(_purchased, 70);
        }

        /// First day bonus
        if ((day == 2 && hour >= 20) || (day == 3 && hour < 5)) {
            return applyPercentage(_purchased, 50);
        }

        /// Second day bonus
        if ((day == 3 && hour >= 5) || (day == 4 && hour < 5)) {
            return applyPercentage(_purchased, 45);
        } 

        /// Days 3 - 20 bonus
        if (day < 22) {
            uint numDays = day - 3;
            if (hour < 5) {
                numDays--;
            }

            return applyPercentage(_purchased, (45 - numDays));
        }

        /// Fill the gap
        if (day == 22 && hour < 5) {
            return applyPercentage(_purchased, 27);
        }

        /// Day 21 bonus
        if ((day == 22 && hour >= 5) || (day == 23 && hour < 5)) {
            return applyPercentage(_purchased, 25);
        }

        /// Day 22 bonus
        if ((day == 23 && hour >= 5) || (day == 24 && hour < 5)) {
            return applyPercentage(_purchased, 20);
        }

        /// Day 23 bonus
        if ((day == 24 && hour >= 5) || (day == 25 && hour < 5)) {
            return applyPercentage(_purchased, 15);
        }

        //else
        revert();
        */
    }

    /// Internal function to apply a specified percentage amount to an integer.
    function applyPercentage(uint _base, uint _percentage)
        internal pure returns (uint num)
    {
        num = _base.mul(_percentage).div(100);
    }
    
}