# ttrpg-cli-tools

- A standalone Ruby command-line ttrpg-utility
- work in progress - 90% done!
- download and enter run bin/roll with Ruby installed to start

## Features

- [x] no arguments, automatically rolls 1d6
- [x] takes an argument, rolls xdy (e.g. 1d20, d8, 4d4)
- [x] takes multiple arguments, rolls multiple die without adding them
- [x] takes +/- arithmetic arguments (e.g. 2d6 + 2, 5d6 - 1d8)
- [x] take highest of and lowest of (e.g. l{2d6}, h2{3d20})
- [x] tarot card draw (command: -t [number])
- [x] playing-card draw (command: -p [number])
- [x] write optparser Options and Help documentation
- [ ] refactor and optimize playing-card draw instead of instantiating a deck array