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
    function disburseFunds(uint _week) internal {
        uint cost = getOraclizeCost();
        if (cost > prizePool) return pauseContract(true, 1);
        modifyPrizePool(false, cost);
        uint profit = calcProfit(_week);
        if (profit == 0) return LogFundsDisbursed(_week, cost, profit, 0, now); // Can't use emit keyword here

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
    }
    /**
     * @dev     Fires an event pertaining to a disbursal of funds.
     *
     * @param   _week   Week of raffle the funds were disbursed from.
     *
     * @param   _cost   Cost of the raffle.
     *
     * @param   _amt    Amount of Wei sent.
     *
     * @param   _addr   Address of receiving contract.
     *
     */
    function logDisbursal(uint _week, uint _cost, uint _amt, address _addr) private {
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