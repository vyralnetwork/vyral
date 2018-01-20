# VyralSale

Source file [../../contracts/VyralSale.sol](../../contracts/VyralSale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;


// BK Next 7 Ok
import {Ownable} from "./traits/Ownable.sol";
import "./math/SafeMath.sol";
import {Campaign} from "./Campaign.sol";
import "./Share.sol";
import {Vesting} from "./Vesting.sol";
import "./PresaleBonuses.sol";
import "../lib/ethereum-datetime/contracts/DateTime.sol";

// BK Ok
contract VyralSale is Ownable {
    // BK Ok
    using SafeMath for uint;

    // BK Ok
    uint public constant MIN_CONTRIBUTION = 1 ether;

    // BK Next block Ok
    enum Phase {
        Deployed,       //0
        Initialized,    //1
        Presale,        //2
        Freeze,         //3
        Ready,          //4
        Crowdsale,      //5
        Finalized,      //6
        Decomissioned   //7
    }

    // BK Ok
    Phase public phase;

    /**
     * PRESALE PARAMS
     */

    // BK Ok
    uint public presaleStartTimestamp;

    // BK Ok
    uint public presaleEndTimestamp;

    // BK Ok
    uint public presaleRate;

    // BK Ok
    uint public presaleCap;

    // BK Ok
    bool public presaleCapReached;

    // BK Ok
    uint public soldPresale;

    /**
     * CROWDSALE PARAMS
     */

    // BK Ok
    uint public saleStartTimestamp;

    // BK Ok
    uint public saleEndTimestamp;

    // BK Ok
    uint public saleRate;

    // BK Ok
    uint public saleCap;

    // BK Ok
    bool public saleCapReached;

    // BK Ok
    uint public soldSale;

    /**
     * GLOBAL PARAMS
     */
    // BK Ok
    address public wallet;

    // BK Ok
    address public vestingWallet;

    // BK Ok
    Share public shareToken;

    // BK Ok
    Campaign public campaign;

    // BK Ok
    DateTime public dateTime;

    // BK NOTE - This variable is unused
    bool public vestingRegistered;

    /**
     * Token and budget allocation constants
     */
    // BK Ok
    uint public constant TOTAL_SUPPLY = 777777777 * (10 ** uint(18));

    // BK Ok
    uint public constant TEAM = TOTAL_SUPPLY.div(7);

    // BK Ok
    uint public constant PARTNERS = TOTAL_SUPPLY.div(7);

    // BK Ok
    uint public constant VYRAL_REWARDS = TOTAL_SUPPLY.div(7).mul(2);

    // BK Ok
    uint public constant SALE_ALLOCATION = TOTAL_SUPPLY.div(7).mul(3);

    /**
     * MODIFIERS
     */

    // BK Ok
    modifier inPhase(Phase _phase) {
        // BK Ok
        require(phase == _phase);
        // BK Ok
        _;
    }

    // BK Ok
    modifier canBuy(Phase _phase) {
        // BK Ok
        require(phase == Phase.Presale || phase == Phase.Crowdsale);

        // BK Ok
        if (_phase == Phase.Presale) {
            // BK Ok
            require(block.timestamp >= presaleStartTimestamp);
        }
        // BK Ok
        if (_phase == Phase.Crowdsale) {
            // BK Ok
            require(block.timestamp >= saleStartTimestamp);
        }
        // BK Ok
        _;
    }

    // BK Ok
    modifier stopInEmergency {
        // BK Ok
        require(!HALT);
        // BK Ok
        _;
    }

    /**
     * PHASES
     */

    /**
     * Initialize Vyral sales.
     */
    // BK Ok - Constructor
    function VyralSale(
        address _share,
        address _datetime
    )
        public
    {
        // BK Ok
        phase = Phase.Deployed;

        // BK Ok
        shareToken = Share(_share);
        // BK Ok
        dateTime = DateTime(_datetime);
    }

    // BK Ok - Only owner can execute
    function initPresale(
        address _wallet,
        uint _presaleStartTimestamp,
        uint _presaleEndTimestamp,
        uint _presaleCap,
        uint _presaleRate
    )
        // BK Ok
        inPhase(Phase.Deployed)
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Next 4 Ok
        require(_wallet != 0x0);
        require(_presaleStartTimestamp >= block.timestamp);
        require(_presaleEndTimestamp > _presaleStartTimestamp);
        require(_presaleCap < SALE_ALLOCATION.div(_presaleRate));

        /// Campaign must be set first.
        // BK Ok
        require(address(campaign) != 0x0);

        // BK Next 5 Ok
        wallet = _wallet;
        presaleStartTimestamp = _presaleStartTimestamp;
        presaleEndTimestamp = _presaleEndTimestamp;
        presaleCap = _presaleCap;
        presaleRate = _presaleRate;

        // BK Ok
        shareToken.transfer(address(campaign), VYRAL_REWARDS);

        // BK Ok
        phase = Phase.Initialized;
        // BK Ok
        return true;
    }

    /// Step 1.5 - Register Vesting Schedules

    // BK Ok - Only owner can execute
    function startPresale()
        // BK Ok
        inPhase(Phase.Initialized)
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        phase = Phase.Presale;
        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function endPresale()
        // BK Ok
        inPhase(Phase.Presale)
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        phase = Phase.Freeze;
        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function initSale(
        uint _saleStartTimestamp,
        uint _saleEndTimestamp,
        uint _saleRate
    )
        // BK Ok
        inPhase(Phase.Freeze)
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Next 2 Ok
        require(_saleStartTimestamp >= block.timestamp);
        require(_saleEndTimestamp > _saleStartTimestamp);

        // BK Next 3 Ok
        saleStartTimestamp = _saleStartTimestamp;
        saleEndTimestamp = _saleEndTimestamp;
        saleRate = _saleRate;
        // BK Ok
        saleCap = (SALE_ALLOCATION.div(_saleRate)).sub(presaleCap);
        // BK Ok
        phase = Phase.Ready;
        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function startSale()
        // BK Ok
        inPhase(Phase.Ready)
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        phase = Phase.Crowdsale;
        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function finalizeSale()
        // BK Ok
        inPhase(Phase.Crowdsale)
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        phase = Phase.Finalized;
        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function decomission()
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        phase = Phase.Decomissioned;
        // BK Ok
        return true;
    }

    /** BUY TOKENS */

    // BK Ok - Fallback function, payable
    function()
        // BK Ok
        stopInEmergency
        // BK Ok
        public payable
    {
        // BK Ok
        if (phase == Phase.Presale) {
            // BK Ok
            buyPresale(0x0);
        // BK Ok
        } else if (phase == Phase.Crowdsale) {
            // BK Ok
            buySale(0x0);
        // BK Ok
        } else {
            // BK Ok
            revert();
        }
    }

    // BK Ok - Presale contribution, payable
    function buyPresale(address _referrer)
        // BK Ok
        inPhase(Phase.Presale)
        // BK Ok
        canBuy(Phase.Presale)
        // BK Ok
        stopInEmergency
        // BK Ok
        public payable
    {
        // BK Ok
        require(msg.value >= MIN_CONTRIBUTION);
        // BK Ok
        require(!presaleCapReached);

        // BK Ok
        uint contribution = msg.value;
        // BK Ok
        uint purchased = contribution.mul(presaleRate);
        // BK Ok
        uint totalSold = soldPresale.add(contribution);

        // BK Ok
        uint excess;

        // extra ether sent
        // BK Ok
        if (totalSold >= presaleCap) {
            // BK Ok
            excess = totalSold.sub(presaleCap);
            // BK Ok
            if (excess > 0) {
                // BK Ok
                purchased = purchased.sub(excess.mul(presaleRate));
                // BK Ok
                contribution = contribution.sub(excess);
                // BK Ok
                msg.sender.transfer(excess);
            }
            // BK Ok
            presaleCapReached = true;
        }

        // BK Ok
        soldPresale = totalSold;
        // BK Ok
        wallet.transfer(contribution);
        // BK Ok
        shareToken.transfer(msg.sender, purchased);

        /// Calculate reward and send it from campaign.
        // BK Ok
        uint reward = PresaleBonuses.presaleBonusApplicator(purchased, address(dateTime));
        // BK Ok
        campaign.sendReward(msg.sender, reward);

        // BK Ok
        if (_referrer != address(0x0)) {
            // BK Ok
            uint referralReward = campaign.join(_referrer, msg.sender, purchased);
            // BK Ok
            campaign.sendReward(_referrer, referralReward);
            // BK Ok - Log event
            LogReferral(_referrer, msg.sender, referralReward);
        }

        // BK Ok - Log event
        LogContribution(phase, msg.sender, contribution);
    }

    // BK Ok - Sale contribution, payable
    function buySale(address _referrer)
        // BK Ok
        inPhase(Phase.Crowdsale)
        // BK Ok
        canBuy(Phase.Crowdsale)
        // BK Ok
        stopInEmergency
        public payable
    {
        // BK Ok
        require(msg.value >= MIN_CONTRIBUTION);
        // BK Ok
        require(!saleCapReached);

        // BK Next 3 Ok
        uint contribution = msg.value;
        uint purchased = contribution.mul(saleRate);
        uint totalSold = soldSale.add(contribution);

        // BK Ok
        uint excess;

        // extra ether sent
        // BK Ok
        if (totalSold >= saleCap) {
            // BK Ok
            excess = totalSold.sub(saleCap);
            // BK Ok
            if (excess > 0) {
                // BK Ok
                purchased = purchased.sub(excess.mul(saleRate));
                // BK Ok
                contribution = contribution.sub(excess);
                // BK Ok
                msg.sender.transfer(excess);
            }
            // BK Ok
            saleCapReached = true;
        }

        // BK Ok
        soldSale = totalSold;
        // BK Ok
        wallet.transfer(contribution);
        // BK Ok
        shareToken.transfer(msg.sender, purchased);

        // BK Ok
        if (_referrer != address(0x0)) {
            // BK Ok
            uint referralReward = campaign.join(_referrer, msg.sender, purchased);
            // BK Ok
            campaign.sendReward(_referrer, referralReward);
            // BK Ok - Log event
            LogReferral(_referrer, msg.sender, referralReward);
        }

        // BK Ok - Log event
        LogContribution(phase, msg.sender, contribution);
    }

    /**
     * ADMIN SETTERS
     */

    // BK Ok - Only owner can execute
    function setPresaleParams(
        uint _presaleStartTimestamp,
        uint _presaleEndTimestamp,
        uint _presaleRate,
        uint _presaleCap
    )
        // BK Ok
        onlyOwner
        // BK Ok
        inPhase(Phase.Initialized)
        external returns (bool)
    {
        // BK Next 3 Ok
        require(_presaleStartTimestamp >= block.timestamp);
        require(_presaleEndTimestamp > _presaleStartTimestamp);
        require(_presaleCap < SALE_ALLOCATION.div(_presaleRate));

        // BK Next 4 Ok
        presaleStartTimestamp = _presaleStartTimestamp;
        presaleEndTimestamp = _presaleEndTimestamp;
        presaleRate = _presaleRate;
        presaleCap = _presaleCap;
    }

    // BK Ok - Only owner can execute
    function setCrowdsaleParams(
        uint _saleStartTimestamp,
        uint _saleEndTimestamp,
        uint _saleRate
    )
        // BK Ok
        onlyOwner
        // BK Ok
        inPhase(Phase.Ready)
        external returns (bool)
    {
        // BK Next 2 Ok
        require(_saleStartTimestamp >= block.timestamp);
        require(_saleEndTimestamp > _saleStartTimestamp);

        // BK Next 3 Ok
        saleStartTimestamp = _saleStartTimestamp;
        saleEndTimestamp = _saleEndTimestamp;
        saleRate = _saleRate;
        // BK Ok
        saleCap = (SALE_ALLOCATION.div(_saleRate)).sub(presaleCap);
    }

    // BK Ok - Only owner can execute
    function rewardBeneficiary(
        address _beneficiary,
        uint _tokens
    )
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        return campaign.sendReward(_beneficiary, _tokens);
    }

    // BK Ok - Only owner can execute
    function distributeTimelockedTokens(
        address _beneficiary,
        uint _tokens
    )
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        return shareToken.transfer(_beneficiary, _tokens);
    }

    // BK Ok - Only owner can execute
    function replaceDecomissioned(address _newAddress)
        // BK Ok
        onlyOwner
        // BK Ok
        inPhase(Phase.Decomissioned)
        external returns (bool)
    {
        // BK Ok
        uint allTokens = shareToken.balanceOf(address(this));
        // BK Ok
        shareToken.transfer(_newAddress, allTokens);
        // BK Ok
        campaign.transferOwnership(_newAddress);

        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function setCampaign(
        address _newCampaign
    )
        // BK Ok
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        require(address(campaign) != _newCampaign && _newCampaign != 0x0);
        // BK Ok
        campaign = Campaign(_newCampaign);

        // BK Ok
        return true;
    }

    // BK Ok - Only owner can execute
    function setVesting(
        address _newVesting
    )
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        require(address(vestingWallet) != _newVesting && _newVesting != 0x0);
        // BK Ok
        vestingWallet = Vesting(_newVesting);
        // BK Ok
        shareToken.approve(address(vestingWallet), TEAM.add(PARTNERS));

        // BK Ok
        return true;
    }

    /**
     * EMERGENCY SWITCH
     */
    // BK Ok
    bool public HALT = false;

    // BK Ok
    function toggleHALT(bool _on)
        onlyOwner
        external returns (bool)
    {
        // BK Ok
        HALT = _on;
        // BK Ok
        return HALT;
    }

    /**
     * LOGS
     */
    // BK Ok - Event
    event LogContribution(Phase phase, address buyer, uint contribution);

    // BK Ok - Event
    event LogReferral(address referrer, address invitee, uint referralReward);
}
```
