pragma solidity ^0.4.11;


import "../math/SafeMath.sol";


/**
 * Represents an incentive for joining a campaign.
 */
library Reward {

    using SafeMath for uint256;

    /**
     * A {Payment} represents the value of a referral. This is the incentive offered by a campaign to both.
     */
    struct Payment {
        /// GigaBytes, Fiat Currency (USD), Tokens etc.
        string units;
        /// The amount being offered
        uint256 amount;
    }


    /**
     * Returns sum of two payments if their units are same.
     */
    function add(Payment storage self, string units, uint256 amount) {
        require(sha3(self.units) == sha3(units));

        require(amount >= 0);

        self.amount.add(amount);
    }

    /**
     * Won't accept ETH
     */
    function Reward() {
    }

}