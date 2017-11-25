pragma solidity ^0.4.18;

import "./math/SafeMath.sol";

library PresaleBonuses {
    using SafeMath for uint;

    function presaleBonusApplicator(uint _contribution, uint _presaleStartTimestamp)
        internal view returns (uint reward)
    {
        if (block.timestamp <= _presaleStartTimestamp.add(1 hours)) {
            return applyPercentage(_contribution, 70);
        }
        if (block.timestamp <= _presaleStartTimestamp.add(1 days)) {
            return applyPercentage(_contribution, 50);
        }
        if (block.timestamp <= _presaleStartTimestamp.add(2 days)) {
            return applyPercentage(_contribution, 45);
        }
        if (block.timestamp <= _presaleStartTimestamp.add(20 days)) {
            uint numDays = (block.timestamp.sub(_presaleStartTimestamp))
                                        .div(1 days);
            numDays = numDays.sub(2);
            return applyPercentage(_contribution, (45 - numDays));
        }
        if (block.timestamp <= _presaleStartTimestamp.add(21 days)) {
            return applyPercentage(_contribution, 25);
        }
        if (block.timestamp <= _presaleStartTimestamp.add(22 days)) {
            return applyPercentage(_contribution, 20);
        }
        if (block.timestamp <= _presaleStartTimestamp.add(23 days)) {
            return applyPercentage(_contribution, 15);
        }
        //else
        revert();
    }

    function applyPercentage(uint _base, uint _percentage)
        internal pure returns (uint num)
    {
        num = _base.mul(_percentage).div(100);
    }
    
}