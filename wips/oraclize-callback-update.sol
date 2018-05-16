/**
 * TODO: Test the new methods work!
 * TODO: Need to account for the edge case scenarios of a replay. Check for the struct already
 * being in place and revert should that be the case? Would need a new param in struct...
 * Could save the last query somewhere and check for that?
 * TODO: Should put all ORACLIZE stuff in its own section really.
 *
 */

contract OraclizeUpdate {

    /**
    * @dev  Modifier to prepend to functions adding the additional
    *       conditional requiring caller of the method to be either
    *       the Oraclize or Etheraffle address.
    */
    modifier onlyOraclize() {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
        _;
    }
    /**
     * @dev   The Oralize call back function. Only callable by Etheraffle 
     *        or the Oraclize address. Emits an event detailing the callback, 
     *        before running the relevant method that acts on the callback.
     * 
     * @param _myID     bytes32 - Unique id oraclize provides with their
     *                            callbacks.
     * @param _result   string - The result of the api call.
     */
    function __callback(bytes32 _myID, string _result) onlyIfNotPaused onlyOraclize {
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        qID[_myID].isRandom ? randomCallback(_myID, _result) : apiCallback(_myID, _result);
    }
    /**
     * @dev     Called when a random.org api callback comes in. It first 
     *          reclaims unclaimed prizes from the raffle ten weeks previous,
     *          disburses this week's raffle's profits, sets the winning 
     *          numbers from the callback in this raffle's struct and finally 
     *          prepares the next Oraclize query to call the Etheraffle API.
     *
     * @param   _myID       The hash of the Oraclize query
     * @param   _result     The result of the Oraclize query
     */
    function randomCallback(bytes32 _myID, string _result) onlyOraclize {
        reclaimUnclaimed();
        disburseFunds(qID[_myID].weekNo);
        setWinningNumbers(qID[_myID].weekNo, _result);
        if (qID[_myID].isManual) return;
        sendQuery(matchesDelay, getQueryString(false, qID[_myID].weekNo), qID[_myID].weekNo, false, false);
    }
    /**
     * @dev     Called when the Etheraffle API callback is received. It sets 
     *          up the next raffle's struct, calculates this raffle's payouts 
     *          then makes the next Oraclize query to call the Random.org api.
     *
     * @param   _myID       The hash of the Oraclize query
     * @param   _result     The result of the Oraclize query
     */
    function apiCallback(bytes32 _myID, string _result) onlyOraclize {
        newRaffle();
        setPayOuts(qID[_myID].weekNo, _result);
        if (qID[_myID].isManual) return;
        uint delay = (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
        sendQuery(delay, getQueryString(true, getWeek()), getWeek(), true, false);
    }
    /**
     * @dev     Prepares the correct Oraclize query string using Oraclize's 
     *          contract's string concat function.
     *
     * @param   _isRandom   Whether the query is to the Random.org api, or Etheraffle's.
     * @param   _weekNo     Raffle number the call is being made on behalf of.
     */
    function getQueryString(bool _isRandom, uint _weekNo) onlyOraclize returns (string) {
        return _isRandom 
               ? strConcat(randomStr1, uint2str(_weekNo), randomStr2)
               : strConcat(apiStr1, uint2str(_weekNo), apiStr2);
    }
    /**
     * @dev     Sends an Oraclize query, stores info w/r/t that query in a
     *          struct mapped to by the hash of the query, and logs the 
     *          pertinent details.
     *
     * @param   _delay      Desired return time for query from sending (in seconds).
     * @param   _str        The Oraclize call string.
     * @param   _weekNo     Week number for raffle in question.
     * @param   _isRandom   Whether the call is destined for Random.org or Etheraffle.
     * @param   _isManual   Whether the call is being made manually or recursively.
     */
    function sendQuery(uint _delay, string _str, uint _weekNo, bool _isRandom, bool _isManual) onlyOraclize {
        bytes32 query = oraclize_query(_delay, "nested", _str, gasAmt);
        qID[query].weekNo   = _weekNo;
        qID[query].isRandom = _isRandom;
        qID[query].isManual = _isManual;
        emit LogQuerySent(query, delay, now);
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
     * @param _status     The desired paused status of the contract.
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
        sendQuery(_delay, getQueryString(_isRandom, _week), _week, _isRandom, _isManual);
    }
    /**
     * @dev     Manually edit (or make!) a query ID struct, that Oraclize callbacks 
     *          can reference.
     *
     * @param _ID         Desired keccak hash key for the struct
     *
     * @param _weekNo     Desired week/raffle number the struct refers to. 
     *
     * @param _isRandom   Whether or not the api call being made is for
     *                    the random.org results draw, or for the Etheraffle
     *                    API results call.
     *
     * @param _isManual   The Oraclize call back is a recursive function in
     *                    which each call fires off another call in perpetuity.
     *                    This bool allows that recursiveness for this call to be
     *                    turned on or off depending on caller's requirements.
     *
     */
    function manuallyEditQID
	(
		bytes32 _ID, 
		uint    _weekNo, 
		bool    _isRandom, 
		bool    _isManual
	) 
		onlyEtheraffle external 
	{
		qID[_ID].weekNo    = _weekNo;
        qID[_ID].isRandom  = _isRandom;
        qID[_ID].isManual  = _isManual;
    }
}
// Original Oraclize callback megafunction!
// function __callback(bytes32 _myID, string _result) onlyIfNotPaused {
//     require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
//     emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
//     if (qID[_myID].isRandom == true) {
//         reclaimUnclaimed();
//         disburseFunds(qID[_myID].weekNo);
//         setWinningNumbers(qID[_myID].weekNo, _result);
//         if (qID[_myID].isManual == true) return;
//         bytes32 query = oraclize_query(matchesDelay, "nested", strConcat(apiStr1, uint2str(qID[_myID].weekNo), apiStr2), gasAmt);
//         qID[query].weekNo = qID[_myID].weekNo;
//         emit LogQuerySent(query, matchesDelay + now, now);
//     } else { // isRandom == false
//         newRaffle();
//         setPayOuts(qID[_myID].weekNo, _result);
//         if (qID[_myID].isManual == true) return;
//         uint delay = (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
//         query = oraclize_query(delay, "nested", strConcat(randomStr1, uint2str(getWeek()), randomStr2), gasAmt);
//         qID[query].weekNo = getWeek();
//         qID[query].isRandom = true;
//         emit LogQuerySent(query, delay, now);
//     }
// }