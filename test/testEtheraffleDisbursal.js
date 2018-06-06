const { assert }    = require("chai")
    // , web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , receiver      = artifacts.require('etherReceiverStub')
    , disbursal     = artifacts.require('etheraffleDisbursal')

contract('etheraffleDisbursal', accounts => {
  
  it('Contract should be owned by account[0]', async () => {
    const contract  = await disbursal.deployed()
        , contOwner = await contract.etheraffle.call()
    assert.equal(contOwner, accounts[0])
  })

  it('Only owner can change owner', async () => {
    const contract = await disbursal.deployed()
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

  it('Only owner can upgrade', async () => {
    const contract = await disbursal.deployed()
        , stub     = await receiver.deployed()
        , owner    = await contract.etheraffle.call()
    try {
      await contract.upgrade(stub.address, {from: accounts[9]})
      assert.fail('Non-owner should not be able to upgade contract!')
    } catch (e) {
      // console.log('Error in non-owner upgrading: ', e)
      // Transaction failed as expected!
    }
    const upgrade = await contract.upgrade(stub.address, {from: owner})
    truffleAssert.eventEmitted(upgrade, 'LogUpgrade', ev => 
      ev.toWhere == stub.address && ev.amountTransferred.toNumber() == 0
    )
  })
  
})