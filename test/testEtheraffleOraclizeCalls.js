const { assert }    = require("chai")
    // , moment        = require('moment')
    , truffleAssert = require('truffle-assertions')
    , etheraffle    = artifacts.require('etheraffle')
    , random1       = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\", \"serialNumber\"]','\\n{\"jsonrpc\": \"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\""
    , random2       = "\",\"params\":{\"n\":\"6\",\"min\":1,\"max\":49,\"replacement\":false,\"base\":10,\"apiKey\":${[decrypt] BBxn5oQTs8LKRkJb32LS+dHf/c//H3sSjehJchlucpdFGEjBwtSu08okSPoSkoQQpPCW56kz7PoGm5VEc8r722oEg01AdB03CbURpSxU5cF9Q7MeyNAaDUcTOvlX1L2T/h/k4PUD6FEIvtynHZrSMisEF+r7WJxgiA==}}']"
    , api1          = "[URL] ['json(https://etheraffle.com/api/test).m','{\"r\":\""
    , api2          = "\",\"k\":${[decrypt] BEhjzZIYd3GIvFUu4rWqwYOFKucnwToOUpP3x/svZVz/Vo68c6yIiq8k6XQDmPLajzSTD/TrpR5cF4BnLLhNDtELy7hQyMmFTuUa3JXBs0G0f4d7cTeIX8IG37KxtNfcvUafJy25}}']"
    , fakeRandom1   = "[URL] ['json(https://etheraffle.com/api/test).m','{\"flag\":\"true\",\"r\":\""
    , fakeRandom2   = "\",\"k\":${[decrypt] BEhjzZIYd3GIvFUu4rWqwYOFKucnwToOUpP3x/svZVz/Vo68c6yIiq8k6XQDmPLajzSTD/TrpR5cF4BnLLhNDtELy7hQyMmFTuUa3JXBs0G0f4d7cTeIX8IG37KxtNfcvUafJy25}}']"
    
// Correct Orac callback time = struct timestamp + rafend

contract('Etheraffle Oraclize Tests Part I', accounts => {

  it('Contract should have prize pool of 1 ETH.', async () => {
    // Add 1 ETH to prize pool -> query prize pool -> assert that it's 1ETH.
    const contract  = await etheraffle.deployed()
        , amount    = 1*10**18
    await contract.manuallyAddToPrizePool({from: accounts[6], value: amount})
    const prizePool = await contract.prizePool.call()
    assert.equal(prizePool.toNumber(), amount, 'Prize pool is not 1 ETH!')
  })
  
  it('Owner can set Oraclize strings correctly.', async () => {
    // Get owner -> change strings as owner -> check they match.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
    await contract.manuallySetOraclizeString(random1, random2, api1, api2, {from: owner})
    const random1After = await contract.randomStr1.call()
        , random2After = await contract.randomStr2.call()
        , api1After    = await contract.apiStr1.call()
        , api2After    = await contract.apiStr2.call()
    assert.equal(random1, random1After, 'Random1 string was not set correctly!')
    assert.equal(random2, random2After, 'Random2 string was not set correctly!')
    assert.equal(api1, api1After, 'Api1 string was not set correctly!')
    assert.equal(api2, api2After, 'Api2 string was not set correctly!')
  })

  it('Non-owner cannot set Oraclize strings.', async () => {
    // Change string as non-owner -> Check tx fails -> Check strings weren't changed.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , r1       = 'Only'
        , r2       = 'owner'
        , a1       = 'can'
        , a2       = 'set'
        , caller   = accounts[5]
    assert.notEqual(owner, caller, 'Function caller is same address contract owner!')
    try {
      // await contract.manuallySetOraclizeString(r1, r2, a1, a2, {from: caller})
      assert.fail('Only contract owner should be able to set Oraclize strings!')
    } catch (e) {
      // console.log('Error when non-owner attempts to set Oraclize strings: ', e)
      // Transaction reverts as expected!
    }
    const r1After = await contract.randomStr1.call()
        , r2After = await contract.randomStr2.call()
        , a1After = await contract.apiStr1.call()
        , a2After = await contract.apiStr2.call()
    assert.notEqual(r1, r1After, 'Random1 string was changed and shouldn\'t have been!')
    assert.notEqual(r2, r2After, 'Random2 string was changed and shouldn\'t have been!')
    assert.notEqual(a1, a1After, 'Api1 string was changed and shouldn\'t have been!')
    assert.notEqual(a2, a2After, 'Api2 string was changed and shouldn\'t have been!')
  })

  it('Non-owner cannot make a manual Oraclize query.', async () => {
    // Craft query -> make query from non-owner account -> check it reverts.
    const contract  = await etheraffle.deployed()
        , owner     = await contract.etheraffle.call()
        , guineaPig = accounts[5]
        , week      = 1
        , delay     = 0
        , random    = false
        , manual    = true
        , status    = false
    assert.notEqual(owner, guineaPig, 'Guinea pig account is the same as owner!')
    try {
      await contract.manuallyMakeOraclizeCall(week, delay, random, manual, status, {from: guineaPig})
    } catch (e) {
      // console.log('Error when non-owner attempts to make Oraclize query: ', e)
      // Transaction reverts as expected!
    }
  })

  it('Owner can execute a Random.org api Oraclize query manually correctly.', async () => {
    // Craft query -> Ensure tx succeeded -> check query sent event is fired.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , week     = 5
        , delay    = 0
        , isRandom = true
        , isManual = true
        , status   = false
    try {
      const oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
      await truffleAssert.eventEmitted(oracCall, 'LogQuerySent')
    } catch (e) {
      assert.fail('Oraclize call should have succeeded!')
    }
  })

  it('Owner can execute a Etheraffle api Oraclize query manually correctly.', async () => {
    // Craft query -> Ensure tx succeeded -> check query sent event is fired.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , week     = 5
        , delay    = 0
        , isRandom = false
        , isManual = true
        , status   = false
    try {
      const oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
      await createDelay(20000) // Need this to allow the bridge to call back so it doesn't crash!
      await truffleAssert.eventEmitted(oracCall, 'LogQuerySent')
    } catch (e) {
      assert.fail('Oraclize call should have succeeded!')
    }
  })
})

