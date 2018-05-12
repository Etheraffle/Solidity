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
        bytes32 query = oraclize_query(delay, "nested", str, gasAmt);
        qID[query].weekNo = getWeek();
        qID[query].isRandom = _isRandom;
        emit LogQuerySent(query, delay, now);
    }
}