pragma solidity ^0.4.18;

/**
 * @title Lockable
 * @dev Adds a locking property to a contract.
 */
contract Lockable {
    bool public locked;

    modifier onlyUnlocked() {
        require(!locked);
        _;
    }

    /// TODO: function lock(bool _locked) {
    ///         locked = _locked;
    ///        }

}