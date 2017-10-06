pragma solidity ^0.4.15;


/**
 * A contract to enforce ownership.
 */
contract Ownable {

    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    /// Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    /**
     * Assign a new owner.
     * @param newOwner  must be a valid address of a contract or an account
     */
    function transferOwnership(address newOwner)
    onlyOwner
    {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}
