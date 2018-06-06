/**
 * Required to move the prize pool since the new contract addToPrizePool method is now called
 * manuallyAddToPrizePool()
 */

contract EtheraffleUpgrade {
    function manuallyAddToPrizePool() payable public {}
}

contract Bridge {

    address public etheraffle;

    event LogFundsAdded(uint amount, uint atTime);

    constructor(address _er) {
        etheraffle = _er;
    }

    function addToPrizePool() public payable {
        emit LogFundsAdded(msg.value, now);
    }

    function movePrizePool(address _newAddr) external {
        require(msg.sender == etheraffle);
        EtheraffleUpgrade(_newAddr).manuallyAddToPrizePool.value(this.balance)();
    }
}