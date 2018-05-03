pragma solidity^0.4.23;

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

  // constructor() {
    // TODO: Lower gas prices by storing hashes of arrays rather than arrays...
    // NB: will no longer be able to retrieve chosen numbers from contract
    // DB will store them having picked them up from events
  // }

  function storeNumbers(uint[] _cNums) public payable {
    raffle[1].numEntries++;
    prizePool += msg.value;
    raffle[1].entries[msg.sender].push(_cNums);
    emit LogTicketBought(1, raffle[1].numEntries, msg.sender, _cNums, raffle[1].entries[msg.sender].length, msg.value, now, 0);
  }

  function storeHash(uint[] _cNums) public payable {
    raffleHash[1].numEntries++;
    prizePool += msg.value;
    raffleHash[1].entries[msg.sender].push(keccak256(_cNums));
    emit LogTicketBought(1, raffle[1].numEntries, msg.sender, _cNums, raffle[1].entries[msg.sender].length, msg.value, now, 0);
  }
  
   function getEntryHash(address _entrant, uint _entryNo) public view returns (bytes32) {
        return raffleHash[1].entries[_entrant][_entryNo];
   }

}