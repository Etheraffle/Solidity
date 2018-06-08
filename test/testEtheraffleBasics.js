const { assert }    = require("chai")
    , moment        = require('moment')
    , truffleAssert = require('truffle-assertions')
    , ethRelief     = artifacts.require('ethRelief')
    , etheraffle    = artifacts.require('etheraffle')
    , disbursal     = artifacts.require('etheraffleDisbursal')

// Run ethereum-bridge for oraclize w/ node bridge -a 9 -H 127.0.0.1 -p 9545 --dev

contract('Etheraffle', accounts => {
  // Correct setup checks
  it('Contract should be owned by account[0]', async () => {
    const contract  = await etheraffle.deployed()
        , contOwner = await contract.etheraffle.call()
    assert.equal(contOwner, accounts[0])
  })

  it('Disbursal address should be set correctly', async () => {
    const contract = await etheraffle.deployed()
        , disb     = await disbursal.deployed()
        , disbAddr = await contract.disburseAddr.call()
    assert.equal(disbAddr, disb.address)
  })

  it('EthRelief address should be set correctly', async () => {
    const contract = await etheraffle.deployed()
        , ethRel   = await ethRelief.deployed()
        , addr     = await contract.ethRelief.call()
    assert.equal(addr, ethRel.address)
  })
  
  it('Contract should balance of 0.1 ETH', async () => {
    const contract = await etheraffle.deployed()
        , balance  = etheraffle.web3.eth.getBalance(contract.address)
    assert.equal(balance.toNumber(), 1*10**17)
  })

  it('Contract should calculate current week correctly', async () => {
    const contract = await etheraffle.deployed()
        , curWeek  = await contract.getWeek.call()
    assert.equal(curWeek.toNumber(), getWeek())
  })

  it('Anyone should be able to add to prize pool', async () => {
    const contract = await etheraffle.deployed()
        , random   = getRandom(accounts.length - 1)
        , value    = 1*10**18
        , tx       = await contract.manuallyAddToPrizePool({from: accounts[random], value: value})
    truffleAssert.eventEmitted(tx, 'LogPrizePoolAddition', ev => 
      ev.fromWhom == accounts[random] && ev.howMuch.toNumber() == value
    )
  })

  it('Contract should now have prize pool of 1 ETH', async () => {
    const contract  = await etheraffle.deployed()
        , prizePool = await contract.prizePool.call()
    assert.equal(prizePool.toNumber(), 1*10**18)
  })

  it('First raffle struct should be set up correctly' , async () => {
    const contract = await etheraffle.deployed()
        , struct   = await contract.raffle.call(getWeek())
        , tktPrice = await contract.tktPrice.call()
    assert.equal(struct[0].toNumber(), tktPrice.toNumber()) // Ticket Price
    assert.equal(struct[1].toNumber(), 0) // Unclaimed amt
    assert.equal(struct[2].toNumber(), getTimestamp()) // Mon timestamp of raffle
    assert.equal(struct[3], false) // Withdraw not open 
    assert.equal(struct[4].toNumber(), 0) // No entries yet
    assert.equal(struct[5].toNumber(), 0) // No free entries yet
  })

  it('Check all initialised variables' , async () => {
    const contract = await etheraffle.deployed()
        , take     = await contract.take.call()
        , gasAmt   = await contract.gasAmt.call()
        , rafEnd   = await contract.rafEnd.call()
        , gasPrc   = await contract.gasPrc.call()
        , paused   = await contract.paused.call()
        , wdrawBfr = await contract.wdrawBfr.call()
        , upgraded = await contract.upgraded.call()
        , tktPrice = await contract.tktPrice.call()
        , oracCost = await contract.oracCost.call()
        , upAddr   = await contract.upgradeAddr.call()
        , resDel   = await contract.resultsDelay.call()
        , matDel   = await contract.matchesDelay.call()
    assert.equal(paused, false)
    assert.equal(upgraded, false)
    assert.equal(take.toNumber(), 150)
    assert.equal(resDel.toNumber(), 3600)
    assert.equal(matDel.toNumber(), 3600)
    assert.equal(gasAmt.toNumber(), 500000)
    assert.equal(rafEnd.toNumber(), 500400)
    assert.equal(wdrawBfr.toNumber(), 6048000)
    assert.equal(gasPrc.toNumber(), 20000000000)
    assert.equal(tktPrice.toNumber(), 2500000000000000)
    assert.equal(oracCost.toNumber(), 1500000000000000)
    assert.equal(upAddr, '0x0000000000000000000000000000000000000000')
  })
  // uint[]  public pctOfPool    = [520, 114, 47, 319]; // ppt...
  // uint[]  public odds         = [56, 1032, 54200, 13983816]; // Rounded down to nearest whole 
})

const rafEnd   = 500400
    , weekDur  = 604800
    , birthday = 1500249600

const pastClosing = _curWeek => 
  moment.utc().format('X') - ((_curWeek * weekDur) + birthday) > rafEnd

const getCurWeek = _ => 
  Math.trunc((moment.utc().format('X') - birthday) / weekDur)

const getWeek = _ =>
  pastClosing(getCurWeek()) ? getCurWeek() + 1 : getCurWeek()

const getTimestamp = _ => 
  (getWeek() * weekDur) + birthday

const getRandom = ceiling => 
  Math.floor(Math.random() * ceiling) + 1
