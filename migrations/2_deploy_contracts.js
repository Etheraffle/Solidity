const amt     = 100 // Init minting of the token 
    , freeLOT = artifacts.require("EtheraffleFreeLOT")
    , addr    = '0x627306090abab3a6e1400e9345bc60c78a8bef57' // Truffle's account[0]

module.exports = deployer => {
  deployer.deploy(freeLOT, addr, amt)
}
