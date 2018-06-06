const { assert }    = require("chai")
// const web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , LOT           = artifacts.require('etheraffleLOT')

contract('etheraffleLOT', accounts => {

  
  it('Contract should be owned by account[0]', async () => {
    console.log('## Initial Contract Setup ##')
    const contract  = await LOT.deployed()
        , contOwner = await contract.etheraffle.call()
    assert.equal(contOwner, accounts[0])
  })

  it('Total supply should equal initial minting of 100000000', async () => {
    const contract  = await LOT.deployed()
        , totSupply = await contract.totalSupply()
    assert.equal(totSupply.toNumber(), 100000000)
  })

  it('Owner\'s balance should equal total supply of 100000000', async () => {
    const contract = await LOT.deployed()
        , owner    = await contract.etheraffle.call()
        , balance  = await contract.balanceOf(owner)
    assert.equal(balance.toNumber(), 100000000)
  })

  it('Owner should be a freezer', async () => {
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , isFreezer = await contract.canFreeze(owner)
    assert.equal(isFreezer, true)
  })

})