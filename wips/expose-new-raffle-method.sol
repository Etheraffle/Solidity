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
        } else { // ∴ new raffle...
            setWeek(newWeek);
            setupRaffleStruct(newWeek, tktPrice, BIRTHDAY + (_week * WEEKDUR));
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
     * @param _timeStamp    Timestamp of Mon 00:00 of the week of this raffle
     *
	 */
   	function setupRaffleStruct(uint _week, uint _tktPrice, uint _timeStamp) internal {
        raffle[_week].tktPrice = _tktPrice
        raffle[_week].timeStamp = _timeStamp;
   	}

    function manuallySetWithdraw(uint _week, bool _status) onlyEtheraffle external {
        setWithdraw(_week, _status);
    }

    function setWithdraw(uint _week, bool _status) internal {
        raffle[_week].wdrawOpen = _status;
    }

    function setWeek(uint _week) internal {
        week = _week;
    }

    function manuallySetWeek(uint _week) onlyEtheraffle external {
        setWeek(_week);
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

// mapping (uint => rafStruct) public raffle;
// struct rafStruct {
//     mapping (address => uint[][]) entries;
//     uint unclaimed;
//     uint[] winNums;
//     uint[] winAmts;
//     uint timeStamp;
//     bool wdrawOpen;
//     uint numEntries;
//     uint freeEntries;
// }