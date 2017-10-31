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
    uint public constant ONE_MILLION = 1000000 * (10 ** uint(18));

    ///
    uint public constant SALE_MIN = 1 ether;

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
    uint public saleBeginsAt = 1512086400;

    /// Sale duration
    uint public saleDuration = 30 days;

    /// Set after sale is over and tokens are allocated
    uint public saleFinalizedAt;

    /// Dictionary of Ether purchased by buyers
    mapping (address => uint) public purchases;

    /// Holds ETH deposits for Vyral
    address public multiSigWallet;

    /// Token in use
    Share public vyralToken;

    /// Vyral sale campaign
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
        address _tokenSupply,
        uint _budgetAmount,
        address _payoffStrategy
    ) {
        token = new Share(_tokenSupply);
        token.transfer(this, token.totalSupply());

        vyralCampaign = new Campaign(address(_token), _budgetAmount, _payoffStrategy);

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
     * @dev Conclude the sale and begin minting process. Tokens are allocated as follows:
     *      A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
     *      B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
     *      C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
     *      D. Crowdsale 42.9% (3/7) - 333,333,333 SHARE
     */
    function finalize()
        external
        inStatus(Status.Ended)
        notInStatus(Status.Finalized)
    {
        uint totalSupply = weiRaised.mul(SHARES_PER_ETH);
        vyralToken.mint(totalSupply, address(multiSigWallet));

        uint oneSeventh = totalSupply.mul(143) / 1000;
        uint twoSevenths = totalSupply.mul(286) / 1000;
        uint threeSevenths = totalSupply.mul(429) / 1000;

        // A. Team & Advisor 14.3% (1/7) - 111,111,111 SHARE
        vyralToken.transfer(VYRAL_TEAM, oneSeventh);

        // B. Partnerships + Development + Sharing Bounties 14.3% (1/7) - 111,111,111 SHARE
        vyralToken.transfer(VYRAL_PARTNERSHIPS, oneSeventh);

        // C. Crowdsale Vyral Rewards & Remainder for Future Vyral Sales 28.6% (2/7) - 111,111,111 SHARE
        vyralToken.transfer(vyralCampaign, twoSevenths);

        // D. Crowdsale 42.9% (3/7) - 333,333,333 SHARE
        uint crowdsaleAllocation = threeSevenths;

        saleStatus = Status.Finalized;
        saleFinalizedAt = now;
    }

    /**
     * Send Ether, receive SHARE.
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
//        uint weiReceived = msg.value;
//        uint shares = weiReceived * SHARES_PER_ETH;
//
//        // Transfer funds to wallet
//        require(multiSigWallet.send(msg.value));
//
//        // Enough to buy any tokens?
//        require(shares > 0);
//
//        // Running totals
//        purchases[buyer] = weiReceived.add(purchases[buyer]);
//        weiRaised = weiRaised.add(weiReceived);

        uint excessAmount = msg.value % price;
        uint purchaseAmount = msg.value - excessAmount;
        uint tokenPurchase = purchaseAmount / SHARES_PER_ETH;

        // Cannot purchase more tokens than this contract has available to sell
        require(tokenPurchase <= token.balanceOf(this));

        // Return any excess msg.value
        if (excessAmount > 0) {
            msg.sender.transfer(excessAmount);
        }

        // Transfer funds to wallet
        multiSigWallet.transfer(purchaseAmount);

        // Transfer tokens to buyer
        token.transfer(buyer, tokenPurchase);

        // Log event
        LogPurchase(buyer, weiReceived);
    }

}
