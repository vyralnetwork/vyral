pragma soldity ^0.4.18;

import "./traits/Ownable.sol";
import "./math/Safemath.sol";
import "./Campaign.sol";
import "./Share.sol";
import "./Vesting.sol";

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
    uint public o;

    /** CROWDSALE PARAMS */
    uint public crowdsaleStartTimestamp;
    uint public crowdsaleEndTimestamp;

    /** GLOBAL PARAMS */
    address public wallet;
    address public vestingWallet;
    Share public shareToken;
    Campaign public campaign;

    /** MODIFIERS */
    function inPhase(Phase _phase) {
        require(phase == _phase);
        _;
    }

    function VyralSale(uint _totalSupply) {
        phase = Phase.Deployed;

        shareToken = new Share(_totalSupply);
    }

    function initialize(address _wallet,
                        uint _presaleStartTimestamp,
                        uint _presaleEndTimestamp)
        inPhase(Phase.Deployed)
        onlyOwner
        external returns (bool)
    {
        require(_wallet != 0x0);
        require(_presaleStartTimestamp > block.timestamp);
        require(_presaleEndTimestamp > _presaleStartTimestamp);

        wallet = _wallet;
        presaleStartTimestamp = _presaleStartTimestamp;
        presaleEndTimestamp = _presaleEndTimestamp;

        vestingWallet = new Vesting(address(shareToken));

        phase = Phase.Initialized;

        return true;
    }

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

    function readySale()
        inPhase(Phase.Freeze)
        onlyOwner
        external returns (bool)
    {
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
        public payable
    {

    }

    function buySale(address _vyralKey)
        inPhase(Phase.Crowdsale)
        public payable
    {

    }

}