const { assert }    = require("chai")
    , web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , FreeLOT       = artifacts.require('etheraffleFreeLOT')

contract('etheraffleFreeLOT', accounts => {
  
  it('Contract should be owned by account[0]', async () => {
    const contract  = await FreeLOT.deployed()
        , contOwner = await contract.etheraffle.call()
    assert.equal(contOwner, accounts[0])
  })

  it('Total supply should equal initial minting of 100', async () => {
    const contract  = await FreeLOT.deployed()
        , totSupply = await contract.totalSupply()
    assert.equal(totSupply, 100)
  })

  it('Owner\'s initial balance should be 100', async () => {
    const contract = await FreeLOT.deployed()
        , balance  = await contract.balanceOf.call(accounts[0])
    assert.equal(balance, 100)
  })

  it('Owner should be a minter & destroyer', async () => {
    const contract = await FreeLOT.deployed()
        , isMinter = await contract.isMinter.call(accounts[0])
        , isDestroyer = await contract.isDestroyer.call(accounts[0])
    assert.equal(isMinter, true)
    assert.equal(isDestroyer, true)
  })

  it('Owner can add & remove a minter', async () => {
    const contract      = await FreeLOT.deployed()
        , checkIfMinter = await contract.isMinter.call(accounts[5])
    assert.equal(checkIfMinter, false)
    const addMinter     = await contract.addMinter(accounts[5])
        , isNowMinter   = await contract.isMinter.call(accounts[5])
    assert.equal(isNowMinter, true)
    const rmMinter      = await contract.removeMinter(accounts[5])
        , isMinter      = await contract.isMinter.call(accounts[5])
    assert.equal(isMinter, false)
    truffleAssert.eventEmitted(addMinter, 'LogMinterAddition')
    truffleAssert.eventEmitted(rmMinter, 'LogMinterRemoval')
  })

  it('Owner can add & remove a destroyer', async () => {
    const contract         = await FreeLOT.deployed()
        , checkIfDestroyer = await contract.isDestroyer.call(accounts[5])
    assert.equal(checkIfDestroyer, false)
    const addDestroyer     = await contract.addDestroyer(accounts[5])
        , isNowDestroyer   = await contract.isDestroyer.call(accounts[5])
    assert.equal(isNowDestroyer, true)
    const rmDestroyer      = await contract.removeDestroyer(accounts[5])
        , isDestroyer      = await contract.isDestroyer.call(accounts[5])
    assert.equal(isDestroyer, false)
    truffleAssert.eventEmitted(addDestroyer, 'LogDestroyerAddition')
    truffleAssert.eventEmitted(rmDestroyer, 'LogDestroyerRemoval')
  })

  it('Minters can mint tokens', async () => {
    const contract = await FreeLOT.deployed()
        , isMinter = await contract.isMinter(accounts[0])
    assert.equal(isMinter, true)
        , mint     = await contract.mint(accounts[1], 100)
        , balance  = await contract.balanceOf.call(accounts[1])
    assert.equal(balance, 100)
    truffleAssert.eventEmitted(mint, 'LogMinting')
  })

  it('Destroyers can destroy tokens', async () => {
    const contract = await FreeLOT.deployed()
        , isDestroyer = await contract.isDestroyer(accounts[0])
    assert.equal(isDestroyer, true)
        , destroy  = await contract.destroy(accounts[1], 50)
        , balance  = await contract.balanceOf.call(accounts[1])
    assert.equal(balance, 50)
    truffleAssert.eventEmitted(destroy, 'LogDestruction')
  })
  
  it('Non-minters can\'t mint tokens', async () => {
    const contract = await FreeLOT.deployed()
    try {
      const isMinter = await contract.isMinter(accounts[6])
      assert.equal(isMinter, false)
      await contract.mint(accounts[6], 100, {from: accounts[6]})
      assert.fail('Non-minter should not be able to mint!')
    } catch(e) {
      // console.log('Error in can\'t mint try/catch: ', e)
      // Transaction failed as expected!
    }
  })

  it('Non-destroyers can\'t destroy tokens', async () => {
    const contract = await FreeLOT.deployed()
    try {
      const isDestroyer = await contract.isDestroyer(accounts[6])
      assert.equal(isDestroyer, false)
      await contract.destroy(accounts[0], 1, {from: accounts[6]})
      assert.fail('Non-destroyer should not be able to destroy!')
    } catch(e) {
      // console.log('Error in can\'t destroy try/catch: ', e)
      // Transaction failed as expected!
    }
  })
  
  it('Destroyers can\'t destroy more tokens than an account owns', async () => {
    const contract = await FreeLOT.deployed()
    try { 
      await contract.destroy(accounts[9], 1)
      assert.fail('Should not be able to destroy more tokens than account owns!')
    } catch(e) {
      // console.log('Error in try catch: ', e)
      // Transaction failed as expected!
    }
  })

  it('Non-owner can\'t add new minters', async () => {
    const contract = await FreeLOT.deployed()
    try { 
      await contract.addMinter(accounts[1], {from: accounts[1]})
      assert.fail('Non-owner should not be able to add new minters!')
    } catch(e) {
      // console.log('Error in try catch: ', e)
      // Transaction failed as expected!
    }
  })

  it('Non-owner can\'t add new destroyers', async () => {
    const contract = await FreeLOT.deployed()
    try { 
      await contract.addDestroyer(accounts[1], {from: accounts[1]})
      assert.fail('Non-owner should not be able to add new destroyers!')
    } catch(e) {
      // console.log('Error in try catch: ', e)
      // Transaction failed as expected!
    }
  })

  it('Non-owner can\'t remove minters', async () => {
    const contract = await FreeLOT.deployed()
    try { 
      await contract.removeMinter(accounts[0], {from: accounts[9]})
      assert.fail('Non-owner should not be able to remove minters!')
    } catch(e) {
      // console.log('Error in try catch: ', e)
      // Transaction failed as expected!
    }
  })

  it('Non-owner can\'t remove destroyers', async () => {
    const contract = await FreeLOT.deployed()
    try { 
      await contract.removeDestroyer(accounts[0], {from: accounts[9]})
      assert.fail('Non-owner should not be able to remove destroyers!')
    } catch(e) {
      // console.log('Error in try catch: ', e)
      // Transaction failed as expected!
    }
  })

  /* Following two tests have to use overloaded version of tx func because it's first in the contract. Pulled it out to here so both have access to it from their respective closures. */
  const txAbi = {
    "constant": false,
    "inputs": [
        {"name": "_to",
        "type": "address"},
        {"name": "_value",
        "type": "uint256"},
        {"name": "_data",
        "type": "bytes"}],
    "name": "transfer",
    "outputs": [
        {"name": "",
        "type": "bool"}
    ],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
  
  it('Account can transfer tokens if sufficient balance', async () => {
    const contract = await FreeLOT.deployed()
    const data = web3Abi.encodeFunctionCall(txAbi, [accounts[8], 10, '0x00'])
    await FreeLOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, data: data, value: 0})
    const balance  = await contract.balanceOf(accounts[8])
    assert.equal(balance.toNumber(), 10)
  })

  it('Account can\'t transfer tokens if insufficient balance', async () => {
    const contract = await FreeLOT.deployed()
    const data = web3Abi.encodeFunctionCall(txAbi, [accounts[0], 11, '0x00'])
    try {
      await FreeLOT.web3.eth.sendTransaction({from: accounts[8], to: contract.address, data: data, value: 0})
      assert.fail('Should not have been able to send tokens!')
    } catch (e) {
      // console.log('Error when sending more tokens than balance: ', e)
      // Transaction failed as expected!
    }
  })

  it('Only owner can change owner', async () => {
    const contract    = await FreeLOT.deployed()
        , changeOwner = await contract.setEtheraffle(accounts[1])
    truffleAssert.eventEmitted(changeOwner, 'LogEtheraffleChange')
    try {
      await contract.setEtheraffle(accounts[9], {from: accounts[9]})
      assert.fail('Attempt to change contract owner should have failed!')
    } catch (e) {
      // console.log('Error when non-owner attempts to change owner: ', e)
      // Transaction failed as expected!
    }
  })

  it('Fallback function should revert', async () => {
    const contract = await FreeLOT.deployed()
    try {
      await FreeLOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, value: 1})
    } catch (e) {
      // console.log('Error when checking if fallback reverts: ', e)
      // Transaction failed as expected!
    }
  })

  it('Only owner can scuttle the contract', async () => {
    const contract = await FreeLOT.deployed()
    try {
      await contract.selfDestruct({from: accounts[4]})
      assert.fail('Only owner should be able to destroy contract!')
    } catch (e) {
      // console.log('Error attempting to destroy contract: ', e)
    }
    const owner = await contract.etheraffle.call()
    await contract.selfDestruct({from: owner})
  })
})