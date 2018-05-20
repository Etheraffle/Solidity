 //TODO: Make the back end event watchers will have to consume the new event!
// TODO: Make sure the getters for entries still work? Or make new one to check if wdrawn?!
 
 contract ChosenNumberHashes {

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
    /**
     * @dev  Function to enter the raffle. Requires the caller to send ether
     *       of amount greater than or equal to the current raffle's tkt price.
     *
     * @param _cNums    Ordered array of entrant's six selected numbers.
     *
     * @param _affID    Affiliate ID of the source of this entry.
     *
     */
    function enterRaffle(uint[] _cNums, uint _affID) payable public onlyIfNotPaused {
        require (validTktPrice(week));
        buyTicket(_cNums, msg.sender, msg.value, _affID);
    }


    /**
     * @dev     Checks whether msg.value is enough to cover the raffle for 
     *          the week in question's ticket price.
     *
     * @param _week     Week number for raffle in question
     *
     */
    function validTktPrice(uint _week) internal view returns (bool) {
        return (
            raffle[_week].tktPrice > 0 && 
            msg.value >= raffle[_week].tktPrice
        );
    }
    /**
     * @dev  Function to enter the raffle on behalf of another address. Requires the 
     *       caller to send ether of amount greater than or equal to the current 
     *       raffle's ticket price. In the event of a win, only the onBehalfOf 
     *       address can claim it.
     *
     * @param _cNums        Ordered array of entrant's six selected numbers.
     *
     * @param _affID        Affiliate ID of the source of this entry.
     *
     * @param _onBehalfOf   The address to be entered on behalf of.
     *
     */
    function enterOnBehalfOf(uint[] _cNums, uint _affID, address _onBehalfOf) payable public onlyIfNotPaused {
        require (validTktPrice(week));
        buyTicket(_cNums, _onBehalfOf, msg.value, _affID);
    }
    /**
     * @dev  Function to enter the raffle for free. Requires the caller's
     *       balance of the Etheraffle freeLOT token to be greater than
     *       zero. Function destroys one freeLOT token, increments the
     *       freeEntries variable in the raffle struct then purchases the
     *       ticket.
     *
     * @param _cNums    Ordered array of entrant's six selected numbers.
     * @param _affID    Affiliate ID of the source of this entry.
     */
    function enterFreeRaffle(uint[] _cNums, uint _affID) payable public onlyIfNotPaused {
        freeLOT.destroy(msg.sender, 1);
        raffle[week].freeEntries++;
        buyTicket(_cNums, msg.sender, msg.value, _affID);
    }
    /**
     * @dev   Function to buy tickets. Internal. Requires the entry number
     *        array to be of length 6, requires the timestamp of the current
     *        raffle struct to have been set, and for this time this function
     *        is call to be before the end of the raffle. Then requires that
     *        the chosen numbers are ordered lowest to highest & bound between
     *        1 and 49. Function increments the total number of entries in the
     *        current raffle's struct, increments the prize pool accordingly
     *        and pushes the chosen number array into the entries map and then
     *        logs the ticket purchase.
     *
     * @param _cNums       Array of users selected numbers.
     * @param _entrant     Entrant's ethereum address.
     * @param _value       The ticket purchase price.
     * @param _affID       The affiliate ID of the source of this entry.
     */
    function buyTicket (uint[] _cNums, address _entrant, uint _value, uint _affID) internal {
        require (raffleOpenForEntry() && validNumbers(_cNums));
        raffle[week].numEntries++;
        addToPrizePool(_value);
        raffle[week].entries[_entrant].push(keccak256(_cNums);
        emit LogTicketBought(week, raffle[week].numEntries, _entrant, _cNums, raffle[week].entries[_entrant].length, _value, now, _affID);
    }

    function raffleOpenForEntry() internal view returns (bool) {
        return (
            raffle[week].timeStamp > 0 &&
            now < raffle[week].timeStamp + rafEnd
        );
    }

    function validNumbers(uint[] _cNums) internal pure returns (bool) {
        return (
            _cNums.length == 6 &&
            0         < _cNums[0] &&
            _cNums[0] < _cNums[1] &&
            _cNums[1] < _cNums[2] &&
            _cNums[2] < _cNums[3] &&
            _cNums[3] < _cNums[4] &&
            _cNums[4] < _cNums[5] &&
            _cNums[5] <= 49
        );
    }
    function addToPrizePool(uint _amt) private {
        prizePool += msg.value;
    }
    /**
     * @dev     Function allowing manual addition to the global prizepool.
     *          Requires the caller to send ether.
     */
    function manuallyAddToPrizePool() payable external {
        require (msg.value > 0);
        addToPrizePool(msg.value);
        emit LogPrizePoolAddition(msg.sender, msg.value, now);
    }
    /**
     * @dev Withdraw Winnings function. User calls this function in order to withdraw
     *      whatever winnings they are owed. Function can be paused via the modifier
     *      function "onlyIfNotPaused"
     *
     * @param _week        Week number of the raffle the winning entry is from
     * @param _entryNum    The entrants entry number into this raffle
     */
    function withdrawWinnings(uint _week, uint _entryNum, uint[] _cNums) onlyIfNotPaused external {
        require (validEntry(_week, _entryNum, _cNums, msg.sender) && openForWithdraw(_week));
        uint matches = getMatches(_cNums, raffle[_week].winNums);
        if (matches == 2) return winFreeGo(_week, _entryNum);
        require (eligibleForWithdraw(_week, matches));
        invalidateEntry(_week, msg.sender, _entryNum);
        subtractFromUnclaimed(_week, matches);
        msg.sender.transfer(raffle[_week].winAmts[matches - 3]);
        emit LogWithdraw(_week, msg.sender, _entryNum, matches, raffle[_week].winAmts[matches - 3], now);
    }

    function subtractFromUnclaimed(uint _week, uint _matches) private {
        require (raffle[_week].winAmts[_matches - 3] <= raffle[_week].unclaimed, 'Prize > Unclaimed!');
        raffle[_week].unclaimed -= raffle[_week].winAmts[_matches - 3];
    }

    function eligibleForWithdraw(uint _week, uint _matches) internal view returns (bool) {
        return (
            _matches >= 3 &&
            raffle[_week].winAmts[_matches - 3] > 0 &&
            raffle[_week].winAmts[_matches - 3] <= this.balance &&
        );
    }

    // will be 0 after a correct withdraw therefore won't pass validity checks plus if empty array is sent, 
    function validEntry(uint _week, uint _entryNum, uint[] _cNums, address _entrant) view internal returns (bool) {
        return raffle[_week].entries[_entrant][_entryNum - 1] == keccak256(_cNums);
    }

    function invalidateEntry(uint _week, address _entrant, uint _entryNum) private {
        raffle[_week].entries[_entrant][_entryNum - 1] = 0;
    }

    function openForWithdraw(uint _week) view internal returns (bool) {
        return (
            raffle[_week].timeStamp > 0 &&
            raffle[_week].winNums.length > 0 &&
            now - raffle[_week].timeStamp > WEEKDUR - (WEEKDUR / 7) &&
            now - raffle[_week].timeStamp < wdrawBfr &&
            raffle[_week].wdrawOpen == true &&
        );
    }
    /**
     * @dev   Function compares array of entrant's 6 chosen numbers to
     *        the raffle in question's winning numbers and returns the 
     *        number of matches.
     *
     * @param _cNums      Array of entrant's chosen numbers 
     *
     * @param _wNums      Array of winning numbers
     *
     */
    function getMatches(uint[] _cNums, uint[] _wNums) pure internal returns (uint) {
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
 }

