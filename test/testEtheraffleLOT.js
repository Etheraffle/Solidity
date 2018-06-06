const { assert }    = require("chai")
// const web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , LOT           = artifacts.require('etheraffleLOT')

// TODO: Write a module to check specifically for reverts in the try/catch catches.

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
  
  console.log('## Owner Abilities ##')
  
  it('Only owner can add & remove freezers', async () => {
    const contract = await LOT.deployed()
    await contract.addFreezer(accounts[1])
    let freezerCheck = await contract.canFreeze.call(accounts[1])
    assert.equal(freezerCheck, true)
    await contract.removeFreezer(accounts[1])
    freezerCheck = await contract.canFreeze.call(accounts[1])
    assert.equal(freezerCheck, false)
    try {
      await contract.addFreezer(accounts[9], {from: accounts[9]})
      assert.fail('Non-owner should not be able to add a freezer!')
    } catch (e) {
      // console.log('Error in non-owner trying to add freezer: ', e)
    }
    try {
      await contract.removeFreezer(accounts[0], {from: accounts[9]})
      assert.fail('Non-owner should not be able to remove a freezer!')
    } catch (e) {
      // console.log('Error in non-owner trying to remove freezer: ', e)
      // Transaction failed as expected!
    }
  })

  it('Only owner can change owner', async () => {
    const contract = await LOT.deployed()
    await contract.setEtheraffle(accounts[1])
    let owner = await contract.etheraffle.call()
    assert.equal(owner, accounts[1])
    try {
      await contract.setEtheraffle(accounts[0])
      assert.fail('Non-owner should not be able to change owner!')
    } catch (e) {
      // console.log('Error in non-owner changing ownership: ', e)
      // Transaction failed as expected!
    }
    await contract.setEtheraffle(accounts[0], {from: accounts[1]})
    owner = await contract.etheraffle.call()
    assert.equal(owner, accounts[0])
  })

  // console.log('## Token Transfers ##')
  
  // console.log('## Freeze Ability ##')

})