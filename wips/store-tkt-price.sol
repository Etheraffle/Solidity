/**
 * Store tkt price in raffle struct to remedy the potential game theoretic ramifications 
 * or the tkt price changes w/r/t withdrawal time of a won prize?
 *
 * Need to reference it now in all tktPrice things!
 * Need the new raffle to bake the tkt price in
 * Need the ticket purchases to reference that price
 * Need the withdraw to calculate prize based off that price.
 * Front end won't matter since that references prizes based off array stored in db
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
        uint tktPrice;
    }

 }