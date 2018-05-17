contract NewConstructor {
    /**
     * @dev   Constructor - sets the Etheraffle contract address &
     *        the disbursal contract address for investors, calls
     *        the newRaffle() function with sets the current
     *        raffle ID global var plus sets up the first raffle's
     *        struct with correct time stamp. Sets the withdraw
     *        before time to a ten week period, and prepares the
     *        initial oraclize call which will begin the recursive
     *        function.
     *
     * @param _freeLOT    The address of the Etheraffle FreeLOT special token.
     * @param _dsbrs      The address of the Etheraffle disbursal contract.
     * @param _msig       The address of the Etheraffle managerial multisig wallet.
     * @param _ethRelief  The address of the EthRelief charity contract.
     */
}


// function Etheraffle(address _freeLOT, address _dsbrs, address _msig, address _ethRelief) payable {
//     week         = getWeek();
//     etheraffle   = _msig;
//     disburseAddr = _dsbrs;
//     ethRelief    = _ethRelief;
//     freeLOT      = FreeLOTInterface(_freeLOT);
//     uint delay   = (week * WEEKDUR) + BIRTHDAY + rafEnd + resultsDelay;
//     raffle[week].timeStamp = (week * WEEKDUR) + BIRTHDAY;
//     bytes32 query = oraclize_query(delay, "nested", strConcat(randomStr1, uint2str(getWeek()), randomStr2), gasAmt);
//     qID[query].weekNo = week;
//     qID[query].isRandom = true;
//     emit LogQuerySent(query, delay, now);
// }