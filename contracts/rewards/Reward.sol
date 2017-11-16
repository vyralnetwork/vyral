pragma solidity ^0.4.18;

import "installed_contracts/tokens/contracts/HumanStandardToken.sol";

/**
 * @dev Represents an incentive for joining a campaign.
 */
library Reward {

    /**
     * @dev A {Payment} represents the value of a referral. This is the incentive offered by a campaign to both.
     */
    struct Payment {
        /// Token as payment
        address token;
        /// The amount being offered
        uint256 amount;
    }

    /**
     * @dev Returns sum of two payments if their units are same.
     */
    function add(Payment storage self, address token, uint256 amount)
        public
    {
        require(self.token == token);

        self.amount += amount;
    }

    /**
     * @dev Won't accept ETH
     */
    // function Reward() {
    // }

}
