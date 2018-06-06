    /**
     * @dev     Function allowing manual addition to the global prizepool.
     *          Requires the caller to send ether, by which amount the 
     *          prize pool is increased.
     *
     */
    function manuallyAddToPrizePool() payable public {
        require (msg.value > 0);
        modifyPrizePool(true, msg.value);
        emit LogPrizePoolAddition(msg.sender, msg.value, now);
    }
    /**
     * @dev     Set the Oraclize strings, in case of url changes. Only callable by
     *          the Etheraffle address.
     *
     * @param   _randomStr1     String with properly escaped characters for 
     *                          first half of Random.org api call.
     *
     * @param   _randomStr2     String with properly escaped characters for 
     *                          second half of Random.org api call.
     *
     * @param   _apiStr1        String with properly escaped characters for 
     *                          first half of Etheraffle api call.
     *
     * @param   _apiStr2        String with properly escaped characters for 
     *                          second half of Etheraffle api call.
     *
     */
    function manuallySetOraclizeString(string _randomStr1, string _randomStr2, string _apiStr1, string _apiStr2) external onlyEtheraffle {
        randomStr1 = _randomStr1;
        randomStr2 = _randomStr2;
        apiStr1    = _apiStr1;
        apiStr2    = _apiStr2;
    }
    /**
     * @dev     Set the ticket price of the raffle. Only callable by the
     *          Etheraffle address.
     *
     * @param   _newPrice   The desired new ticket price.
     *
     */
    function manuallySetTktPrice(uint _newPrice) external onlyEtheraffle {
        tktPrice = _newPrice;
    }
    /**
     * @dev     Set new take percentage. Only callable by the Etheraffle
     *          address.
     *
     * @param   _newTake   The desired new take, parts per thousand.
     *
     */
    function manuallySetTake(uint _newTake) external onlyEtheraffle {
        take = _newTake;
    }
    /**
     * @dev     Set the payouts manually, in case of a failed Oraclize call.
     *          Only callable by the Etheraffle address.
     *
     * @param   _week           The week number of the raffle to set the payouts for.
     *
     * @param   _numMatches     Number of matches. Comma-separated STRING of 4
     *                          integers long, consisting of the number of 3 match
     *                          winners, 4 match winners, 5 & 6 match winners in
     *                          that order.
     *
     */
    function manuallySetPayouts(uint _week, string _numMatches) external onlyEtheraffle {
        setPayOuts(_week, _numMatches);
    }
    /**
     * @dev     Set the FreeLOT token contract address, in case of future updrades.
     *          Only allable by the Etheraffle address.
     *
     * @param   _newAddr   New address of FreeLOT contract.
     */
    function manuallySetFreeLOT(address _newAddr) external onlyEtheraffle {
        freeLOT = FreeLOTInterface(_newAddr);
      }
    /**
     * @dev     Set the EthRelief contract address, and gas required to run
     *          the receiving function. Only allable by the Etheraffle address.
     *
     * @param   _newAddr   New address of the EthRelief contract.
     */
    function manuallySetEthRelief(address _newAddr) external onlyEtheraffle {
        ethRelief = _newAddr;
    }
    /**
     * @dev     Set the dividend contract address, and gas required to run
     *          the receive ether function. Only callable by the Etheraffle
     *          address.
     *
     * @param   _newAddr   New address of dividend contract.
     */
    function manuallySetDisbursingAddr(address _newAddr) external onlyEtheraffle {
        disburseAddr = _newAddr;
    }
    /**
     * @dev     Set the Etheraffle multisig contract address, in case of future
     *          upgrades. Only callable by the current Etheraffle address.
     *
     * @param   _newAddr   New address of Etheraffle multisig contract.
     */
    function manuallySetEtheraffle(address _newAddr) external onlyEtheraffle {
        etheraffle = _newAddr;
    }
    /**
     * @dev     Set the raffle end time, in number of seconds passed
     *          the start time of 00:00am Monday. Only callable by
     *          the Etheraffle address.
     *
     * @param   _newTime    The time desired in seconds.
     */
    function manuallySetRafEnd(uint _newTime) external onlyEtheraffle {
        rafEnd = _newTime;
    }
    /**
     * @dev     Set the wdrawBfr time - the time a winner has to withdraw
     *          their winnings before the unclaimed prizepool is rolled
     *          back into the global prizepool. Only callable by the
     *          Etheraffle address.
     *
     * @param   _newTime    The time desired in seconds.
     */
    function manuallySetWithdrawBefore(uint _newTime) external onlyEtheraffle {
        wdrawBfr = _newTime;
    }
    /**
     * @dev     Set the paused status of the raffles. Only callable by
     *          the Etheraffle address.
     *
     * @param   _status    The desired status of the raffles.
     */
    function manuallySetPaused(bool _status) external onlyEtheraffle {
        pauseContract(_status);
    }
    /**
     * @dev     Set the percentage-of-prizepool array. Only callable by the
     *          Etheraffle address.
     *
     * @param   _newPoP     An array of four integers totalling 1000.
     */
    function manuallySetPercentOfPool(uint[] _newPoP) external onlyEtheraffle {
        pctOfPool = _newPoP;
    }
    /**
	 * @dev		Allows manual set up of a new raffle via creating a struct
     *          with the correct timestamp and ticket price. Only callable
     *          by the Etheraffle multisig address.
	 *
	 * @param   _week       Desired week number for new raffle struct.
     *
     * @param   _tktPrice   Desired ticket price for the raffle
     *
     * @param   _timeStamp  Timestamp of Mon 00:00 of the week of this raffle
     *
	 */
    function manuallySetupRaffleStruct(uint _week, uint _tktPrice, uint _timeStamp) external onlyEtheraffle {
        setUpRaffleStruct(_week, _tktPrice, _timeStamp);
    }
	/**
	 * @dev		Manually sets the withdraw status of a raffle. Only
     *          callable by the Etheraffle multisig.
	 *
	 * @param   _week   Week number for raffle in question.
     *
     * @param   _status Desired withdraw status for raffle.
     *
	 */
    function manuallySetWithdraw(uint _week, bool _status) external onlyEtheraffle {
        setWithdraw(_week, _status);
    }
    /**
	 * @dev		Manually sets the global week variable. Only callable
     *          by the Etheraffle multisig wallet.
	 *
	 * @param   _week   Desired week number.
     *
	 */
    function manuallySetWeek(uint _week) external onlyEtheraffle {
        setWeek(_week);
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