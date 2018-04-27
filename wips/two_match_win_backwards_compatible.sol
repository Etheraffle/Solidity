pragma solidity^0.4.21;7

contract FreeLOTInterface {
	function balanceOf(address _owner) constant external returns (uint balance) {}
	function transfer(address _to, uint _value) external {}
}

contract ERDeprecated {
	function getChosenNumbers(address _entrant, uint _week, uint _entryNum) constant external returns (uint[]) {}
	function getWinningDetails(uint _week) constant external returns (uint[], uint[]) {}
}

contract FreeLOTWin {

	bool public paused;
	address public etheraffle;
	mapping (address => mapping (uint => mapping (uint => bool))) claimed; // Map address to weekNo to entryNum to bool


	event LogPauseStatus(bool currentStatus, uint atTime);
    event LogTokenDeposit(address fromWhom, uint tokenAmount, bytes data);

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

	function withdraw(uint _week, uint _entryNum) onlyIfNotPaused external {

		// Check erDeprecated contract
		// set claimed[msg.sender][_week][_entryNum] = true
		// require the above to be !
		// require _week < 38
		// get winning details
		// get chosen numbers
		// calc matches
		// if two, send token
		// log it


		// Etheraffles w.draw function...
		// 	require
		// 	(
		// 			raffle[_week].timeStamp > 0 &&
		// 			now - raffle[_week].timeStamp > WEEKDUR - (WEEKDUR / 7) &&
		// 			now - raffle[_week].timeStamp < wdrawBfr &&
		// 			raffle[_week].wdrawOpen == true &&
		// 			raffle[_week].entries[msg.sender][_entryNum - 1].length == 6
		// 	);
		// 	uint matches = getMatches(_week, msg.sender, _entryNum);
		// 	if (matches == 2) return winFreeGo(_week, _entryNum);
		// 	require
		// 	(
		// 			matches >= 3 &&
		// 			raffle[_week].winAmts[matches - 3] > 0 &&
		// 			raffle[_week].winAmts[matches - 3] <= this.balance
		// 	);
		// 	raffle[_week].entries[msg.sender][_entryNum - 1].push(1);
		// 	if (raffle[_week].winAmts[matches - 3] <= raffle[_week].unclaimed) {
		// 			raffle[_week].unclaimed -= raffle[_week].winAmts[matches - 3];
		// 	} else {
		// 			raffle[_week].unclaimed = 0;
		// 			pauseContract(5);
		// 	}
		// 	msg.sender.transfer(raffle[_week].winAmts[matches - 3]);
		// 	emit LogWithdraw(_week, msg.sender, _entryNum, matches, raffle[_week].winAmts[matches - 3], now);
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