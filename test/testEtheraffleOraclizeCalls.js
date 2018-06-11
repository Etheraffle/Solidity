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

  it('Owner can set Oraclize strings correctly', async () => {
    // Get owner -> change strings as owner -> check they match.
    const contract = await etheraffle.deployed()
        , owner    = await contract.etheraffle.call()
        , random1  = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\", \"serialNumber\"]','\\n{\"jsonrpc\": \"2.0\",\"method\":\"generateSignedIntegers\",\"id\":\""
        , random2  = "\",\"params\":{\"n\":\"6\",\"min\":1,\"max\":49,\"replacement\":false,\"base\":10,\"apiKey\":${[decrypt] BBxn5oQTs8LKRkJb32LS+dHf/c//H3sSjehJchlucpdFGEjBwtSu08okSPoSkoQQpPCW56kz7PoGm5VEc8r722oEg01AdB03CbURpSxU5cF9Q7MeyNAaDUcTOvlX1L2T/h/k4PUD6FEIvtynHZrSMisEF+r7WJxgiA==}}']"
        , api1     = "[URL] ['json(https://etheraffle.com/api/test).m','{\"r\":\""
        , api2     = "\",\"k\":${[decrypt] BEhjzZIYd3GIvFUu4rWqwYOFKucnwToOUpP3x/svZVz/Vo68c6yIiq8k6XQDmPLajzSTD/TrpR5cF4BnLLhNDtELy7hQyMmFTuUa3JXBs0G0f4d7cTeIX8IG37KxtNfcvUafJy25}}']"
    await contract.manuallySetOraclizeString(random1, random2, api1, api2, {from: owner})
    const random1After = await contract.randomStr1.call()
        , random2After = await contract.randomStr2.call()
        , api1After    = await contract.apiStr1.call()
        , api2After    = await contract.apiStr2.call()
    assert.equal(random1, random1After, 'Random1 string not set correctly!')
    assert.equal(random2, random2After, 'Random2 string not set correctly!')
    assert.equal(api1, api1After, 'Api1 string not set correctly!')
    assert.equal(api2, api2After, 'Api2 string not set correctly!')
  })

})

//_contract = etheraffle.at(contract.address)
const getAllEvents = _contract => {
  return new Promise((resolve, reject) => {
    return _contract.allEvents({},{fromBlock:0, toBlock: 'latest'})
    .get((err, res) => !err ? resolve(res) : console.log(err))
  })
}
