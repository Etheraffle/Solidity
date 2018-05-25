    /**
     * @dev  Function totals up oraclize cost for the raffle, subtracts
     *       it from the prizepool (if less than, if greater than if
     *       pauses the contract and fires an event). Calculates profit
     *       based on raffle's tickets sales and the take percentage,
     *       then forwards that amount of ether to the disbursal contract.
     *
     * @param _week   The week number of the raffle in question.
     */
    function disburseFunds(uint _week) internal {
        uint oracTot = 2 * oraclizeCost(); // 2 queries per draw...
        if (oracTot > prizePool) return pauseContract(1);
        prizePool -= oracTot;
        uint profit;
        if (raffle[_week].numEntries > 0) {
            profit = ((raffle[_week].numEntries - raffle[_week].freeEntries) * tktPrice * take) / 1000;
            prizePool -= profit;
            uint half = profit / 2;
            ReceiverInterface(disburseAddr).receiveEther.value(half)();
            ReceiverInterface(ethRelief).receiveEther.value(profit - half)();
            emit LogFundsDisbursed(_week, oracTot, profit - half, ethRelief, now);
            emit LogFundsDisbursed(_week, oracTot, half, disburseAddr, now);
            return;
        }
        emit LogFundsDisbursed(_week, oracTot, profit, 0, now);
    }
    /**
     * @dev     Returns the cost of an Oraclize api call.
     */
    function oraclizeCost() internal view returns (uint) {
        return (gasAmt * gasPrc) + oracCost;
    }