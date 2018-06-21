const { assert }    = require("chai")
    , moment        = require('moment')
    , truffleAssert = require('truffle-assertions')
    , etheraffle    = artifacts.require('etheraffle')
    , ethRelief     = artifacts.require('ethRelief')
    , disbursal     = artifacts.require('etheraffleDisbursal')
    , random1       = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\", \"serialNumber\"]','\\n{\"jsonrpc\": \"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\""
    , random2       = "\",\"params\":{\"n\":\"6\",\"min\":1,\"max\":49,\"replacement\":false,\"base\":10,\"apiKey\":${[decrypt] BBxn5oQTs8LKRkJb32LS+dHf/c//H3sSjehJchlucpdFGEjBwtSu08okSPoSkoQQpPCW56kz7PoGm5VEc8r722oEg01AdB03CbURpSxU5cF9Q7MeyNAaDUcTOvlX1L2T/h/k4PUD6FEIvtynHZrSMisEF+r7WJxgiA==}}']"
    , api1          = "[URL] ['json(https://etheraffle.com/api/test).m','{\"r\":\""
    , api2          = "\",\"k\":${[decrypt] BEhjzZIYd3GIvFUu4rWqwYOFKucnwToOUpP3x/svZVz/Vo68c6yIiq8k6XQDmPLajzSTD/TrpR5cF4BnLLhNDtELy7hQyMmFTuUa3JXBs0G0f4d7cTeIX8IG37KxtNfcvUafJy25}}']"
    , fakeRandom1   = "[URL] ['json(https://etheraffle.com/api/test).m','{\"flag\":\"true\",\"r\":\""
    , fakeRandom2   = "\",\"k\":${[decrypt] BEhjzZIYd3GIvFUu4rWqwYOFKucnwToOUpP3x/svZVz/Vo68c6yIiq8k6XQDmPLajzSTD/TrpR5cF4BnLLhNDtELy7hQyMmFTuUa3JXBs0G0f4d7cTeIX8IG37KxtNfcvUafJy25}}']"
    
