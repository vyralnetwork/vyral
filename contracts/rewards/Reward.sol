pragma solidity ^0.4.18;

import '../../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';
import '../../node_modules/zeppelin-solidity/contracts/token/StandardToken.sol';

/**
 * @dev Represents an incentive for joining a campaign.
 */
library Reward {
    using SafeMath for uint256;

    /**
     * @dev A {Payment} represents the value of a referral. This is the incentive offered by a campaign to both.
     */
    struct Payment {
        /// Token as payment
        StandardToken token;
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
        require(amount >= 0); // TODO: Is this check needed since a uint256 cannot be neg??

        self.amount.add(amount);
    }

    /**
     * @dev Won't accept ETH
     */
    // function Reward() {
    // }

}
