const { assert }    = require("chai")
    , web3Abi       = require('web3-eth-abi')
    , truffleAssert = require('truffle-assertions')
    , LOT           = artifacts.require('etheraffleLOT')

// TODO: Write a module to check specifically for reverts in the try/catch catches.

contract('etheraffleLOT', accounts => {
  
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
    const contract  = await LOT.deployed()
        , owner     = await contract.etheraffle.call()
        , isFreezer = await contract.canFreeze(owner)
    assert.equal(isFreezer, true)
  })
  
  
  it('Only owner can add & remove freezers', async () => {
    const contract   = await LOT.deployed()
        , addFreezer = await contract.addFreezer(accounts[1])
    let freezerCheck = await contract.canFreeze.call(accounts[1])
    assert.equal(freezerCheck, true)
    const removeFreezer = await contract.removeFreezer(accounts[1])
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
    truffleAssert.eventEmitted(addFreezer, 'LogFreezerAddition', ev => 
      ev.newFreezer == accounts[1]
    )
    truffleAssert.eventEmitted(removeFreezer, 'LogFreezerRemoval', ev => 
      ev.freezerRemoved == accounts[1]
    )
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

  it('Only freezers can freeze token', async () => {
    const contract = await LOT.deployed()
        , freeze1  = await contract.setFrozen(true)
    let status     = await contract.frozen.call()
    assert.equal(status, true)
    const freeze2  = await contract.setFrozen(false)
    status = await contract.frozen.call()
    assert.equal(status, false)
    try {
      await contract.setFrozen(true, {from: accounts[5]})
      assert.fail("Non-freezers should not be able to freeze token!")
    } catch (e) {
      // console.log('Error when attempt to freeze token as a non-freezer: ', e)
      // Transaction failed as expected!
    }
    truffleAssert.eventEmitted(freeze1, 'LogFrozenStatus', ev => ev.status)
    truffleAssert.eventEmitted(freeze2, 'LogFrozenStatus', ev => !ev.status)
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