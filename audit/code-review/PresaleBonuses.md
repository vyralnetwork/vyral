# PresaleBonuses

Source file [../../contracts/PresaleBonuses.sol](../../contracts/PresaleBonuses.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// BK Next 2 Ok
import "./math/SafeMath.sol";
import "../lib/ethereum-datetime/contracts/api.sol";

// BK Ok
library PresaleBonuses {
    // BK Ok
    using SafeMath for uint;

    // BK Ok - View function
    function presaleBonusApplicator(uint _purchased, address _dateTimeLib)
        internal view returns (uint reward)
    {
        // BK Next 3 Ok
        DateTimeAPI dateTime = DateTimeAPI(_dateTimeLib);
        uint hour = dateTime.getHour(block.timestamp);
        uint day = dateTime.getDay(block.timestamp);

        /// First 4 hours bonus
        // BK Next block Ok
        if (day == 2 && hour >= 16 && hour < 20) {
            return applyPercentage(_purchased, 70);
        }

        /// First day bonus
        // BK Next block Ok
        if ((day == 2 && hour >= 20) || (day == 3 && hour < 5)) {
            return applyPercentage(_purchased, 50);
        }

        /// Second day bonus
        // BK Next block Ok
        if ((day == 3 && hour >= 5) || (day == 4 && hour < 5)) {
            return applyPercentage(_purchased, 45);
        } 

        /// Days 3 - 20 bonus
        // BK Next block Ok
        if (day < 22) {
            uint numDays = day - 3;
            if (hour < 5) {
                numDays--;
            }

            return applyPercentage(_purchased, (45 - numDays));
        }

        /// Fill the gap
        // BK Next block Ok
        if (day == 22 && hour < 5) {
            return applyPercentage(_purchased, 27);
        }

        /// Day 21 bonus
        // BK Next block Ok
        if ((day == 22 && hour >= 5) || (day == 23 && hour < 5)) {
            return applyPercentage(_purchased, 25);
        }

        /// Day 22 bonus
        // BK Next block Ok
        if ((day == 23 && hour >= 5) || (day == 24 && hour < 5)) {
            return applyPercentage(_purchased, 20);
        }

        /// Day 23 bonus
        // BK Next block Ok
        if ((day == 24 && hour >= 5) || (day == 25 && hour < 5)) {
            return applyPercentage(_purchased, 15);
        }

        //else
        // BK Ok
        revert();
    }

    /// Internal function to apply a specified percentage amount to an integer.
    // BK Ok - Pure function
    function applyPercentage(uint _base, uint _percentage)
        internal pure returns (uint num)
    {
        // BK Ok
        num = _base.mul(_percentage).div(100);
    }
    
}
```
