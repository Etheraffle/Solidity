    function performAccounting(uint _week) internal {
        uint cost = getOraclizeCost();
        accountForCosts(cost);
        uint profit = calcProfit(_week);
        accountForProfit(profit);
        distributeFunds(_week, cost, profit);
    }

    function distributeFunds(uint _week, uint _cost, uint _profit) private {
        if (_profit == 0) return LogFundsDisbursed(_week, _cost, 0, 0, now); // Can't use emit keyword after return statement...
        uint half = _profit / 2;
        disburseFunds(_week, _cost, half, disburseAddr);
        disburseFunds(_week, _cost, _profit - half, ethRelief);
    }

    function accountForProfit(uint _profit) private {
        if (_profit == 0) return 
        modifyPrizePool(false, profit);
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
     * @dev     Returns the cost of the Oraclize api calls
     *          (two per draw).
     *
     */
    function getOraclizeCost() internal view returns (uint) {
        return ((gasAmt * gasPrc) + oracCost) * 2;
    }