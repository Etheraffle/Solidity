/*
 *      Welcome to the 𝐄𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞 Smart-Contract!
 *      The 𝐎𝐍𝐋𝐘 decentralized, charitable blockchain lottery!
 *      
 *      ##########################################
 *      ##########################################
 *      ###                                    ###
 *      ###          𝐏𝐥𝐚𝐲 & 𝐖𝐢𝐧 𝐄𝐭𝐡𝐞𝐫          ###
 *      ###                 at                 ###
 *      ###          𝐄𝐓𝐇𝐄𝐑𝐀𝐅𝐅𝐋𝐄.𝐂𝐎𝐌          ###
 *      ###                                    ###
 *      ##########################################
 *      ##########################################
 *
 *      Etheraffle is designed to give 𝐡𝐮𝐠𝐞 𝐩𝐫𝐢𝐳𝐞𝐬 to 
 *      players, sustainable 𝐄𝐓𝐇 𝐝𝐢𝐯𝐢𝐝𝐞𝐧𝐝𝐬 to 𝐋𝐎𝐓 token 
 *      holders, and 𝐥𝐢𝐟𝐞-𝐜𝐡𝐚𝐧𝐠𝐢𝐧𝐠 𝐟𝐮𝐧𝐝𝐢𝐧𝐠 to charities.
 *
 *      Learn more & get involved at 𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞.𝐜𝐨𝐦/𝐈𝐂𝐎 to become a
 *      𝐋𝐎𝐓 token holder today! Holding 𝐋𝐎𝐓 tokens automatically  
 *      makes you a part of the decentralized, autonomous organisation  
 *      that 𝐎𝐖𝐍𝐒 Etheraffle. Take your place in this decentralized, 
 *      altruistic vision of the future!
 *
 *      If you want to chat to us you have loads of options:
 *      On 𝐓𝐞𝐥𝐞𝐠𝐫𝐚𝐦 @ 𝐡𝐭𝐭𝐩𝐬://𝐭.𝐦𝐞/𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞
 *      Or on 𝐓𝐰𝐢𝐭𝐭𝐞𝐫 @ 𝐡𝐭𝐭𝐩𝐬://𝐭𝐰𝐢𝐭𝐭𝐞𝐫.𝐜𝐨𝐦/𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞
 *      Or on 𝐑𝐞𝐝𝐝𝐢𝐭 @ 𝐡𝐭𝐭𝐩𝐬://𝐞𝐭𝐡𝐞𝐫𝐚𝐟𝐟𝐥𝐞.𝐫𝐞𝐝𝐝𝐢𝐭.𝐜𝐨𝐦
 *
 */
pragma solidity^0.4.21;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/src/strings.sol";

contract ReceiverInterface {
    function receiveEther() external payable {}
}

contract EtheraffleUpgrade {
    function manuallyAddToPrizePool() payable external {}
}

contract FreeLOTInterface {
    function mint(address _to, uint _amt) external {}
    function destroy(address _from, uint _amt) external {}
    function balanceOf(address who) constant public returns (uint) {}
}

