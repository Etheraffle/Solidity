pragma solidity^0.4.21;

contract EtheraffleInterface {
    function getUserNumEntries(address _entrant, uint _week) constant external returns (uint) {}
}

contract LOTInterface {
    function transfer(address _to, uint _value) external {}
    function balanceOf(address _owner) constant external returns (uint) {}
}

/* solium-disable */

contract Promo is EtheraffleInterface {

    uint constant RAFEND   = 500400;// 7:00pm Saturdays
    uint constant BIRTHDAY = 1500249600;// Etheraffle's birthday <3
    address etheraffle;
    bool public isActive;
    uint public rate;
    LOTInterface LOTContract;
    EtheraffleInterface etheraffleContract;
    mapping (address => mapping (uint => bool)) public claimed;// Map address => weekNo => claimed bool
    
    event LogActiveStatus(bool currentStatus, uint atTime);
    event LogTokenDeposit(address fromWhom, uint tokenAmount, bytes data);
    event LogLOTClaim(address whom, uint howMany, uint inWeek, uint atTime);

    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    /*
     * @dev 
     * @param _er
     * @param _LOT
     * @param _erMsig
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
     * @dev 
     */
    function claimLOT() public {
        require(
            !claimed[msg.sender][getWeek()] &&
            isActive
            );
        uint amt = getNumEntries();
        require(getLOTBalance() >= amt);
        claimed[msg.sender][getWeek()] = true;
        LOTContract.transfer(msg.sender, amt);
        LogLOTClaim(msg.sender, amt, ,getWeek(), now);
    }
    /*
     * @dev 
     */
    function getNumEntries() view returns (uint) {
        return etheraffleContract.getUserNumEntries(msg.sender, getWeek());
    }
    /*
     * @dev 
     * @param _status
     */
    function togglePromo(bool _status) external onlyEtheraffle {
        isActive = _status;
        LogActiveStatus(_status, now);
    }
    /*
     * @dev 
     * @param
     */
    function getWeek() public constant returns (uint) {
        uint curWeek = (now - BIRTHDAY) / 604800;
        if (now - ((curWeek * 604800) + BIRTHDAY) > RAFEND) curWeek++;
        return curWeek;
    }
    /**
     * @dev ERC223 tokenFallback function allows to log ERC223 token deposits properly.
     * @param _from  Address of the sender.
     * @param _value Amount of deposited tokens.
     * @param _data  Token transaction data.
     */
    function tokenFallback(address _from, uint256 _value, bytes _data) external {
        if (_value > 0) LogTokenDeposit(_from, _value, _data);
    }
    /*
     * @dev 
     */
    function getLOTBalance() pure returns (uint) {
        return LOTContract.balanceOf(this);
    }
    /*
     * @dev 
     */
    function destroy() external onlyEtheraffle {
        LOTContract.transfer(etheraffle, LOTContract.balanceOf(this));
        selfdestruct(etheraffle);
    }
    /*
     * @dev 
     */    
    function () external payable {
        revert();
    }
}