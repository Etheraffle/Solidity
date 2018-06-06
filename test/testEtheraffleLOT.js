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
    await LOT.web3.eth.sendTransaction({from: accounts[0], to: contract.address, data: data, value: 0})
    balance = await contract.balanceOf(accounts[8])
    assert.equal(balance.toNumber(), 10000000)
    balance = await contract.balanceOf(accounts[0])
    assert.equal(balance.toNumber(), 90000000)
  })

  // it('Account can\'t transfer tokens if insufficient balance', async () => {
  //   const contract = await LOT.deployed()
  //   const data = web3Abi.encodeFunctionCall(txAbi, [accounts[0], 11, '0x00'])
  //   try {
  //     await LOT.web3.eth.sendTransaction({from: accounts[8], to: contract.address, data: data, value: 0})
  //     assert.fail('Should not have been able to send tokens!')
  //   } catch (e) {
  //     // console.log('Error when sending more tokens than balance: ', e)
  //     // Transaction failed as expected!
  //   }
  // })

  it('Only freezers can freeze token', async () => {
    const contract = await LOT.deployed()
    await contract.setFrozen(true)
    let status = await contract.frozen.call()
    assert.equal(status, true)
    await contract.setFrozen(false)
    status = await contract.frozen.call()
    assert.equal(status, false)
    try {
      await contract.setFrozen(true, {from: accounts[5]})
      assert.fail("Non-freezers should not be able to freeze token!")
    } catch (e) {
      // console.log('Error when attempt to freeze token as a non-freezer: ', e)
      // Transaction failed as expected!
    }
  })

  // token txs when frozen!
  
  
  

})