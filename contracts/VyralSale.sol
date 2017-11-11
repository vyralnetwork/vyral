pragma solidity ^0.4.18;

import "./Campaign.sol";
import "./Share.sol";

import '../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol';

/**
 * @title Vyral Sale
 * @dev The driver contract.
 */
contract VyralSale is Ownable {
    using SafeMath for uint;

    /// Some useful constants
    uint public constant ONE_MILLION = 1000000 * (10 ** uint(18));

    /// Minimum contribution amount.
    uint public constant SALE_MIN = 1 ether;

    /// Maximum contribtuion amount.
    uint public constant SALE_MAX = 50000 ether;

    /// Exchange rate 1 Ether = 1,700 SHAREs
    uint public constant SHARES_PER_ETH = 4825;

    /// Total tokens that can be minted
    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(18));

    /// Address at which to hold tokens for team and advisors
    address public VYRAL_TEAM = 0x0;

    /// Address at which to hold tokens for partnerships and development
    address public VYRAL_PARTNERSHIPS = 0x0;


    /// The sale can be in one of the following states
    enum Status {
        Created,
        Started,
        Ended,
        Finalized
    }

    // Current state of the sale
    Status public saleStatus;

    /// Funds collected so far.
    uint public weiRaised = 0;

    /// Sale start date (December 1, 2017)
    uint public saleBeginsAt = 1512086400; // TODO: can use type uint64 for timestamps.

    /// Sale duration
    uint public saleDuration = 30 days;

    /// Set after sale is over and tokens are allocated
    uint public saleFinalizedAt;

    /// Mapping from purchaser address to amount of ether spent
    mapping (address => uint) public purchases;

    /// Holds ETH deposits for Vyral
    address public wallet;

    /// Token in use
    Share public token;

    /// Vyral sale campaign
    Campaign campaign;

    /*
     * Modifiers
     */
    modifier ifExceedsMinPurchase {
        require(msg.value >= SALE_MIN);
        _;
    }

    modifier ifBelowHardCap {
        require(weiRaised.add(msg.value) <= SALE_MAX);
        _;
    }

    modifier inStatus(Status _status) {
        require(saleStatus == _status);
        _;
    }

    modifier notInStatus(Status _status) {
        require(saleStatus != _status);
        _;
    }


    /*
     * Events
     */
    event LogPurchase(address buyer, uint amount);

    /**
     * One of a kind.
     */
    function VyralSale(
        uint _budgetAmount,
        address _payoffStrategy
    ) {
        token = new Share(TOTAL_SUPPLY);
        token.transfer(this, token.totalSupply());

        campaign = new Campaign(address(token), _budgetAmount, _payoffStrategy);

        saleStatus = Status.Created;
    }


    /**
     * @dev By default, SHAREs are allocated if ETH is sent to this contract.
     */
    function()
        public
        payable
    {
        buyTokens(msg.sender);
    }

    /**
     * @dev Conclude the sale and begin minting process. Tokens are allocated as follows:
     *      A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
     *      B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
     *      C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
     *      D. Crowdsale 42.9% (3/7) - 333,333,333 SHARE
     */
    function finalize()
        external
        onlyOwner
        inStatus(Status.Ended)
        notInStatus(Status.Finalized)
    {
        uint totalSupply = weiRaised.mul(SHARES_PER_ETH);
        token.mint(totalSupply, address(wallet));

        uint oneSeventh = totalSupply.mul(143).div(1000);
        uint twoSevenths = totalSupply.mul(286).div(1000);
        uint threeSevenths = totalSupply.mul(429).div(1000);

        // A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
        token.transfer(VYRAL_TEAM, oneSeventh);

        // B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
        token.transfer(VYRAL_PARTNERSHIPS, oneSeventh);

        // C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
        token.transfer(campaign, twoSevenths);

        // D. Crowdsale 42.9% (3/7) - 333,333,333 SHARE
        uint crowdsaleAllocation = threeSevenths;   // TODO: use this variable

        saleStatus = Status.Finalized;
        saleFinalizedAt = now;
    }

    /**
     * @dev Send Ether, receive SHARE.
     *
     * @param buyer Address of buying contract or account
     */
    function buyTokens(
        address buyer
    )
        internal // TODO: Can make this public
        ifBelowHardCap
        ifExceedsMinPurchase
    {
        uint weiReceived = msg.value;
        uint shares = weiReceived * SHARES_PER_ETH;

        // Transfer funds to wallet
        wallet.transfer(msg.value);

        // Enough to buy any tokens?
        require(shares > 0);

//        // Running totals
//        purchases[buyer] = weiReceived.add(purchases[buyer]);
//        weiRaised = weiRaised.add(weiReceived);

        uint excessAmount = msg.value % SHARES_PER_ETH;
        uint purchaseAmount = msg.value - excessAmount;
        uint tokenPurchase = purchaseAmount / SHARES_PER_ETH;

        // Cannot purchase more tokens than this contract has available to sell
        require(tokenPurchase <= token.balanceOf(this));

        // Return any excess msg.value
        if (excessAmount > 0) {
            msg.sender.transfer(excessAmount);
        }

        // Transfer funds to wallet
        wallet.transfer(purchaseAmount);

        // Transfer tokens to buyer
        token.transfer(buyer, tokenPurchase);

        // Log event
        LogPurchase(buyer, weiReceived);
    }

}