contract Etheraffle is usingOraclize {
    using strings for *;
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###             Variables              ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    uint    public week;
    bool    public paused;
    uint    public upgraded;
    uint    public prizePool;
    address public ethRelief;
    address public etheraffle;
    address public upgradeAddr;
    address public disburseAddr;
    uint    public take         = 150; // ppt
    uint    public gasAmt       = 500000;
    uint    public resultsDelay = 3600;
    uint    public matchesDelay = 3600;
    uint    public rafEnd       = 500400; // 7:00pm Saturdays
    uint    public wdrawBfr     = 6048000;
    uint    public gasPrc       = 20000000000; // 20 gwei
    uint    public tktPrice     = 2000000000000000;
    uint    public oracCost     = 1500000000000000; // $1 @ $700
    uint[]  public pctOfPool    = [520, 114, 47, 319]; // ppt...
    uint[]  public odds         = [56, 1032, 54200, 13983816]; // Rounded down to nearest whole 
    uint  constant WEEKDUR      = 604800;
    uint  constant BIRTHDAY     = 1500249600;//Etheraffle's birthday <3
    string randomStr1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\", \"serialNumber\"]','\\n{\"jsonrpc\": \"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\"";
    string randomStr2 = "\",\"params\":{\"n\":\"6\",\"min\":1,\"max\":49,\"replacement\":false,\"base\":10,\"apiKey\":${[decrypt] BKM3j7tH7qBIQKuadP5kJ547Au1uB1Zo41u6tCfLPT3GDGJJCEpXLS87u1xlYsFu/i21zycQJgVFWzev+ZSjflQKsOCFbdN5oUSiR/GvD5nuLblzG6H+xq2lVdZ0lN/EZjrCmgMfaF0r3uo/FKcRdAnbf2wxKQ5Vfg==}}']";
    string apiStr1    = "[URL] ['json(https://etheraffle.com/api/a).m','{\"r\":\"";
    string apiStr2    = "\",\"k\":${[decrypt] BGQljYtTQ+yq9TZztMcWycMiaAezwNm3ppmcBvdh37ZJVJiTFbQw+h+WycbJtaklSFe2+S228NTf9eOh+6y06dlVpbJ3S28JhDOg50j4wqAIXdtCWDZLkAgyjXI3pOa3SJY3RV2b}}']";
    FreeLOTInterface freeLOT;
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###          Data Structures           ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    mapping (uint => rafStruct) public raffle;
    struct rafStruct {
        mapping (address => uint[][]) entries;
        uint tktPrice;
        uint unclaimed;
        uint[] winNums;
        uint[] winAmts;
        uint timeStamp;
        bool wdrawOpen;
        uint numEntries;
        uint freeEntries;
    }

    mapping (bytes32 => qIDStruct) public qID;
    struct qIDStruct {
        uint weekNo;
        bool isRandom;
        bool isManual;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###             Modifiers              ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
    * @dev  Modifier to prepend to functions adding the additional
    *       conditional requiring caller of the method to be the
    *       etheraffle address.
    */
    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    /**
    * @dev  Modifier to prepend to functions adding the additional
    *       conditional requiring the paused bool to be false.
    */
    modifier onlyIfNotPaused() {
        require(!paused);
        _;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###              Events                ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    event LogFunctionsPaused(uint identifier, uint atTime);
    event LogQuerySent(bytes32 queryID, uint dueAt, uint sendTime);
    event LogReclaim(uint indexed fromRaffle, uint amount, uint atTime);
    event LogUpgrade(address newContract, uint ethTransferred, uint atTime);
    event LogPrizePoolAddition(address fromWhom, uint howMuch, uint atTime);
    event LogFreeLOTWin(uint indexed forRaffle, address toWhom, uint entryNumber, uint amount, uint atTime);
    event LogOraclizeCallback(address functionCaller, bytes32 queryID, string result, uint indexed forRaffle, uint atTime);
    event LogFundsDisbursed(uint indexed forRaffle, uint oraclizeTotal, uint amount, address indexed toAddress, uint atTime);
    event LogWithdraw(uint indexed forRaffle, address indexed toWhom, uint forEntryNumber, uint matches, uint amountWon, uint atTime);
    event LogWinningNumbers(uint indexed forRaffle, uint numberOfEntries, uint[] wNumbers, uint currentPrizePool, uint randomSerialNo, uint atTime);
    event LogTicketBought(uint indexed forRaffle, uint indexed entryNumber, address indexed theEntrant, uint[] chosenNumbers, uint personalEntryNumber, uint tktCost, uint atTime, uint affiliateID);
    event LogPrizePoolsUpdated(uint newMainPrizePool, uint indexed forRaffle, uint unclaimedPrizePool, uint threeMatchWinAmt, uint fourMatchWinAmt, uint fiveMatchWinAmt, uint sixMatchwinAmt, uint atTime);
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###            Constructor             ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @dev     Constructor. Sets the Etheraffle multisig address, 
     *          the EthRelief & Disbursal contract addresses and 
     *          instantiates the FreeLOT contract. Sets up an 
     *          initial raffle struct.
     *
     */
    constructor() payable {
        week         = getWeek();
        etheraffle   = 0x97f535e98cf250cdd7ff0cb9b29e4548b609a0bd;
        disburseAddr = 0xb6a5f50b5ce5909a9c75ce27fec96e5de393af61;
        ethRelief    = 0x7ee65fe55accd9430f425379851fe768270c6699;
        freeLOT      = FreeLOTInterface(0xc39f7bB97B31102C923DaF02bA3d1bD16424F4bb);
        setupRaffleStruct(week, 2500000000000000, (week * WEEKDUR) + BIRTHDAY);
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###           Raffle Setup             ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @dev   Function which gets current week number and if different
     *        from the global var week number, it updates that and sets
     *        up the new raffle struct. Should only be called once a
     *        week after the raffle is closed. Should it get called
     *        sooner, the contract is paused for inspection.
     *
     */
    function setUpNewRaffle() internal {
        uint newWeek = getWeek();
        if (newWeek == week) return pauseContract(true, 4);
        setWeek(newWeek);
        setUpRaffleStruct(newWeek, tktPrice, BIRTHDAY + (newWeek * WEEKDUR));
    }
    /**
     * @dev   Function using Etheraffle's birthday to calculate the
     *        week number since then.
     */
    function getWeek() public constant returns (uint) {
        uint curWeek = (now - BIRTHDAY) / WEEKDUR;
        return pastClosingTime(curWeek) ? curWeek + 1 : curWeek
    }
    /**
     * @dev     Returns true if time of calling is past a raffle's 
     *          designated end time.
     *
     */
    function pastClosingTime(uint _curWeek) internal view returns (bool) {
        return now - ((curWeek * WEEKDUR) + BIRTHDAY) > rafEnd;
    }
	/**
	 * @dev		Sets up new raffle via creating a struct with the correct 
     *          timestamp and ticket price. 
	 *
	 * @param   _week       Desired week number for new raffle struct.
     *
     * @param   _tktPrice   Desired ticket price for the raffle
     *
     * @param    _timeStamp Timestamp of Mon 00:00 of the week of this raffle
     *
	 */
   	function setUpRaffleStruct(uint _week, uint _tktPrice, uint _timeStamp) internal {
        raffle[_week].tktPrice  = _tktPrice;
        raffle[_week].timeStamp = _timeStamp;
   	}
	/**
	 * @dev		Sets the withdraw status of a raffle.
	 *
	 * @param   _week   Week number for raffle in question.
     *
     * @param   _status Desired withdraw status for raffle.
     *
	 */
    function setWithdraw(uint _week, bool _status) internal {
        raffle[_week].wdrawOpen = _status;
    }
    /**
	 * @dev		Sets the global week variable.
	 *
	 * @param   _week   Desired week number.
     *
	 */
    function setWeek(uint _week) internal {
        week = _week;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###           Pause Contract           ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @dev     Sets the paused status of the contract to the bool 
     *          passed in. This affects various of the contracts 
     *          functions via the onlyIfNotPaused modifier.
     *
     * @param   _status     Desired pause status.
     *
     */
    function pauseContract(bool _status) internal {
        paused = _status;
    }
    /**
     * @dev     Sets the paused status of the contract to the bool 
     *          passed in. Logs an event with a uint identifying the 
     *          reason for pausing the contract to the front-end 
     *          event watcher.
     *
     * @param   _status Desired pause status.
     *
     * @param   _id     Uint identifing the reason function was called.
     */
    function pauseContract(bool _status, uint _id) internal {
        pauseContract(_status);
        emit LogFunctionsPaused(_id, now);
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###         Ticket Purchasing          ###
     *      ###                                    ###
     *      ##########################################
     *
     */
   /**
     * @dev     Function to enter a raffle. Checks for correct ticket price, 
     *          then purchases ticket. Only callable when the contract is 
     *          not paused.
     *
     * @param   _cNums  Ordered array of entrant's six selected numbers.
     *
     * @param   _affID  Affiliate ID of the source of this entry.
     *
     */
    function enterRaffle(uint[] _cNums, uint _affID) payable public onlyIfNotPaused {
        require (validTktPrice(week));
        buyTicket(_cNums, msg.sender, msg.value, _affID);
    }
    /**
     * @dev     Function to enter the raffle on behalf of another address.  
     *          Checks for correct ticket price. Only callable when the 
     *          contract is not paused. In the event of a win, only the 
     *          onBehalfOf address can claim it.
     *  
     * @param   _cNums        Ordered array of entrant's six selected numbers.
     *
     * @param   _affID        Affiliate ID of the source of this entry.
     *
     * @param   _onBehalfOf   The address to be entered on behalf of.
     *
     */
    function enterOnBehalfOf(uint[] _cNums, uint _affID, address _onBehalfOf) payable public onlyIfNotPaused {
        require (validTktPrice(week));
        buyTicket(_cNums, _onBehalfOf, msg.value, _affID);
    }
    /**
     * @dev     Function to enter the raffle for free. Requires the caller's
     *          balance of the Etheraffle freeLOT token to be greater than
     *          zero. Function destroys one freeLOT token, increments the
     *          freeEntries variable in the raffle struct then purchases the
     *          ticket. Only callable if contract is not paused.
     *
     * @param   _cNums    Ordered array of entrant's six selected numbers.
     *
     * @param   _affID    Affiliate ID of the source of this entry.
     *
     */
    function enterFreeRaffle(uint[] _cNums, uint _affID) payable public onlyIfNotPaused {
        decrementFreeLOT(msg.sender, 1);
        incremementEntries(week, true);
        buyTicket(_cNums, msg.sender, msg.value, _affID);
    }
    /**
     * @dev     Checks that a raffle struct has a ticket price set and whether 
     *          the caller's msg.value is greater than or equal to that price.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function validTktPrice(uint _week) internal view returns (bool) {
        return (
            raffle[_week].tktPrice > 0 && 
            msg.value >= raffle[_week].tktPrice
        );
    }
    /**
     * @dev     Decrement an address' FreeLOT token holdings by a specified 
     *          amount.
     *
     * @param   _address  The address owning the FreeLOT token(s)
     *
     * @param   _amt      The amount of FreeLOT to destroy.
     *
     */
    function decrementFreeLOT(address _address, uint _amt) internal {
        freeLOT.destroy(_address, _amt);
    }
    /**
     * @dev     Internal function that purchases raffle tickets. Requires the 
     *          raffle be open for entry and the chosen numbers be valid. 
     *          Increments number of entries in the raffle strut, adds the ticket 
     *          price to the prize pool and stores a hash of the entrants chosen 
     *          numbers before logging the purchase.   
     *
     * @param   _cNums      Array of users selected numbers.
     *
     * @param   _entrant    Entrant's ethereum address.
     *
     * @param   _value      The ticket purchase price.
     *
     * @param   _affID      Affiliate ID of the source of this entry.
     *
     */
    function buyTicket(uint[] _cNums, address _entrant, uint _value, uint _affID) internal {
        require (raffleOpenForEntry() && validNumbers(_cNums));
        incremementEntries(week, false);
        addToPrizePool(_value);
        storeEntry(week, _entrant, _cNums);
        emit LogTicketBought(week, raffle[week].numEntries, _entrant, _cNums, raffle[week].entries[_entrant].length, _value, now, _affID);
    }
    /**
     * @dev     Stores a ticket purchase by hashing the chosen numbers 
     *          and pushing them into an array mapped to the user's 
     *          address in the relevant raffle's struct.
     *
     * @param   _week       Week number for raffle in question.
     *
     * @param   _entrant    The entrant's address.
     *
     * @param   _cNums      The entrant's chosen numbers.
     *
     */
    function storeEntry(uint _week, address _entrant, uint[] _cNums) internal {
        raffle[_week].entries[_entrant].push(keccak256(_cNums));
    }
    /**
     * @dev     Increments the number of entries in a raffle struct. 
     *          Increments free entries if bool passed is true, else 
     *          normal entries otherwise.
     *
     * @param   _week   Week number for raffle in question
     *
     * @param   _free   Whether it is a free entry or not.
     *
     */
    function incremementEntries(uint _week, bool _free) internal {
        _free ? raffle[week].freeEntries++ : raffle[_week].numEntries++;
    }
    /**
     * @dev     Temporal & raffle struct setup requirements that need to be 
     *          satisfied before a raffle ticket can be purchased.
     */
    function raffleOpenForEntry() internal view returns (bool) {
        return (
            raffle[week].timeStamp > 0 &&
            now < raffle[week].timeStamp + rafEnd
        );
    }
    /**
     * @dev     Series of requirements a raffle ticket's chosen numbers must 
     *          pass in order to qualify as valid. Ensures that there are six 
     *          numbers, in ascending order, between one and 49.
     *
     * @param   _cNums  Array of a ticket's proposed numbers in question.
     *
     */
    function validNumbers(uint[] _cNums) internal pure returns (bool) {
        return (
            _cNums.length == 6    &&
            0         < _cNums[0] &&
            _cNums[0] < _cNums[1] &&
            _cNums[1] < _cNums[2] &&
            _cNums[2] < _cNums[3] &&
            _cNums[3] < _cNums[4] &&
            _cNums[4] < _cNums[5] &&
            _cNums[5] <= 49
        );
    }
    /**
     * @dev     Modifies prizePool var. If true passed is in as first 
     *          argument, prizePool is incremented by _amt, if  false, 
     *          decremented. In which latter case, it requires the minuend 
     *          be smaller than the subtrahend.  
     *
     * @param   _bool   Boolean signifying addtion or subtraction. 
     *
     * @param   _amt    Amount to modify the prize pool by.
     *
     */
    function modifyPrizePool(bool _bool, uint _amt) private {
        if (!_bool) require (_amt <= prizePool, '_amt > prizePool!');
        prizePool = _bool ? prizePool + _amt : prizePool - _amt;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###         Withdraw Winnings          ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @dev     User calls this function in order to withdraw whatever 
     *          winnings they are owed. It requires the entry be valid 
     *          and the raffle open for withdraw. Function retrieves the
     *          number of matches then pays out accordingly. Only callable 
     *          if the contract is not paused.
     *
     * @param   _week       Week number of the raffle the winning entry is from.
     *
     * @param   _entryNum   The entrant's entry number into this raffle.
     *
     */
    function withdrawWinnings(uint _week, uint _entryNum, uint[] _cNums) external onlyIfNotPaused {
        require (validEntry(_week, _entryNum, _cNums, msg.sender) && openForWithdraw(_week));
        uint matches = getMatches(_cNums, raffle[_week].winNums);
        require (matches >= 2);
        matches == 2 
            ? winFreeGo(_week, _entryNum, msg.sender) 
            : payWinnings(_week, _entryNum, matches, msg.sender);
    }
    /*
     * @dev     Mints a FreeLOT coupon to a two match winner allowing them 
     *          a free entry to Etheraffle. Function pausable by pause toggle.
     *
     * @param   _week       Week number of raffle whence the win originates.
     *
     * @param   _entryNum   Entry number of the win in question.
     *
     * @param   _entrant    Entry to whom the win belongs.
     *
     */
    function winFreeGo(uint _week, uint _entryNum, address _entrant) private onlyIfNotPaused {
        invalidateEntry(_week, _entrant, _entryNum);
        freeLOT.mint(_entrant, 1);
        emit LogFreeLOTWin(_week, _entrant, _entryNum, 1, now);
    }
    /**
     * @dev     If ticket wins ETH this function first checks the eligibility 
     *          for withdraw before invalidating the ticket, deducting the win 
     *          from the unclaimed prizepool and finally transferring the winnings.
     *
     * @param   _week       Week number for raffle in question.
     *
     * @param   _entryNum   Entry number for ticket in question.
     *
     * @param   _matches    Number of matches ticket make to winning numbers.
     *
     * @param   _entrant    Address of the ticket holder.
     *
     */
    function payWinnings(uint _week, uint _entryNum, , uint _matches, address _entrant) private {
        require (eligibleForWithdraw(_week, matches));
        invalidateEntry(_week, _entrant, _entryNum);
        modifyUnclaimed(false, _week, raffle[_week].winAmts[_matches - 3]);
        transferWinnings(_entrant, raffle[_week].winAmts[matches - 3]);
        emit LogWithdraw(_week, _entrant, _entryNum, _matches, raffle[_week].winAmts[_matches - 3], now);
    }
    /**
     * @dev     Tranfers an amount of ETH to an address.
     *
     * @param   _address    Address to transger ETH to.
     *
     * @param   _amt        Amount of Wei to transfer.
     *
     */
    function transferWinnings(address _address, uint _amt) private {
        _address.transfer(_amt);
    }
    /**
     * @dev     Modifies the unclaimed variable in a struct. If true passed 
     *          in as first argument, unclaimed is incremented by _amt, if 
     *          false, decremented. In which latter case, it requires the 
     *          minuend is smaller than the subtrahend.   
     *
     * @param   _bool     Boolean signifying addtion or subtraction.
     *
     * @param   _week     Week number for raffle in question.
     *
     * @param   _amt      Amount unclaimed is to be modified by.
     *
     */
    function modifyUnclaimed(bool _bool, uint _week, uint _amt) private {
        if (!_bool) require (_amt <= raffle[_week].unclaimed, 'Prize amt > Unclaimed!');
        raffle[_week].unclaimed = _bool ? raffle[_week].unclaimed + _amt : raffle[_week].unclaimed - _amt;
    }
    /**
     * @dev     Various requirements w/r/t number of matches, win amounts 
     *          being set in the raffle struct and contract balance that 
     *          need to be passed before withdrawal can be processed.
     *
     * @param   _week     Week number for raffle in question.
     *
     * @param   _matches  Number of matches the entry in question has made.
     *
     */
    function eligibleForWithdraw(uint _week, uint _matches) view internal returns (bool) {
        return (
            _matches >= 3 &&
            raffle[_week].winAmts[_matches - 3] > 0 &&
            raffle[_week].winAmts[_matches - 3] <= this.balance &&
        );
    }
    /**
     * @dev     Compares hash of provided entry numbers to previously bought 
     *          ticket's hashed entry numbers.
     *
     * @param   _week       Week number for raffle in question.
     *
     * @param   _entryNum   Entry number in question.
     *
     * @param   _cNums      Propsed entry numbers for entry in question.
     *
     * @param   _entrant    Address of entrant in question.
     *
     */
    function validEntry(uint _week, uint _entryNum, uint[] _cNums, address _entrant) view internal returns (bool) {
        return raffle[_week].entries[_entrant][_entryNum - 1] == keccak256(_cNums);
    }
    /**
     * @dev     Function zeroes the previously stored hash of an entrant's 
     *          ticket's chosen numbers.
     *
     * @param   _week       Week number for raffle in question.
     *
     * @param   _entrant    Address of the entrant in question.
     *
     * @param   _entryNum   Entry number in question.
     *
     */
    function invalidateEntry(uint _week, address _entrant, uint _entryNum) private {
        raffle[_week].entries[_entrant][_entryNum - 1] = 0;
    }
    /**
     * @dev     Various temporal requirements plus struct setup requirements 
     *          that need to be met before a prize withdrawal can be processed. 
     *          In order: Winning numbers need to be set, withdraw bool needs 
     *          to be true, raffle's timestamp needs to be set, that the time 
     *          the function is called needs to be before the withdraw deadline, 
     *          and that the time the function is called needs to be six days 
     *          beyond the timestamp. 
     *
     * @param   _week   Week number for the raffle in question.
     *
     */
    function openForWithdraw(uint _week) view internal returns (bool) {
        return (
            winNumbersSet(_week) &&
            raffle[_week].wdrawOpen &&
            raffle[_week].timeStamp > 0 &&
            now - raffle[_week].timeStamp < wdrawBfr &&
            now - raffle[_week].timeStamp > WEEKDUR - (WEEKDUR / 7)
        );
    }
    /**
     * @dev     Function compares two arrays of the same length to one 
     *          another to see how many numbers they have in common.
     *
     * @param   _cNums  Array of entrant's chosen numbers.
     *
     * @param   _wNums  Array of winning numbers.
     *
     */
    function getMatches(uint[] _cNums, uint[] _wNums) pure internal returns (uint) {
        require(_cNums.length == 6 && _wNums.length == 6);
        uint matches;
        for (uint i = 0; i < 6; i++) {
            for (uint j = 0; j < 6; j++) {
                if (_cNums[i] == _wNums[j]) {
                    matches++;
                    break;
                }
            }
        }
        return matches;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###         Oraclize Callback          ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @dev    Called by the weekly Oraclize callback. Checks raffle 10
     *         weeks older than current raffle for any unclaimed prize
     *         pool. If any found, returns it to the main prizePool and
     *         zeros the amount.
     *
     */
    function reclaimUnclaimed() internal {
        uint old = getWeek() - 11;
        uint amt = getUnclaimed(old);
        if (amt == 0) return;
        modifyPrizePool(true, amt);
        modifyUnclaimed(false, old, amt);
        emit LogReclaim(old, amt, now);
    }
    //TODO: Check is this is used more than once - might be a refactor too far?
    /**
     * @dev     Returns the unclaimed prize pool sequestered in a raffle's
     *          struct.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function getUnclaimed(uint _week) public view returns (uint) {
        return raffle[_week].unclaimed;
    }





    /**
     * @dev  Function totals up oraclize cost for the raffle, subtracts
     *       it from the prizepool (if less than, if greater than if
     *       pauses the contract and fires an event). Calculates profit
     *       based on raffle's tickets sales and the take percentage,
     *       then forwards that amount of ether to the disbursal contract.
     *
     * @param _week   The week number of the raffle in question.
     */
    function disburseFunds(uint _week) internal {
        uint oracTot = 2 * ((gasAmt * gasPrc) + oracCost);//2 queries per draw...
        if (oracTot > prizePool) return pauseContract(1);
        prizePool -= oracTot;
        uint profit;
        if (raffle[_week].numEntries > 0) {
            profit = ((raffle[_week].numEntries - raffle[_week].freeEntries) * tktPrice * take) / 1000;
            prizePool -= profit;
            uint half = profit / 2;
            ReceiverInterface(disburseAddr).receiveEther.value(half)();
            ReceiverInterface(ethRelief).receiveEther.value(profit - half)();
            emit LogFundsDisbursed(_week, oracTot, profit - half, ethRelief, now);
            emit LogFundsDisbursed(_week, oracTot, half, disburseAddr, now);
            return;
        }
        emit LogFundsDisbursed(_week, oracTot, profit, 0, now);
    }
    /**
     * @dev   The Oralize call back function. The oracalize api calls are
     *        recursive. One to random.org for the draw and the other to
     *        the Etheraffle api for the numbers of matches each entry made
     *        against the winning numbers. Each calls the other recursively.
     *        The former when calledback closes and reclaims any unclaimed
     *        prizepool from the raffle ten weeks previous to now. Then it
     *        disburses profit to the disbursal contract, then it sets the
     *        winning numbers received from random.org into the raffle
     *        struct. Finally it prepares the next oraclize call. Which
     *        latter callback first sets up the new raffle struct, then
     *        sets the payouts based on the number of winners in each tier
     *        returned from the api call, then prepares the next oraclize
     *        query for a week later to draw the next raffle's winning
     *        numbers.
     *
     * @param _myID     bytes32 - Unique id oraclize provides with their
     *                            callbacks.
     * @param _result   string - The result of the api call.
     */
    function __callback(bytes32 _myID, string _result) onlyIfNotPaused {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        if (qID[_myID].isRandom == true) {
            reclaimUnclaimed();
            disburseFunds(qID[_myID].weekNo);
            setWinningNumbers(qID[_myID].weekNo, _result);
            if (qID[_myID].isManual == true) return;
            bytes32 query = oraclize_query(matchesDelay, "nested", strConcat(apiStr1, uint2str(qID[_myID].weekNo), apiStr2), gasAmt);
            qID[query].weekNo = qID[_myID].weekNo;
            emit LogQuerySent(query, matchesDelay + now, now);
        } else {
            newRaffle();
            setPayOuts(qID[_myID].weekNo, _result);
            if (qID[_myID].isManual == true) return;
            uint delay = (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
            query = oraclize_query(delay, "nested", strConcat(randomStr1, uint2str(getWeek()), randomStr2), gasAmt);
            qID[query].weekNo = getWeek();
            qID[query].isRandom = true;
            emit LogQuerySent(query, delay, now);
        }
    }
    /**
     * @dev     Slices a string according to specified delimiter, returning
     *          the sliced parts in an array. Courtesy of Nick Johnson via
     *          https://github.com/Arachnid/solidity-stringutils
     *
     * @param   _string   The string to be sliced.
     */
    function stringToArray(string _string) internal pure returns (string[]) {
        var str    = _string.toSlice();
        var delim  = ",".toSlice();
        var parts  = new string[](str.count(delim) + 1);
        for (uint i = 0; i < parts.length; i++) {
            parts[i] = str.split(delim).toString();
        }
        return parts;
    }
    /**
     * @dev   Takes oraclize random.org api call result string and splits
     *        it at the commas into an array, parses those strings in that
     *        array as integers and pushes them into the winning numbers
     *        array in the raffle's struct. Fires event logging the data,
     *        including the serial number of the random.org callback so
     *        its veracity can be proven.
     *
     * @param _week    The week number of the raffle in question.
     * @param _result   The results string from oraclize callback.
     */
    function setWinningNumbers(uint _week, string _result) internal {
        string[] memory arr = stringToArray(_result);
        for (uint i = 0; i < arr.length; i++){
            raffle[_week].winNums.push(parseInt(arr[i]));
        }
        uint serialNo = parseInt(arr[6]);
        emit LogWinningNumbers(_week, raffle[_week].numEntries, raffle[_week].winNums, prizePool, serialNo, now);
    }
    /*  
     * @dev     Returns TOTAL payout per tier when calculated using the odds method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
     */
    function oddsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return oddsSingle(_matchesIndex) * _numWinners;
    }
    /*
     * @dev     Returns TOTAL payout per tier when calculated using the splits method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
     */
    function splitsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return splitsSingle(_numWinners, _matchesIndex) * _numWinners;
    }
    /*
     * @dev     Returns single payout when calculated using the odds method.
     *
     * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
     */
    function oddsSingle(uint _matchesIndex) internal view returns (uint) {
        return tktPrice * odds[_matchesIndex];
    }
    /*
     * @dev     Returns a single payout when calculated using the splits method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
     */
    function splitsSingle(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return (prizePool * pctOfPool[_matchesIndex]) / (_numWinners * 1000);
    }
    /**
     * @dev   Takes the results of the oraclize Etheraffle api call back
     *        and uses them to calculate the prizes due to each tier
     *        (3 matches, 4 matches etc) then pushes them into the winning
     *        amounts array in the raffle in question's struct. Calculates
     *        the total winnings of the raffle, subtracts it from the
     *        global prize pool sequesters that amount into the raffle's
     *        struct "unclaimed" variable, ∴ "rolling over" the unwon
     *        ether. Enables winner withdrawals by setting the withdraw
     *        open bool to true.
     *
     * @param _week    The week number of the raffle in question.
     * @param _result  The results string from oraclize callback.
     */
    function setPayOuts(uint _week, string _result) internal {
        string[] memory numWinnersStr = stringToArray(_result);
        if (numWinnersStr.length < 4) return pauseContract(2);
        uint[] memory numWinnersInt = new uint[](4);
        for (uint i = 0; i < 4; i++) {
            numWinnersInt[i] = parseInt(numWinnersStr[i]);
        }
        uint[] memory payOuts = new uint[](4);
        uint total;
        for (i = 0; i < 4; i++) {
            if (numWinnersInt[i] != 0) {
                uint amt = oddsTotal(numWinnersInt[i], i) <= splitsTotal(numWinnersInt[i], i) 
                         ? oddsSingle(i) 
                         : splitsSingle(numWinnersInt[i], i); 
                payOuts[i] = amt;
                total += payOuts[i] * numWinnersInt[i];
            }
        }
        raffle[_week].unclaimed = total;
        if (raffle[_week].unclaimed > prizePool) return pauseContract(3);
        prizePool -= raffle[_week].unclaimed;
        for (i = 0; i < payOuts.length; i++) {
            raffle[_week].winAmts.push(payOuts[i]);
        }
        raffle[_week].wdrawOpen = true;
        emit LogPrizePoolsUpdated(prizePool, _week, raffle[_week].unclaimed, payOuts[0], payOuts[1], payOuts[2], payOuts[3], now);
    }
    /**
     * @dev     Manually make an Oraclize API call, incase of automation
     *          failure. Only callable by the Etheraffle address.
     *
     * @param _delay      Either a time in seconds before desired callback
     *                    time for the API call, or a future UTC format time for
     *                    the desired time for the API callback.
     * @param _week       The week number this query is for.
     * @param _isRandom   Whether or not the api call being made is for
     *                    the random.org results draw, or for the Etheraffle
     *                    API results call.
     * @param _isManual   The Oraclize call back is a recursive function in
     *                    which each call fires off another call in perpetuity.
     *                    This bool allows that recursiveness for this call to be
     *                    turned on or off depending on caller's requirements.
     */
    function manuallyMakeOraclizeCall
    (
        uint _week,
        uint _delay,
        bool _isRandom,
        bool _isManual,
        bool _status
    )
        onlyEtheraffle external
    {
        paused = _status;
        string memory weekNumStr = uint2str(_week);
        if (_isRandom == true){
            bytes32 query = oraclize_query(_delay, "nested", strConcat(randomStr1, weekNumStr, randomStr2), gasAmt);
            qID[query].weekNo   = _week;
            qID[query].isRandom = true;
            qID[query].isManual = _isManual;
        } else {
            query = oraclize_query(_delay, "nested", strConcat(apiStr1, weekNumStr, apiStr2), gasAmt);
            qID[query].weekNo   = _week;
            qID[query].isManual = _isManual;
        }
    }
    /**
     * @dev    Set the Oraclize strings, in case of url changes. Only callable by
     *         the Etheraffle address  .
     *
     * @param _newRandomHalfOne       string - with properly escaped characters for
     *                                the first half of the random.org call string.
     * @param _newRandomHalfTwo       string - with properly escaped characters for
     *                                the second half of the random.org call string.
     * @param _newEtheraffleHalfOne   string - with properly escaped characters for
     *                                the first half of the EtheraffleAPI call string.
     * @param _newEtheraffleHalfTwo   string - with properly escaped characters for
     *                                the second half of the EtheraffleAPI call string.
     *
     */
    function setOraclizeString
    (
        string _newRandomHalfOne,
        string _newRandomHalfTwo,
        string _newEtheraffleHalfOne,
        string _newEtheraffleHalfTwo
    )
        onlyEtheraffle external
    {
        randomStr1 = _newRandomHalfOne;
        randomStr2 = _newRandomHalfTwo;
        apiStr1    = _newEtheraffleHalfOne;
        apiStr2    = _newEtheraffleHalfTwo;
    }
    /**
     * @dev   Set the ticket price of the raffle. Only callable by the
     *        Etheraffle address.
     *
     * @param _newPrice   uint - The desired new ticket price.
     *
     */
    function setTktPrice(uint _newPrice) onlyEtheraffle external {
        tktPrice = _newPrice;
    }
    /**
     * @dev    Set new take percentage. Only callable by the Etheraffle
     *         address.
     *
     * @param _newTake   uint - The desired new take, parts per thousand.
     *
     */
    function setTake(uint _newTake) onlyEtheraffle external {
        take = _newTake;
    }
    /**
     * @dev     Set the payouts manually, in case of a failed Oraclize call.
     *          Only callable by the Etheraffle address.
     *
     * @param _week         The week number of the raffle to set the payouts for.
     * @param _numMatches   Number of matches. Comma-separated STRING of 4
     *                      integers long, consisting of the number of 3 match
     *                      winners, 4 match winners, 5 & 6 match winners in
     *                      that order.
     */
    function setPayouts(uint _week, string _numMatches) onlyEtheraffle external {
        setPayOuts(_week, _numMatches);
    }
    /**
     * @dev   Set the FreeLOT token contract address, in case of future updrades.
     *        Only allable by the Etheraffle address.
     *
     * @param _newAddr   New address of FreeLOT contract.
     */
    function setFreeLOT(address _newAddr) onlyEtheraffle external {
        freeLOT = FreeLOTInterface(_newAddr);
      }
    /**
     * @dev   Set the EthRelief contract address, and gas required to run
     *        the receiving function. Only allable by the Etheraffle address.
     *
     * @param _newAddr   New address of the EthRelief contract.
     */
    function setEthRelief(address _newAddr) onlyEtheraffle external {
        ethRelief = _newAddr;
    }
    /**
     * @dev   Set the dividend contract address, and gas required to run
     *        the receive ether function. Only callable by the Etheraffle
     *        address.
     *
     * @param _newAddr   New address of dividend contract.
     */
    function setDisbursingAddr(address _newAddr) onlyEtheraffle external {
        disburseAddr = _newAddr;
    }
    /**
     * @dev   Set the Etheraffle multisig contract address, in case of future
     *        upgrades. Only callable by the current Etheraffle address.
     *
     * @param _newAddr   New address of Etheraffle multisig contract.
     */
    function setEtheraffle(address _newAddr) onlyEtheraffle external {
        etheraffle = _newAddr;
    }
    /**
     * @dev     Set the raffle end time, in number of seconds passed
     *          the start time of 00:00am Monday. Only callable by
     *          the Etheraffle address.
     *
     * @param _newTime    The time desired in seconds.
     */
    function setRafEnd(uint _newTime) onlyEtheraffle external {
        rafEnd = _newTime;
    }
    /**
     * @dev     Set the wdrawBfr time - the time a winner has to withdraw
     *          their winnings before the unclaimed prizepool is rolled
     *          back into the global prizepool. Only callable by the
     *          Etheraffle address.
     *
     * @param _newTime    The time desired in seconds.
     */
    function setWithdrawBeforeTime(uint _newTime) onlyEtheraffle external {
        wdrawBfr = _newTime;
    }
    /**
     * @dev     Set the paused status of the raffles. Only callable by
     *          the Etheraffle address.
     *
     * @param _status    The desired status of the raffles.
     */
    function setPaused(bool _status) onlyEtheraffle external {
        paused = _status;
    }
    /**
     * @dev     Set the percentage-of-prizepool array. Only callable by the
     *          Etheraffle address.
     *
     * @param _newPoP     An array of four integers totalling 1000.
     */
    function setPercentOfPool(uint[] _newPoP) onlyEtheraffle external {
        pctOfPool = _newPoP;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###              Getters               ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @dev     Get a entrant's number of entries into a specific raffle
     *
     * @param   _week       The week number of the raffle in question.
     *
     * @param   _entrant    The entrant in question.
     *
     */
    function getUserNumEntries(address _entrant, uint _week) constant external returns (uint) {
        return raffle[_week].entries[_entrant].length;
    }
    /**
     * @dev     Get chosen numbers of an entrant, for a specific raffle.
     *          Returns an array.
     *
     * @param   _entrant    The entrant in question's address.
     *
     * @param   _week       The week number of raffle in question.
     *
     * @param   _entryNum   The entrant's entry number in this raffle.
     *
     */
    function getChosenNumbersHash(address _entrant, uint _week, uint _entryNum) constant external returns (bytes32) {
        return raffle[_week].entries[_entrant][_entryNum-1];
    }
    /**
     * @dev     Get winning details of a raffle, ie, it's winning numbers
     *          and the prize amounts. Returns two arrays.
     *
     * @param   _week   The week number of the raffle in question.
     *
     */
    function getWinningDetails(uint _week) constant external returns (uint[], uint[]) {
        return (raffle[_week].winNums, raffle[_week].winAmts);
    }
    /**
     * @dev     Upgrades the Etheraffle contract. Only callable by the
     *          Etheraffle address. Calls an addToPrizePool method as
     *          per the abstract contract above. Function renders the
     *          entry method uncallable, cancels the Oraclize recursion,
     *          then zeroes the prizepool and sends the funds to the new
     *          contract. Sets a var tracking when upgrade occurred and logs
     *          the event.
     *
     * @param _newAddr   The new contract address.
     */
    function upgradeContract(address _newAddr) onlyEtheraffle external {
        require(upgraded == 0 && upgradeAddr == address(0));
        uint amt    = prizePool;
        upgradeAddr = _newAddr;
        upgraded    = now;
        week        = 0;
        prizePool   = 0;
        gasAmt      = 0;
        apiStr1     = "";
        randomStr1  = "";
        require(this.balance >= amt);
        EtheraffleUpgrade(_newAddr).manuallyAddToPrizePool.value(amt)();
        emit LogUpgrade(_newAddr, amt, upgraded);
    }
    /**
     * @dev     Self destruct contract. Only callable by Etheraffle address.
     *          function. It deletes all contract code and data and forwards
     *          any remaining ether from non-claimed winning raffle tickets
     *          to the EthRelief charity contract. Requires the upgrade contract
     *          method to have been called 10 or more weeks prior, to allow
     *          winning tickets to be claimed within the usual withdrawal time
     *          frame.
     */
    function selfDestruct() onlyEtheraffle external {
        require(now - upgraded > WEEKDUR * 10);
        selfdestruct(ethRelief);
    }
    /**
     * @dev     Function allowing manual addition to the global prizepool.
     *          Requires the caller to send ether.
     */
    function addToPrizePool() payable external {
        require(msg.value > 0);
        prizePool += msg.value;
        emit LogPrizePoolAddition(msg.sender, msg.value, now);
    }
    /**
     * @dev     Fallback function.
     */
    function () payable external {}
}