contract('Etheraffle Oraclize Tests Part II', accounts => {

  it('Contract should setup correctly.', async () => {
    // Add 1 ETH to prize pool -> query prize pool -> assert that it's 1ETH.
    const contract  = await etheraffle.deployed()
        , amount    = 1*10**18
        , owner     = await contract.etheraffle.call()
    await contract.manuallyAddToPrizePool({from: accounts[6], value: amount})
    const prizePool = await contract.prizePool.call()
    assert.equal(prizePool.toNumber(), amount, 'Prize pool is not 1 ETH!')
    await contract.manuallySetOraclizeString(random1, random2, api1, api2, {from: owner})
    const random1After = await contract.randomStr1.call()
        , random2After = await contract.randomStr2.call()
        , api1After    = await contract.apiStr1.call()
        , api2After    = await contract.apiStr2.call()
    assert.equal(random1, random1After, 'Random1 string was not set correctly!')
    assert.equal(random2, random2After, 'Random2 string was not set correctly!')
    assert.equal(api1, api1After, 'Api1 string was not set correctly!')
    assert.equal(api2, api2After, 'Api2 string was not set correctly!')
  })

  // Need to use fresh contract so there are no prior Oraclize Callbacks
  it('Oraclize callback function not executed when contract is paused.', async () => {
    // Pause contract -> craft & send query -> check the callback didn't fire an event -> unpause contract.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , week     = 5
        , delay    = 0
        , isRandom = true
        , isManual = true
        , status   = true // Otherwise the orac call unpauses the contract!
    await contract.manuallySetPaused(true)
    let paused = await contract.paused.call()
    assert.isTrue(paused, 'Contract is not paused!')
    const oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
    await truffleAssert.eventEmitted(oracCall, 'LogQuerySent', null, 'Query sent event should have fired!')
    await createDelay(20000) // Give time for Oraclize callback to occur...
    // const oracEvent = await getOraclizeCallback(etheraffle.at(contract.address), week)(
    const oracEvent = await filterEvents('LogOraclizeCallback', etheraffle.at(contract.address))
    assert.equal(oracEvent.length, 0, 'An Oraclize callback event should not have been emitted!')
    await contract.manuallySetPaused(false)
    paused = await contract.paused.call()
    assert.isFalse(paused, 'Contract is paused!')
  })

  it('Random.org api Oraclize query sets up QID correctly.', async () => {
    // Craft query -> check query sent event fired -> check struct is set correctly.
    let qID
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , week     = 5
        , delay    = 0
        , isRandom = true
        , isManual = true
        , status   = false
        , oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
    await truffleAssert.eventEmitted(oracCall, 'LogQuerySent', ev => qID = ev.queryID)
    it('Random.org Oraclize query sets up QID struct correctly.', async () => {
      const struct      = await contract.qID.call(qID)
          , statusAfter = await contract.paused.call()
      assert.equal(status, statusAfter, 'Contract paused status was changed and shouldn\'t have been!')
      assert.equal(struct[0].toNumber(), week, 'QID Struct week number doesn\'t match week number sent in query!')
      assert.isTrue(struct[1], 'isRandom in struct should be true!')
      assert.isTrue(struct[2], 'isManual in struct should be true!')
    })
  })

  it('Etheraffle api Oraclize query sets up QID correctly.', async () => {
    // Craft query -> check query sent event fired -> check struct is set correctly.
    let qID
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , week     = 5
        , delay    = 0
        , isRandom = false
        , isManual = true
        , status   = false
        , oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
    await truffleAssert.eventEmitted(oracCall, 'LogQuerySent', ev => qID = ev.queryID, 'Query sent event should have fired!')
    const struct      = await contract.qID.call(qID)
        , statusAfter = await contract.paused.call()
    assert.equal(status, statusAfter, 'Contract paused status was changed and shouldn\'t have been!')
    assert.equal(struct[0].toNumber(), week, 'QID Struct week number doesn\'t match week number sent in query!')
    assert.isFalse(struct[1], 'isRandom in struct should be false!')
    assert.isTrue(struct[2], 'isManual in struct should be true!')
  })
})

