const { assert }    = require("chai")
    , web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , LOT           = artifacts.require('etheraffleLOT')

// TODO: Write a module to check specifically for reverts in the try/catch catches.

contract('Etheraffle LOT Token Tests', accounts => {
  
  it('Contract should be owned by account[0]', async () => {
    // Get contract owner -> check it's account[0]
    const contract  = await LOT.deployed()
        , contOwner = await contract.etheraffle.call()
    assert.equal(contOwner, accounts[0], 'Owner is not account[0]!')
  })

  it('Total supply should equal initial minting of 100000000', async () => {
    // Get total supply -> compared to expected total supply
    const contract  = await LOT.deployed()
        , totSupply = await contract.totalSupply()
        , amount    = 100000000
    assert.equal(totSupply.toNumber(), amount, 'Total supply doesn\'t equal initial minting!')
  })

  it('Owner\'s balance should equal total supply.', async () => {
    // Get total supply -> get owner balance -> check they match
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , balance   = await contract.balanceOf(owner)
        , totSupply = await contract.totalSupply.call()
        , amount    = 100000000
    assert.equal(totSupply.toNumber(), amount, 'Total supply doesn\'t equal expected amount!')
    assert.equal(balance.toNumber(), totSupply.toNumber(), 'Owner\'s balance doesn\'t equal total supply!')
  })

  it('Owner should be a freezer', async () => {
    // Check owner is freezer
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , isFreezer = await contract.canFreeze(owner)
    assert.isTrue(isFreezer, 'Owner is not a freezer!')
  })
  
  
  it('Owner can add & remove freezers', async () => {
    // Use owner to dd subject as freezer -> check subject is freezer -> remove subject as freezer -> check subject is no longer freezer
    const contract   = await LOT.deployed()
        , owner      = await contract.etheraffle.call()
        , notOwner   = accounts[7]
        , guineaPig    = accounts[1]
        , addFreezer = await contract.addFreezer(guineaPig, {from: owner})
    let isFreezer = await contract.canFreeze.call(guineaPig)
    assert.isTrue(isFreezer, 'Account is not a freezer!')
    assert.notEqual(owner, notOwner, 'Owner and not owner are the same account!')
    const removeFreezer = await contract.removeFreezer(guineaPig, {from: owner})
    isFreezer = await contract.canFreeze.call(guineaPig)
    assert.isFalse(isFreezer, 'Account has not been removed from freezer list!')
    truffleAssert.eventEmitted(addFreezer, 'LogFreezerAddition', ev => 
      ev.newFreezer == guineaPig
    )
    truffleAssert.eventEmitted(removeFreezer, 'LogFreezerRemoval', ev => 
      ev.freezerRemoved == guineaPig
    )
  })

  it('Non-owner cannot add or remove freezers', async () => {
    // As non-owner add subject as freezer -> check tx fails -> remove owner as freezer -> check tx fails.
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , notOwner  = accounts[7]
        , guineaPig = accounts[1]
    try {
      await contract.addFreezer(guineaPig, {from: notOwner})
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

  it('Owner can change owner', async () => {
    //  Get owner -> change owner -> check new owner -> change owner back -> check for original owner
    const contract  = await LOT.deployed()
        , guineaPig = accounts[6]
    let owner = await contract.etheraffle.call()
    const originalOwner = owner
    assert.notEqual(owner, guineaPig, 'Onwer is same account as guinea pig account!')
    const change1 = await contract.setEtheraffle(guineaPig, {from: owner})
    owner = await contract.etheraffle.call()
    assert.equal(owner, guineaPig, 'Owner should now be the guinea pig account!')
    const change2 = await contract.setEtheraffle(originalOwner, {from: guineaPig})
    owner = await contract.etheraffle.call()
    assert.equal(owner, originalOwner, 'Owner should now be the original owner again!')
    truffleAssert.eventEmitted(change1, 'LogEtheraffleChange', ev => ev.prevER == originalOwner && ev.newER == guineaPig)
    truffleAssert.eventEmitted(change2, 'LogEtheraffleChange', ev => ev.prevER == guineaPig && ev.newER == originalOwner)
  })

  it('Non-owner cannot change owner', async () => {
    // Check an account is not owner -> attempt to change owner -> check it fails.
    const contract = await LOT.deployed()
        , owner = await contract.etheraffle.call()
        , guineaPig = accounts[4]
    assert.notEqual(owner, guineaPig, 'Owner and guinea pig account are the same!')
    try {
      await contract.setEtheraffle(guineaPig, {from: guineaPig})
      assert.fail('Non-owner should not be able to change owner!')
    } catch (e) {
      //console.log('Error in non-owner changing ownership: ', e)
      // Transaction reverts as expected!
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
  
  it('Account can transfer tokens if they have sufficient balance', async () => {
    // Query account's balance -> attempt to move fewer tokens than balance -> check it transfers correctly.
    const contract           = await LOT.deployed()
        , mover              = accounts[0]
        , recipient          = accounts[8]
        , amount             = 10000000
        , dummyData          = '0x00'
        , balMoverBefore     = await contract.balanceOf(mover)
        , balRecipientBefore = await contract.balanceOf(recipient)
    assert.isAbove(balMoverBefore.toNumber(), amount, 'Mover doesn\'t have sufficient tokens to send tx!')
    const data = web3Abi.encodeFunctionCall(txAbi, [recipient, amount, dummyData])
    await LOT.web3.eth.sendTransaction({from: mover, to: contract.address, data: data})
    const balMoverAfter     = await contract.balanceOf(mover)
        , balRecipientAfter = await contract.balanceOf(recipient)
    assert.equal(balMoverAfter.toNumber(), balMoverBefore.toNumber() - amount, 'Mover\'s tokens didn\'t decrement by correct amount!')
    assert.equal(balRecipientAfter.toNumber(), balRecipientBefore.toNumber() + amount, 'Receipients\'s tokens didn\'t increment by correct amount!')
  })

  it('Account can\'t transfer tokens if insufficient balance', async () => {
    // Query accounts balance -> attempt to move balance + 1 tokens -> check for fail.
    const contract  = await LOT.deployed()
        , guineaPig = accounts[8]
        , recipient = accounts[0]
        , balance   = await contract.balanceOf(guineaPig)
        , dummyData = '0x00'
        , data      = web3Abi.encodeFunctionCall(txAbi, [recipient, balance + 1, dummyData])
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
    // Pick account -> ensure account is not freezer -> attempt to freeze token -> check token is not frozen
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

  it('Tokens can be moved when not frozen', async () => {
    // Ensure contract not frozen -> move an amount of tokens -> check amount of tokens have moved correctly
    const contract          = await LOT.deployed()
        , dummyData         = '0x00'
        , amount            = 100000
        , mover             = accounts[0]
        , receiver          = accounts[4]
        , status            = await contract.frozen.call()
        , moverBalBefore    = await contract.balanceOf(mover)
        , receiverBalBefore = await contract.balanceOf(receiver)
        , data              = web3Abi.encodeFunctionCall(txAbi, [receiver, amount, dummyData])
    assert.isAbove(moverBalBefore.toNumber(), amount, 'Token mover doesn\'t have sufficient tokens to move!')
    assert.isFalse(status, 'Token is frozen!')
    const tx               = await LOT.web3.eth.sendTransaction({from: mover, to: contract.address, data: data})
        , moverBalAfter    = await contract.balanceOf(mover)
        , receiverBalAfter = await contract.balanceOf(receiver)
    assert.equal(moverBalAfter.toNumber(), moverBalBefore.toNumber() - amount)
    assert.equal(receiverBalAfter.toNumber(), receiverBalBefore.toNumber() + amount)
  })

  it('Tokens can\'t be moved when frozen', async () => {
    // Freeze contract -> attempt to move tokens
    const contract  = await LOT.deployed()
        , mover     = accounts[0]
        , receiver  = accounts[4]
        , dummyData = '0x00'
    await contract.setFrozen(true)
    let status = await contract.frozen.call()
    assert.isTrue(status, 'Token is not frozen!')
    let balance = await contract.balanceOf(mover)
    const data = web3Abi.encodeFunctionCall(txAbi, [receiver, balance, dummyData])
    try {
      await LOT.web3.eth.sendTransaction({from: mover, to: contract.address, data: data})
      assert.fail('Account should not be able to move tokens when they\'re frozen!')
    } catch (e) {
      // console.log('Error when attempting to move tokens when frozen: ', e)
      // Transaction failed as expected!
    }
  })
  
  it('Fallback function should revert', async () => {
    // Call fallback function -> check it fails
    const contract = await LOT.deployed()
    try {
      await LOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, value: 1})
    } catch (e) {
      // console.log('Error when checking if fallback reverts: ', e)
      // Transaction failed as expected!
    }
  })

  it('Contract cannot be scuttled when token is not frozen', async () => {
    // Ensure contract not frozen -> attempt to scuttle -> check it failed
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , canFreeze = await contract.canFreeze.call(owner)
    assert.isTrue(canFreeze, 'Owner needs to be able to freeze!')
    await contract.setFrozen(false, {from: owner})
    const status = await contract.frozen.call()
    assert.isFalse(status, 'Token needs to be unfrozen!')
    try {
      await contract.selfDestruct({from: owner})
      assert.fail('Contract should not be scuttleable when not frozen!')
    } catch (e) {
      // console.log('Error attempting to destroy contract whilst token isn\'t frozen: ', e)
      // Transaction reverts as expected!
    }
  })

  it('Non-owners cannot scuttle the contract', async () => {
    // Ensure contract is frozen -> attempt to scuttle as a non owner -> check it failed
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , nonOwner  = accounts[3]
        , canFreeze = await contract.canFreeze.call(owner)
    assert.notEqual(owner, nonOwner, 'Non owner & owner are the same account!')
    assert.isTrue(canFreeze, 'Owner needs to be able to freeze!')
    await contract.setFrozen(true, {from: owner})
    const status = await contract.frozen.call()
    assert.isTrue(status, 'Token needs to be frozen to test scuttling!')
    try {
      await contract.selfDestruct({from: nonOwner})
      assert.fail('Only owner should be able to destroy contract!')
    } catch (e) {
      // console.log('Error attempting to destroy contract: ', e)
      // Transaction failed as expected!
    }
  })

  it('Contract can only be scuttled by owner when token is frozen', async () => {
    // Check owner can freeze -> freeze token -> check is frozen -> scuttle contract
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , canFreeze = await contract.canFreeze.call(owner)
    assert.isTrue(canFreeze, 'Owner needs to be able to freeze!')
    await contract.setFrozen(true, {from: owner})
    const status = await contract.frozen.call()
    assert.isTrue(status, 'Token needs to be frozen to test scuttling!')
    await contract.selfDestruct({from: owner})
  })

})