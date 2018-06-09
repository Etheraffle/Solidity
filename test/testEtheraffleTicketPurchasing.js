const { assert }    = require("chai")
    // , moment        = require('moment')
    , truffleAssert = require('truffle-assertions')
    // , ethRelief     = artifacts.require('ethRelief')
    , etheraffle    = artifacts.require('etheraffle')
    , freeLOT       = artifacts.require('etheraffleFreeLOT')
    // , disbursal     = artifacts.require('etheraffleDisbursal')

contract('EtheraffleTicketPurchasing', accounts => {
  // Test all three methods for buying tickets!! Check correct struc vars afterwards
  // Edit the raf end variable and check it reverts when trying to enter raffle! (no struct...)
  // set up the "next" raffles struct manually then enter that one and test vars etc!

  it('Tickets can only be purchased by sending >= ticket price', async () => {
    const contract = await etheraffle.deployed()
        , week     = await contract.getWeek.call()
        , struct   = await contract.raffle.call(week)
        , tktPrice = struct[0].toNumber()
        , entrant  = accounts[0]
        , entry    = [1,2,3,4,5,6]
        , affID    = 0
        , entryGT  = await contract.enterRaffle(entry, affID, {from: entrant, value: tktPrice + 1})
        , entryEQ  = await contract.enterRaffle(entry, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(entryGT, 'LogTicketBought')
    truffleAssert.eventEmitted(entryEQ, 'LogTicketBought')
    try {
      await contract.enterRaffle(entry, affID, {from: entrant, value: tktPrice - 1})
      assert.fail('Shouldn\'t be able to enter raffle for less than ticket price!')
    } catch (e) {
      // console.log('Error when buying ticket for less than ticket price: ', e)
      // Transaction reverts as expected!
    }
  })

  it('Should log all ticket purchase details correctly', async () => {
    const contract = await etheraffle.deployed()
        , week     = await contract.getWeek.call()
        , struct   = await contract.raffle.call(week)
        , tktPrice = struct[0].toNumber()
        , entry    = [1,2,3,4,5,6]
        , entrant  = accounts[5]
        , affID    = 5
        , tx       = await contract.enterRaffle(entry, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(tx, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == entry[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }] = await getAllEvents(etheraffle.at(contract.address))
        , entryNum = await contract.getUserNumEntries(entrant, week)
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), entryNum.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
  })

  it('Any account can purchase a tkt', async () => {
    const contract = await etheraffle.deployed()
        , week     = await contract.getWeek.call()
        , struct   = await contract.raffle.call(week)
        , tktPrice = struct[0].toNumber()
        , affID    = 0
    accounts.map((e, i) => contract.enterRaffle((new Array(6).fill().map((_, j) => j + i + 1)), affID, {from: e, value: tktPrice}))
            .map(async p => truffleAssert.eventEmitted(await p, 'LogTicketBought'))
  })

  it('Raffle entries in struct should increment on entry', async () => {
    const contract = await etheraffle.deployed()
        , week     = await contract.getWeek.call()
        , struct   = await contract.raffle.call(week)
        , entries  = struct[4].toNumber()
        , tktPrice = struct[0].toNumber()
        , entry    = await contract.enterRaffle([1,2,3,4,5,6], 0, {from: accounts[0], value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought')
    const newStruct  = await contract.raffle.call(week)
        , newEntries = newStruct[4].toNumber()
    assert.equal(newEntries, entries + 1)
  })

  it('Prize pool should increment by ticket price on entry', async () => {
    const contract  = await etheraffle.deployed()
        , week      = await contract.getWeek.call()
        , prizePool = await contract.prizePool.call() 
        , struct    = await contract.raffle.call(week)
        , tktPrice  = struct[0].toNumber()
        , entry     = await contract.enterRaffle([1,2,3,4,5,6], 0, {from: accounts[0], value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought')
    const newPrizePool = await contract.prizePool()
    assert.equal(prizePool.toNumber() + tktPrice, newPrizePool.toNumber())
  })

  it('Can enter on behalf of another address', async () => {
    const contract   = await etheraffle.deployed()
        , week       = await contract.getWeek.call()
        , struct     = await contract.raffle.call(week)
        , tktPrice   = struct[0].toNumber()
        , numbers    = [7,8,9,10,11,12]
        , affID      = 0
        , buyer      = accounts[7]
        , onBehalfOf = accounts[8] 
        , entry      = await contract.enterOnBehalfOf(numbers, affID, onBehalfOf, {from: buyer, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }] = await getAllEvents(etheraffle.at(contract.address))
        , numEntries = await contract.getUserNumEntries(onBehalfOf, week)
    assert.equal(args.theEntrant, onBehalfOf)
    assert.equal(args.personalEntryNumber.toNumber(), numEntries.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
  })

  it('Can only enter on behalf of someone when paying >= ticket price', async () => {
    const contract   = await etheraffle.deployed()
        , week       = await contract.getWeek.call()
        , struct     = await contract.raffle.call(week)
        , tktPrice   = struct[0].toNumber()
        , numbers    = [7,8,9,10,11,12]
        , affID      = 0
        , buyer      = accounts[7]
        , onBehalfOf = accounts[8] 
        , entryGT  = await contract.enterOnBehalfOf(numbers, affID, onBehalfOf, {from: buyer, value: tktPrice + 1})
        , entryEQ  = await contract.enterOnBehalfOf(numbers, affID, onBehalfOf, {from: buyer, value: tktPrice})
    truffleAssert.eventEmitted(entryGT, 'LogTicketBought')
    truffleAssert.eventEmitted(entryEQ, 'LogTicketBought')
    try {
      await contract.enterOnBehalfOf(numbers, affID, onBehalfOf, {from: buyer, value: tktPrice - 1})
      assert.fail('Shouldn\'t be able to enter on behalf of another into a raffle for less than ticket price!')
    } catch (e) {
      // console.log('Error when buying ticket for someone else for less than ticket price: ', e)
      // Transaction reverts as expected!
    }
  })

  it('Entries on behalf of increments the correct user\'s number of entries', async () => {
    const contract     = await etheraffle.deployed()
        , week         = await contract.getWeek.call()
        , struct       = await contract.raffle.call(week)
        , tktPrice     = struct[0].toNumber()
        , numbers      = [7,8,9,10,11,12]
        , affID        = 0
        , buyer        = accounts[7]
        , onBehalfOf   = accounts[8] 
        , numEntries   = await contract.getUserNumEntries(onBehalfOf, week)
        , buyerEntries = await contract.getUserNumEntries(buyer, week)
        , entry        = await contract.enterOnBehalfOf(numbers, affID, onBehalfOf, {from: buyer, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }] = await getAllEvents(etheraffle.at(contract.address))
        , entriesNow = await contract.getUserNumEntries(onBehalfOf, week)
        , buyerEntriesNow = await contract.getUserNumEntries(buyer, week)
    assert.equal(args.theEntrant, onBehalfOf)
    assert.equal(args.personalEntryNumber.toNumber(), entriesNow.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
    assert.equal(entriesNow.toNumber(), numEntries.toNumber() + 1)
    assert.equal(buyerEntriesNow.toNumber(), buyerEntries.toNumber())
  })


  it('Can enter raffle for free using a FreeLOT token', async () => {
    const contract   = await etheraffle.deployed()
        , freeCont   = await freeLOT.deployed()
        , week       = await contract.getWeek.call()
        , numbers    = [7,8,9,10,11,12]
        , affID      = 0
        , tktPrice   = 0
        , entrant    = accounts[0]
        , freeBal    = await freeCont.balanceOf.call(entrant)
    await freeCont.addDestroyer(contract.address) // ER contract needs to destroy FreeLOT tokens!
    assert.isAbove(freeBal.toNumber(), 0, 'FreeLOT balance is zero!')
    const entry = await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }] = await getAllEvents(etheraffle.at(contract.address))
        , numEntries = await contract.getUserNumEntries(entrant, week)
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), numEntries.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
  })
  
  it('FreeLOT entries can pay for tickets if they wish', async () => {
    const contract   = await etheraffle.deployed()
        , freeCont   = await freeLOT.deployed()
        , week       = await contract.getWeek.call()
        , numbers    = [7,8,9,10,11,12]
        , affID      = 0
        , tktPrice   = 1*10**18
        , entrant    = accounts[0]
        , freeBal    = await freeCont.balanceOf.call(entrant)
        , prizePool  = await contract.prizePool.call()
    assert.isAbove(freeBal.toNumber(), 0, 'FreeLOT balance is zero!')
    const entry        = await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
        , prizePoolNow = await contract.prizePool.call()
    assert.equal(prizePoolNow.toNumber(), prizePool.toNumber() + tktPrice)
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }] = await getAllEvents(etheraffle.at(contract.address))
        , numEntries = await contract.getUserNumEntries(entrant, week)
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), numEntries.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
  })

  it('FreeLOT entries increments free entries & entries correctly', async () => {
    const contract    = await etheraffle.deployed()
        , freeCont    = await freeLOT.deployed()
        , week        = await contract.getWeek.call()
        , struct      = await contract.raffle.call(week)
        , numEntries  = struct[4]
        , freeEntries = struct[5]
        , numbers     = [7,8,9,10,11,12]
        , affID       = 0
        , tktPrice    = 0
        , entrant     = accounts[0]
        , freeBal     = await freeCont.balanceOf.call(entrant)
    assert.isAbove(freeBal.toNumber(), 0, 'FreeLOT balance is zero!')
    const entry = await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }]  = await getAllEvents(etheraffle.at(contract.address))
        , userEntries = await contract.getUserNumEntries(entrant, week)
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), userEntries.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
    const structAfter      = await contract.raffle.call(week)
        , numEntriesAfter  = structAfter[4]
        , freeEntriesAfter = structAfter[5]
    assert.equal(numEntriesAfter.toNumber(), numEntries.toNumber() + 1)
    assert.equal(freeEntriesAfter.toNumber(), freeEntries.toNumber() + 1)
  })

  it('FreelOT entries increments user\'s numbers of entries correctly', async () => {
    const contract    = await etheraffle.deployed()
        , freeCont    = await freeLOT.deployed()
        , week        = await contract.getWeek.call()
        , numbers     = [7,8,9,10,11,12]
        , affID       = 0
        , tktPrice    = 0
        , entrant     = accounts[0]
        , userEntries = await contract.getUserNumEntries(entrant, week)
        , freeBal     = await freeCont.balanceOf.call(entrant)
    assert.isAbove(freeBal.toNumber(), 0, 'FreeLOT balance is zero!')
    const entry = await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }]       = await getAllEvents(etheraffle.at(contract.address))
        , userEntriesAfter = await contract.getUserNumEntries(entrant, week)
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), userEntriesAfter.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
    assert.equal(userEntriesAfter.toNumber(), userEntries.toNumber() + 1)
  })

  it('FreeLOT entries destroy one of the entrant\'s freeLOT tokens', async () => {
    const contract      = await etheraffle.deployed()
        , freeCont      = await freeLOT.deployed()
        , week          = await contract.getWeek.call()
        , numbers       = [7,8,9,10,11,12]
        , affID         = 0
        , tktPrice      = 0
        , entrant       = accounts[0]
        , freeBalBefore = await freeCont.balanceOf.call(entrant)
        , freeTotBefore = await freeCont.totalSupply.call()
    assert.isAbove(freeBalBefore.toNumber(), 0, 'FreeLOT balance is zero!')
    const entry = await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }]   = await getAllEvents(etheraffle.at(contract.address))
        , userEntries  = await contract.getUserNumEntries(entrant, week)
        , freeBalAfter = await freeCont.balanceOf.call(entrant)
        , freeTotAfter = await freeCont.totalSupply.call()
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), userEntries.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
    assert.equal(freeBalAfter.toNumber(), freeBalBefore.toNumber() - 1)
    assert.equal(freeTotAfter.toNumber(), freeTotBefore.toNumber() - 1)
  })
  
  it('Free entries are not possible without entrant owning a FreeLOT token', async () => {
    const contract = await etheraffle.deployed()
        , freeCont = await freeLOT.deployed()
        , numbers  = [7,8,9,10,11,12]
        , affID    = 0
        , tktPrice = 0
        , entrant  = accounts[6]
        , freeBal  = await freeCont.balanceOf.call(entrant)
    assert.equal(freeBal.toNumber(), 0, 'FreeLOT balance is greater than zero!')
    try {
      await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
      assert.fail('Entrant shouldn\'t be able to enter for free without a freeLOT token!')
    } catch (e) {
      // console.log('Error when attempting to enter for free sans a FreeLOT token', e)
      // Transaction reverted as expected!
    }
  })
  
  it('Prize pool doesn\'t increment after a FreeLOT entry', async () => {
    const contract  = await etheraffle.deployed()
        , freeCont  = await freeLOT.deployed()
        , week      = await contract.getWeek.call()
        , numbers   = [7,8,9,10,11,12]
        , affID     = 0
        , tktPrice  = 0
        , entrant   = accounts[0]
        , freeBal   = await freeCont.balanceOf.call(entrant)
        , prizePool = await contract.prizePool.call()
    assert.isAbove(freeBal.toNumber(), 0, 'FreeLOT balance is zero!')
    const entry = await contract.enterFreeRaffle(numbers, affID, {from: entrant, value: tktPrice})
    truffleAssert.eventEmitted(entry, 'LogTicketBought', ev =>
      ev.tktCost.toNumber() == tktPrice &&
      ev.chosenNumbers.reduce((acc, e, i) => acc && e == numbers[i], true)
    )
    /* Can't access indexed logs via truffleAssert hence following */
    const [{ args }]     = await getAllEvents(etheraffle.at(contract.address))
        , userEntries    = await contract.getUserNumEntries(entrant, week)
        , freeBalAfter   = await freeCont.balanceOf.call(entrant)
        , prizePoolAfter = await contract.prizePool.call()
    assert.equal(args.theEntrant, entrant)
    assert.equal(args.personalEntryNumber.toNumber(), userEntries.toNumber())
    assert.equal(args.forRaffle.toNumber(), week)
    assert.equal(freeBalAfter.toNumber(), freeBal.toNumber() - 1)
    assert.equal(prizePool.toNumber(), prizePoolAfter.toNumber())
  })

  // Add an "enter on behalf of for free " function and test it thoroughly
  
  // it('Can enter on behalf of another address for free using a FreeLOT token', async () => {})
  // it('Can\'t enter on behalf of another address for free without a FreeLOT token', async () => {})
  // it('FreeLOT on behalf of entries increment correct user\'s entries', async () => {})
  // it('FreeLOT on behalf of entries do not increment prizepool', async () => {})
  // it('FreeLOT on behalf of entries destroy a FreeLOT token of the buyer not the recipient', async () => {})
  // it('FreeLOT on behalf of entries can pay for tickets if they wish', async () => {})
  // it('FreeLOT on behalf of increments free entries & entries correctly', async () => {})

  // close the raffle somehow and test raffle closed entry.

})

/* Supply arg in form of: etheraffle.at(contract.address) */
const getAllEvents = _contract => {
  return new Promise((resolve, reject) => {
    return _contract.allEvents({},{fromBlock:0, toBlock: 'latest'})
    .get((err, res) => !err ? resolve(res) : console.log(err))
  })
}