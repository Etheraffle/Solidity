pragma solidity^0.4.21;

/* solium-disable */

contract EtheraffleInterface {
    function getUserNumEntries(address _entrant, uint _week) returns (uint) {}
}

contract LOTInterface {
    function transfer(address _to, uint _value) {}
    function balanceOf(address _owner) returns (uint) {}
}

contract Promo is EtheraffleInterface {
    
    address etheraffle;
    bool public isActive;
    uint public rate;

    uint constant public RAFEND   = 500400;// 7:00pm Saturdays
    uint constant public BIRTHDAY = 1500249600;// Etheraffle's birthday <3
    uint constant public ICOSTART = 1522281600;//Thur 29th March 2018
    uint constant public TIER1END = 1523491200;//Thur 12th April 2018
    uint constant public TIER2END = 1525305600;//Thur 3rd May 2018
    uint constant public TIER3END = 1527724800;//Thur 31st May 2018
    
    LOTInterface LOTContract;
    EtheraffleInterface etheraffleContract;

    /* Mapping of  user address to weekNo to claimed bool */
    mapping (address => mapping (uint => bool)) public claimed;
    
    event LogActiveStatus(bool currentStatus, uint atTime);
    event LogTokenDeposit(address fromWhom, uint tokenAmount, bytes data);
    event LogLOTClaim(address whom, uint howMany, uint inWeek, uint atTime);
    /*
     * @dev     Modifier requiring function caller to be the Etheraffle 
     *          multisig wallet address
     */
    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    /*
     * @dev     Constructor - sets promo running and instantiates required
     *          contracts.
     * @param _er       Etheraffle contract address
     * @param _LOT      LOT token contract address
     * @param _erMsig   Etheraffle multisig address
     */
    //'0x4251139bf01d46884c95b27666c9e317df68b876','0xafd9473dfe8a49567872f93c1790b74ee7d92a9f','0x97f535e98cf250cdd7ff0cb9b29e4548b609a0bd'
    function Promo(address _er, address _LOT, address _erMsig) public {
        isActive = true;
        rate = 200000000;
        etheraffle = _erMsig;
        LOTContract = LOTInterface(_LOT);
        etheraffleContract = EtheraffleInterface(_er);
    }
    /*
     * @dev     Function used to redeem promotional LOT owed. Sends the 
     *          promo LOT earnt by the Etheraffle player. Requires user to 
     *          not have already claimed in chosenweek, and for promo to be active. 
     *          Function retrieves user's number of entries in Etheraffle this 
     *          week and returns LOT tokens based on the exchange rate and number 
     *          of entries as a multiplier. Logs the claim and emits event of it.
     */
    function redeem(uint _weekNo) public {
        require(
            !claimed[msg.sender][getWeek()] &&
            isActive
            );
        uint amt = _weekNo == 0 ? getNumEntries(msg.sender, getWeek()) : getNumEntries(msg.sender, _weekNo);
        require(getLOTBalance() >= amt);
        claimed[msg.sender][getWeek()] = true;
        LOTContract.transfer(msg.sender, amt);
        emit LogLOTClaim(msg.sender, amt, getWeek(), now);
    }
    /*
     * @dev     Returns number of entries made in Etheraffle contract by function 
     *          caller in whatever the current week is.
     */
    function getNumEntries(address _address uint _weekNo) public constant returns (uint) {
        uint week = _weekNo == 0 ? getWeek() : _weekNo;
        return etheraffleContract.getUserNumEntries(_address, week);
    }
    /*
     * @dev     Toggles promo on & off. Only callable by the Etheraffle
     *          multisig wallet.
     * @param _status   Desired bool status of the promo
     */
    function togglePromo(bool _status) external onlyEtheraffle {
        isActive = _status;
        emit LogActiveStatus(_status, now);
    }
    /*
     * @dev     Same getWeek function as seen in main Etheraffle contract to 
     *          ensure parity of week number - as defined by number of weeks 
     *          since Etheraffle's birthday.
     */
    function getWeek() public constant returns (uint) {
        uint curWeek = (now - BIRTHDAY) / 604800;
        if (now - ((curWeek * 604800) + BIRTHDAY) > RAFEND) curWeek++;
        return curWeek;
    }
    /**
     * @dev     ERC223 tokenFallback function allows to receive ERC223 token 
     *          deposits properly.
     * @param _from  Address of the sender.
     * @param _value Amount of deposited tokens.
     * @param _data  Token transaction data.
     */
    function tokenFallback(address _from, uint256 _value, bytes _data) external {
        if (_value > 0) emit LogTokenDeposit(_from, _value, _data);
    }
    /*
     * @dev     Retrieves current LOT token balance of this contract.
     */
    function getLOTBalance() internal constant returns (uint) {
        return LOTContract.balanceOf(this);
    }
    /*
     * @dev     Function returns bool re whether or not address in question 
     *          has claimed promo LOT for the week in question.
     *
     * @param _address  Ethereum address to be queried
     * @param _weekNo   Week number to be queried (use 0 for current week)
     */
    function hasRedeemed(address _address, uint _weekNo) public constant returns (bool) {
        uint week = _weekNo == 0 ? getWeek() : _weekNo;
        return claimed[_address][week];
    }
    /*
     * @dev     Function returns current ICO tier's exchange 
     *          rate of LOT per ETH.
     */
    function getRate() public constant returns (uint) {
        if (now <  ICOSTART) return 110000 * 10 ** 6;
        if (now <= TIER1END) return 100000 * 10 ** 6;
        if (now <= TIER2END) return 90000  * 10 ** 6;
        if (now <= TIER3END) return 80000  * 10 ** 6;
        else return 0;
    }
    /*
     * @dev     Scuttles contract, sending any remaining LOT tokens back 
     *          to the Etheraffle multisig (by whom it is only callable)
     */
    function scuttle() external onlyEtheraffle {
        LOTContract.transfer(etheraffle, LOTContract.balanceOf(this));
        selfdestruct(etheraffle);
    }
}

    