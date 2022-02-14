# Atari 8-bit Scorched Earth source code
---------------------------------------------------
by Tomasz 'pecus' Pecko and Pawel 'pirx' Kalinowski

Warsaw, Miami 2000, 2001, 2002, 2003, 2009, 2012, 2013, 2022

you can contact us at pecus@poczta.fm or pirx@5oft.pl
home page of this project is https://github.com/pkali/scorch_src

this source code was compiled under OMC65 crossassembler 
(https://github.com/pkali/omc65)
and on 2012-06-21 translated to mads

game source code is split into 5+1 parts:
- scorch.asm is the main game code (with many assorted routines)
- grafproc.asm - graphics routines like line or circle
- textproc.asm - text routines like list of weapons and shop
- variables.asm - all non-zero page variables and constants
- display.asm - display lists and text screen definitions
- ai.asm - artificial stupidity of computer opponents

we were trying to use as much macros and pseudo-ops as possible
they are defined in atari.hea and macro.hea files together with many
atari constants. This way it should be relatively easy to
port this code to e.g. C64

After those N years of working on this piece of code
we are sure it would be much wiser to write it in C, Action!
or MadPascal but on the other hand it is so much fun to type 150 chars
where you want to have y=ax+b :)

originally most variables were in Polish, comments were sparse
but we wanted to release this piece of code to public
and due to being always short of time/energy (to finish the game)
we decided it must go in 'English' to let other people work on it

## Changes:


###### Build 127
2022-02-14
- option to select number of rounds in a game
- rudimentary game over message (in results screen)
- game restarts

###### Build 126
2022-01-30
- fixed bug 006 (After some attacks the OffensiveText stays on the screen)
- fixed bug 015 (Only first shoot of FunkyBomb is correct
- fixed bug 016 (No falling soil after leapfrog)


##### Build 125
2022-01-23
- included splash screen by KAZ


##### Build 124
2013-12-21
- removed large chunk of redundant 4x4 print code and table generation code,
  over 1kb gained.
- plot and point routines speeded up by ~20 cycles :P (and shortened by few bytes as well)
- fixed bug 011. High flying bullets sometimes cause brief screen garbage - like a DL damaged
  fixed by plotpointer (the top line) changed from HSCROLL based to regular $f line with plot
- screen memory moved to low area ($1010), making the game start at $3010 and easier
  to be loaded. Other minor memory layout modifications.

##### Build 123
2013-12-10
- fixed bug 013: sometimes demo mode does not work (it stops on results display)
- fixed bug 012: (newly introduced) Death explosions are offset right and possibly up.
- prepared the game for various screen width. The only problem is memory layout.
  Basically it is impossible to make contiguous wide screen of more than 170 lines.
  Changing the screen to non-contiguous would require rewrite of all character
  manipulating routines.
- fixed bug 014: FunkyBomb shoots with too high angle, 
  funkyBomb angle changed from -8..+8 to -16..+16
- speeded up explosions by drawing only odd circles. Not bad visually and 2x faster.

##### Build 122
2013-11-17
- tank expend 1 energy with each shoot to avoid endless shooting loops
- small visual glitch with background colour fixed
- death messages "defensive texts" in source do not stay on screen after some explosions

##### Build 121
2013-11-10
- Poolshark and Shooter can buy weapons
- Purchase screen moved to the beginning of the round

##### Build 120
2013-11-09
SillyVenture 2K13 joint effort to bring artificial intelligence into life:
- Shooter and Poolshark shooting programmed
- several small bugfixes and improvements as proposed by SillyVenture crowd 

##### Build 119
2012-06-17
Scorch sources translated to MADS with the sweet repl.sh script.

MISSING UPDATE INFORMATION... POSSIBLY NOTHING IMPORTANT HAPPENED HERE.

##### Build 115
2009-08-25
- fixed bug 001 (lack of explosions on the empty ground)
- fixed bug 003 (wrapping death's head explosions)
- fixed plot (faster explosions)
- fukk, just 6 years and we are back!!! This game is pretty addictive :)

TO DO:
- send our wives and kids away much more often :))))

##### Build 114
2003-08-22
- Results after each round are displayed in the right
  sequence, i.e. the best one is on the top
- during second and following rounds shooting sequence
  is such that the worst tank shoots first

The above changes does not look terrific, but there was
a lot of thinking to do it correctly. What is the most
important the overall game feeling improved a lot!

program.s65
- added routine SortSequence

textproc.s65
- changed routine DisplayResults to show round results in correct order

##### Build 113
2003-08-17
- AI Opponents move barrels to the right position
  before firing a bullet.
- Purchase screen is not displayed for AI opponents.
- There is 2 sec delay after displaying
  "Defensive" text i.e. text before death

program.s65
- added routine MoveBarrelToNewPosition which rotates barrel of the tank until it sits at the right (newly randomized) angle

textproc.s65
- added routine PurchaseAI it is a framework for all AI purchases

SHORTSYS.S65
- new macro PAUSE (waits given number of frames)


##### Build 112
2003-08-15

First attempts to create a framework for intelligent
opponents (AI). Right now there is only one level
of "intelligence" - Moron. 

Moron shoots at random angle with random force.

program.s65
- routine Round checks the Skill level and if it is not human branches to ArtificialIntelligence routine.
- new routines:
    - ArtificialIntelligence
    - RandomizeForce
    - RandomizeAngle

TO DO:
- nice rotating barrel of AI tank
- AI weapon purchase and usage
- AI better than Moronic... (but how...)
- tanks' shooting sequence should be from weakest to the strongest, not random

##### Build 111
2003-07-27

program.s65:
- added sequential shooting (not necessarily tank no. 1 shoots first)
- added routine "RandomizeSequence" that is called before each round
- initial angle of the tank's barrel is randomized (was always 45 degrees right)

variables.s65
- added table "TankSequence"

grafproc.s65
- shorter delay during Flight

...older history missing...