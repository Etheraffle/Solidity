/*
 * Solidity test for Etheraffle payOuts mechanism upgrade.
 */
pragma solidity^0.4.21;

contract payOutUpgrade {

    uint public tktPrice = 3000000000000000;       // 0.003 ether
    uint public prizePool = 2000000000000000000;   // 2 ether
    uint[] public pctOfPool = [520, 114, 47, 319]; // ppt...
    uint[] public odds = [56,1032,54200,13983816]; // Actual odds rounded down to nearest dp
        
    event LogResults(uint pO0, uint pO1, uint pO2, uint pO3, uint totalPayouts);
    /*
     * @dev     Returns TOTAL payout when calculated using the odds method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function oddsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return oddsSingle(_matchesIndex) * _numWinners;
    }
    /*
     * @dev     Returns TOTAL payout when calculated using the splits method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function splitsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
        return splitsSingle(_numWinners, _matchesIndex) * _numWinners;
    }
    /*
     * @dev     Returns single payout when calculated using the odds method.
     *
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
     */
    function oddsSingle(uint _matchesIndex) internal view returns (uint) {
        return tktPrice * odds[_matchesIndex];
    }
    /*
     * @dev     Returns a single payout when calculated using the splits method.
     *
     * @param _numWinners       Number of X match winners
     * @param _matchesIndex     Number of matches - 3 used to traverse arrays
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
     */
    //pay @ odds ONLY IF odds total < splits total!
    function setPayouts(uint[] _numWinnersInt) public {
        require(_numWinnersInt.length == 4);
        uint[] memory payOuts = new uint[](4);
        uint total;
        for (uint i = 0; i < 4; i++) {
            if (_numWinnersInt[i] != 0) {
                uint amt = oddsTotal(_numWinnersInt[i], i) <= splitsTotal(_numWinnersInt[i], i) 
                         ? oddsSingle(i) 
                         : splitsSingle(_numWinnersInt[i], i); 
                payOuts[i] = amt;
                total += payOuts[i] * _numWinnersInt[i];
            }
        }
        emit LogResults(payOuts[0], payOuts[1], payOuts[2], payOuts[3], total);
    }
    // Should fire event showing payouts array: [168000000000000000, 0, 0, 0] & total: 168000000000000000
    // (∵ it's using the odds method)
    function test1() public {
        uint[] memory testArr1 = new uint[](4);
        testArr1[0] = 1;
        testArr1[1] = 0;
        testArr1[2] = 0;
        testArr1[3] = 0;
        setPayouts(testArr1);
    }
    // Should fire event showing payouts array: [10400000000000000, 0, 0, 0] & total: 1040000000000000000
    // (∵ it's using the split method)
    function test2() public {
        uint[] memory testArr2 = new uint[](4);
        testArr2[0] = 1000;
        testArr2[1] = 0;
        testArr2[2] = 0;
        testArr2[3] = 0;
        setPayouts(testArr2);
    }
}