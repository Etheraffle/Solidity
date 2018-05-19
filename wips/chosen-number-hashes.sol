 //TODO: Make the back end event watchers will have to consume the new event!
 // Oops. Using hashes breaks the stop-withdraw-twice mechanism. We have no array to push zero onto! Can we rehash with a zero? Something like that?
 
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
    // NEW VERSION OF THIS FUNC EXISTS, DEFINITELY SETS TICKET PRICE SO DON'T WORRY
    // function newRaffle() internal {
    //     uint newWeek = getWeek();
    //     if (newWeek == week) {
    //         pauseContract(4);
    //     } else {//∴ new raffle...
    //         week = newWeek;
    //         raffle[newWeek].tktPrice = tktPrice;
    //         raffle[newWeek].timeStamp = BIRTHDAY + (newWeek * WEEKDUR);
    //     }
    // }
    /**
     * @dev  Function to enter the raffle. Requires the caller to send ether
     *       of amount greater than or equal to the current raffle's tkt price.
     *
     * @param _cNums    Ordered array of entrant's six selected numbers.
     *
     * @param _affID    Affiliate ID of the source of this entry.
     *
     */
    function enterRaffle(uint[] _cNums, uint _affID) payable external onlyIfNotPaused {
        require(raffle[week].tktPrice > 0 && msg.value >= raffle[week].tktPrice);
        buyTicket(_cNums, msg.sender, msg.value, _affID);
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
    function enterOnBehalfOf(uint[] _cNums, uint _affID, address _onBehalfOf) payable external onlyIfNotPaused {
        require(raffle[week].tktPrice > 0 && msg.value >= raffle[week].tktPrice);
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
    function enterFreeRaffle(uint[] _cNums, uint _affID) payable external onlyIfNotPaused {
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
    function buyTicket
    (
        uint[]  _cNums,
        address _entrant,
        uint    _value,
        uint    _affID
    )
        internal
    {
        require
        (
            _cNums.length == 6 &&
            raffle[week].timeStamp > 0 &&
            now < raffle[week].timeStamp + rafEnd &&
            0         < _cNums[0] &&
            _cNums[0] < _cNums[1] &&
            _cNums[1] < _cNums[2] &&
            _cNums[2] < _cNums[3] &&
            _cNums[3] < _cNums[4] &&
            _cNums[4] < _cNums[5] &&
            _cNums[5] <= 49
        );
        raffle[week].numEntries++;
        prizePool += _value;
        raffle[week].entries[_entrant].push(keccak256(_cNums);
        emit LogTicketBought(week, raffle[week].numEntries, _entrant, _cNums, raffle[week].entries[_entrant].length, _value, now, _affID);
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
        require
        (
            areChosenNumbers(_week, _entryNum, _cNums, msg.sender) &&
            raffle[_week].timeStamp > 0 &&
            now - raffle[_week].timeStamp > WEEKDUR - (WEEKDUR / 7) &&
            now - raffle[_week].timeStamp < wdrawBfr &&
            raffle[_week].wdrawOpen == true &&
            raffle[_week].entries[msg.sender][_entryNum - 1].length == 6 // TODO: This is the broken bit! Seperate require to test for hashed with zero? Then can pass string saying 'Already withdrawn' or something?
        );
        uint matches = getMatches(_week, msg.sender, _entryNum);
        if (matches == 2) return winFreeGo(_week, _entryNum);
        require
        (
            matches >= 3 &&
            raffle[_week].winAmts[matches - 3] > 0 &&
            raffle[_week].winAmts[matches - 3] <= this.balance
        );
        // Or even just reset it to zero? (does resetting an array element to zero cost cheap gas? TEST SAYS YES)
        raffle[_week].entries[msg.sender][_entryNum - 1].push(1); // TODO: overwrite the hash with same numbers and a zero?
        if (raffle[_week].winAmts[matches - 3] <= raffle[_week].unclaimed) {
            raffle[_week].unclaimed -= raffle[_week].winAmts[matches - 3];
        } else {
            raffle[_week].unclaimed = 0;
            pauseContract(5);
        }
        msg.sender.transfer(raffle[_week].winAmts[matches - 3]);
        emit LogWithdraw(_week, msg.sender, _entryNum, matches, raffle[_week].winAmts[matches - 3], now);
    }

    function areChosenNumbers(uint _week, uint _entryNum, uint[] _cNums, _entrant) view internal returns (bool) {
        return raffle[_week].entries[_entrant][_entryNum - 1] == keccak256(_cNums);
    }

    // If we zero the entry number in the entries array we know it's withdraw.
    // TODO: Make sure the getters for entries still work? Or make new one to check if wdrawn?
    // Make one to get entrant array.length so we can get the entries themselves. Any zeroes == withdrawn already.

    // function isAlreadyWithdrawn(uint _week, uint _entryNum, uint[] _cNums, _entrant) view internal returns (bool) {
    //     return raffle[_week].entries[_entrant][_entryNum - 1] == keccak256(_cNums, 0);
    // }
 }

     

