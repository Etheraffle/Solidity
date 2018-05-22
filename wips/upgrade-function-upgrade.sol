    /**
     * @dev     Upgrades the Etheraffle contract. Only callable by the
     *          Etheraffle address. Calls an addToPrizePool method as
     *          per the abstract contract above. Function renders the
     *          entry method uncallable, cancels the Oraclize recursion,
     *          then zeroes the prizepool and sends the funds to the new
     *          contract. Sets a var tracking when upgrade occurred and logs
     *          the event.
     *
     * @param _newAddr   The new contract address.
     */
    function upgradeContract(address _newAddr) onlyEtheraffle external {
        require(upgraded == 0 && upgradeAddr == address(0));
        uint amt    = prizePool;
        upgradeAddr = _newAddr;
        upgraded    = now;
        week        = 0;
        prizePool   = 0;
        gasAmt      = 0;
        apiStr1     = "";
        randomStr1  = "";
        require(this.balance >= amt);
        EtheraffleUpgrade(_newAddr).manuallyAddToPrizePool.value(amt)();
        emit LogUpgrade(_newAddr, amt, upgraded);
    }