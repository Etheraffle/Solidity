// const { assert }    = require("chai")
//     , moment        = require('moment')
//     , truffleAssert = require('truffle-assertions')
//     , etheraffle    = artifacts.require('etheraffle')

const rafEnd   = 500400
const weekDur  = 604800
const birthday = 1500249600
// pastClosing :: Int -> Bool
const pastClosing = _curWeek => 
  moment.utc().format('X') - ((_curWeek * weekDur) + birthday) > rafEnd;
// getWeek :: () -> Int
const getWeek = _ => {
  let curWeek = (moment.utc().format('X') - birthday) / weekDur
  return pastClosing(curWeek) ? curWeek + 1 : curWeek
}


// function getWeek() public constant returns (uint) {
//   uint curWeek = (now - BIRTHDAY) / WEEKDUR;
//   return pastClosingTime(curWeek) ? curWeek + 1 : curWeek;
// }

// contract('Etheraffle', accounts => {
//   // Correct setup checks
//   it('Contract should be owned by account[0]', async () => {
//     // console.log(accounts.map((e, i) => `account ${i} address: ${e}`))
//     const contract  = await disbursal.deployed()
//         , contOwner = await contract.etheraffle.call()
//     assert.equal(contOwner, accounts[0])
//   })

// })

/* All of the onlyEtheraffle funcs....

function manuallySetOraclizeString(string _randomStr1, string _randomStr2, string _apiStr1, string _apiStr2) external onlyEtheraffle {

function manuallySetTktPrice(uint _newPrice) external onlyEtheraffle {

function manuallySetTake(uint _newTake) external onlyEtheraffle {

function manuallySetPayouts(uint _week, string _numMatches) external onlyEtheraffle {

function manuallySetFreeLOT(address _newAddr) external onlyEtheraffle {

function manuallySetEthReliefAddr(address _newAddr) external onlyEtheraffle {

function manuallySetDisbursingAddr(address _newAddr) external onlyEtheraffle {

function manuallySetEtheraffleAddr(address _newAddr) external onlyEtheraffle {

function manuallySetRafEndTime(uint _newTime) external onlyEtheraffle {

function manuallySetWithdrawBefore(uint _newTime) external onlyEtheraffle {

function manuallySetPaused(bool _status) external onlyEtheraffle {

function manuallySetPercentOfPool(uint[] _newPoP) external onlyEtheraffle {

function manuallySetupRaffleStruct(uint _week, uint _tktPrice, uint _timeStamp) external onlyEtheraffle {

function manuallySetWithdraw(uint _week, bool _status) external onlyEtheraffle {

function manuallySetWeek(uint _week) external onlyEtheraffle {

function manuallyMakeOraclizeCall(uint _week, uint _delay, bool _isRandom, bool _isManual, bool _status) onlyEtheraffle external {


function manuallyModifyQID(bytes32 _ID, uint _weekNo, bool _isRandom, bool _isManual) onlyEtheraffle external {

function upgradeContract(address _newAddr) onlyEtheraffle external {

function selfDestruct() onlyEtheraffle external {
*/
/*
const funcs    = [
  {title: 'FuncOne', f: manuallySetTktPrice(10)},{},{}]
const contract = await disbursal.deployed()
  funcs.map(f => {
    if(f.title, async () => {
      await contract.f()
    })
  })
  .map(f => {
    if(f.title, async () => {
      try { 
        await contract.f()
        assert.fail(`Function ${f.title} succeeded when it shouldn't`)
      } catch (e) { 
        console.log('Expected failure message: ', e)
        // Failed as exected!
      }
    })
  })
*/

