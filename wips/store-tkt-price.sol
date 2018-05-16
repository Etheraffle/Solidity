/**
 * Store tkt price in raffle struct to remedy the potential game theoretic ramifications 
 * or the tkt price changes w/r/t withdrawal time of a won prize?
 *
 * Need to reference it now in all tktPrice things!
 * Need the new raffle to bake the tkt price in - DONE
 * Need the ticket purchases to reference that price
 * Need the withdraw to calculate prize based off that price.
 * Front end won't matter since that references prizes based off array stored in db
 * Might need to capture the tktPrice into the db too, add it into an event?
 */

 contract StoreTktPrice {

    mapping (uint => rafStruct) public raffle;
    struct rafStruct {
        mapping (address => uint[][]) entries;
        uint tktPrice;
        uint unclaimed;
        uint[] winNums;
        uint[] winAmts;
        uint timeStamp;
        bool wdrawOpen;
        uint numEntries;
        uint freeEntries;
    }
    /**
     * @dev   Function which gets current week number and if different
     *        from the global var week number, it updates that and sets
     *        up the new raffle struct. Should only be called once a
     *        week after the raffle is closed. Should it get called
     *        sooner, the contract is paused for inspection.
     */
    function newRaffle() internal {
        uint newWeek = getWeek();
        if (newWeek == week) {
            pauseContract(4);
        } else {//∴ new raffle...
            week = newWeek;
            raffle[newWeek].tktPrice = tktPrice;
            raffle[newWeek].timeStamp = BIRTHDAY + (newWeek * WEEKDUR);
        }
    }
 }