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
    uint public constant SALE_MAX = 77777 ether;

    /// Exchange rate 1 Ether = this many SHAREs
    uint public constant SHARES_PER_ETH = 4285;

    /*
     * Token constants
     */

    string public constant TOKEN_NAME = "Vyral Token";

    string public constant TOKEN_SYMBOL = "SHARE";

    uint8 public constant TOKEN_DECIMALS = 18;

    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(TOKEN_DECIMALS));

    uint public constant ONE_SEVENTH = 111111111 * (10 ** uint(TOKEN_DECIMALS));

    uint public constant TWO_SEVENTHS = 222222222 * (10 ** uint(TOKEN_DECIMALS));

    uint public constant THREE_SEVENTHS = 333333333 * (10 ** uint(TOKEN_DECIMALS));

    /*
     * Storage
     */

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

    /// In case of emergency
    bool public halted;

    /// Funds collected so far.
    uint public weiRaised = 0;

    /// Presale period
    uint public presaleStartTime;
    uint public presaleEndTime;
    uint public presaleDuration = 23 days;

    /// Sale period
    uint public saleStartTime;
    uint public saleEndTime;
    uint public saleDuration = 30 days;

    /// Set after sale is over and tokens are allocated
    uint public saleFinalizedAt;

    /// Mapping from purchaser address to amount of ether spent
    mapping (address => uint) public purchases;

    /// Holds ETH deposits for Vyral
    address public wallet;

    /// Address at which to hold tokens for team and advisors
    address public team;

    /// Address at which to hold tokens for partnerships and development
    address public partnerships;

    /// Token in use
    HumanStandardToken public token;

    /// Vyral sale campaign
    Campaign public campaign;

    /*
     * Modifiers
     */

    modifier isAtLeastMinPurchase {
        require(msg.value >= SALE_MIN);
        _;
    }

    modifier isBelowHardCap {
        require(weiRaised.add(msg.value) <= SALE_MAX);
        _;
    }

    modifier isNotHalted {
        assert(!halted);
        _;
    }

    modifier isAfter(uint timestamp) {
        assert(now >= timestamp);
        _;
    }

    modifier isBefore(uint timestamp) {
        assert(now < timestamp);
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
     *      C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 222,222,222 SHARE
     *      D. Crowdsale 42.8% (3/7) - 333,333,333 SHARE
     */
    function VyralSale(
        address _wallet,
        address _team,
        address _partnerships,
        uint _presaleStartTime,
        uint _saleStartTime
    )
        public
    {
        wallet = _wallet;
        team = _team;
        partnerships = _partnerships;

        presaleStartTime = _presaleStartTime;
        presaleEndTime = presaleStartTime + presaleDuration;

        saleStartTime = _saleStartTime;
        saleEndTime = saleStartTime + saleDuration;

        // Create SHARE token
        token = new HumanStandardToken(TOTAL_SUPPLY, TOKEN_NAME, TOKEN_DECIMALS, TOKEN_SYMBOL);

        // Create a campaign and set 28.6% (2/7) of tokens as budget
        campaign = new Campaign(address(token), TWO_SEVENTHS);

        // A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
        token.transfer(team, ONE_SEVENTH);

        // B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
        token.transfer(partnerships, ONE_SEVENTH);

        // C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 222,222,222 SHARE
        token.transfer(campaign, TWO_SEVENTHS);

        // D. Crowdsale 42.8% (3/7) - 333,333,333 SHARE
        token.transfer(this, THREE_SEVENTHS);

        saleStatus = Status.Ready;
    }


    /**
     * @dev By default, SHAREs are allocated if ETH is sent to this contract.
     */
    function()
        public
        payable
        isAtLeastMinPurchase
        isBelowHardCap
        isNotHalted
        inStatus(Status.SaleStarted)
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
        payable
//        isAtLeastMinPurchase
//        isBelowHardCap
//        isAfter(saleStartTime)
//        isBefore(saleEndTime)
//        isNotHalted
//        inStatus(Status.SaleStarted)
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
