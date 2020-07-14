# ttrpg-cli-tools

- A standalone Ruby command-line tool for rolling dice and drawing cards, for use with tabletop role-playing games.
- work in progress - 90% done!
- download and enter run bin/roll with Ruby installed to start

## Features
("ruby bin/roll" aliased in terminal screenshots below as "roll")

- [x] no arguments, automatically rolls 1d6
![roll command screenshot](https://i.imgur.com/AfDYyNX.png)
- [x] takes an argument, rolls xdy (e.g. 1d20, d8, 4d4)
![one argument screenshot](https://i.imgur.com/IGYZqIh.png)
- [x] takes multiple arguments, rolls multiple die without adding them
![multiple arguments screenshot](https://i.imgur.com/eYKXge4.png)
- [x] takes +/- arithmetic arguments (e.g. 2d6 + 2, 5d6 - 1d8)
![arithmetic arguments screenshot](https://i.imgur.com/URdZmJq.png)
- [x] take highest of and lowest of (e.g. l{2d6}, h2{3d20})
![highest modifier screenshot](https://i.imgur.com/uUtmveq.png)
- [x] tarot card draw (command: `-t [number]`)
![tarot draw screenshot](https://i.imgur.com/HWWW3f4.png)
- [x] playing-card draw (command: -p [number])
![playing card draw screenshot](https://i.imgur.com/aWDClBQ.png)

## Screenshots
no argument:
![roll command](https://i.imgur.com/AfDYyNX.png)
one argument:
![one argument screenshot](https://i.imgur.com/IGYZqIh.png)
multiple arguments:
![multiple arguments screenshot](https://i.imgur.com/eYKXge4.png)