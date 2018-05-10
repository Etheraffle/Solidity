pragma solidity^0.4.23;

contract FreeLOTInterface {
	function balanceOf(address _owner) constant external returns (uint balance) {}
	function transfer(address _to, uint _value) external {}
}

contract ERDeprecated {
	function getChosenNumbers(address _entrant, uint _week, uint _entryNum) constant external returns (uint[]) {}
	// function getWinningDetails(uint _week) constant external returns (uint[], uint[]) {}
	mapping (uint => rafStruct) public raffle;
    struct rafStruct {
        mapping (address => uint[][]) entries;
        uint unclaimed;
        uint[] winNums;
        uint[] winAmts;
        uint timeStamp;
        bool wdrawOpen;
        uint numEntries;
        uint freeEntries;
    }
}

contract FreeLOTWin {

	bool public paused;
	address public etheraffle;
	mapping (address => mapping (uint => mapping (uint => bool))) claimed; // Map address to weekNo to entryNum to bool


	event LogPauseStatus(bool currentStatus, uint atTime);
    event LogTokenDeposit(address fromWhom, uint tokenAmount, bytes data);
	event LogWithdraw(address toWhom, uint forRaffle, uint entryNumber, uint atTime);

	FreeLOTInterface freeLOT;
	ERDeprecatedInterface erDeprecated;

	modifier onlyIfNotPaused() {
		require(!paused);
		_;
	}

	modifier onlyEtheraffle() {
		require(msg.sender == etheraffle);
		_;
	}

	function constructor(address _freeLOT, address _erDeprecated) {
		freeLOT = FreeLOTInterface(0xc39f7bb97b31102c923daf02ba3d1bd16424f4bb);
		erDeprecated = ERDeprecatedInterface(0x4251139bf01d46884c95b27666c9e317df68b876);
	}

	function pause(bool _status) onlyEtheraffle public {
		paused = status;
		emit LogPauseStatus(_status, atTime);
	}

	function getWinNums(uint _week) internal view returns (uint[]) {
		return erDeprecated.raffle[_week].winNums;
	}

	function getChosen(address _entrant, uint _week, uint _entryNum) internal view returns (uint[]) {
		return getChosenNumbers(_entrant, _week, _entryNum);
	}
    /**
     * @dev   Function compares array of entrant's 6 chosen numbers to
      *       the raffle in question's winning numbers, counting how
      *       many matches there are.
      *
      * @param _week         The week number of the Raffle in question
      * @param _entrant      Entrant's ethereum address
      * @param _entryNum     number of entrant's entry in question.
     */
    function getMatches(uint _week, address _entrant, uint _entryNum) view internal returns (uint) {
		uint[] chosen  = getChosen(_entrant, _week, _entryNum);
		uint[] winNums = getWinNums(_week);
        uint matches;
        for (uint i = 0; i < 6; i++) {
            for (uint j = 0; j < 6; j++) {
                if (chosen[i] == winNums[j]) {
                    matches++;
                    break;
                }
            }
        }
        return matches;
    }

	function withdraw(uint _week, uint _entryNum) onlyIfNotPaused external {

		// require(!claimed[msg.sender][_week][_entryNum], 'Already withdrawn!')
		// claimed[msg.sender][_week][_entryNum] = true
		// require(_week < 38, 'Not an eligible week number!')
		// uint matches = getMatches(_week, msg.sender, _entryNum)
		// require(matches == 2, 'Not a two match win!');
		// FreeLOT.transfer(msg.sender, 1);
		// emit LogWithdraw(msg.sender, _week, _entryNum, now);
	}

	function scuttle() onlyEtheraffle public {
		uint amt = freeLOT.balanceOf(this);
		freeLOT.transfer(etheraffle, amt);
		selfdestruct(etheraffle);
	}
	/**
     * @dev     ERC223 tokenFallback function allows to receive ERC223 tokens 
     *          properly.
     *
     * @param _from  Address of the sender.
     * @param _value Amount of deposited tokens.
     * @param _data  Token transaction data.
     */
    function tokenFallback(address _from, uint256 _value, bytes _data) external {
        if (_value > 0) emit LogTokenDeposit(_from, _value, _data);
    }

}