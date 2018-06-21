/**
 * NOTE: This v2 currently in testing phase, see deprecated for current main-chain version. It's also more method call-y than v1, and so slightly more expensive in gas (for turnovers, not the end user!) but MUCH more readable/maintainable.
 */
/**
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
pragma solidity^0.4.20;

// import "github.com/oraclize/ethereum-api/oraclizeAPI.sol"; // Truffle uses the actual sol files
// import "github.com/Arachnid/solidity-stringutils/src/strings.sol"; // Truffle uses the actual sol files
import "./strings.sol";
import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

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
     * @title   Etheraffle
     * @author  Greg Kapka (github.com/gskapka)
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
    uint    public tktPrice     = 2500000000000000;
    uint    public oracCost     = 1500000000000000; // $1 @ $700
    uint[]  public pctOfPool    = [520, 114, 47, 319]; // ppt...
    uint[]  public odds         = [56, 1032, 54200, 13983816]; // Rounded down to nearest whole 
    uint  constant public WEEKDUR      = 604800;
    uint  constant public BIRTHDAY     = 1500249600;//Etheraffle's birthday <3
    // TODO: Can set strings after the fact to make deploy cheaper?
    string public randomStr1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\", \"serialNumber\"]','\\n{\"jsonrpc\": \"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\"";
    string public randomStr2 = "\",\"params\":{\"n\":\"6\",\"min\":1,\"max\":49,\"replacement\":false,\"base\":10,\"apiKey\":${[decrypt] BKM3j7tH7qBIQKuadP5kJ547Au1uB1Zo41u6tCfLPT3GDGJJCEpXLS87u1xlYsFu/i21zycQJgVFWzev+ZSjflQKsOCFbdN5oUSiR/GvD5nuLblzG6H+xq2lVdZ0lN/EZjrCmgMfaF0r3uo/FKcRdAnbf2wxKQ5Vfg==}}']";
    string public apiStr1    = "[URL] ['json(https://etheraffle.com/api/a).m','{\"r\":\"";
    string public apiStr2    = "\",\"k\":${[decrypt] BGQljYtTQ+yq9TZztMcWycMiaAezwNm3ppmcBvdh37ZJVJiTFbQw+h+WycbJtaklSFe2+S228NTf9eOh+6y06dlVpbJ3S28JhDOg50j4wqAIXdtCWDZLkAgyjXI3pOa3SJY3RV2b}}']";
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
        mapping (address => bytes32[]) entries;
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
    * @notice   Modifier to prepend to functions adding the additional
    *           conditional requiring caller of the method to be the
    *           etheraffle address.
    */
    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    /**
    * @notice   Modifier to prepend to functions adding the additional
    *           conditional requiring the paused bool to be false.
    */
    modifier onlyIfNotPaused() {
        require(!paused);
        _;
    }
    /**
     * @notice  Modifier to prepend to functions adding the additional
     *          conditional requiring caller of the method to be either
     *          the Oraclize or Etheraffle address.
     *
     */
    modifier onlyOraclize() {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
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
    event LogPrizePoolsUpdated(uint newMainPrizePool, uint indexed forRaffle, uint ticketPrice, uint unclaimedPrizePool, uint[] winningAmounts, uint atTime);
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
     * @notice  Constructor. Sets the Etheraffle multisig address, 
     *          the EthRelief & Disbursal contract addresses and 
     *          instantiates the FreeLOT contract. Sets up an 
     *          initial raffle struct.
     *
     * @param   _etheraffle Address of the Etheraffle multisig.
     *
     * @param   _disburse   Address of the disbursal contract.
     *
     * @param   _ethRelief  Address of the EthRelief contract.
     *
     * @param   _freeLOT    Address of the freeLOT contract.
     *
     * 0x97f535e98cf250cdd7ff0cb9b29e4548b609a0bd - Etheraffle
     * 0xb6a5f50b5ce5909a9c75ce27fec96e5de393af61 - Disbursal
     * 0x7ee65fe55accd9430f425379851fe768270c6699 - EthRelief
     * 0xc39f7bB97B31102C923DaF02bA3d1bD16424F4bb - FreeLOT
     */
    function Etheraffle(address _etheraffle, address _disburse, address _ethRelief, address _freeLOT) public payable {
        week         = getWeek();
        etheraffle   = _etheraffle;
        disburseAddr = _disburse;
        ethRelief    = _ethRelief;
        freeLOT      = FreeLOTInterface(_freeLOT);
        setUpRaffleStruct(week, 2500000000000000, (week * WEEKDUR) + BIRTHDAY);
        // TODO: Remove in prod!
        OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
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
     * @notice  Function which gets current week number and if different
     *          from the global var week number, it updates that and sets
     *          up the new raffle struct. Should only be called once a
     *          week after the raffle is closed. Should it get called
     *          sooner, the contract is paused for inspection.
     *
     */
    function setUpNewRaffle() internal {
        uint newWeek = getWeek();
        if (newWeek == week) return pauseContract(true, 4);
        setWeek(newWeek);
        setUpRaffleStruct(newWeek, tktPrice, BIRTHDAY + (newWeek * WEEKDUR));
    }
    /**
     * @notice  Function using Etheraffle's birthday to calculate the
     *          week number since then.
     *
     * @return  The current week number.
     *
     */
    function getWeek() public constant returns (uint) {
        uint curWeek = (now - BIRTHDAY) / WEEKDUR;
        return pastClosingTime(curWeek) ? curWeek + 1 : curWeek;
    }
    /**
     * @notice  Calculates if time function is called is past a raffle's 
     *          designated end time.
     *
     * @return  True if past closing else false.
     *
     */
    function pastClosingTime(uint _curWeek) internal view returns (bool) {
        return now - ((_curWeek * WEEKDUR) + BIRTHDAY) > rafEnd;
    }
	/**
	 * @notice	Sets up new raffle via creating a struct with the correct 
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
	 * @notice	Sets the withdraw status of a raffle.
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
	 * @notice	Sets the global week variable.
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
     * @notice  Sets the paused status of the contract to the bool 
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
     * @notice  Sets the paused status of the contract to the bool 
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
     *
     *      ##########################################
     *      ###                                    ###
     *      ###         Ticket Purchasing          ###
     *      ###                                    ###
     *      ##########################################
     *
     */
   /**
     * @notice  Function to enter a raffle. Checks for correct ticket price, 
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
     * @notice  Function to enter the raffle on behalf of another address.  
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
     * @notice  Function to enter the raffle for free. Requires the caller's
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
     * @notice  Function to enter the raffle on behalf of another address 
     *          for free. Requires the caller's balance of the Etheraffle 
     *          freeLOT token to be greater than zero. Function destroys 
     *          one freeLOT token, increments the freeEntries variable in 
     *          the raffle struct then purchases the ticket. Only callable 
     *          when the contract is not paused. In the event of a win, only 
     *          the onBehalfOf address can claim it.
     *  
     * @param   _cNums        Ordered array of entrant's six selected numbers.
     *
     * @param   _affID        Affiliate ID of the source of this entry.
     *
     * @param   _onBehalfOf   The address to be entered on behalf of.
     *
     */
    function enterOnBehalfOfFree(uint[] _cNums, uint _affID, address _onBehalfOf) payable public onlyIfNotPaused {
        decrementFreeLOT(msg.sender, 1);
        incremementEntries(week, true);
        buyTicket(_cNums, _onBehalfOf, msg.value, _affID);
    }
    /**
     * @notice  Checks that a raffle struct has a ticket price set and whether 
     *          the caller's msg.value is greater than or equal to that price.
     *
     * @param   _week   Week number for raffle in question.
     *
     * @return  True if msg.value greater than tktPrice, else false.
     *
     */
    function validTktPrice(uint _week) internal view returns (bool) {
        return (
            raffle[_week].tktPrice > 0 && 
            msg.value >= raffle[_week].tktPrice
        );
    }
    /**
     * @notice  Decrement an address' FreeLOT token holdings by a specified 
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
     * @notice  Internal function that purchases raffle tickets. Requires the 
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
        modifyPrizePool(true, _value);
        storeEntry(week, _entrant, _cNums);
        emit LogTicketBought(week, raffle[week].numEntries, _entrant, _cNums, raffle[week].entries[_entrant].length, _value, now, _affID);
    }
    /**
     * @notice  Stores a ticket purchase by hashing the chosen numbers 
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
     * @notice  Increments the number of entries in a raffle struct. 
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
     * @notice  Temporal & raffle struct setup requirements that need to be 
     *          satisfied before a raffle ticket can be purchased.
     *
     * @return  True if raffle is open for entry, else false.
     *
     */
    function raffleOpenForEntry() internal view returns (bool) {
        return (
            raffle[week].timeStamp > 0 &&
            now < raffle[week].timeStamp + rafEnd
        );
    }
    /**
     * @notice  Series of requirements a raffle ticket's chosen numbers must 
     *          pass in order to qualify as valid. Ensures that there are six 
     *          numbers, in ascending order, between one and 49.
     *
     * @param   _cNums  Array of a ticket's proposed numbers in question.
     *
     * @return  True if numbers are valid, else false.
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
     * @notice  Modifies prizePool var. If true passed is in as first 
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
        if (!_bool) require (_amt <= prizePool);
        prizePool = _bool ? prizePool + _amt : prizePool - _amt;
        // TODO: Remove temp event logging!
        emit LogPrizePoolModification(_amt, _bool, now);
    }
    event LogPrizePoolModification(uint amount, bool wasPrizeAddition, uint atTime);
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
     * @notice  User calls this function in order to withdraw whatever 
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
     * @notice  Mints a FreeLOT coupon to a two match winner allowing them 
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
     * @notice  If ticket wins ETH this function first checks the eligibility 
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
    function payWinnings(uint _week, uint _entryNum, uint _matches, address _entrant) private {
        require (eligibleForWithdraw(_week, _matches));
        invalidateEntry(_week, _entrant, _entryNum);
        modifyUnclaimed(false, _week, raffle[_week].winAmts[_matches - 3]);
        transferWinnings(_entrant, raffle[_week].winAmts[_matches - 3]);
        emit LogWithdraw(_week, _entrant, _entryNum, _matches, raffle[_week].winAmts[_matches - 3], now);
    }
    /**
     * @notice  Tranfers an amount of ETH to an address.
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
     * @notice  Modifies the unclaimed variable in a struct. If true passed 
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
        if (!_bool) require (_amt <= raffle[_week].unclaimed);
        raffle[_week].unclaimed = _bool ? raffle[_week].unclaimed + _amt : raffle[_week].unclaimed - _amt;
    }
    /**
     * @notice  Various requirements w/r/t number of matches, win amounts 
     *          being set in the raffle struct and contract balance that 
     *          need to be passed before withdrawal can be processed.
     *
     * @param   _week     Week number for raffle in question.
     *
     * @param   _matches  Number of matches the entry in question has made.
     *
     * @return  True if eligible for withdraw, else false.
     *
     */
    function eligibleForWithdraw(uint _week, uint _matches) view internal returns (bool) {
        return (
            _matches >= 3 &&
            raffle[_week].winAmts[_matches - 3] > 0 &&
            raffle[_week].winAmts[_matches - 3] <= this.balance
        );
    }
    /**
     * @notice  Compares hash of provided entry numbers to previously bought 
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
     * @return  True if entry is valid, else false.
     *
     */
    function validEntry(uint _week, uint _entryNum, uint[] _cNums, address _entrant) view internal returns (bool) {
        return raffle[_week].entries[_entrant][_entryNum - 1] == keccak256(_cNums);
    }
    /**
     * @notice  Function zeroes the previously stored hash of an entrant's 
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
     * @notice  Various temporal requirements plus struct setup requirements 
     *          that need to be met before a prize withdrawal can be processed. 
     *          In order: Winning numbers need to be set, withdraw bool needs 
     *          to be true, raffle's timestamp needs to be set, that the time 
     *          the function is called needs to be before the withdraw deadline, 
     *          and that the time the function is called needs to be six days 
     *          beyond the timestamp. 
     *
     * @param   _week   Week number for the raffle in question.
     *
     * @return  True if raffle is open for withdraw, else false.
     *
     */
    function openForWithdraw(uint _week) view internal returns (bool) {
        return (
            winningNumbersSet(_week) &&
            raffle[_week].wdrawOpen &&
            raffle[_week].timeStamp > 0 &&
            now - raffle[_week].timeStamp < wdrawBfr &&
            now - raffle[_week].timeStamp > WEEKDUR - (WEEKDUR / 7)
        );
    }
    /**
     * @notice  Function performs set intersection on two arrays
     *          and counts to see how many numbers they have in common.
     *
     * @param   _cNums  Array of entrant's chosen numbers.
     *
     * @param   _wNums  Array of winning numbers.
     *
     * @return  Amount of numbers two arrays have in common.
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
     * @notice  The Oralize call back function. Only callable by Etheraffle 
     *          or the Oraclize address. Emits an event detailing the callback, 
     *          before running the relevant method that acts on the callback.
     * 
     * @param   _myID    Unique id oraclize provides with their callbacks.
     *                            
     * @param   _result  The result of the api call.
     *
     */
    function __callback(bytes32 _myID, string _result) public onlyIfNotPaused onlyOraclize {
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        queryIsRandom(_myID) 
            ? randomCallback(_myID, _result) 
            : apiCallback(_myID, _result);
    }
        /**
     * @notice  Checks if an Oraclize query was made manually or not.
     *
     * @param   _ID     Bytes32 hash identifying the query in question.
     *
     * @return  True if query was made manually, else false.
     *
     */
    function queryIsManual(bytes32 _ID) internal view returns (bool) {
        return qID[_ID].isManual;
    }
    /**
     * @notice  Checks if an Oraclize query was to Random.org or not.
     *
     * @param   _ID     Bytes32 hash identifying the query in question.
     *
     * @return  True if query pertains to a Random.org api call, else false.
     *
     */
    function queryIsRandom(bytes32 _ID) internal view returns (bool) {
        return qID[_ID].isRandom;
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###          Random Callback           ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @notice  Called when a random.org api callback comes in. It first 
     *          reclaims unclaimed prizes from the raffle ten weeks previous,
     *          disburses this week's raffle's profits, sets the winning 
     *          numbers from the callback in this raffle's struct and finally 
     *          prepares the next Oraclize query to call the Etheraffle API.
     *          Function requires the winning numbers to not already have been
     *          set which stops Oraclize replays causing havoc!
     *
     * @param   _myID       The hash of the Oraclize query
     *
     * @param   _result     The result of the Oraclize query
     *
     */
    function randomCallback(bytes32 _myID, string _result) internal onlyOraclize {
        require(!winningNumbersSet(qID[_myID].weekNo));
        reclaimUnclaimed();
        performAccounting(qID[_myID].weekNo);
        setWinningNumbers(qID[_myID].weekNo, _result);
        if (queryIsManual(_myID)) return;
        sendQuery(matchesDelay, getQueryString(false, qID[_myID].weekNo), qID[_myID].weekNo, false, false);
    }
    /**
     * @notice  Returns bool depending on whether the winning numbers
     *          have been set in the struct or not.
     *
     * @param   _week   Week number for raffle in question.
     *
     * @return  True if winning numbers are set correctly in raffle struct.
     *
     */
    function winningNumbersSet(uint _week) internal view returns (bool) {
        return raffle[_week].winNums.length > 0;
    }
    /**
     * @notice  Called by the weekly Oraclize callback. Checks raffle 10
     *          weeks older than current raffle for any unclaimed prize
     *          pool. If any found, returns it to the main prizePool and
     *          zeros the amount.
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
     * @notice  Returns the unclaimed prize pool sequestered in a raffle's
     *          struct.
     *
     * @param   _week   Week number for raffle in question.
     *
     * @return  Unclaimed prize pool sequestered in raffle's struct in Wei.
     *
     */
    function getUnclaimed(uint _week) public view returns (uint) {
        return raffle[_week].unclaimed;
    }
        /**
     * @notice  Calculates and accounts for a raffle's costs and profits, 
     *          before distributing the latter should there be any.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function performAccounting(uint _week) internal {
        uint cost = getOraclizeCost();
        accountForCosts(cost);
        uint profit = calcProfit(_week);
        accountForProfit(profit);
        distributeFunds(_week, cost, profit);
    }
    /**
     * @notice  Takes oraclize random.org api call result string and splits
     *          it at the commas into an array, parses those strings in that
     *          array as integers and pushes them into the winning numbers
     *          array in the raffle's struct. Fires event logging the data,
     *          including the serial number of the random.org callback so
     *          its veracity can be proven.
     *
     * @param   _week    The week number of the raffle in question.
     *
     * @param   _result   The results string from oraclize callback.
     *
     */
    function setWinningNumbers(uint _week, string _result) internal {
        string[] memory arr = stringToArray(_result);
        for (uint i = 0; i < 6; i++){
            raffle[_week].winNums.push(parseInt(arr[i]));
        }
        uint serialNo = parseInt(arr[6]);
        emit LogWinningNumbers(_week, raffle[_week].numEntries, raffle[_week].winNums, prizePool, serialNo, now);
    }
    /**
     * @notice  Returns the cost of the Oraclize api calls
     *          (two per draw).
     *
     * @return  The cost of the two Oraclize API calls per draw.
     *
     */
    function getOraclizeCost() internal view returns (uint) {
        return ((gasAmt * gasPrc) + oracCost) * 2;
    }
    /**
     * @notice  Subtracts a given cost from the prize pool. Pauses contract 
     *          instead if cost is greater than the prize pool.
     *
     * @param   _cost   Amount to be deducted from the prize pool.
     *
     */
    function accountForCosts(uint _cost) private {
        if (_cost > prizePool) return pauseContract(true, 1);
        if (_cost == 0) return; // TODO: Unnecessary? Will save a little gas except on deploy...
        modifyPrizePool(false, _cost);
    }
    /**
     * @notice  Calculates profits earnt from a raffle. If there are 
     *          no paid entries or if free entries outweigh paid 
     *          entries, returns 0.
     *
     * @param   _week   Week number for raffle in question.
     *
     * @return  The profit generated from a raffle's ticket sales.
     *
     */
    function calcProfit(uint _week) internal view returns (uint) {
        return (raffle[_week].numEntries > 0 && raffle[_week].numEntries > raffle[_week].freeEntries)
            ? ((raffle[_week].numEntries - raffle[_week].freeEntries) * tktPrice * take) / 1000
            : 0;
    }
    /**
     * @notice  Subtracts a given amount of profit from the prize pool, if 
     *          said amount is greater than zero.
     *
     * @param   _profit   Amount to be deducted from the prize pool.
     *
     */
    function accountForProfit(uint _profit) private {
        if (_profit == 0) return;
        modifyPrizePool(false, _profit);
    }
    /**
     * @notice  Distributes any profit earnt from a raffle. Half goes to 
     *          the disbursal contract for the DAO of token holders, and 
     *          the remainder to the EthRelief contract for charitable 
     *          donations.
     *
     * @param   _week       Week number for raffle in question.
     *
     * @param   _cost       Cost of running this raffle.
     *
     * @param   _profit     Profit from running this raffle.
     *
     */
    function distributeFunds(uint _week, uint _cost, uint _profit) private {
        if (_profit == 0) return LogFundsDisbursed(_week, _cost, 0, 0, now); // Can't use emit keyword after return statement...
        uint half = _profit / 2;
        disburseFunds(_week, _cost, half, disburseAddr);
        disburseFunds(_week, _cost, _profit - half, ethRelief);
    }
    /**
     * @notice  Sends funds via a given contract's "receiver" interface,
     *          which ensures an event is fired in the receiving contract, 
     *          announcing the funds' arrival.
     *
     * @param   _addr   Address of receiving contract.
     *
     * @param   _amt    Amount of Wei to send.
     *
     */
    function disburseFunds(uint _week, uint _cost, uint _amt, address _addr) private {
        ReceiverInterface(_addr).receiveEther.value(_amt)();
        emit LogFundsDisbursed(_week, _cost, _amt, _addr, now);
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###        Etheraffle Callback         ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @notice  Called when the Etheraffle API callback is received. It sets 
     *          up the next raffle's struct, calculates this raffle's payouts 
     *          then makes the next Oraclize query to call the Random.org api.
     *          Function requires the winning amounts to not already have been
     *          set which stops Oraclize replays causing havoc!
     *
     * @param   _myID       The hash of the Oraclize query
     *
     * @param   _result     The result of the Oraclize query
     *
     */
    function apiCallback(bytes32 _myID, string _result) internal onlyOraclize {
        require (!winAmountsSet(qID[_myID].weekNo));
        setUpNewRaffle();
        setPayOuts(qID[_myID].weekNo, _result);
        if (queryIsManual(_myID)) return;
        sendQuery(getNextDeadline(), getQueryString(true, getWeek()), getWeek(), true, false);
    }
    /**
     * @notice  Returns bool depending on whether the win amounts have 
     *          been set in the struct or not.
     *
     * @param   _week   Week number for raffle in question.
     *
     * @return  True if the winning amounts are set correctly in the 
     *          raffle's struct, else false.
     *
     */
    function winAmountsSet(uint _week) internal view returns (bool) {
        return raffle[_week].winAmts.length > 0;
    }
    /**
     * @notice  Returns the number of seconds until the next occurring 
     *          raffle deadline.
     *
     * @return  The deadline in UTC format of the raffle calculated 
     *          from the current week number.
     *
     */
    function getNextDeadline() internal view returns (uint) {
        return (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
    }
    /**
     * @notice  Takes the results of the oraclize Etheraffle api call back
     *          and uses them to calculate the prizes due to each tier
     *          (3 matches, 4 matches etc) then pushes them into the winning
     *          amounts array in the raffle in question's struct. Calculates
     *          the total winnings of the raffle, subtracts it from the
     *          global prize pool sequesters that amount into the raffle's
     *          struct "unclaimed" variable, ∴ "rolling over" the unwon
     *          ether. Enables winner withdrawals by setting the withdraw
     *          open bool to true.
     *
     * @param   _week       The week number of the raffle in question.
     *
     * @param   _result     The results string from oraclize callback.
     *
     */
    function setPayOuts(uint _week, string _result) internal {
        string[] memory numWinnersStr = stringToArray(_result);
        if (numWinnersStr.length < 4) return pauseContract(true, 2);
        for (uint i = 0; i < 4; i++) {
            uint amt = 0;
            uint numWinners = parseInt(numWinnersStr[i]);
            if (numWinners != 0) {
                amt = calcPrize(numWinners, i, _week);
                modifyUnclaimed(true, _week, amt * numWinners);
            }
            raffle[_week].winAmts.push(amt);
        }
        // if (raffle[_week].unclaimed > prizePool) return pauseContract(true, 3); // TODO: reinstate? (Would be a double check, is this bad?)
        modifyPrizePool(false, raffle[_week].unclaimed);
        setWithdraw(_week, true);
        emit LogPrizePoolsUpdated(prizePool, _week, raffle[_week].tktPrice, raffle[_week].unclaimed, raffle[_week].winAmts, now);
    }
    /**
     * @notice  Calculates the total prizes for a given tier using the 
     *          splits method & the odds method, and returns the singular 
     *          prize using whichever method returned from the preceeding.
     *
     * @param   _numWinners   Number of winners in this tier
     *
     * @param   _i            Index this tier corresponds to in odds/splits arrays
     *
     * @param   _week         The week number of the raffle in question.
     *
     * @return  The prize amount in Wei for a given tier w/r/t number of
     *          winners in that tier.
     *
     */
    function calcPrize(uint _numWinners, uint _i, uint _week) internal view returns (uint) {
        return oddsTotal(_numWinners, _i, _week) <= splitsTotal(_numWinners, _i) ? oddsSingle(_i, _week) : splitsSingle(_numWinners, _i); 
    }
    /*  
     * @notice  Calculates the total payout per tier when calculated using 
     *          the odds method.
     *
     * @param   _numWinners     Number of X match winners.
     *
     * @param   _matchesIndex   Index of matches array (∴ 3 match win,
     *                          4 match win etc).
     *
     * @return  The total prize amount in Wei for a given tier, calculated 
     *          using the true odds for a given number of matches.
     *
     */
    function oddsTotal(uint _numWinners, uint _matchesIndex, uint _week) internal view returns (uint) {
        return oddsSingle(_matchesIndex, _week) * _numWinners;
    }
    /*
     * @notice  Calculates the total payout per tier when calculated using
     *          the splits method.
     *
     * @param    _numWinners     Number of X match winners.
     *
     * @param    _matchesIndex   Index of matches array (∴ 3 match win,
     *                           4 match win etc).
     *
     * @return  The total prize amount in Wei for a given tier, calculated
     *          using a percentage split for a given tier of the total 
     *          prize pool.
     *
     */
    function splitsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return splitsSingle(_numWinners, _matchesIndex) * _numWinners;
    }
    /*
     * @notice  Calculates single payout when calculated using the odds
     *          method.
     *
     * @param   _matchesIndex   Index of matches array (∴ 3 match win,
     *                          4 match win etc).
     *
     * @return  A single prize amount in Wei for a given tier, calculated
     *          using the true odds for a given number of matches.
     *
     */
    function oddsSingle(uint _matchesIndex, uint _week) internal view returns (uint) {
        return (raffle[_week].tktPrice * odds[_matchesIndex] * (1000 - take)) / 1000;
    }
    /*
     * @notice  Calculates a single payout when calculated using the 
     *          splits method.
     *
     * @param   _numWinners     Number of X match winners.
     *
     * @param   _matchesIndex   Index of matches array (∴ 3 match win,
     *                          4 match win etc).
     *
     * @return  A single prize amount in Wei for a given tier, calculated
     *          using a percentage split for a given tier of the total 
     *          prize pool.
     *
     */
    function splitsSingle(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return (prizePool * pctOfPool[_matchesIndex]) / (_numWinners * 1000);
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###         Oraclize Queries           ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @notice  Modifies a query ID struct with the passed in information. 
     *          (Or creates it if struct doesn't exist yet...)
     *
     * @param   _ID         Bytes32 hash identifier for the struct.
     *
     * @param   _weekNo     Week number relevant to struct.
     *
     * @param   _isRandom   Whether the struct refers to a Random.org api call.
     *
     * @param   _isManual   Whether the struct was manually created or not.
     *                      If manual, the Oraclize callback returns before the 
     *                      next recursive Oraclize query is sent.
     *
     */
    function modifyQIDStruct(bytes32 _ID, uint _weekNo, bool _isRandom, bool _isManual) internal {
        qID[_ID].weekNo    = _weekNo;
        qID[_ID].isRandom  = _isRandom;
        qID[_ID].isManual  = _isManual;
    }
    /**
     * @notice  Prepares the correct Oraclize query string using Oraclize's 
     *          contract's string concat function.
     *
     * @param   _isRandom   Whether the query is to the Random.org api, or Etheraffle's.
     *
     * @param   _weekNo     Raffle number the call is being made on behalf of.
     *
     * @return  A string making up the full Oraclize query for either the Random.org
     *          or Etheraffle API calls, depending on bool passed in.
     *
     */
    function getQueryString(bool _isRandom, uint _weekNo) internal onlyOraclize returns (string) {
        return _isRandom 
               ? strConcat(randomStr1, uint2str(_weekNo), randomStr2)
               : strConcat(apiStr1, uint2str(_weekNo), apiStr2);
    }
    /**
     * @notice  Sends an Oraclize query, stores info w/r/t that query in a
     *          struct mapped to by the hash of the query, and logs the 
     *          pertinent details.
     *
     * @param   _delay      Desired return time for query from sending.
     *
     * @param   _str        The Oraclize call string.
     *
     * @param   _weekNo     Week number for raffle in question.
     *
     * @param   _isRandom   Whether the call is destined for Random.org 
     *                      or Etheraffle.
     *
     * @param   _isManual   Whether the call is being made manually or 
     *                      recursively.
     *
     */
    function sendQuery(uint _delay, string _str, uint _weekNo, bool _isRandom, bool _isManual) internal onlyOraclize {
        bytes32 query = oraclize_query(_delay, "nested", _str, gasAmt);
        modifyQIDStruct(query, _weekNo, _isRandom, _isManual);
        emit LogQuerySent(query, _delay, now);
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###             Utilities              ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @notice  Slices a string according to specified delimiter, returning
     *          the sliced parts in an array. Courtesy of Nick Johnson via
     *          https://github.com/Arachnid/solidity-stringutils
     *
     * @param   _string   The string to be sliced.
     *
     * @return  An array of strings.
     *
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
     * @notice  Fallback function.
     */
    function () payable external {}
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###              Setters               ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @notice  Function allowing manual addition to the global prizepool.
     *          Requires the caller to send ether, by which amount the 
     *          prize pool is increased.
     *
     */
    function manuallyAddToPrizePool() payable public {
        require (msg.value > 0);
        modifyPrizePool(true, msg.value);
        emit LogPrizePoolAddition(msg.sender, msg.value, now);
    }
    /**
     * @notice  Set the Oraclize strings, in case of url changes. Only callable by
     *          the Etheraffle address.
     *
     * @param   _randomStr1     String with properly escaped characters for 
     *                          first half of Random.org api call.
     *
     * @param   _randomStr2     String with properly escaped characters for 
     *                          second half of Random.org api call.
     *
     * @param   _apiStr1        String with properly escaped characters for 
     *                          first half of Etheraffle api call.
     *
     * @param   _apiStr2        String with properly escaped characters for 
     *                          second half of Etheraffle api call.
     *
     */
    function manuallySetOraclizeString(string _randomStr1, string _randomStr2, string _apiStr1, string _apiStr2) external onlyEtheraffle {
        randomStr1 = _randomStr1;
        randomStr2 = _randomStr2;
        apiStr1    = _apiStr1;
        apiStr2    = _apiStr2;
    }
    /**
     * @notice  Set the ticket price of the raffle. Only callable by the
     *          Etheraffle address.
     *
     * @param   _newPrice   The desired new ticket price.
     *
     */
    function manuallySetTktPrice(uint _newPrice) external onlyEtheraffle {
        tktPrice = _newPrice;
    }
    /**
     * @notice  Set new take percentage. Only callable by the Etheraffle
     *          address.
     *
     * @param   _newTake   The desired new take, parts per thousand.
     *
     */
    function manuallySetTake(uint _newTake) external onlyEtheraffle {
        take = _newTake;
    }
    /**
     * @notice  Set the payouts manually, in case of a failed Oraclize call.
     *          Only callable by the Etheraffle address.
     *
     * @param   _week           The week number of the raffle to set the payouts for.
     *
     * @param   _numMatches     Number of matches. Comma-separated STRING of 4
     *                          integers long, consisting of the number of 3 match
     *                          winners, 4 match winners, 5 & 6 match winners in
     *                          that order.
     *
     */
    function manuallySetPayouts(uint _week, string _numMatches) external onlyEtheraffle {
        setPayOuts(_week, _numMatches);
    }
    /**
     * @notice  Set the FreeLOT token contract address, in case of future updrades.
     *          Only allable by the Etheraffle address.
     *
     * @param   _newAddr   New address of FreeLOT contract.
     */
    function manuallySetFreeLOT(address _newAddr) external onlyEtheraffle {
        freeLOT = FreeLOTInterface(_newAddr);
      }
    /**
     * @notice  Set the EthRelief contract address, and gas required to run
     *          the receiving function. Only allable by the Etheraffle address.
     *
     * @param   _newAddr   New address of the EthRelief contract.
     */
    function manuallySetEthReliefAddr(address _newAddr) external onlyEtheraffle {
        ethRelief = _newAddr;
    }
    /**
     * @notice  Set the dividend contract address, and gas required to run
     *          the receive ether function. Only callable by the Etheraffle
     *          address.
     *
     * @param   _newAddr   New address of dividend contract.
     */
    function manuallySetDisbursingAddr(address _newAddr) external onlyEtheraffle {
        disburseAddr = _newAddr;
    }
    /**
     * @notice  Set the Etheraffle multisig contract address, in case of future
     *          upgrades. Only callable by the current Etheraffle address.
     *
     * @param   _newAddr   New address of Etheraffle multisig contract.
     */
    function manuallySetEtheraffleAddr(address _newAddr) external onlyEtheraffle {
        etheraffle = _newAddr;
    }
    /**
     * @notice  Set the raffle end time, in number of seconds passed
     *          the start time of 00:00am Monday. Only callable by
     *          the Etheraffle address.
     *
     * @param   _newTime    The time desired in seconds.
     */
    function manuallySetRafEndTime(uint _newTime) external onlyEtheraffle {
        rafEnd = _newTime;
    }
        /**
     * @notice  Set the matches delay time. Number of seconds between 
     *          the recursive Random.org api call, and the Etheraffle 
     *          api call.
     *
     * @param   _newTime    The time desired in seconds.
     */
    function manuallySetMatchesDelayTime(uint _newTime) external onlyEtheraffle {
        matchesDelay = _newTime;
    }
    /**
     * @notice  Set the wdrawBfr time - the time a winner has to withdraw
     *          their winnings before the unclaimed prizepool is rolled
     *          back into the global prizepool. Only callable by the
     *          Etheraffle address.
     *
     * @param   _newTime    The time desired in seconds.
     */
    function manuallySetWithdrawBefore(uint _newTime) external onlyEtheraffle {
        wdrawBfr = _newTime;
    }
    /**
     * @notice  Set the paused status of the raffles. Only callable by
     *          the Etheraffle address.
     *
     * @param   _status    The desired status of the raffles.
     */
    function manuallySetPaused(bool _status) external onlyEtheraffle {
        pauseContract(_status);
    }
    /**
     * @notice  Set the percentage-of-prizepool array. Only callable by the
     *          Etheraffle address.
     *
     * @param   _newPoP     An array of four integers totalling 1000.
     */
    function manuallySetPercentOfPool(uint[] _newPoP) external onlyEtheraffle {
        pctOfPool = _newPoP;
    }
    /**
	 * @notice	Allows manual set up of a new raffle via creating a struct
     *          with the correct timestamp and ticket price. Only callable
     *          by the Etheraffle multisig address.
	 *
	 * @param   _week       Desired week number for new raffle struct.
     *
     * @param   _tktPrice   Desired ticket price for the raffle
     *
     * @param   _timeStamp  Timestamp of Mon 00:00 of the week of this raffle
     *
	 */
    function manuallySetupRaffleStruct(uint _week, uint _tktPrice, uint _timeStamp) external onlyEtheraffle {
        setUpRaffleStruct(_week, _tktPrice, _timeStamp);
    }
	/**
	 * @notice	Manually sets the withdraw status of a raffle. Only
     *          callable by the Etheraffle multisig.
	 *
	 * @param   _week   Week number for raffle in question.
     *
     * @param   _status Desired withdraw status for raffle.
     *
	 */
    function manuallySetWithdraw(uint _week, bool _status) external onlyEtheraffle {
        setWithdraw(_week, _status);
    }
    /**
	 * @notice	Manually sets the global week variable. Only callable
     *          by the Etheraffle multisig wallet.
	 *
	 * @param   _week   Desired week number.
     *
	 */
    function manuallySetWeek(uint _week) external onlyEtheraffle {
        setWeek(_week);
    }
        /**
     * @notice  Manually make an Oraclize API call, incase of automation
     *          failure. Only callable by the Etheraffle address.
     *
     * @param   _delay      Either a time in seconds before desired callback
     *                      time for the API call, or a future UTC format time
     *                      for the desired time for the API callback.
     *
     * @param   _week       The week number this query is for.
     *
     * @param   _isRandom   Whether or not the api call being made is for
     *                      the random.org results draw, or for the 
     *                      Etheraffle API results call.
     *
     * @param   _isManual   The Oraclize call back is a recursive function in
     *                      which each call fires off another call in perpetuity.
     *                      This bool allows that recursiveness for this call to
     *                      be turned on or off depending on caller's requirements.
     *
     * @param   _status     The desired paused status of the contract.
     *
     */
    function manuallyMakeOraclizeCall(uint _week, uint _delay, bool _isRandom, bool _isManual, bool _status) onlyEtheraffle external {
        pauseContract(_status);
        sendQuery(_delay, getQueryString(_isRandom, _week), _week, _isRandom, _isManual);
    }
    /**
     * @notice  Manually edit (or make!) a query ID struct, that Oraclize callbacks 
     *          can reference.
     *
     * @param   _ID         Desired keccak hash key for the struct
     *
     * @param   _weekNo     Desired week/raffle number the struct refers to. 
     *
     * @param   _isRandom   Whether or not the api call being made is for
     *                      the random.org results draw, or for the Etheraffle
     *                      API results call.
     *
     * @param   _isManual   The Oraclize call back is a recursive function in
     *                      which each call fires off another call in perpetuity.
     *                      This bool allows that recursiveness for this call to be
     *                      turned on or off depending on caller's requirements.
     *
     */
    function manuallyModifyQID(bytes32 _ID, uint _weekNo, bool _isRandom, bool _isManual) onlyEtheraffle external {
        modifyQIDStruct(_ID, _weekNo, _isRandom, _isManual);
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
     * @notice  Get a entrant's number of entries into a specific raffle
     *
     * @param   _week       The week number of the raffle in question.
     *
     * @param   _entrant    The entrant in question.
     *
     * @return  The number of entries an entrant has made in a given raffle.
     *
     */
    function getUserNumEntries(address _entrant, uint _week) constant external returns (uint) {
        return raffle[_week].entries[_entrant].length;
    }
    /**
     * @notice  Get chosen numbers of an entrant, for a specific raffle.
     *          Returns an array.
     *
     * @param   _entrant    The entrant in question's address.
     *
     * @param   _week       The week number of raffle in question.
     *
     * @param   _entryNum   The entrant's entry number in this raffle.
     *
     * @return  The hash of an entrant's entry numbers in the specified raffle. 
     *
     */
    function getChosenNumbersHash(address _entrant, uint _week, uint _entryNum) constant external returns (bytes32) {
        return raffle[_week].entries[_entrant][_entryNum-1];
    }
    /**
     * @notice  Get winning details of a raffle, ie, it's winning numbers
     *          and the prize amounts. Returns two arrays.
     *
     * @param   _week   The week number of the raffle in question.
     *
     * @return  The two arrays stored in the given raffle's struct, 
     *          containing if set the winning numbers and the winning
     *          winning amounts respectively.
     *
     */
    function getWinningDetails(uint _week) constant external returns (uint[], uint[]) {
        return (raffle[_week].winNums, raffle[_week].winAmts);
    }
    /**
     *
     *      ##########################################
     *      ###                                    ###
     *      ###         Upgrade Functions          ###
     *      ###                                    ###
     *      ##########################################
     *
     */
    /**
     * @notice  Upgrades the Etheraffle contract. Only callable by the
     *          Etheraffle address. Calls an addToPrizePool method as
     *          per the abstract contract above. Function renders the
     *          entry method uncallable, cancels the Oraclize recursion,
     *          then zeroes the prizepool and sends the funds to the new
     *          contract. Sets a var tracking when upgrade occurred and logs
     *          the event.
     *
     * @param   _newAddr   The new contract address.
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
     * @notice  Self destruct contract. Only callable by Etheraffle address.
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
}

