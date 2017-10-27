pragma solidity ^0.4.15;


import "./math/SafeMath.sol";
import "./traits/Ownable.sol";
import "./Campaign.sol";
import "./Share.sol";


/**
 * The driver contract.
 */
contract VyralSale is Ownable {

    using SafeMath for uint256;


    /// Some useful constants
    uint256 public constant ONE_MILLION = 1000000 * 10 ** 18;

    ///
    uint256 public constant SALE_MIN = 1 ether;

    uint256 public constant SALE_MAX = 50000 ether;

    /// Exchange rate 1 Ether = 1,700 SHAREs
    uint256 public constant TOKEN_PRICE = 1700;

    uint256 public constant TOTAL_SUPPLY = 777777777 * (10 ** uint256(decimals));

    /// Tokens available for sale in the 1st contribution period
    uint256 public constant TOKENS_FOR_FIRST_SALE = 40 * ONE_MILLION;

    uint256 public constant TOKENS_FOR_SECOND_SALE = 40 * ONE_MILLION;

    /// Tokens allocated for Decibel.LIVE employees
    uint256 public constant TOKENS_FOR_DECIBEL_LIVE = 20 * ONE_MILLION;

    /// Token in use
    Share public token = new Share();

    /// Tokens sold so far.
    uint256 public belsSold = 0;

    // Sale start date (October 1, 2017)
    uint public start = 1506816000;

    /// Dictionary of Ether purchased by buyers
    mapping (address => uint) public purchases;

    /// Dictionary of tokens sold to investors
    mapping (address => uint) public sales;

    /// Holds ETH deposits for Decibel.LIVE
    address public multiSigWallet;

    /// Vyral token sale campaign
    Campaign vyralCampaign;

    /*
     * Modifiers
     */

    modifier isGreaterThanMinPurchase {
        require(msg.value >= MIN_CONTRIBUTION);
        _;
    }

    modifier isBelowHardCap {
        require(weiRaised.add(msg.value) <= SALE_MAX);
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
        address token,
        uint256 budgetAmount,
        uint256 rewardAmount,
        address payoffStrategy
    ) {
        vyralCampaign = new Campaign(token, budgetAmount, rewardAmount, payoffStrategy);
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
     * Send Ether, receive SHAREs.
     *
     * @param buyer Address of buying contract or account
     */
    function buyTokens(
        address buyer
    )
        internal
        isBelowHardCap
        isGreaterThanMinPurchase
    {
        uint256 weiReceived = msg.value;
        uint256 shares = weiReceived * TOKEN_PRICE;

        // Transfer funds to wallet
        require(multiSigWallet.send(msg.value));

        // Enough to buy any tokens?
        require(shares > 0);

        // Running totals
        purchases[buyer] = weiReceived.add(purchases[buyer]);
        weiRaised = safeAdd(weiRaised, weiReceived);

        // Log event
        LogPurchase(buyer, weiReceived);
    }

}
