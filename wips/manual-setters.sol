/**
     * @dev    Set the Oraclize strings, in case of url changes. Only callable by
     *         the Etheraffle address  .
     *
     * @param _newRandomHalfOne       string - with properly escaped characters for
     *                                the first half of the random.org call string.
     * @param _newRandomHalfTwo       string - with properly escaped characters for
     *                                the second half of the random.org call string.
     * @param _newEtheraffleHalfOne   string - with properly escaped characters for
     *                                the first half of the EtheraffleAPI call string.
     * @param _newEtheraffleHalfTwo   string - with properly escaped characters for
     *                                the second half of the EtheraffleAPI call string.
     *
     */
    function setOraclizeString
    (
        string _newRandomHalfOne,
        string _newRandomHalfTwo,
        string _newEtheraffleHalfOne,
        string _newEtheraffleHalfTwo
    )
        onlyEtheraffle external
    {
        randomStr1 = _newRandomHalfOne;
        randomStr2 = _newRandomHalfTwo;
        apiStr1    = _newEtheraffleHalfOne;
        apiStr2    = _newEtheraffleHalfTwo;
    }
    /**
     * @dev   Set the ticket price of the raffle. Only callable by the
     *        Etheraffle address.
     *
     * @param _newPrice   uint - The desired new ticket price.
     *
     */
    function setTktPrice(uint _newPrice) onlyEtheraffle external {
        tktPrice = _newPrice;
    }
    /**
     * @dev    Set new take percentage. Only callable by the Etheraffle
     *         address.
     *
     * @param _newTake   uint - The desired new take, parts per thousand.
     *
     */
    function setTake(uint _newTake) onlyEtheraffle external {
        take = _newTake;
    }
    /**
     * @dev     Set the payouts manually, in case of a failed Oraclize call.
     *          Only callable by the Etheraffle address.
     *
     * @param _week         The week number of the raffle to set the payouts for.
     * @param _numMatches   Number of matches. Comma-separated STRING of 4
     *                      integers long, consisting of the number of 3 match
     *                      winners, 4 match winners, 5 & 6 match winners in
     *                      that order.
     */
    function setPayouts(uint _week, string _numMatches) onlyEtheraffle external {
        setPayOuts(_week, _numMatches);
    }
    /**
     * @dev   Set the FreeLOT token contract address, in case of future updrades.
     *        Only allable by the Etheraffle address.
     *
     * @param _newAddr   New address of FreeLOT contract.
     */
    function setFreeLOT(address _newAddr) onlyEtheraffle external {
        freeLOT = FreeLOTInterface(_newAddr);
      }
    /**
     * @dev   Set the EthRelief contract address, and gas required to run
     *        the receiving function. Only allable by the Etheraffle address.
     *
     * @param _newAddr   New address of the EthRelief contract.
     */
    function setEthRelief(address _newAddr) onlyEtheraffle external {
        ethRelief = _newAddr;
    }
    /**
     * @dev   Set the dividend contract address, and gas required to run
     *        the receive ether function. Only callable by the Etheraffle
     *        address.
     *
     * @param _newAddr   New address of dividend contract.
     */
    function setDisbursingAddr(address _newAddr) onlyEtheraffle external {
        disburseAddr = _newAddr;
    }
    /**
     * @dev   Set the Etheraffle multisig contract address, in case of future
     *        upgrades. Only callable by the current Etheraffle address.
     *
     * @param _newAddr   New address of Etheraffle multisig contract.
     */
    function setEtheraffle(address _newAddr) onlyEtheraffle external {
        etheraffle = _newAddr;
    }
    /**
     * @dev     Set the raffle end time, in number of seconds passed
     *          the start time of 00:00am Monday. Only callable by
     *          the Etheraffle address.
     *
     * @param _newTime    The time desired in seconds.
     */
    function setRafEnd(uint _newTime) onlyEtheraffle external {
        rafEnd = _newTime;
    }
    /**
     * @dev     Set the wdrawBfr time - the time a winner has to withdraw
     *          their winnings before the unclaimed prizepool is rolled
     *          back into the global prizepool. Only callable by the
     *          Etheraffle address.
     *
     * @param _newTime    The time desired in seconds.
     */
    function setWithdrawBeforeTime(uint _newTime) onlyEtheraffle external {
        wdrawBfr = _newTime;
    }
    /**
     * @dev     Set the paused status of the raffles. Only callable by
     *          the Etheraffle address.
     *
     * @param _status    The desired status of the raffles.
     */
    function setPaused(bool _status) onlyEtheraffle external {
        paused = _status;
    }
    /**
     * @dev     Set the percentage-of-prizepool array. Only callable by the
     *          Etheraffle address.
     *
     * @param _newPoP     An array of four integers totalling 1000.
     */
    function setPercentOfPool(uint[] _newPoP) onlyEtheraffle external {
        pctOfPool = _newPoP;
    }