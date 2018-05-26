    /**
     * @dev    Called by the weekly Oraclize callback. Checks raffle 10
     *         weeks older than current raffle for any unclaimed prize
     *         pool. If any found, returns it to the main prizePool and
     *         zeros the amount.
     *
     */
    function reclaimUnclaimed() internal {
        uint old = getWeek() - 11;
        uint amt = getUnclaimed(old);
        if (amt == 0) return;
        modifyPrizePool(true, amt);
        modifyUnclaimed(false, old, amt);
        emit LogReclaim(old, amt, now);
    }
    /**
     * @dev     Returns the unclaimed prize pool sequestered in a raffle's
     *          struct.
     *
     * @param   _week   Week number for raffle in question.
     *
     */
    function getUnclaimed(uint _week) public view returns (uint) {
        return raffle[_week].unclaimed;
    }