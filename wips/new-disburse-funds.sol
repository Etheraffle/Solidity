    /**
     * @dev     Calculates and accounts for a raffle's costs and profits, 
     *          before distributing the latter should there be any.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function performAccounting(uint _week) internal {
        uint cost = getOraclizeCost();
        accountForCosts(cost);
        uint profit = calcProfit(_week);
        accountForProfit(profit);
        distributeFunds(_week, cost, profit);
    }
    /**
     * @dev     Returns the cost of the Oraclize api calls
     *          (two per draw).
     *
     */
    function getOraclizeCost() internal view returns (uint) {
        return ((gasAmt * gasPrc) + oracCost) * 2;
    }
    /**
     * @dev     Subtracts a given cost from the prize pool. Pauses contract 
     *          instead if cost is greater than the prize pool.
     *
     * @param   _cost   Amount to be deducted from the prize pool.
     *
     */
    function accountForCosts(uint _cost) private {
        if (_cost > prizePool) return pauseContract(true, 1);
        if (cost == 0) return; // TODO: Unnecessary?
        modifyPrizePool(false, _cost);
    }
    /**
     * @dev     Calculates profits earnt from a raffle. If there are 
     *          no paid entries or if free entries outweigh paid 
     *          entries, returns 0.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function calcProfit(uint _week) internal view returns (uint) {
        return (raffle[_week].numEntries > 0 && 
                raffle[_week].numEntries > raffle[_week].freeEntries)
            ? ((raffle[_week].numEntries - raffle[_week].freeEntries) * tktPrice * take) / 1000
            : 0;
    }
    /**
     * @dev     Subtracts a given amount of profit from the prize pool, if 
     *          said amount is greater than zero.
     *
     * @param   _profit   Amount to be deducted from the prize pool.
     *
     */
    function accountForProfit(uint _profit) private {
        if (_profit == 0) return 
        modifyPrizePool(false, profit);
    }
    /**
     * @dev     Distributes any profit earnt from a raffle. Half goes to 
     *          the disbursal contract for the DAO of token holders, and 
     *          the remainder to the EthRelief contract for charitable 
     *          donations.
     *
     * @param   _week       Week number for raffle in question.
     *
     * @param   _cost       Cost of running this raffle.
     *
     * @param   _profit     Profit from running this raffle.
     *
     */
    function distributeFunds(uint _week, uint _cost, uint _profit) private {
        if (_profit == 0) return LogFundsDisbursed(_week, _cost, 0, 0, now); // Can't use emit keyword after return statement...
        uint half = _profit / 2;
        disburseFunds(_week, _cost, half, disburseAddr);
        disburseFunds(_week, _cost, _profit - half, ethRelief);
    }
    /**
     * @dev     Sends funds via a given contract's "receiver" interface,
     *          which ensures an event is fired in the receiving contract, 
     *          announcing the funds' arrival.
     *
     * @param   _addr   Address of receiving contract.
     *
     * @param   _amt    Amount of Wei to send.
     *
     */
    function disburseFunds(uint _week, uint _cost, uint _amt, address _addr) private {
        ReceiverInterface(_addr).receiveEther.value(_amt)();
        emit LogFundsDisbursed(_week, _cost, _amt, _addr, now);
    }