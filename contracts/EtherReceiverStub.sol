pragma solidity^0.4.24;

contract EtherReceiverStub {
    
    address public etheraffle;

    event LogEtherReceived(address fromWhere, uint howMuch, uint atTime);
    /**
     * @notice  Sets the etheraffle var to the Etheraffle mangerial
     *          multisig account.
     *
     * @param   _etheraffle   The Etheraffle multisig account
     *
     */
    constructor(address _etheraffle) {
        etheraffle = _etheraffle;
    }
    /**
     * @notice  Standard receive ether function. Fires event
     *          announcing arrivale of ETH.
     *
     */
    function receiveEther() payable external {
        emit LogEtherReceived(msg.sender, msg.value, now);
    }
    /**
     * @notice  Deletes contract data and moves any funds to given
     *          address.
     *
     * @param   _addr   The destination address for any ether herein.
     *
     */
    function selfDestruct(address _addr) external {
        require(msg.sender == etheraffle);
        selfdestruct(_addr);
    }

}