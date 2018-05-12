/**
 * Need to account for the edge case scenarios of a replay. Check for the struct already
 * being in place and revert should that be the case
 *
 * NB: Will the MANUAL oraclize queries still work? Can they in fact use the new createQuery func?
 *
 * TODO: Test the new methods work!
 */

contract OraclizeUpdate {

    function __callback(bytes32 _myID, string _result) onlyIfNotPaused {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        qID[_myID].isRandom ? randomCallback(_myID, _result) : apiCallback(_myID, _result);
    }

    function randomCallback(bytes32 _myID, string _result) internal {
        reclaimUnclaimed();
        disburseFunds(qID[_myID].weekNo);
        setWinningNumbers(qID[_myID].weekNo, _result);
        if (qID[_myID].isManual) return;
        sendQuery(matchesDelay, getQueryString(false, qID[_myID].weekNo), qID[_myID].weekNo, false, false);
    }

    function apiCallback(bytes32 _myID, string _result) internal {
        newRaffle();
        setPayOuts(qID[_myID].weekNo, _result);
        if (qID[_myID].isManual) return;
        uint delay = (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
        sendQuery(delay, getQueryString(true, getWeek()), getWeek(), true, false);
    }

    function getQueryString(bool _isRandom, uint _weekNo) internal returns (string) {
        return _isRandom 
               ? strConcat(randomStr1, uint2str(_weekNo), randomStr2)
               : strConcat(apiStr1, uint2str(_weekNo), apiStr2);
    }

    function sendQuery(uint _delay, string _str, uint _weekNo, bool _isRandom, bool _isManual) internal {
        bytes32 query = oraclize_query(_delay, "nested", _str, gasAmt);
        qID[query].weekNo   = _weekNo;
        qID[query].isRandom = _isRandom;
        qID[query].isManual = _isManual;
        emit LogQuerySent(query, delay, now);
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

}