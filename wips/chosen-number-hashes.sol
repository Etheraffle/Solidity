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
            ? winFreeGo(_week, _entryNum) 
            : payWinnings(_week, _entryNum, matches, msg.sender);
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
    function payWinnings(uint _week, uint _entryNum, , uint _matches, address _entrant) internal {
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
 }

