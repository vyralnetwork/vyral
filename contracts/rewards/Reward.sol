pragma solidity ^0.4.11;


import "../math/SafeMath.sol";
import "../tokens/ERC20.sol";


/**
 * Represents an incentive for joining a campaign.
 */
library Reward {

    using SafeMath for uint256;

    /**
     * A {Payment} represents the value of a referral. This is the incentive offered by a campaign to both.
     */
    struct Payment {
        /// Token as payment
        ERC20 token;
        /// The amount being offered
        uint256 amount;
    }


    /**
     * Returns sum of two payments if their units are same.
     */
    function add(Payment storage self, address token, uint256 amount) {
        require(self.token == token);

        require(amount >= 0);

        self.amount.add(amount);
    }

    /**
     * Won't accept ETH
     */
    function Reward() {
    }

}