contract('Etheraffle Oraclize Tests Part VII - Full Raffle Turnover', accounts => {
  
  const _now        = moment.utc().format('X')
      , initBal     = 1*10**18
      , numEntries  = accounts.length
      , birthday    = 1500249600
      , tempDelay   = 30
      , weekDur     = 604800
      , pctOfPool   = [520, 114, 47, 319]
      , odds        = [56, 1032, 54200, 13983816]
      , qArr        = []
  etheraffle.deployed().then(contract => {
    const queryEvents = contract.LogQuerySent({}, {fromBlock: 0, toBlock: 'latest'})
    let counter = 0
    queryEvents.watch((err, res) => {
      err ? console.log('Error watching query events: ', err) : counter += 1
      qArr.push(res)
      if (counter == 3) queryEvents.stopWatching()
    })
  })

  it('Contract should setup correctly', async () => {
    // Add 1 ETH to prize pool, set Oraclize strings -> query prize pool & strings -> check that pp & strings are correct.
    const contract = await etheraffle.deployed()
        , amount   = initBal
        , owner    = await contract.etheraffle.call()
    await contract.manuallyAddToPrizePool({from: accounts[6], value: amount})
    const prizePool = await contract.prizePool.call()
    assert.equal(prizePool.toNumber(), amount, 'Prize pool is not 10 ETH!')
    await contract.manuallySetOraclizeString(fakeRandom1, fakeRandom2, api1, api2, {from: owner})
    const random1After = await contract.randomStr1.call()
        , random2After = await contract.randomStr2.call()
        , api1After    = await contract.apiStr1.call()
        , api2After    = await contract.apiStr2.call()
    assert.equal(fakeRandom1, random1After, 'Random1 string was not set correctly!')
    assert.equal(fakeRandom2, random2After, 'Random2 string was not set correctly!')
    assert.equal(api1, api1After, 'Api1 string was not set correctly!')
    assert.equal(api2, api2After, 'Api2 string was not set correctly!')
   })

   it('Percent of pool array should be correct', async () => {
    // Check contract for pop vars -> assert same as vars in main function's scope
    const contract  = await etheraffle.deployed()
    pctOfPool.map(async (pop, i) => {
      let contractPOP = await contract.pctOfPool.call(i)
      assert.equal(contractPOP.toNumber(), pctOfPool[i], `Contract percent of pool at index ${i} is incorrect!`)
    })
  })

  it('Odds array should be correct', async () => {
    // Check contract for pop vars -> assert same as vars in main function's scope
    const contract  = await etheraffle.deployed()
    odds.map(async (odd, i) => {
      let contractOdd = await contract.odds.call(i)
      assert.equal(contractOdd.toNumber(), odds[i], `Contract odds at index ${i} are incorrect!`)
    })
  })

  it('Should set up current week\'s raffle struct correctly', async () => {
    // Get week -> set up new raffle struct -> inspect structs data for veracity.
    const contract  = await etheraffle.deployed()
        , owner     = await contract.etheraffle.call()
        , week      = await contract.getWeek()
        , tktPrice  = await contract.tktPrice.call()
        , birthday  = await contract.BIRTHDAY.call()
        , weekDur   = await contract.WEEKDUR.call()
        , timeStamp = birthday.toNumber() + (week.toNumber() * weekDur.toNumber())
    await contract.manuallySetupRaffleStruct(week.toNumber(), tktPrice.toNumber(), timeStamp, {from: owner})
    const struct = await contract.raffle.call(week.toNumber())
    assert.equal(struct[0].toNumber(), tktPrice.toNumber(), 'Ticket price incorrectly set in struct!')
    assert.equal(struct[2].toNumber(), timeStamp, 'Timestamp incorrectly set in struct!')
    assert.isFalse(struct[3], 'Withdraw should not be open in raffle struct!')
    assert.equal(struct[4].toNumber(), 0, 'There should not be any entries in this raffle!')
    assert.equal(struct[5].toNumber(), 0, 'There should not be any free entries into this raffle!')
  })

  it('Should set current week correctly', async () => {
    // Get week from contract -> set week -> check week is set.
    const contract  = await etheraffle.deployed()
        , owner = await contract.etheraffle.call()
        , week  = await contract.getWeek()
    await contract.manuallySetWeek(week.toNumber(), {from: owner})
    const weekNow  = await contract.week.call()
    assert.equal(week.toNumber(), weekNow.toNumber(), 'Contract\'s week variable not set correctly!')
  })

  it(`Enter the current raffle ${accounts.length} times`, async () => {
    // Enter raffle with each account -> check numEntries has incremented -> check prize pool has incremented
    const contract  = await etheraffle.deployed()
        , affID     = 0
        , week      = await contract.week.call()
        , prizePool = await contract.prizePool.call()
    let struct      = await contract.raffle.call(week.toNumber())
    const tktPrice  = struct[0].toNumber()
    accounts.map(async (account, i) => await contract.enterRaffle([1+i,2+i,3+i,4+i,5+i,6+i], affID, {from: account, value: tktPrice}))
    struct = await contract.raffle.call(week.toNumber())
    const numEntries   = struct[4].toNumber()
        , newPrizePool = await contract.prizePool.call()
    assert.equal(numEntries, accounts.length, 'Incorrect number of entries into this raffle!')
    assert.equal(newPrizePool.toNumber(), prizePool.toNumber() + (tktPrice * accounts.length), 'Prize pool not incremented correctly!')
  })

  it('Set raffle end time, thereby closing the previous raffle', async () => {
    // Set raf end -> check get week increments -> enter raffle -> check it's a new raffle entry.
    const contract  = await etheraffle.deployed()
        , owner     = await contract.etheraffle.call()
        , week      = await contract.week.call()
        , struct    = await contract.raffle.call(week.toNumber())
        , timeStamp = struct[2].toNumber()
        , rafEnd    = _now - timeStamp
    await contract.manuallySetRafEndTime(rafEnd, {from: owner})
    const rafEndCheck = await contract.rafEnd.call()
    assert.equal(rafEndCheck.toNumber(), rafEnd, 'New raffle end time was not set correctly!')
  })
  
  it('Week number and getWeek() should return different values', async () => {
    // get week from var -> get week from func -> check they differ by one.
    await createDelay(15000)
    const contract = await etheraffle.deployed()
        , weekVar  = await contract.week.call()
        , weekFunc = await contract.getWeek()
    assert.equal(weekFunc.toNumber(), weekVar.toNumber() + 1, 'New raffle end time has not taken affect in getWeek function!')
  })

  it('Raffles can no longer be entered due to next struct not being set up yet', async () => {
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , tktPrice = await contract.tktPrice.call()
        , nums     = [1,2,3,4,5,6]
        , affID    = 0
    try {
      await contract.enterRaffle(nums, affID, {from: owner, value: tktPrice.toNumber()})
      assert.fail('Should not have been able to enter a raffle with no struct set up!')
    } catch (e) {
      // console.log('Error when attempting to enter a closed raffle: ', e)
      // Transaction reverts as expected!
    }
  })

  it(`Should set matches delay to ${tempDelay} seconds`, async () => {
    // Set matches delay to 30s -> check delay set correctly.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
    await contract.manuallySetMatchesDelayTime(tempDelay, {from: owner})
    const newDelay = await contract.matchesDelay.call()
    assert.equal(newDelay.toNumber(), tempDelay, 'New matches delay time not set!')
  })

  it('Make a non-manual Random.org api Oraclize query', async () => {
    // Craft non-manual Random.org query -> check it's qID strut is correct
    let qID
    const contract     = await etheraffle.deployed()
        , owner        = await contract.etheraffle.call()
        , week         = await contract.week.call()
        , delay        = 0
        , isRandom     = true
        , isManual     = false
        , status       = false
        , oracCall     = await contract.manuallyMakeOraclizeCall(week.toNumber(), delay, isRandom, isManual, status, {from: owner})
    await truffleAssert.eventEmitted(oracCall, 'LogQuerySent', ev => qID = ev.queryID)
    const struct = await contract.qID.call(qID)
        , paused = await contract.paused.call()
    assert.equal(struct[0], week.toNumber(), 'Query week number and struct week number do not agree!')
    assert.isTrue(struct[1], 'isRandom in struct for this query ID should be true!')
    assert.isFalse(struct[2], 'isManual in struct for this query ID should be false!')
    assert.isFalse(paused, 'Contract should not be paused!')
  })

  it('Should account for profit and costs in the prize pool', async () => {
    // Watch for prize pool modifcation event for calculated amount -> assert veracity
    const contract = await etheraffle.deployed()
        , conEvent = contract.LogPrizePoolModification({}, {fromBlock: 0, toBlock: 'latest'})
        , week     = await contract.getWeek()
        , struct   = await contract.raffle.call(week.toNumber() - 1)
        , take     = await contract.take.call() // ppt 
        , tktPrice = struct[0].toNumber()
        , entries  = struct[4].toNumber()
        , profit   = Math.trunc(((tktPrice * entries) * take.toNumber()) / 1000)
        , ev       = await waitForConditionalEvent(conEvent, profit)
    assert.equal(ev.args.amount.toNumber(), profit, 'Profit and costs have not been accounted for!')
  })

  it('Should disburse funds correctly', async () => {
    // Watch for fund disbursal event -> ensure details correct.
    const contract  = await etheraffle.deployed()
        , conEvent  = await contract.LogFundsDisbursed({}, {fromBlock: 0, toBlock: 'latest'})
        , week      = await contract.getWeek()
        , struct    = await contract.raffle.call(week.toNumber() - 1)
        , take      = await contract.take.call() // ppt 
        , tktPrice  = struct[0].toNumber()
        , entries   = struct[4].toNumber()
        , profit    = Math.trunc(((tktPrice * entries) * take.toNumber()) / 1000)
        , half      = Math.trunc(profit / 2)
        , ev        = await waitForEvent(conEvent)
    assert.equal(ev.args.amount.toNumber(), half, 'Disbursal event amount incorrect!')
  })

})

