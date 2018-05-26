    /**
     * @dev  Function totals up oraclize cost for the raffle, subtracts
     *       it from the prizepool (if less than, if greater than if
     *       pauses the contract and fires an event). Calculates profit
     *       based on raffle's tickets sales and the take percentage,
     *       then forwards that amount of ether to the disbursal contract.
     *
     * @param _week   The week number of the raffle in question.
     */

     //TODO: Rename this function? Or break it up and call more funcs in the api callback? Like, accountForOraclize(), accountForProfit() disburseFunds() - uses I dunno, a generic sender for the the two cases of EthRelief plus disbursal? Or call the big function bookKeeping() or something? performAccounting()???
    function performAccounting(uint _week) internal {
        uint cost = getOraclizeCost();
        accountForCosts(cost);
        uint profit = calcProfit(_week);
        accountForProfit(profit);
        distributeFunds(_week, cost, profit);


        // if (profit == 0) return logDisbursal(_week, cost, 0, 0, now); // Can't use emit keyword here

        //if zero, else disburse funds...
        // if (raffle[_week].numEntries > 0) {
        //     profit = calcProfit(_week);
        //     modifyPrizePool(false, profit);
        //     uint half = profit / 2;
        //     ReceiverInterface(disburseAddr).receiveEther.value(half)();
        //     ReceiverInterface(ethRelief).receiveEther.value(profit - half)();
        //     emit LogFundsDisbursed(_week, cost, profit - half, ethRelief, now);
        //     emit LogFundsDisbursed(_week, cost, half, disburseAddr, now);
        //     return;
        // }
        
    }

    function distributeFunds(uint _week, uint _cost, uint _profit) private {
        if (_profit == 0) LogFundsDisbursed(_week, _cost, 0, 0, now);
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