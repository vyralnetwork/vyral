pragma solidity ^0.4.18;

import {Ownable} from "./traits/Ownable.sol";
import "./math/SafeMath.sol";
import "./Campaign.sol";
import "./Share.sol";
import {Vesting} from "./Vesting.sol";

import "../lib/ethereum-datetime/contracts/DateTime.sol";

contract VyralSale is Ownable {
    using SafeMath for uint;

    uint public constant MIN_CONTRIBUTION = 1 ether;
    
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

    Phase public phase;

    /** PRESALE PARAMS */
    uint public presaleStartTimestamp;
    uint public presaleEndTimestamp;
    uint public presaleRate;
    uint public presaleAllocation;

    bool public presaleCapReached;
    uint public soldPresale;

    /** CROWDSALE PARAMS */
    uint public saleStartTimestamp;
    uint public saleEndTimestamp;
    uint public saleRate;
    uint public saleAllocation;

    bool public saleCapReached;
    uint public soldSale;

    /** GLOBAL PARAMS */
    address public wallet;
    address public vestingWallet;
    Share public shareToken;
    Campaign public campaign;
    DateTime public dateTime;

    bool public vestingRegistered;

    uint public constant TOTAL_SUPPLY = 777777777 ether;

    uint public constant TEAM = TOTAL_SUPPLY.div(7);
    uint public constant PARTNERS = TOTAL_SUPPLY.div(7);
    uint public constant VYRAL_REWARDS = TOTAL_SUPPLY.div(7).mul(2);
    uint public constant SALE_ALLOCATION = TOTAL_SUPPLY.div(7).mul(3);

    /** MODIFIERS */
    modifier inPhase(Phase _phase) {
        require(phase == _phase);
        _;
    }

    modifier canBuy(Phase _phase) {
        require(phase == Phase.Presale || phase == Phase.Crowdsale);

        if (_phase == Phase.Presale) {
            require(block.timestamp >= presaleStartTimestamp);
        }
        if (_phase == Phase.Crowdsale) {
            require(block.timestamp >= saleStartTimestamp);
        }
        _;
    }

    modifier presaleOpenHours {
        uint8 hourUTC = dateTime.getHour(block.timestamp);
        require(hourUTC < 5 || hourUTC >= 16);
        _;
    }

    /** PHASES */

    function VyralSale() {
        phase = Phase.Deployed;

        shareToken = new Share();
        // shareToken = new Share(TOTAL_SUPPLY);
        dateTime = new DateTime();
    }

    function initialize(address _wallet,
                        uint _presaleStartTimestamp,
                        uint _presaleEndTimestamp,
                        uint _presaleAllocation)
        inPhase(Phase.Deployed)
        onlyOwner
        external returns (bool)
    {
        require(_wallet != 0x0);
        require(_presaleStartTimestamp > block.timestamp);
        require(_presaleEndTimestamp > _presaleStartTimestamp);
        require(_presaleAllocation < SALE_ALLOCATION);

        wallet = _wallet;
        presaleStartTimestamp = _presaleStartTimestamp;
        presaleEndTimestamp = _presaleEndTimestamp;
        presaleAllocation = _presaleAllocation;

        vestingWallet = new Vesting(address(shareToken));

        shareToken.approve(vestingWallet, TEAM.add(PARTNERS));
        shareToken.addTransferrer(vestingWallet);

        phase = Phase.Initialized;
        return true;
    }

    /// Step 1.5 - Register Vesting Schedules

    function startPresale()
        inPhase(Phase.Initialized)
        onlyOwner
        external returns (bool)
    {

        phase = Phase.Presale;
        return true;
    }

    function endPresale()
        inPhase(Phase.Presale)
        onlyOwner
        external returns (bool)
    {
        phase = Phase.Freeze;

        return true;
    }

    function readySale(uint _saleStartTimestamp,
                       uint _saleEndTimestamp)
        inPhase(Phase.Freeze)
        onlyOwner
        external returns (bool)
    {
        require(_saleStartTimestamp > block.timestamp);
        require(_saleEndTimestamp > _saleStartTimestamp);

        saleStartTimestamp = _saleStartTimestamp;
        saleEndTimestamp = _saleEndTimestamp;
        saleAllocation = SALE_ALLOCATION.sub(soldPresale);

        phase = Phase.Ready;
        return true;
    }

    function startSale()
        inPhase(Phase.Ready)
        onlyOwner
        external returns (bool)
    {
        phase = Phase.Crowdsale;
        return true;
    }

    function finalizeSale()
        inPhase(Phase.Crowdsale)
        onlyOwner
        external returns (bool)
    {
        phase = Phase.Finalized;
        return true;
    }

    function decomission() 
        inPhase(Phase.Finalized)
        onlyOwner
        external returns (bool)
    {
        phase = Phase.Decomissioned;
        return true;
    }

    /** BUY TOKENS */

    function ()
        public payable
    {
        if (phase == Phase.Presale) {
            buyPresale(0x0);
        }
        if (phase == Phase.Crowdsale) {
            buySale(0x0);
        }
        //else
        revert();
    }

    function buyPresale(address _vyralKey)
        inPhase(Phase.Presale)
        canBuy(Phase.Presale)
        presaleOpenHours
        public payable
    {
        require(msg.value >= MIN_CONTRIBUTION);
        require(!presaleCapReached);

        uint contribution = msg.value;

        uint purchased = contribution.mul(presaleRate);

        uint totalSold = soldPresale.add(purchased);
        uint excess;
        if (totalSold >= presaleAllocation) {
            excess = totalSold.sub(presaleAllocation);
            if (excess > 0) {
                purchased = purchased.sub(excess);
                contribution - contribution.sub(excess.div(presaleRate));
                msg.sender.transfer(excess.div(presaleRate));
            }
            presaleCapReached = true;
        }

        wallet.transfer(contribution);
        shareToken.transfer(msg.sender, purchased);

    }

    function buySale(address _vyralKey)
        inPhase(Phase.Crowdsale)
        canBuy(Phase.Crowdsale)
        public payable
    {
        require(msg.value >= MIN_CONTRIBUTION);
        require(!saleCapReached);

        uint contribution = msg.value;

        uint purchased = contribution.mul(saleRate);

        uint totalSold = soldSale.add(purchased);
        uint excess;
        if (totalSold >= saleAllocation) {
            excess = totalSold.sub(saleAllocation);
            if (excess > 0) {
                purchased = purchased.sub(excess);
                contribution = contribution.sub(excess.div(saleRate));
                msg.sender.transfer(excess.div(saleRate));
            }
            saleCapReached = true;
        }

        wallet.transfer(contribution);
        shareToken.transfer(msg.sender, purchased);
    }

    /** ADMIN SETTERS */

    /// TODO

    /** EMERGENCY SWITCH */
    bool public HALT;

    function toggleHALT(bool _on)
        onlyOwner 
        external returns (bool)
    {
        HALT = _on;
        return HALT;
    }

    /** LOGS */
    event PhaseShift(Phase phase);
    event Contribution(Phase phase, address buyer, uint contribtuion);
    event Referral(address referrer, address referree, uint reward);
}