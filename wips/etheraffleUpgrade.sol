/*
    Put in odds as readable vars - DONE
    new calc function - DONE
    all manual oracle calls to unpause contract too - DONE
    2 match win = free token?
*/

pragma solidity^0.4.21;

contract newPayoutsWIP {

    uint[] public odds = [56,1032,54200,13983816]; // Rounded down to nearest dp
    
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


