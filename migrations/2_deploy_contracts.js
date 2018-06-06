const etheraffleLOT       = artifacts.require("EtheraffleLOT")
    , etheraffleFreeLOT   = artifacts.require("EtheraffleFreeLOT")
    , etheraffleDisbursal = artifacts.require("EtheraffleDisbursal")
    , etherReceiverStub   = artifacts.require("EtherReceiverStub")
    , amt  = 100 // Init minting of the token for tests
    , addr = '0x627306090abab3a6e1400e9345bc60c78a8bef57' // Truffle's account[0]

module.exports = deployer => {
  deployer.deploy(etherReceiverStub, addr)
  deployer.deploy(etheraffleLOT, addr, amt)
  deployer.deploy(etheraffleDisbursal, addr)
  deployer.deploy(etheraffleFreeLOT, addr, amt)
}
