const amt     = 100
    , freeLOT = artifacts.require("EtheraffleFreeLOT")
    , addr    = '0x627306090abab3a6e1400e9345bc60c78a8bef57'

module.exports = deployer => {
  deployer.deploy(freeLOT, addr, amt)
}
