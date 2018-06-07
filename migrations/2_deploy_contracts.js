const ethRelief           = artifacts.require("EthRelief")
    , etheraffleLOT       = artifacts.require("EtheraffleLOT")
    , etheraffleFreeLOT   = artifacts.require("EtheraffleFreeLOT")
    , etherReceiverStub   = artifacts.require("EtherReceiverStub")
    , etheraffleDisbursal = artifacts.require("EtheraffleDisbursal")
    , amt  = 100 // Init minting of the token for tests
    , addr = '0x627306090abab3a6e1400e9345bc60c78a8bef57' // Truffle's account[0]

module.exports = deployer => {
  deployer.deploy(etherReceiverStub, addr)
  deployer.deploy(ethRelief, addr)
  deployer.deploy(etheraffleLOT, addr, amt)
  deployer.deploy(etheraffleDisbursal, addr)
  deployer.deploy(etheraffleFreeLOT, addr, amt)
  // deployer.deploy(ethRelief, addr).then(() => {
  //   return deployer.deploy(etheraffleDisbursal, addr).then(() => {
  //     return deployer.deploy(etheraffleFreeLOT, addr, amt).then(() => {
  //       //Now have access to the above contract addresses for deploying ER.
  //       return deployer.deploy(etheraffle, addr, etheraffleDisbursal.address, ethRelief.address, etheraffleFreeLOT.address)
  //        Once ER compiles, this alone might be enough for testing since it's deploying them all...
  //     })
  //   })
  // })
}