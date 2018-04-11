/*
    all manual oracle calls to unpause contract too - DONE - ADDED
    REMOVE THE SET GAS PRICE THINGY - DONE - ADDED(removed :P)
    add mint interface - DONE - ADDED
    change encryption - DONE - ADDED
    2 match win = free token? - DONE - ADDED
    Put in odds as readable vars - DONE - ADDED
    capitalise constants - DONE - ADDED
    Enter on behalf of - DONE - ADDED
    Make callback function callable by Etheraffle too? - DONE - ADDED

    new calc function - DONE
    bump comiler number
    Split out into separate contracts eventually?
    Break up the oracle call back function more?

*/

pragma solidity^0.4.21;

contract newPayoutsWIP {

    uint[] public odds = [56,1032,54200,13983816]; // Rounded down to nearest whole number
    
    //pay @ odds ONLY IF odds total < splits total!
    /*
     * @dev     Returns TOTAL payout when calculated using the odds method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function oddsTotal(uint _numWinners, uint _matchesIndex) internal pure returns (uint) {
        return oddsSingle(_matchesIndex) * _numWinners';
    }
    /*
     * @dev     Returns TOTAL payout when calculated using the splits method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function splitsTotal(uint _numWinners, uint _matchesIndex) internal pure returns (uint) {
        return splitsSingle(uint _numWinners, uint _matchesIndex) * _numWinners';
    }
    /*
     * @dev     Returns single payout when calculated using the odds method.
     *
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function oddsSingle(uint _matchesIndex) internal pure returns (uint) {
        return tktPrice * odds[_matchesIndex]
    }
    /*
     * @dev     Returns a single payout when calculated using the splits method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function splitsSingle(uint _numWinners uint _matchesIndex) internal pure returns (uint) {
        return (prizePool * pctOfPool[_matchesIndex]) / (_numWinners * 1000)
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
        if (numWinnersStr.length < 4) {
          pauseContract(2);
          return;
        }
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
        if (raffle[_week].unclaimed > prizePool) {
          pauseContract(3);
          return;
        }
        prizePool -= raffle[_week].unclaimed;
        for (i = 0; i < payOuts.length; i++) {
            raffle[_week].winAmts.push(payOuts[i]);
        }
        raffle[_week].wdrawOpen = true;
        LogPrizePoolsUpdated(prizePool, _week, raffle[_week].unclaimed, payOuts[0], payOuts[1], payOuts[2], payOuts[3], now);
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
     * @param _status     Toggle the pause status of the contract.
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
}

contract FreeLOTInterface {
    function balanceOf(address who) constant public returns (uint) {}
    function destroy(address _from, uint _amt) external {}
    function mint(address _to, uint _amt) external {}
}

contract possibleTwoMatchWinImplementation {

    /**
     * @dev Withdraw Winnings function. User calls this function in order to withdraw
     *      whatever winnings they are owed. Function can be paused via the modifier
     *      function "onlyIfNotPaused"
     *
     * @param _week        Week number of the raffle the winning entry is from
     * @param _entryNum    The entrants entry number into this raffle
     */
    function withdrawWinnings(uint _week, uint _entryNum) onlyIfNotPaused external {
        require
        (
            raffle[_week].timeStamp > 0 &&
            now - raffle[_week].timeStamp > weekDur - (weekDur / 7) &&
            now - raffle[_week].timeStamp < wdrawBfr &&
            raffle[_week].wdrawOpen == true &&
            raffle[_week].entries[msg.sender][_entryNum - 1].length == 6
        );
        uint matches = getMatches(_week, msg.sender, _entryNum);
        if (matches == 2) return winFreeGo(_week, _entryNum);
        require
        (
            matches >= 3 &&
            raffle[_week].winAmts[matches - 3] > 0 &&
            raffle[_week].winAmts[matches - 3] <= this.balance
        );
        raffle[_week].entries[msg.sender][_entryNum - 1].push(0);
        if (raffle[_week].winAmts[matches - 3] <= raffle[_week].unclaimed) {
            raffle[_week].unclaimed -= raffle[_week].winAmts[matches - 3];
        } else {
            raffle[_week].unclaimed = 0;
            pauseContract(5);
        }
        msg.sender.transfer(raffle[_week].winAmts[matches - 3]);
        LogWithdraw(_week, msg.sender, _entryNum, matches, raffle[_week].winAmts[matches - 3], now);
    }

    event LogFreeLOTWin(uint raffleID, address whom, uint entryNum, uint amount, uint atTime);

    function winFreeGo(uint _week, uint _entryNum) onlyIfNotPaused external {
        raffle[_week].entries[msg.sender][_entryNum - 1].push(0);// Can't withdraw twice
        FreeLOT.mint(msg.sender, 1);
        emit LogFreeLOTWin(_week, msg.sender, _entryNum, 1, now);
    }
}


contract enterOnBehalfOf {
    /**
     * @dev  Function to enter the raffle on behalf of another address. Requires the 
     *       caller to send ether of amount greater than or equal to the ticket price.
     *       In the event of a win, only the onBehalfOf address can claim it.
     *
     * @param _cNums    Ordered array of entrant's six selected numbers.
     * @param _affID    Affiliate ID of the source of this entry.
     */
    function enterOnBehalfOf(uint[] _cNums, uint _affID, address _onBehalfOf) payable external onlyIfNotPaused {
        require(msg.value >= tktPrice);
        buyTicket(_cNums, _onBehalfOf, msg.value, _affID);
    }
}


