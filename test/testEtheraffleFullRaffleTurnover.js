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
