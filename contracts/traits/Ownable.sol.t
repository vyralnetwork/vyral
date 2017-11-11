pragma solidity ^0.4.18;

/**
 * @title Ownable 
 * @dev A contract to enforce ownership.
 */
contract Ownable {

    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    /// Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * Assign a new owner.
     * @param newOwner  must be a valid address of a contract or an account
     */
    function transferOwnership (
        address newOwner
    )
        onlyOwner
        public
    {
        require(newOwner != address(0));
        owner = newOwner;
    }
}
