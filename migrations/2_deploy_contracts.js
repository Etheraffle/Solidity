const ethRelief           = artifacts.require("EthRelief")
    , etheraffle          = artifacts.require("Etheraffle")
    , etheraffleLOT       = artifacts.require("EtheraffleLOT")
    , etheraffleFreeLOT   = artifacts.require("EtheraffleFreeLOT")
    , etherReceiverStub   = artifacts.require("EtherReceiverStub")
    , etheraffleDisbursal = artifacts.require("EtheraffleDisbursal")

module.exports = (deployer, networks, accounts) => {
  const amt  = 100
      , addr = accounts[0]
  deployer.deploy(etherReceiverStub, addr)
  deployer.deploy(etheraffleLOT, addr, amt)
  deployer.deploy(ethRelief, addr).then(ethReliefRes =>
    deployer.deploy(etheraffleDisbursal, addr).then(disbRes =>
      deployer.deploy(etheraffleFreeLOT, addr, amt).then(freeAddr =>
        deployer.deploy(etheraffle, addr, disbRes.address, ethReliefRes.address, freeAddr.address, {value: 1*10**17, gas: 6700000})
      )
    )
  )
}