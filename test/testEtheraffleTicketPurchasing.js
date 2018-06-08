const { assert }    = require("chai")
    , moment        = require('moment')
    , truffleAssert = require('truffle-assertions')
    , ethRelief     = artifacts.require('ethRelief')
    , etheraffle    = artifacts.require('etheraffle')
    , disbursal     = artifacts.require('etheraffleDisbursal')

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

  //'Can only enter on behalf of when paying >= ticket price'

})

/* Supply arg in form of: etheraffle.at(contract.address) */
const getAllEvents = _contract => {
  return new Promise((resolve, reject) => {
    return _contract.allEvents({},{fromBlock:0, toBlock: 'latest'})
    .get((err, res) => !err ? resolve(res) : console.log(err))
  })
}