// contract('Etheraffle Oraclize Tests Part III', accounts => {

//   it('Contract should setup correctly.', async () => {
//     // Add 1 ETH to prize pool -> query prize pool -> assert that it's 1ETH.
//     const contract  = await etheraffle.deployed()
//         , amount    = 1*10**18
//         , owner     = await contract.etheraffle.call()
//     await contract.manuallyAddToPrizePool({from: accounts[6], value: amount})
//     const prizePool = await contract.prizePool.call()
//     assert.equal(prizePool.toNumber(), amount, 'Prize pool is not 1 ETH!')
//     await contract.manuallySetOraclizeString(random1, random2, api1, api2, {from: owner})
//     const random1After = await contract.randomStr1.call()
//         , random2After = await contract.randomStr2.call()
//         , api1After    = await contract.apiStr1.call()
//         , api2After    = await contract.apiStr2.call()
//     assert.equal(random1, random1After, 'Random1 string was not set correctly!')
//     assert.equal(random2, random2After, 'Random2 string was not set correctly!')
//     assert.equal(api1, api1After, 'Api1 string was not set correctly!')
//     assert.equal(api2, api2After, 'Api2 string was not set correctly!')
//   })

//   it('Manual Random.org api Oraclize queries should not recursively create another query.', async () => {
//     // Craft manual Random query -> check it emits correct event -> wait 20 seconds and check a second query isn't created.
//     const contract = await etheraffle.deployed()
//         , owner    = await contract.etheraffle.call()
//         , week     = 5
//         , delay    = 0
//         , isRandom = true
//         , isManual = true
//         , status   = false
//         , oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
//     await truffleAssert.eventEmitted(oracCall, 'LogQuerySent', ev => qID = ev.queryID)
//     await createDelay(20000)
//     const queryEvents = await getQueryEvents(etheraffle.at(contract.address), week)
//     assert.equal(queryEvents.length, 1, 'A second Oraclize query should not have been sent!')
//   })

//   it('Should result in one Oraclize callback event.', async () => {
//     // Get events from Oraclize cbs -> check only one fired -> check its params -> check its QID struct.
//     await createDelay(20000)
//     const contract = await etheraffle.deployed()
//         , week     = 5
//         , oracCBs  = await filterEvents('LogOraclizeCallback', etheraffle.at(contract.address))
//         , { args } = oracCBs[0]
//     assert.equal(oracCBs.length, 1, 'More than one Oraclize callback was received!')
//     assert.equal(args.forRaffle.toNumber(), week, 'Oraclize callback was for the wrong week!')
//     assert.equal(JSON.parse(args.result).length, 2, 'Random.org results array length not correct!')
//     assert.equal(JSON.parse(args.result)[0].length, 6, 'Random.org random numbers array length not correct!')
//     const struct = await contract.qID.call(args.queryID)
//     assert.equal(struct[0], week, 'Query week number and struct week number do not agree!')
//     assert.isTrue(struct[1], 'isRandom in struct for this query ID should be true!')
//     assert.isTrue(struct[2], 'isManaul in struct for this query ID should be true!')
//   })

