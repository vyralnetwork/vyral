pragma solidity ^0.4.18;

import "./traits/Ownable.sol";
import './math/SafeMath.sol';
import "./Campaign.sol";
import "tokens/HumanStandardToken.sol";


/**
 * @title Vyral Sale
 * @dev The driver contract.
 */
contract VyralSale is Ownable {
    using SafeMath for uint;

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

    /*
     * Token constants
     */

    string public constant TOKEN_NAME = "Vyral Token";

    string public constant TOKEN_SYMBOL = "SHARE";

    uint8 public constant TOKEN_DECIMALS = 18;


    /// The sale can be in one of the following states
    enum Status {
        Ready,
        PresaleStarted,
        PresaleEnded,
        SaleStarted,
        SaleEnded,
        Finalized
    }

    // Current state of the sale
    Status public saleStatus;

    /// Funds collected so far.
    uint public weiRaised = 0;

    /// Sale start date (December 1, 2017)
    uint64 public saleBeginsAt = 1512086400;

    /// Sale duration
    uint public saleDuration = 30 days;

    /// Set after sale is over and tokens are allocated
    uint public saleFinalizedAt;

    /// Mapping from purchaser address to amount of ether spent
    mapping (address => uint) public purchases;

    /// Holds ETH deposits for Vyral
    address public wallet;

    /// Token in use
    HumanStandardToken public token;

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
     * @dev Begin sale. Tokens are allocated as follows:
     *      A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
     *      B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
     *      C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
     *      D. Crowdsale 42.9% (3/7) - 333,333,333 SHARE
     */
    function VyralSale(
        address _payoffStrategy
    )
        public
    {
        uint oneSeventh = TOTAL_SUPPLY.mul(143).div(1000);
        uint twoSevenths = TOTAL_SUPPLY.mul(286).div(1000);
        uint threeSevenths = TOTAL_SUPPLY.mul(429).div(1000);

        token = new HumanStandardToken(TOTAL_SUPPLY, TOKEN_NAME, TOKEN_DECIMALS, TOKEN_SYMBOL);

        // A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
        token.transfer(VYRAL_TEAM, oneSeventh);

        // B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
        token.transfer(VYRAL_PARTNERSHIPS, oneSeventh);

        // C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
        token.transfer(campaign, twoSevenths);

        // D. Crowdsale 42.9% (3/7) - 333,333,333 SHARE
        token.transfer(this, threeSevenths);

        // Create a campaign and set 28.6% (2/7) of tokens as budget
        campaign = new Campaign(address(token), twoSevenths, _payoffStrategy);

        saleStatus = Status.Ready;
    }


    /**
     * @dev By default, SHAREs are allocated if ETH is sent to this contract.
     */
    function()
        public
        payable
    {
        // Called without referral key
        buyTokens(0x0);
    }

    /**
     * @dev Send Ether, receive SHARE.
     *
     * @param _referrer Address of referrer
     */
    function buyTokens(
        address _referrer
    )
        public
        ifBelowHardCap
        ifExceedsMinPurchase
        inStatus(Status.SaleStarted)
    {
        address buyer = msg.sender;
        uint weiReceived = msg.value;
        uint shares = weiReceived * SHARES_PER_ETH;

        // Transfer funds to wallet
        wallet.transfer(msg.value);

        // Enough to buy any tokens?
        require(shares > 0);

        // Cannot purchase more tokens than this contract has available to sell
        require(shares <= token.balanceOf(this));

        // Transfer tokens to buyer
        token.transfer(buyer, shares);

        // Log event
        LogPurchase(buyer, weiReceived);
    }

    /**
     *
     */
    function finalize()
        external
        onlyOwner
        inStatus(Status.SaleEnded)
        notInStatus(Status.Finalized)
    {
        saleStatus = Status.Finalized;
        saleFinalizedAt = now;
    }
}
