# KAIROS

CMPM 121 Assignment 4\
Name: Kayla Nguyen\
Game Title: _KAIROS_\
Download Link (could not get the browser hosting to work, so please download the .love file under deliverables/KAIROS.love): https://yuuth.itch.io/kairos

## INTRODUCTION

_Description from canvas assignment._ This project's goal is to make a CCCG (Casual Collectable Card Game), or 3CG for short, core gameplay loop. Bits and pieces have been taken from games like Hearthstone, Smash Up, Nova Island, and Dfiance. The theme is Greek Mythology.

## IMPLEMENTATION

### PROGRAMMING PATTERNS

State Pattern - Used for game states (ex: YOUR_TURN, AI_TURN), card states (ex: IDLE, MOUSE_OVER, SELECTED), and button states (IDLE, PRESSED).

Component Pattern - Game objects (card, pile, button) use component systems (position vect or, rendering/drawing every frame, behavior functions).

Object Pool Pattern - Cards are created once in initialize and moved between card piles (board, hand, deck) instead of being created/destroyed every frame.

Command Pattern - The selector system is used for card selection and placement actions with location validation checks. Takes input from mouse buttons.

Observer Pattern - Valid location highlighting automatically updates when a card is selected.

Flyweight Pattern - Card data templates in the Data.lua file are shared between card instances. One single sprite file is used for all card faces.

Factory Pattern - Deck creation creates card instances from data templates.

### FEEDBACK

Reviewer 1: Maddison Lobo \
Comments: Reduce cconditional logic repitition, some if/else statements are repeated in mousePressed and attack logic. Create disabled button visual to indicate player cannot press it during AI turn.\
Reviewer 2: Crystal Tran \
Comments: Show pile power totals on top of each pile. Make a symbol on player cards to show how much power each card has. \
Reviewer 3: Mitchell Pham \
Comments: Instead of outlining each valid location, highlight them or fill them in with a specific color to draw player attention to these spots.

### POSTMORTEM

Please see document titled "deliverables/postmortem.pdf"

### ASSETS

Sprites: All art is made by me. \
Font: https://www.dafont.com/golden-sun.font \
SFX: N/A
MUSIC: N/A