const createDelay = time =>
  new Promise(resolve => setTimeout(resolve, time))

const getAllEvents = _contract => // Where _contract = etheraffle.at(contract.address)
  new Promise((resolve, reject) => 
    _contract.allEvents({},{fromBlock:0, toBlock: 'latest'}).get((err, res) => 
      err ? reject(null) : resolve(res)))

const filterEvents = (_str, _contract) =>
    getAllEvents(_contract)
    .then(res => res.filter(({ event }) => event == _str))
    .catch(e => console.log('Error filtering events: ', e))

/* Payout Calculations from the smart contract re-written in JS */
const calcPayout = (_odds, _tktPrice, _take, _numWinners, _prizePool, _pctOfPool) => 
  oddsTotal(_odds, _tktPrice, _take, _numWinners) < splitsTotal(_prizePool, _pctOfPool, _numWinners) 
    ? oddsSingle(_odds, _tktPrice, _take) 
    : splitsSingle(_prizePool, _pctOfPool, _numWinners)

const oddsTotal = (_odds, _tktPrice, _take, _numWinners) => 
  oddsSingle(_odds, _tktPrice, _take) * _numWinners;

const splitsTotal = (_prizePool, _pctOfPool, _numWinners) =>
  splitsSingle(_prizePool, _pctOfPool, _numWinners) * _numWinners

const oddsSingle = (_odds, _tktPrice, _take) =>
  (_tktPrice * _odds * (1000 - _take)) / 1000

const splitsSingle = (_prizePool, _pctOfPool, _numWinners) =>
  (_prizePool * _pctOfPool) / (_numWinners * 1000)

const waitForEvent = _event => 
  new Promise((resolve, reject) => 
    _event.watch((err, res) =>
      err ? reject(err) : (resolve(res), _event.stopWatching())))

const waitForConditionalEvent = (_event, _amt) => 
  new Promise((resolve, reject) => 
    _event.watch((err, res) => {
      if (err) reject(err)
      if (res.args.amount.toNumber() == _amt) {
        resolve(res)
        _event.stopWatching()
      }
    })
  )
