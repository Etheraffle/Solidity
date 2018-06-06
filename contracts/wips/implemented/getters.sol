    /**
     * @dev     Get a entrant's number of entries into a specific raffle
     *
     * @param   _week       The week number of the raffle in question.
     *
     * @param   _entrant    The entrant in question.
     *
     */
    function getUserNumEntries(address _entrant, uint _week) constant external returns (uint) {
        return raffle[_week].entries[_entrant].length;
    }
    /**
     * @dev     Get chosen numbers of an entrant, for a specific raffle.
     *          Returns an array.
     *
     * @param   _entrant    The entrant in question's address.
     *
     * @param   _week       The week number of raffle in question.
     *
     * @param   _entryNum   The entrant's entry number in this raffle.
     *
     */
    function getChosenNumbersHash(address _entrant, uint _week, uint _entryNum) constant external returns (bytes32) {
        return raffle[_week].entries[_entrant][_entryNum-1];
    }
    /**
     * @dev     Get winning details of a raffle, ie, it's winning numbers
     *          and the prize amounts. Returns two arrays.
     *
     * @param   _week   The week number of the raffle in question.
     *
     */
    function getWinningDetails(uint _week) constant external returns (uint[], uint[]) {
        return (raffle[_week].winNums, raffle[_week].winAmts);
    }