//   it('Should result in one LogWinningNumbers event.', async () => {
//     // Get events for win nums -> check only one event -> check its params.
//     await createDelay(20000)
//     const contract  = await etheraffle.deployed()
//         , week      = 5
//         , struct    = await contract.raffle.call(week)
//         , entries   = struct[4].toNumber()
//         , winNums   = await filterEvents('LogWinningNumbers', etheraffle.at(contract.address))
//         , prizePool = await contract.prizePool.call()
//         , { args }  = winNums[0]
//     assert.equal(winNums.length, 1, 'More than one winning numbers event was fired!')
//     assert.equal(args.wNumbers.length, 6, 'An incorrect amount of winning numbers were logged!')
//     assert.equal(args.forRaffle.toNumber(), week, 'Winning numbers event was for the wrong week!')
//     assert.equal(args.numberOfEntries.toNumber(), entries, 'Number of entries was incorrectly logged in winning numbers event!')
//     assert.equal(args.currentPrizePool.toNumber(), prizePool, 'Prize pool wasnt incorrectly logged in winning numbers event!')
//   })

//   it('Should result in one disbursal event.', async () => {
//     // Get disbursal events -> check only one event -> check its params.
//     await createDelay(20000)
//     const contract = await etheraffle.deployed()
//         , week     = 5
//         , gasAmt   = await contract.gasAmt.call()
//         , gasPrc   = await contract.gasPrc.call()
//         , oracCost = await contract.oracCost.call()
//         , oracTot  = ((gasAmt.toNumber() * gasPrc.toNumber()) + oracCost.toNumber()) * 2
//         , struct   = await contract.raffle.call(week)
//         , entries  = struct[4].toNumber()
//         , disb     = await filterEvents('LogFundsDisbursed', etheraffle.at(contract.address))
//         , { args } = disb[0]
//     assert.equal(entries, 0, 'There should have been no entries into this raffle!')
//     assert.equal(disb.length, 1, 'More than one disbursal event was fired!')
//     assert.equal(args.oraclizeTotal, oracTot, 'Oraclize total was calculated incorrectly!')
//     assert.equal(args.amount, 0, 'Amount disbursed should be zero!')
//   })

//   it('Contract should not be paused after manual Random.org callback', async () => {
//     // Check contract paused var -> assert that it's false.
//     const contract = await etheraffle.deployed()
//         , paused   = await contract.paused.call()
//     assert.isFalse(paused, 'Contract should not be paused!')
//   })

// })

// contract('Etheraffle Oraclize Tests Part IV', accounts => {

//   it('Contract should setup correctly', async () => {
//     // Add 1 ETH to prize pool -> query prize pool -> assert that it's 1ETH.
//     const contract  = await etheraffle.deployed()
//         , amount    = 1*10**18
//         , owner     = await contract.etheraffle.call()
//     await contract.manuallyAddToPrizePool({from: accounts[6], value: amount})
//     const prizePool = await contract.prizePool.call()
//     assert.equal(prizePool.toNumber(), amount, 'Prize pool is not 1 ETH!')
//     await contract.manuallySetOraclizeString(random1, random2, api1, api2, {from: owner})
//     const random1After = await contract.randomStr1.call()
//         , random2After = await contract.randomStr2.call()
//         , api1After    = await contract.apiStr1.call()
//         , api2After    = await contract.apiStr2.call()
//     assert.equal(random1, random1After, 'Random1 string was not set correctly!')
//     assert.equal(random2, random2After, 'Random2 string was not set correctly!')
//     assert.equal(api1, api1After, 'Api1 string was not set correctly!')
//     assert.equal(api2, api2After, 'Api2 string was not set correctly!')
//   })
 
//   it('Manual Etheraffle api Oraclize queries should not recursively create another query.', async () => {
//     // Craft manual ER query -> check it emits correct event -> wait 20 seconds and check a second query isn't created
//     const contract = await etheraffle.deployed()
//         , owner    = await contract.etheraffle.call()
//         , week     = 5
//         , delay    = 0
//         , isRandom = false
//         , isManual = true
//         , status   = false
//         , oracCall = await contract.manuallyMakeOraclizeCall(week, delay, isRandom, isManual, status, {from: owner})
//     await truffleAssert.eventEmitted(oracCall, 'LogQuerySent', ev => qID = ev.queryID)
//     await createDelay(20000)
//     const queryEvents = await getQueryEvents(etheraffle.at(contract.address), week)
//     assert.equal(queryEvents.length, 1, 'A second Oraclize query should not have been sent!')
//   })

// })

const createDelay = time =>
  new Promise(resolve => setTimeout(resolve, time))

