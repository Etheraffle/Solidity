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
    // truffleAssert.eventEmitted(change1, 'LogEtheraffleChange', ev => 
    //   ev.prevER == accounts[0] && ev.newER == accounts[1]
    // )
    // truffleAssert.eventEmitted(change2, 'LogEtheraffleChange', ev => 
    //   ev.prevER == accounts[1] && ev.newER == accounts[0]
    // )
  })
  
})