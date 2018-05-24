//WRITE OVERLOADED SET PAUSE FUNCTION, ONE WITHOUT THE ID PARAM AND ONE WITH?!?!?

    /**
     * @dev  To pause the contract's functions should the need arise. Internal.
     *       Logs an event of the pausing.
     *
     * @param _id    A uint to identify the caller of this function.
     */
    function pauseContract(bool _status, uint _id) internal {
      paused = _status;
      emit LogFunctionsPaused(_id, now);
    }

    function pauseContract(bool _status) internal {
      paused = _status;
    }