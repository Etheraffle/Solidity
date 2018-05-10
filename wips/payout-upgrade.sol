pragma solidity^0.4.23;
/**
 * New version of payouts must reflect the ticket price minus the take. 
 * Changes will only affect the odds single calcs since splits singles will only take affect
 * when splits singles become SMALLER than odds singles.
 *
 * Make these functions pure? Pass in ALL args? Can the arrays be made CONSTANT?
 */
contract PayoutUpgrade {

	uint[] public constant PCTOFPOOL = [520, 114, 47, 319]; // ppt...
	uint[] public constant ODDS      = [56, 1032, 54200, 13983816]; // Rounded down to nearest whole 
	uint   public          take      = 150; // ppt
    // /*  
    //  * @dev     Returns TOTAL payout per tier when calculated using the odds method.
    //  *
    //  * @param _numWinners       Number of X match winners
    //  * @param _matchesIndex     Index of matches array (∴ 3 match win, 4 match win etc)
    //  */
    // function oddsTotal(uint _numWinners, uint _matchesIndex) internal view returns (uint) {
    //     return oddsSingle(_matchesIndex) * _numWinners;
    // }
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
    function oddsSingle(uint _matchesIndex) internal view returns (uint) {
        return (tktPrice * odds[_matchesIndex] * (1000 - take)) / 1000;
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
}