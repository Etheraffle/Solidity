const { assert }    = require("chai")
    , truffleAssert = require('truffle-assertions')
    , receiver      = artifacts.require('etherReceiverStub')
    , disbursal     = artifacts.require('etheraffleDisbursal')

contract('Etheraffle Disbursal Tests', accounts => {
  
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

  it('Fallback function should accept ETH', async () => {
    const contract = await disbursal.deployed()
    let balance    = await disbursal.web3.eth.getBalance(contract.address)
    assert.equal(balance.toNumber(), 0)
    await disbursal.web3.eth.sendTransaction({to: contract.address, from: accounts[5], value: 10})
    balance = await disbursal.web3.eth.getBalance(contract.address)
    assert.equal(balance.toNumber(), 10)
  })

  if('Can\'t scuttle contract before it\'s been upgraded', async () => {
    const contract = await disbursal.deployed()
        , stub     = await receiver.deployed()
        , owner    = await contract.etheraffle.call()
    let upgraded   = await contract.upgraded.call()
    assert.equal(upgraded, false)
    try {
      await contract.selfDestruct(owner)
      assert.fail('Contract should not be able to be scuttled without upgrading first!')
    } catch (e) {
      // console.log('Error when attempted to scuttle before upgrading: ', e)
      // Transaction failed as expected!
    }
  })

  it('Contract has ETH in prior to upgrade', async () => {
    const contract = await disbursal.deployed()
    let balance    = await disbursal.web3.eth.getBalance(contract.address)
    assert.equal(balance.toNumber(), 10) // From prior fallback test...
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
      ev.toWhere == stub.address && ev.amountTransferred.toNumber() == 10
    )
  })

  it('This contract\'s balance moved entirely to upgrade contract', async () => {
    const contract = await disbursal.deployed()
        , stub     = await receiver.deployed()
    let balance    = await disbursal.web3.eth.getBalance(contract.address)
    assert.equal(balance.toNumber(), 0)
    balance        = await disbursal.web3.eth.getBalance(stub.address)
    assert.equal(balance.toNumber(), 10)
  })

  it('Only owner can scuttle contract once it\'s been upgraded', async () => {
    const contract = await disbursal.deployed()
        , owner    = await contract.etheraffle.call()
        , upgraded = await contract.upgraded.call()
    assert.isTrue(upgraded, 'Upgraded var returned false!')
    try {
      await contract.selfDestruct(accounts[4], {from: accounts[4]})
      assert.fail('Only owner can scuttle after contract upgrade!')
    } catch (e) {
      // console.log('Error when non-owner attempts to scuttle before upgrading: ', e)
      // Transaction failed as expected!
    }
    await contract.selfDestruct(owner, {from: owner})
  })

})