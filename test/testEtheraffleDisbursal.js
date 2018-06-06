const { assert }    = require("chai")
// , web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , disbursal     = artifacts.require('etheraffleDisbursal')

contract('etheraffleDisbursal', accounts => {
  
  it('Contract should be owned by account[0]', async () => {
    const contract  = await disbursal.deployed()
        , contOwner = await contract.etheraffle.call()
    assert.equal(contOwner, accounts[0])
  })
  
})