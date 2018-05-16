/**
 * Store tkt price in raffle struct to remedy the potential game theoretic ramifications 
 * or the tkt price changes w/r/t withdrawal time of a won prize?
 */

 contract StoreTktPrice {

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