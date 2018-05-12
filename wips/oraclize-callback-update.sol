/**
 * Need to account for the edge case scenarios of a replay. Check for the struct already
 * being in place and revert should that be so.
 *
 */

contract OraclizeUpdate {

     function __callback(bytes32 _myID, string _result) onlyIfNotPaused {
        require(msg.sender == oraclize_cbAddress() || msg.sender == etheraffle);
        emit LogOraclizeCallback(msg.sender, _myID, _result, qID[_myID].weekNo, now);
        if (qID[_myID].isRandom == true) {
            reclaimUnclaimed();
            disburseFunds(qID[_myID].weekNo);
            setWinningNumbers(qID[_myID].weekNo, _result);
            if (qID[_myID].isManual == true) return;
            bytes32 query = oraclize_query(matchesDelay, "nested", strConcat(apiStr1, uint2str(qID[_myID].weekNo), apiStr2), gasAmt);
            qID[query].weekNo = qID[_myID].weekNo;
            emit LogQuerySent(query, matchesDelay + now, now);
        } else {
            newRaffle();
            setPayOuts(qID[_myID].weekNo, _result);
            if (qID[_myID].isManual == true) return;
            uint delay = (getWeek() * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
            query = oraclize_query(delay, "nested", strConcat(randomStr1, uint2str(getWeek()), randomStr2), gasAmt);
            qID[query].weekNo = getWeek();
            qID[query].isRandom = true;
            emit LogQuerySent(query, delay, now);
        }
    }
}