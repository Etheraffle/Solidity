/**
 * TODO: Test the new methods work!
 *
 */

contract OraclizeUpdate {
    /**
     *         #########################################
     *         ##         Oraclize Functions          ##
     *         #########################################
     */
    
    uint    public gasAmt = 500000;
    uint    public gasPrc = 20000000000; // 20 gwei

    mapping (bytes32 => qIDStruct) public qID;

    struct qIDStruct {
        uint weekNo;
        bool isRandom;
        bool isManual;
    }

    string randomStr1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\", \"serialNumber\"]','\\n{\"jsonrpc\": \"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\"";
    string randomStr2 = "\",\"params\":{\"n\":\"6\",\"min\":1,\"max\":49,\"replacement\":false,\"base\":10,\"apiKey\":${[decrypt] BKM3j7tH7qBIQKuadP5kJ547Au1uB1Zo41u6tCfLPT3GDGJJCEpXLS87u1xlYsFu/i21zycQJgVFWzev+ZSjflQKsOCFbdN5oUSiR/GvD5nuLblzG6H+xq2lVdZ0lN/EZjrCmgMfaF0r3uo/FKcRdAnbf2wxKQ5Vfg==}}']";
    string apiStr1    = "[URL] ['json(https://etheraffle.com/api/a).m','{\"r\":\"";
    string apiStr2    = "\",\"k\":${[decrypt] BGQljYtTQ+yq9TZztMcWycMiaAezwNm3ppmcBvdh37ZJVJiTFbQw+h+WycbJtaklSFe2+S228NTf9eOh+6y06dlVpbJ3S28JhDOg50j4wqAIXdtCWDZLkAgyjXI3pOa3SJY3RV2b}}']";

    event LogQuerySent(bytes32 queryID, uint dueAt, uint sendTime);
    event LogOraclizeCallback(address functionCaller, bytes32 queryID, string result, uint indexed forRaffle, uint atTime);

    /**
     * @dev     Modifier to prepend to functions adding the additional
     *          conditional requiring caller of the method to be either
     *          the Oraclize or Etheraffle address.
     *
     */
    modifier onlyOraclize() {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
        _;
    }
    /**
     * @dev     The Oralize call back function. Only callable by Etheraffle 
     *          or the Oraclize address. Emits an event detailing the callback, 
     *          before running the relevant method that acts on the callback.
     * 
     * @param   _myID    Unique id oraclize provides with their callbacks.
     *                            
     * @param   _result  The result of the api call.
     *
     */
    function __callback(bytes32 _myID, string _result) onlyIfNotPaused onlyOraclize {
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        qID[_myID].isRandom 
            ? randomCallback(_myID, _result) 
            : apiCallback(_myID, _result);
    }
    /**
     * @dev     Called when a random.org api callback comes in. It first 
     *          reclaims unclaimed prizes from the raffle ten weeks previous,
     *          disburses this week's raffle's profits, sets the winning 
     *          numbers from the callback in this raffle's struct and finally 
     *          prepares the next Oraclize query to call the Etheraffle API.
     *          Function requires the winning numbers to not already have been
     *          set which stops Oraclize replays causing havoc!
     *
     * @param   _myID       The hash of the Oraclize query
     *
     * @param   _result     The result of the Oraclize query
     *
     */
    function randomCallback(bytes32 _myID, string _result) onlyOraclize {
        require(!winNumbersSet(qID[_myID].weekNo));
        reclaimUnclaimed();
        disburseFunds(qID[_myID].weekNo);
        setWinningNumbers(qID[_myID].weekNo, _result);
        if (queryIsManual(_myID)) return;
        sendQuery(matchesDelay, getQueryString(false, qID[_myID].weekNo), qID[_myID].weekNo, false, false);
    }
    /**
     * @dev     Checks if an Oraclize query was made manually or not.
     *
     * @param   _ID     Bytes32 hash identifying the query in question.
     *
     */
    function queryIsManual(bytes32 _ID) internal view returns (bool) {
        return qID[_ID].isManual;
    }
    /**
     * @dev     Returns bool depending on whether the winning numbers
     *          have been set in the struct or not.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function winNumbersSet(uint _week) internal view returns (bool) {
        return raffle[_week].winNums.length > 0;
    }
    /**
     * @dev     Called when the Etheraffle API callback is received. It sets 
     *          up the next raffle's struct, calculates this raffle's payouts 
     *          then makes the next Oraclize query to call the Random.org api.
     *          Function requires the winning amounts to not already have been
     *          set which stops Oraclize replays causing havoc!
     *
     * @param   _myID       The hash of the Oraclize query
     *
     * @param   _result     The result of the Oraclize query
     *
     */
    function apiCallback(bytes32 _myID, string _result) onlyOraclize {
        require (!winAmountsSet(qID[_myID].weekNo));
        newRaffle();
        setPayOuts(qID[_myID].weekNo, _result);
        if (queryIsManual(_myID)) return;
        sendQuery(getNextDeadline(), getQueryString(true, getWeek()), getWeek(), true, false);
    }
    /**
     * @dev     Returns bool depending on whether the win amounts have 
     *          been set in the struct or not.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function winAmountsSet(uint _week) internal returns (bool) {
        return raffle[_week].winAmts.length > 0;
    }
    /**
     * @dev     Returns the number of seconds until the next occurring 
     *          raffle deadline.
     *
     */
    function getNextDeadline() internal view returns (uint) {
        return (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
    }
    /**
     * @dev     Prepares the correct Oraclize query string using Oraclize's 
     *          contract's string concat function.
     *
     * @param   _isRandom   Whether the query is to the Random.org api, or Etheraffle's.
     *
     * @param   _weekNo     Raffle number the call is being made on behalf of.
     *
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
     * @param   _delay      Desired return time for query from sending.
     *
     * @param   _str        The Oraclize call string.
     *
     * @param   _weekNo     Week number for raffle in question.
     *
     * @param   _isRandom   Whether the call is destined for Random.org 
     *                      or Etheraffle.
     *
     * @param   _isManual   Whether the call is being made manually or 
     *                      recursively.
     *
     */
    function sendQuery(uint _delay, string _str, uint _weekNo, bool _isRandom, bool _isManual) onlyOraclize {
        bytes32 query = oraclize_query(_delay, "nested", _str, gasAmt);
        modifyQIDStruct(query, _weekNo, _isRandom, _isManual);
        emit LogQuerySent(query, delay, now);
    }
    /**
     * @dev     Manually make an Oraclize API call, incase of automation
     *          failure. Only callable by the Etheraffle address.
     *
     * @param   _delay      Either a time in seconds before desired callback
     *                      time for the API call, or a future UTC format time
     *                      for the desired time for the API callback.
     *
     * @param   _week       The week number this query is for.
     *
     * @param   _isRandom   Whether or not the api call being made is for
     *                      the random.org results draw, or for the 
     *                      Etheraffle API results call.
     *
     * @param   _isManual   The Oraclize call back is a recursive function in
     *                      which each call fires off another call in perpetuity.
     *                      This bool allows that recursiveness for this call to
     *                      be turned on or off depending on caller's requirements.
     *
     * @param   _status     The desired paused status of the contract.
     *
     */
    function manuallyMakeOraclizeCall(uint _week, uint _delay, bool _isRandom, bool _isManual, bool _status) onlyEtheraffle external {
        pauseContract(_status);
        sendQuery(_delay, getQueryString(_isRandom, _week), _week, _isRandom, _isManual);
    }
    /**
     * @dev     Manually edit (or make!) a query ID struct, that Oraclize callbacks 
     *          can reference.
     *
     * @param   _ID         Desired keccak hash key for the struct
     *
     * @param   _weekNo     Desired week/raffle number the struct refers to. 
     *
     * @param   _isRandom   Whether or not the api call being made is for
     *                      the random.org results draw, or for the Etheraffle
     *                      API results call.
     *
     * @param   _isManual   The Oraclize call back is a recursive function in
     *                      which each call fires off another call in perpetuity.
     *                      This bool allows that recursiveness for this call to be
     *                      turned on or off depending on caller's requirements.
     *
     */
    function manuallyModifyQID(bytes32 _ID, uint _weekNo, bool _isRandom, bool _isManual) onlyEtheraffle external {
        modifyQIDStruct(_ID, _weekNo, _isRandom, _isManual);
    }
    /**
     * @dev     Modifies a query ID struct with the passed in information. 
     *          (Or creates it if struct doesn't exist yet...)
     *
     * @param   _ID         Bytes32 hash identifier for the struct.
     *
     * @param   _weekNo     Week number relevant to struct.
     *
     * @param   _isRandom   Whether the struct refers to a Random.org api call.
     *
     * @param   _isManual   Whether the struct was manually created or not.
     *                      If manual, the Oraclize callback returns before the 
     *                      next recursive Oraclize query is sent.
     *
     */
    function modifyQIDStruct(bytes32 _ID, uint _weekNo, bool _isRandom, bool _isManual) internal {
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