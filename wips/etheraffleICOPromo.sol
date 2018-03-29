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

    uint constant RAFEND   = 500400;// 7:00pm Saturdays
    uint constant BIRTHDAY = 1500249600;// Etheraffle's birthday <3
    address etheraffle;
    bool public isActive;
    uint public rate;
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
     * @dev     Fallback function used for main contract feature. Claims the 
     *          promo LOT earnt by the Etheraffle player. Requires user to 
     *          not have already claimed this week, and for promo to be active. 
     *          Function retrieves user's number of entries in Etheraffle this 
     *          week and returns LOT tokens based on the exchange rate and number 
     *          of entries as a multiplier. Logs the claim and emits event of it.
     */
    function () public {
        require(
            !claimed[msg.sender][getWeek()] &&
            isActive
            );
        uint amt = getNumEntries();
        require(getLOTBalance() >= amt);
        claimed[msg.sender][getWeek()] = true;
        LOTContract.transfer(msg.sender, amt);
        emit LogLOTClaim(msg.sender, amt, getWeek(), now);
    }
    /*
     * @dev     Returns number of entries made in Etheraffle contract by function 
     *          caller in whatever the current week is.
     */
    function getNumEntries() public constant returns (uint) {
        return etheraffleContract.getUserNumEntries(msg.sender, getWeek());
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
     * @dev     Destroys contract, sending any remaining LOT tokens back 
     *          to the Etheraffle multisig.
     */
    function destroy() external onlyEtheraffle {
        LOTContract.transfer(etheraffle, LOTContract.balanceOf(this));
        selfdestruct(etheraffle);
    }
}