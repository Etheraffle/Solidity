const rafEnd   = 500400
const weekDur  = 604800
const birthday = 1500249600

const pastClosing = _curWeek => 
  moment.utc().format('X') - ((_curWeek * weekDur) + birthday) > rafEnd

const getCurWeek = _ => 
  Math.trunc((moment.utc().format('X') - birthday) / weekDur)

const getWeek = _ =>
  pastClosing(getCurWeek()) ? getCurWeek() + 1 : getCurWeek()

// function getWeek() public constant returns (uint) {
//   uint curWeek = (now - BIRTHDAY) / WEEKDUR;
//   return pastClosingTime(curWeek) ? curWeek + 1 : curWeek;
// }

const getRandom = ceiling => Math.floor(Math.random() * ceiling) + 1

module.exports = { getRandom, getWeek }
