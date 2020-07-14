# ttrpg-cli-tools

- A standalone Ruby command-line tool for rolling dice and drawing cards, for use with tabletop role-playing games.
- work in progress - 90% done!
- download and enter run bin/roll with Ruby installed to start
- Demo at [Repl.it](https://repl.it/@khongcodes/ttrpg-cli-tools#main.rb)

## Features
("ruby bin/roll" aliased below as "roll")

- [x] no arguments, automatically rolls 1d6
```
$ roll

rolling 1d6
1
=> 1

```

- [x] takes an argument, rolls xdy (e.g. 1d20, d8, 4d4)
```
$ roll 4d4

rolling 4d4
1, 1, 4, 1
=> 7

```

- [x] takes multiple arguments, rolls multiple die without adding them
```
$ roll 1d20 d8 4d4

rolling 1d20
18
=> 18

rolling d8
4
=> 4

rolling 4d4
4, 3, 2, 2
=> 11

```

- [x] takes +/- arithmetic arguments (e.g. 2d6 + 2, 5d6 - 1d8)
```
$ roll 1d20 + 2d6 - d4

rolling 1d20 + 2d6 - d4
6  /  1, 6  /  -3
=> 10

```

- [x] take highest of and lowest of (e.g. l{2d6}, h2{3d20})
```
$ roll 1d20 + h2{3d6}

rolling 1d20 + h2{3d6}
18  /  [5], [5], 3
=> 28

```

- [x] tarot card draw (command: `-t [number]`)
```
$ roll -t 2

2 tarot cards drawn:

Ten of Wands
Minor Arcana
Suit: wands

Description: A figure carries ten heavy wands, trying to keep them together, bowed over by their weight. They approach a town which is not too far.

Meaning (upright): Burden, extra responsibility, hard work, completion
Meaning (inverted): Overburdened or overstressed, need for delegation

-------------------------------

Seven of Pentacles
Minor Arcana
Suit: pentacles

Description: A figure rests their head over their hands on their shovel, admiring the fruit of their hard work. Their gesture suggests fatigue. Six pentacles hang on the vegetation, and one rests at the figure's feet.

Meaning (upright): Long-term view, sustained work, perseverance, diligence, investment
Meaning (inverted): Lack of vision, limited payoff or results, distractions or impatience 

```

- [x] playing-card draw (command: -p [number])
```
$ roll -p 5

5 playing cards drawn:

King of Hearts
Ace of Hearts
Queen of Spades
Ten of Spades
Ace of Spades

```