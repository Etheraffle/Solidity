const { assert }    = require("chai")
    , moment        = require('moment')
    , utils         = require('./utils')
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

})