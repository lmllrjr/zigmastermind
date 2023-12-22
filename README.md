# Zig Mastermind
This is a very simple version of the game [Mastermind](https://en.wikipedia.org/wiki/Mastermind_(board_game)) for the terminal.

[![zig mastermind demo](./images/zigmastermind.gif)](https://asciinema.org/a/FdVPkIDr0WCzk1Z6DRQztmz2B)

## OBJECT OF THE GAME
The object of MASTERMIND (r) is to guess a secret code consisting of a series of 4 numbers/colors (in this one it is the numbers ```[1 2 3 4 5 6]```).

> [!NOTE]
> To make it more difficult, this version uses all numbers ```[0 1 2 3 4 5 6 7 8 9]```

Each guess results in feedback narrowing down the possibilities of the code.
You win when you can crack the code within 12 guesses.

* (1) A ```*``` indicates a Code Character of the right number and
in the right position.
* (2) A ```+``` indicates a Character of the right number but in the wrong position.
* (3) A ```.``` indicates a wrong number that does not appear in the secret code.

> [!IMPORTANT]
> The indicators do not show which position they correspond to.
> They are displayed randmonly every guess.
