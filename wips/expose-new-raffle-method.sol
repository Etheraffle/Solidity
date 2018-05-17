/**
 * Need to make a newRaffle() method & have it only callable by Etheraffle. Make sure this will allow
 * manual creation of the raffle struct ready for the first oraclize call that'll be set off.
 */
 contract ExposeNewRaffle {
    /**
     * @dev   Function which gets current week number and if different
     *        from the global var week number, it updates that and sets
     *        up the new raffle struct. Should only be called once a
     *        week after the raffle is closed. Should it get called
     *        sooner, the contract is paused for inspection.
     */
    function newRaffle() internal {
        uint newWeek = getWeek();
        if (newWeek == week) {
            pauseContract(4);
            return;
        } else { // ∴ new raffle...
            week = newWeek;
            raffle[newWeek].tktPrice = tktPrice;
            raffle[newWeek].timeStamp = BIRTHDAY + (newWeek * WEEKDUR);
        }
    }
	/**
	 * @dev		Allows manual creation of a new raffle struct, plus can
	 * 			  toggle paused status of contract if needs be. Can only 
	 *			  be called by the Etheraffle address.
	 *
	 * @param _week		    Desired week number for new raffle struct.
     *
	 * @param _paused	    Desired pause status of contract.
     *
     * @param _tktPrice     Desired ticket price for the raffle
     *
	 */
   	function manuallyMakeNewRaffle(uint _week, bool _paused, uint _tktPrice) onlyEtheraffle external {
        week = _week;
        if (paused != _paused) paused = _paused;
        tktPrice != _tktPrice ? raffle[tktPrice].tktPrice = _tktPrice : raffle[tktPrice].tktPrice = tktPrice;
        raffle[_week].tktPrice = _tktPrice
        raffle[_week].timeStamp = BIRTHDAY + (_week * WEEKDUR);
   	}
}

//  /**
//  * @dev   Function which gets current week number and if different
//  *        from the global var week number, it updates that and sets
//  *        up the new raffle struct. Should only be called once a
//  *        week after the raffle is closed. Should it get called
//  *        sooner, the contract is paused for inspection.
//  */
// function newRaffle() internal {
//     uint newWeek = getWeek();
//     if (newWeek == week) {
//         pauseContract(4);
//         return;
//     } else {//∴ new raffle...
//         week = newWeek;
//         raffle[newWeek].timeStamp = BIRTHDAY + (newWeek * WEEKDUR);
//     }
// }