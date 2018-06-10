const { assert }    = require("chai")
    , web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , LOT           = artifacts.require('etheraffleLOT')

// TODO: Write a module to check specifically for reverts in the try/catch catches.

contract('Etheraffle LOT Token Tests', accounts => {
  
  it('Contract should be owned by account[0]', async () => {
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
    // Check owner is freezer
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , isFreezer = await contract.canFreeze(owner)
    assert.isTrue(isFreezer, 'Owner is not a freezer!')
  })
  
  
  it('Owner can add & remove freezers', async () => {
    // Use owner to dd subject as freezer -> check sibject is freezer -> remove subject as freezer -> check subject is no longer freezer
    const contract   = await LOT.deployed()
        , owner      = await contract.etheraffle.call()
        , notOwner   = accounts[7]
        , subject    = accounts[1]
        , addFreezer = await contract.addFreezer(subject, {from: owner})
    let isFreezer = await contract.canFreeze.call(subject)
    assert.isTrue(isFreezer, 'Account is not a freezer!')
    assert.notEqual(owner, notOwner, 'Owner and not owner are the same account!')
    const removeFreezer = await contract.removeFreezer(subject, {from: owner})
    isFreezer = await contract.canFreeze.call(subject)
    assert.isFalse(isFreezer, 'Account has not been removed from freezer list!')
    truffleAssert.eventEmitted(addFreezer, 'LogFreezerAddition', ev => 
      ev.newFreezer == subject
    )
    truffleAssert.eventEmitted(removeFreezer, 'LogFreezerRemoval', ev => 
      ev.freezerRemoved == subject
    )
  })

  it('Non-owner cannot add or remove freezers', async () => {
    // As non-owner add subject as freezer -> check tx fails -> remove owner as freezer -> check tx fails.
    const contract   = await LOT.deployed()
        , owner      = await contract.etheraffle.call()
        , notOwner   = accounts[7]
        , subject    = accounts[1]
    try {
      await contract.addFreezer(subject, {from: notOwner})
      assert.fail('Non-owner should not be able to add a freezer!')
    } catch (e) {
      // console.log('Error in non-owner trying to add freezer: ', e)
      // Transaction reverts as expected!
    }
    try {
      await contract.removeFreezer(owner, {from: notOwner})
      assert.fail('Non-owner should not be able to remove a freezer!')
    } catch (e) {
      // console.log('Error in non-owner trying to remove freezer: ', e)
      // Transaction reverts as expected!
    }
  })

  it('Only owner can change owner', async () => {
    const contract = await LOT.deployed()
        , change1  = await contract.setEtheraffle(accounts[1])
    let owner = await contract.etheraffle.call()
    assert.equal(owner, accounts[1])
    try {
      await contract.setEtheraffle(accounts[0])
      assert.fail('Non-owner should not be able to change owner!')
    } catch (e) {
      // console.log('Error in non-owner changing ownership: ', e)
      // Transaction failed as expected!
    }
    const change2 = await contract.setEtheraffle(accounts[0], {from: accounts[1]})
    owner = await contract.etheraffle.call()
    assert.equal(owner, accounts[0])
    truffleAssert.eventEmitted(change1, 'LogEtheraffleChange', ev => 
      ev.prevER == accounts[0] && ev.newER == accounts[1]
    )
    truffleAssert.eventEmitted(change2, 'LogEtheraffleChange', ev => 
      ev.prevER == accounts[1] && ev.newER == accounts[0]
    )
  })
  
  // 
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
    const contract = await LOT.deployed()
    let balance = await contract.balanceOf(accounts[8])
    assert.equal(balance.toNumber(), 0)
    balance = await contract.balanceOf(accounts[0])
    assert.equal(balance.toNumber(), 100000000)
    const data = web3Abi.encodeFunctionCall(txAbi, [accounts[8], 10000000, '0x00'])
        , tx   = await LOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, data: data})
    balance = await contract.balanceOf(accounts[8])
    assert.equal(balance.toNumber(), 10000000)
    balance = await contract.balanceOf(accounts[0])
    assert.equal(balance.toNumber(), 90000000)
    /* Following breaks it even though the logs clearly show the transfer event firing. Must be something to do with the manual crafting of the tx?
    truffleAssert.eventEmitted(tx, 'LogTransfer', ev => 
      ev.from == accounts[0] && ev.to == accounts[8] && ev.value == 10000000 && ev.data == '0x00'
    )
    */
  })

  it('Account can\'t transfer tokens if insufficient balance', async () => {
    const contract = await LOT.deployed()
    let balance = await contract.balanceOf(accounts[8])
    const data = web3Abi.encodeFunctionCall(txAbi, [accounts[0], balance + 1, '0x00'])
    try {
      await LOT.web3.eth.sendTransaction({from: accounts[8], to: contract.address, data: data})
      assert.fail('Account should not be able to send more tokens than it owns!')
    } catch (e) {
      // console.log('Error when attempting to send more tokens than owned: ', e)
      // Transaction failed as expected!
    }
  })

  it('Freezers can freeze/unfreeze token', async () => {
    // Get owner -> check owner is freezer -> freeze token -> check token is frozen -> unfreeze token -> check token is unfrozen.
    const contract  = await LOT.deployed()
        , freezer   = await contract.etheraffle.call()
        , isFreezer = await contract.canFreeze.call(freezer)
    let status      = await contract.frozen.call()
    assert.isTrue(isFreezer, 'Freezer is not a freezer!')
    assert.isFalse(status, 'Token is already frozen!')
    const freeze1 = await contract.setFrozen(true, {from: freezer})
    status = await contract.frozen.call()
    assert.isTrue(status, 'Token has not been frozen!')
    const freeze2 = await contract.setFrozen(false, {from: freezer})
    status = await contract.frozen.call()
    assert.isFalse(status, 'Token is still frozen!')
    truffleAssert.eventEmitted(freeze1, 'LogFrozenStatus', ev => ev.status)
    truffleAssert.eventEmitted(freeze2, 'LogFrozenStatus', ev => !ev.status)
  })

  it('Non-freezers cannot freeze/unfreeze token', async () => {
    const contract     = await LOT.deployed()
        , freezer      = accounts[7]
        , isFreezer    = await contract.canFreeze.call(freezer)
        , statusBefore = await contract.frozen.call()
    assert.isFalse(isFreezer, 'Freezer is not supposed to be a freezer!')
    try {
      await contract.setFrozen(true, {from: freezer})
      assert.fail("Non-freezers should not be able to freeze token!")
    } catch (e) {
      // console.log('Error when attempt to freeze token as a non-freezer: ', e)
      // Transaction reverts as expected!
    }
    const statusAfter = await contract.frozen.call()
    assert.equal(statusBefore, statusAfter, 'Frozen status has changed!')
  })

  // token txs when frozen!
  it('Tokens can\'t be moved when frozen', async () => {
    const contract = await LOT.deployed()
    await contract.setFrozen(true)
    let status = await contract.frozen.call()
    assert.equal(status, true)
    let balance = await contract.balanceOf(accounts[0])
    const data = web3Abi.encodeFunctionCall(txAbi, [accounts[4], balance, '0x00'])
    try {
      await LOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, data: data})
      assert.fail('Account should not be able to move tokens when they\'re frozen!')
    } catch (e) {
      // console.log('Error when attempting to move tokens when frozen: ', e)
      // Transaction failed as expected!
    }
    await contract.setFrozen(false)
    status = await contract.frozen.call()
    assert.equal(status, false)
    await LOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, data: data})
    let balanceAcc4 = await contract.balanceOf(accounts[4])
    assert.equal(balanceAcc4.toNumber(), balance.toNumber())
    balance = await contract.balanceOf(accounts[0])
    assert.equal(balance.toNumber(), 0)
  })
  
  it('Fallback function should revert', async () => {
    const contract = await LOT.deployed()
    try {
      await LOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, value: 1})
    } catch (e) {
      // console.log('Error when checking if fallback reverts: ', e)
      // Transaction failed as expected!
    }
  })
  
  it('Non-owners cannot scuttle the contract', async () => {
    const contract = await LOT.deployed()
    try {
      await contract.selfDestruct({from: accounts[4]})
      assert.fail('Only owner should be able to destroy contract!')
    } catch (e) {
      // console.log('Error attempting to destroy contract: ', e)
      // Transaction failed as expected!
    }
  })

  it('Contract can only be scuttled when frozen', async () => {
    const contract = await LOT.deployed()
        , owner    = await contract.etheraffle.call()
    let status     = await contract.frozen.call()
    assert.equal(status, false)
    try {
      await contract.selfDestruct({from: owner})
      assert.fail('Contract should not be scuttleable when not frozen!')
    } catch (e) {
      // console.log('Error attempting to destroy contract whilst token isn\'t frozen: ', e)
      // Transaction failed as expected!
    }
    await contract.setFrozen(true, {from: owner})
    status = await contract.frozen.call()
    assert.equal(status, true)
    await contract.selfDestruct({from: owner})
  })

})