// const freeLOT = artifacts.require("./etheraffleFreeLOT.sol")

// /* Constructor Args */
// const amt  = 100
// const addr = '0x627306090abab3a6e1400e9345bc60c78a8bef57'

// module.exports = deployer => {
//   deployer.deploy(freeLOT, addr, amt);
// }
var freeLOT = artifacts.require("EtheraffleFreeLOT");
// var MetaCoin = artifacts.require("./MetaCoin.sol");
var amt  = 100
var addr = '0x627306090abab3a6e1400e9345bc60c78a8bef57'

module.exports = function(deployer) {
  deployer.deploy(freeLOT, addr, amt);
};
