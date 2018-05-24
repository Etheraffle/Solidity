    /**
     * @dev     Sets the paused status of the contract to the bool 
     *          passed in. Logs an event with a uint identifying the 
     *          reason for pausing the contract to the front-end 
     *          event watcher.
     *
     * @param   _status Desired pause status.
     *
     * @param   _id     Uint identifing the reason function was called.
     */
    function pauseContract(bool _status, uint _id) internal {
      pauseContract(_status);
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