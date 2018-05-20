pragma solidity^0.4.23;
/**
 * New version of payouts must reflect the ticket price minus the take. 
 * Changes will only affect the odds single calcs since splits singles will only take affect
 * when splits singles become SMALLER than odds singles.
 *
 * Make these functions pure? Pass in ALL args? Can the arrays be made CONSTANT? (Apparently not!)
 */
contract PayoutUpgrade {

    event LogPrizePoolsUpdated(uint newMainPrizePool, uint indexed forRaffle, uint ticketPrice, uint unclaimedPrizePool, uint threeMatchWinAmt, uint fourMatchWinAmt, uint fiveMatchWinAmt, uint sixMatchwinAmt, uint atTime);

    /*  
     * @dev     Returns TOTAL payout per tier when calculated using the odds method.
     *
     * @param _numWinners       Number of X match winners
     *
     * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
     *
     */
    function oddsTotal(uint _numWinners, uint _matchesIndex, uint _week) internal view returns (uint) {
        return oddsSingle(_matchesIndex, _week) * _numWinners;
    }
    // /*
    //  * @dev     Returns TOTAL payout per tier when calculated using the splits method.
    //  *
    //  * @param _numWinners       Number of X match winners
    //  * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
    //  */
    // function splitsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
    //     return splitsSingle(_numWinners, _matchesIndex) * _numWinners;
    // }
    /*
     * @dev     Returns single payout when calculated using the odds method.
     *
     * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
     */
    function oddsSingle(uint _matchesIndex, uint _week) internal view returns (uint) {
        return (raffle[_week].tktPrice * odds[_matchesIndex] * (1000 - take)) / 1000;
    }
    // /*
    //  * @dev     Returns a single payout when calculated using the splits method.
    //  *
    //  * @param _numWinners       Number of X match winners
    //  * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
    //  */
    // function splitsSingle(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
    //     return (prizePool * pctOfPool[_matchesIndex]) / (_numWinners * 1000);
    // }
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
                uint amt = oddsTotal(numWinnersInt[i], i, _week) <= splitsTotal(numWinnersInt[i], i) 
                         ? oddsSingle(i, _week) 
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
        setWithdraw(_week, true);
        emit LogPrizePoolsUpdated(prizePool, _week, raffle[_week].tktPrice, raffle[_week].unclaimed, payOuts[0], payOuts[1], payOuts[2], payOuts[3], now);
    }
}   