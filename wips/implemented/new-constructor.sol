contract NewConstructor {
    /**
     * @dev     Constructor. Sets the Etheraffle multisig address, 
     *          the EthRelief & Disbursal contract addresses and 
     *          instantiates the FreeLOT contract. Sets up an 
     *          initial raffle struct.
     *
     */
    constructor() payable {
        week         = getWeek();
        etheraffle   = 0x97f535e98cf250cdd7ff0cb9b29e4548b609a0bd;
        disburseAddr = 0xb6a5f50b5ce5909a9c75ce27fec96e5de393af61;
        ethRelief    = 0x7ee65fe55accd9430f425379851fe768270c6699;
        freeLOT      = FreeLOTInterface(0xc39f7bB97B31102C923DaF02bA3d1bD16424F4bb);
        setupRaffleStruct(week, 2500000000000000, (week * WEEKDUR) + BIRTHDAY);
    }
}
