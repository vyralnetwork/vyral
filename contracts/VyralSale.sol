pragma solidity ^0.4.15;


import "./math/SafeMath.sol";
import "./traits/Ownable.sol";
import "./Campaign.sol";
import "./Share.sol";


/**
 * The driver contract.
 */
contract VyralSale is Ownable {

    using SafeMath for uint;


    /// Some useful constants
    uint public constant ONE_MILLION = 1000000 * 10 ** 18;

    ///
    uint public constant SALE_MIN = 1 ether;

    uint public constant SALE_MAX = 50000 ether;

    /// Exchange rate 1 Ether = 1,700 SHAREs
    uint public constant SHARES_PER_ETH = 1700;

    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(18));

    address public TEAM = 0x3a965407cEd5E62C5aD71dE491Ce7B23DA5331A4;


    /// The sale can be in one of the following states
    enum Status {
        Created,
        Started,
        Ended,
        Finalized
    }

    // Current state of the sale
    Status public saleStatus;

    /// Token in use
    Share public token = new Share();

    /// Funds collected so far.
    uint public weiRaised = 0;

    /// Sale start date (December 1, 2017)
    uint public saleBeginsAt = 1512086400;

    /// Sale duration
    uint public saleDuration = 30 days;

    /// Set after sale is over and tokens are allocated
    uint public saleFinalizedAt;

    /// Dictionary of Ether purchased by buyers
    mapping (address => uint) public purchases;

    /// Holds ETH deposits for Vyral
    address public multiSigWallet;

    /// Vyral token sale campaign
    Campaign vyralCampaign;

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
        if (saleStatus != _status) throw;
        _;
    }

    modifier notInStatus(Status _status) {
        if (saleStatus == _status) throw;
        _;
    }


    /*
     * Modifiers
     */

    event LogPurchase(address buyer, uint amount);

    /**
     * One of a kind.
     */
    function VyralSale(
        address _token,
        uint _budgetAmount,
        uint _rewardAmount,
        address _payoffStrategy
    ) {
        vyralCampaign = new Campaign(_token, _budgetAmount, _rewardAmount, _payoffStrategy);

        saleStatus = Status.Created;
    }


    /**
     * By default, SHAREs are allocated if ETH is sent to this contract.
     */
    function()
        public
        payable
    {
        buyTokens(msg.sender);
    }

    /**
     * Conclude the sale and begin minting process.
     * Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
     * Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
     * Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
     * Crowdsale 42.9% (3/7) - 333,333,333 SHARE
     */
    function finalize()
        external
        inStatus(Status.Ended)
        notInStatus(Status.Finalized)
    {
        uint purchasedSupply = weiRaised.mul(SHARES_PER_ETH);
        uint totalSupply = purchasedSupply.mul(1000).div(429);
        token.mint(totalSupply);

        // A. 14.3% allocated to team and advisors
        uint teamAllocation = totalSupply.mul(143) / 1000;
        token.transfer(TEAM, teamAllocation);

        saleStatus = Status.Finalized;
        saleFinalizedAt = now;
    }

    /**
     * @dev
     */
    function isSale()
    public
    constant
    returns (bool)
    {
        return (now > saleBeginsAt);
    }

    /**
     * @dev Returns true if sale has concluded.
     */
    function isSaleOver()
        public
        constant
        returns (bool)
    {
        return block.timestamp >= (saleBeginsAt + saleDuration);
    }

    /**
     * Send Ether, receive SHAREs.
     *
     * @param buyer Address of buying contract or account
     */
    function buyTokens(
        address buyer
    )
        internal
        ifBelowHardCap
        ifExceedsMinPurchase
    {
        uint weiReceived = msg.value;
        uint shares = weiReceived * SHARES_PER_ETH;

        // Transfer funds to wallet
        require(multiSigWallet.send(msg.value));

        // Enough to buy any tokens?
        require(shares > 0);

        // Running totals
        purchases[buyer] = weiReceived.add(purchases[buyer]);
        weiRaised = weiRaised.add(weiReceived);

        // Log event
        LogPurchase(buyer, weiReceived);
    }

}
