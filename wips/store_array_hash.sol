pragma solidity^0.4.23;
/*
TODO: Implement new withdraw method that requires user to provide their chosen numbers (front end will take care of this), then those numbers can be verified via the struct before the number of matches are ascertained.

*/
contract StoreHash {

  uint public prizePool;

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

  mapping (uint => rafStructHash) public raffleHash;

  struct rafStructHash {
    mapping (address => bytes32[]) entries;
    uint unclaimed;
    uint[] winNums;
    uint[] winAmts;
    uint timeStamp;
    bool wdrawOpen;
    uint numEntries;
    uint freeEntries;
  }

  event LogTicketBought(uint forRaffle, uint entryNumber, address theEntrant, uint[] chosenNumbers, uint personalEntryNumber, uint tktCost, uint atTime, uint affiliateID);
  /**
   * Current method
   * 215,000 gas (190,000 for subsequent entries)
   */
  function storeNumbers(uint[] _cNums) public payable {
    raffle[1].numEntries++;
    prizePool += msg.value;
    raffle[1].entries[msg.sender].push(_cNums);
    emit LogTicketBought(1, raffle[1].numEntries, msg.sender, _cNums, raffle[1].entries[msg.sender].length, msg.value, now, 0);
  }
  /**
   * Proposed new method
   * 95,000 gas (65,000 for subsequent entries)
   * a roughly 65% reduction in gas price
   */
  function storeHash(uint[] _cNums) public payable {
    raffleHash[1].numEntries++;
    prizePool += msg.value;
    raffleHash[1].entries[msg.sender].push(hashEntry(_cNums));
    emit LogTicketBought(1, raffle[1].numEntries, msg.sender, _cNums, raffle[1].entries[msg.sender].length, msg.value, now, 0);
  
  function hashEntry(uint[] _cNums) pure public returns (bytes32) {
    return keccak256(_nums);
  }
  /**
   * Getter for the hashes stored in the raffle struct
   */
  function getEntryHash(address _entrant, uint _entryNo) public view returns (bytes32) {
    return raffleHash[1].entries[_entrant][_entryNo];
  }

}