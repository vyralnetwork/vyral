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
    function add(Reward.Payment payment1, Reward.Payment payment2) returns (Payment) {
        require(payment1.units == payment2.units);

        require(payment1.amount >= 0);
        require(payment2.amount >= 0);

        Payment memory sum = new Payment();
        sum.units = payment1.units;
        sum.amount = payment1.units;
        sum = payment1.amount.add(payment2.amount);
        return sum;
    }

    /**
     * Won't accept ETH
     */
    function Reward() {
    }

}