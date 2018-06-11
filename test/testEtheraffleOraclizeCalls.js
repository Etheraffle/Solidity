const { assert }    = require("chai")
    // , moment        = require('moment')
    , truffleAssert = require('truffle-assertions')
    , etheraffle    = artifacts.require('etheraffle')

// Correct Orac callback time = struct timestamp + rafend

contract('Etheraffle Oraclize Tests', accounts => {
  
  it('Only owner can set Oraclize strings', async () => {
    // Change string as non-owner -> Check tx fails.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , random1  = 'Only'
        , random2  = 'owner'
        , api1     = 'can'
        , api2     = 'set'
        , caller   = accounts[5]
    assert.notEqual(owner, caller, 'Function caller is not different to owner!')
    try {
      await contract.manuallySetOraclizeString(random1, random2, api1, api2, {from: caller})
      assert.fail('Only contract owner should be able to set Oraclize strings!')
    } catch (e) {
      // console.log('Error when non-owner attempts to set Oraclize strings: ', e)
      // Transaction reverts as expected!
    }
  })
})