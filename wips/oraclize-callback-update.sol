/**
 * Need to account for the edge case scenarios of a replay. Check for the struct already
 * being in place and revert should that be the case
 *
 * NB: Will the MANUAL oraclize queries still work? Can they in fact use the new createQuery func?
 *
 * TODO: Update the manuallyMakeOraclize() method use the new createQuery thingy here.
 */

contract OraclizeUpdate {

    function __callback(bytes32 _myID, string _result) onlyIfNotPaused {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        qID[_myID].isRandom ? randomCallback(_myID, _result) : apiCallback(_myId, _result);
    }

    function randomCallback(bytes32 _myID, string _result) internal {
        reclaimUnclaimed();
        disburseFunds(qID[_myID].weekNo);
        setWinningNumbers(qID[_myID].weekNo, _result);
        if (qID[_myID].isManual) return;
        createQuery(true, _myID);
    }

    function apiCallback(bytes32 _myID, string _result) internal {
        newRaffle();
        setPayOuts(qID[_myID].weekNo, _result);
        if (qID[_myID].isManual) return;
        createQuery(false, _myID);
    }

    function createQuery(bool _isRandom, bytes32 _myID) internal {
        uint delay = _isRandom 
                   ? matchesDelay 
                   : (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
        string memory str = _isRandom 
                   ? strConcat(apiStr1, uint2str(qID[_myID].weekNo), apiStr2)
                   : strConcat(randomStr1, uint2str(getWeek()), randomStr2);
        uint weekNo = _isRandom ? qID[_myID].weekNo : getWeek();
        sendQuery(delay, str, weekNo, !_isRandom, false); // invert the random boolean!
        // bytes32 query = oraclize_query(delay, "nested", str, gasAmt);
        // qID[query].weekNo = _isRandom ? qID[_myID].weekNo : getWeek();
        // qID[query].isRandom = !_isRandom; // Invert the boolean 
        // emit LogQuerySent(query, delay, now);
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




    // Refactor to use new createQuery thingy (in which the new check for duplicates will take place!)
    // Need to pass in isManual bool to createQuery()
    // Need to pass in weekNo as well
    // basically should make it as close to a pure function as possible...

    // function manuallyMakeOraclizeCall
    // (
    //     uint _week,
    //     uint _delay,
    //     bool _isRandom,
    //     bool _isManual,
    //     bool _status
    // )
    //     onlyEtheraffle external
    // {
    //     paused = _status;
    //     string memory weekNumStr = uint2str(_week);
    //     if (_isRandom == true){
    //         bytes32 query = oraclize_query(_delay, "nested", strConcat(randomStr1, weekNumStr, randomStr2), gasAmt);
    //         qID[query].weekNo   = _week;
    //         qID[query].isRandom = true;
    //         qID[query].isManual = _isManual;
    //     } else {
    //         query = oraclize_query(_delay, "nested", strConcat(apiStr1, weekNumStr, apiStr2), gasAmt);
    //         qID[query].weekNo   = _week;
    //         qID[query].isManual = _isManual;
    //     }
    // }

}