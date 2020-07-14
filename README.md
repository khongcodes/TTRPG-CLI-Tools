# ttrpg-cli-tools

- A standalone Ruby command-line ttrpg-utility
- work in progress
- run bin/roll with Ruby to start

- [x] no arguments, automatically rolls 1d6
- [x] takes an argument, rolls xdy (e.g. 1d20, d8, 4d4)
- [x] takes multiple arguments, rolls multiple die without adding them
- [x] takes +/- arithmetic arguments (e.g. 2d6 + 2, 5d6 - 1d8)
- [x] take highest of and lowest of (e.g. l{2d6}, h2{3d20})

- [ ] tarot card draw
- [ ] playing-card draw
- [ ] write optparser Options and Help documentation