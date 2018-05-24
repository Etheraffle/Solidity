//WRITE OVERLOADED SET PAUSE FUNCTION, ONE WITHOUT THE ID PARAM AND ONE WITH?!?!?

    /**
     * @dev  To pause the contract's functions should the need arise.
     *       Logs an event of the pausing.
     *
     * @param _id    A uint to identify the caller of this function.
     */
    function pauseContract(bool _status, uint _id) internal {
      paused = _status;
      emit LogFunctionsPaused(_id, now);
    }
    /**
     * @dev     Sets the paused status of the contract to the bool 
     *          passed in. This affects various of the contracts 
     *          functions via the onlyIfNotPaused modifier.
     *
     * @param   _status     Desired pause status.
     *
     */
    function pauseContract(bool _status) internal {
      paused = _status;
    }