/**
 * Store tkt price in raffle struct to remedy the potential game theoretic ramifications 
 * or the tkt price changes w/r/t withdrawal time of a won prize?
 *
 * Need the new raffle to bake the tkt price in - DONE
 * Need the ticket purchases to reference that price - DONE
 * Need the setPayouts to calculate prize based off that price.- DONE
 * Front end won't matter since that references prizes based off array stored in db
 * Might need to capture the tktPrice into the db too, add it into an event? - DONE
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
    // NEW VERSION OF THIS FUNC EXISTS, DEFINITELY SETS TICKET PRICE SO DON'T WORRY
    // function newRaffle() internal {
    //     uint newWeek = getWeek();
    //     if (newWeek == week) {
    //         pauseContract(4);
    //     } else {//∴ new raffle...
    //         week = newWeek;
    //         raffle[newWeek].tktPrice = tktPrice;
    //         raffle[newWeek].timeStamp = BIRTHDAY + (newWeek * WEEKDUR);
    //     }
    // }
    /**
     * @dev  Function to enter the raffle. Requires the caller to send ether
     *       of amount greater than or equal to the current raffle's tkt price.
     *
     * @param _cNums    Ordered array of entrant's six selected numbers.
     *
     * @param _affID    Affiliate ID of the source of this entry.
     *
     */
    function enterRaffle(uint[] _cNums, uint _affID) payable external onlyIfNotPaused {
        require(raffle[week].tktPrice > 0 && msg.value >= raffle[week].tktPrice);
        buyTicket(_cNums, msg.sender, msg.value, _affID);
    }
    /**
     * @dev  Function to enter the raffle on behalf of another address. Requires the 
     *       caller to send ether of amount greater than or equal to the current 
     *       raffle's ticket price. In the event of a win, only the onBehalfOf 
     *       address can claim it.
     *
     * @param _cNums        Ordered array of entrant's six selected numbers.
     *
     * @param _affID        Affiliate ID of the source of this entry.
     *
     * @param _onBehalfOf   The address to be entered on behalf of.
     *
     */
    function enterOnBehalfOf(uint[] _cNums, uint _affID, address _onBehalfOf) payable external onlyIfNotPaused {
        require(raffle[week].tktPrice > 0 && msg.value >= raffle[week].tktPrice);
        buyTicket(_cNums, _onBehalfOf, msg.value, _affID);
    }
 }