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

})

const rafEnd   = 500400
    , weekDur  = 604800
    , birthday = 1500249600

const pastClosing = _curWeek => 
  moment.utc().format('X') - ((_curWeek * weekDur) + birthday) > rafEnd

const getCurWeek = () => 
  Math.trunc((moment.utc().format('X') - birthday) / weekDur)

const getWeek = () =>
  pastClosing(getCurWeek()) ? getCurWeek() + 1 : getCurWeek()

const getRandom = ceiling => 
  Math.floor(Math.random() * ceiling) + 1