//_contract = etheraffle.at(contract.address)
const getAllEvents = _contract => 
  new Promise((resolve, reject) => 
    _contract.allEvents({},{fromBlock:0, toBlock: 'latest'}).get((err, res) => 
      err ? reject(null) : resolve(res)))

const filterEvents = (_str, _contract) =>
    getAllEvents(_contract)
    .then(res => res.filter(({ event }) => event == _str))
    .catch(e => console.log(e))

const getOraclizeCallback = (_contract, _week) => 
  new Promise((resolve, reject) => 
    _contract.LogOraclizeCallback({forRaffle: _week},{fromBlock: 0, toBlock: "latest"}).get((err,res) =>
      err ? reject(null) : resolve(res)))

const getQueryEvents = (_contract, _week) => 
  new Promise((resolve, reject) => 
    _contract.LogQuerySent({forRaffle: _week},{fromBlock: 0, toBlock: "latest"}).get((err, res) =>
      err ? reject(null) : resolve(res)))

const getReclaimEvents = (_contract, _week) => 
  new Promise((resolve, reject) => 
    _contract.LogReclaim({forRaffle: _week},{fromBlock: 0, toBlock: "latest"}).get((err, res) =>
      err ? reject(null) : resolve(res)))

const getFundsDisbursedEvents = (_contract, _week) => 
  new Promise((resolve, reject) => 
    _contract.LogFundsDisbursed({forRaffle: _week},{fromBlock: 0, toBlock: "latest"}).get((err, res) =>
      err ? reject(null) : resolve(res)))

const getFundsWinNumsEvents = (_contract, _week) => 
  new Promise((resolve, reject) => 
    _contract.LogWinningNumbers({forRaffle: _week},{fromBlock: 0, toBlock: "latest"}).get((err, res) =>
      err ? reject(null) : resolve(res)))
     
/*
  Check contract status is changed per an oraclize query
  
  enter x number of times and do the maths to calc the prizes correctly
  check events fired by orac cbs to make sure timings are correct for the recursion
  check manual ones don't cause recursion
  check non manual ones DO cause recursion
  make api have a true/false flag? change the string to make random calls for real, vs "random" from api? Check flag exists first, since it won't for the real api one!

    await createDelay(20000) // Give time for Oraclize callback to occur...
    const oracEvent = await getOraclizeCallback(etheraffle.at(contract.address), week)
    assert.equal(oracEvent.length, 1, 'More than one Oraclize callback event occurred!')
    console.log('oracEvents: ', oracEvent)
    oracEvent.map(({event, args: {queryID, result, forRaffle}}) => {
      assert.equal(event, 'LogOraclizeCallback', 'Wrong event was retrieved!')
      assert.equal(queryID, qID, 'Callback was for wrong QID!')
      assert.equal(JSON.parse(result)[0].length, 6, 'Wrong number of random numbers retrieved!')
      assert.equal(forRaffle.toNumber(), week, 'Callback was for wrong raffle number!')
    })  
    // can test for all the correct event fires too from the randomCallback function etc.
  

  Events emitted during test:
  ---------------------------

  LogQuerySent(queryID: 0xb6d9e12e63c4098a55e05fa6437a6e28078f9ea34940e4f466705c9ed60b528a, dueAt: 0, sendTime: 1529178710)
  LogOraclizeCallback(functionCaller: 0x5aeda56215b167893e80b4fe645ba6d5bab767de, queryID: 0x396f7f998bfc1a43748e886f2992cf4e29722b785ec704612c18f951272685b7, result: [[31, 32, 39, 27, 35, 21], 391], forRaffle: <indexed>, atTime: 1529178731)
  LogFundsDisbursed(forRaffle: <indexed>, oraclizeTotal: 23000000000000000, amount: 0, toAddress: <indexed>, atTime: 1529178731)    LogWinningNumbers(forRaffle: <indexed>, numberOfEntries: 0, wNumbers: 31,32,39,27,35,21, currentPrizePool: 977000000000000000, randomSerialNo: 391, atTime: 1529178731)    LogOraclizeCallback(functionCaller: 0x5aeda56215b167893e80b4fe645ba6d5bab767de, queryID: 0xff4252f307a6baf4775936efd1ff0211a1bcd650f1d1cfcd2332c29b597fff8c, result: [1, 0, 0, 0], forRaffle: <indexed>, atTime: 1529178733)    LogFunctionsPaused(identifier: 4, atTime: 1529178733)
  LogPrizePoolsUpdated(newMainPrizePool: 977000000000000000, forRaffle: <indexed>, ticketPrice: 0, unclaimedPrizePool: 0, winningAmounts: 0,0,0,0, atTime: 1529178733)
*/