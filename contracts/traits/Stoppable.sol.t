pragma solidity ^0.4.0;


import "./Ownable.sol";


/**
 * Stop, resume controls. Throws is called in invalid state.
 */
contract Stoppable is Ownable {

    bool public stopped;


    modifier onlyInEmergency {
        require(!stopped);
        _;
    }


    function stop() external onlyOwner {
        stopped = true;
    }


    function resume() external onlyOwner onlyInEmergency {
        stopped = false;
    }
}
