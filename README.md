# Scorch - Atari 8-bit Scorched Earth clone source code
---------------------------------------------------

Scorch is a multi-player, turn-based, artillery video game. Tanks do turn-based battle in two-dimensional terrain, with each player adjusting the angle and power of their tank turret before each shot.

by Tomasz 'Pecus' Pecko and Pawel 'pirx' Kalinowski

Warsaw, Miami 2000, 2001, 2002, 2003, 2009, 2012, 2013, 2022

Contributors:
- Kaz - splash screen, ideas
- Miker (@mikerro) - game sfx, ideas, QA
- Adam (@6502adam) - font, ideas, QA
- Bocianu (@bocianu) - important ideas, FujiNet implementation, QA
- Emkay - splash screen music
- Fox (@pfusik) - plot and point optimization

QA: Probabilitydragon, KrzysRog, Beeblebrox, EnderDude, lopezpb, Dracon, brad-colbert, archon800, Shaggy the Atarian

You can contact us via [AtariAge](https://atariage.com) or [AtariOnLine](https://atarionline.pl) forums.

This source code was originally compiled under [OMC65 crossassembler](https://github.com/pkali/omc65) and on 2012-06-21 translated to [mads](https://github.com/tebe6502/Mad-Assembler).

Compilation: `mads scorch.asm -o:scorch.xex`


Game source code is split into 5+4 parts:
- scorch.asm is the main game code (with many assorted routines)
- grafproc.asm - graphics routines like line or circle
- textproc.asm - text routines like list of weapons and shop
- variables.asm - all non-zero page variables
- constants.asm - various tables of constants 
- display.asm - display lists and text screen definitions
- ai.asm - artificial stupidity of computer opponents
- weapons.asm - general arsenal of tankies
- definitions.asm - label definitions, moved to make it work better with Altirra debug (it doesn't).

We were trying to use macros, pseudo-ops and simple graphics primitives as much as possible.
This way it should be relatively easy to port this code to e.g. C64

After those N years of working on this piece of code we are sure it would be much wiser to write it in C, Action! or MadPascal but on the other hand it is so much fun to type 150 chars where all you want to have y=a*x+b :)

Originally most variables were in Polish, comments were sparse, but we wanted to release this piece of code to public.
Because of being always short of time/energy (to finish the game) we decided it must go in 'English' to let other people work on it.
It never happened, but we got some encouraging comments and we are still trying to do something from time to time.

With the advent of fujinet (https://fujinet.online/) we are thinking about making the game interplanetary, err, with multiplayer over the net. We'll see.

## Changes:

###### Version 1.00
2022-08-13

Silly Version 1.00
This is an official Silly Venture Summer Edition Atari 50 release. The game reached version 1.00.

The game manual is available at https://github.com/pkali/scorch_src/wiki
All 48KB+ 8-bit Atari computers are supported.

Thank you @Pecusx and @Miker for your hard work over the last few weeks - I was almost entirely absent because of the real-world attack.

Most important changes:
* New Game Over screen with a summary of wins, direct hits and earned cash. https://github.com/pkali/scorch_src/issues/9
* Tank barrels are drawn procedurally to make aiming easier..
* Various SFX and music updates with new tunes for all parts of the game. https://github.com/pkali/scorch_src/issues/112
* AI can use White Flag.
* 3 different tank shapes https://github.com/pkali/scorch_src/issues/64.
* All AI levels are programmed. Cyborg is tough! https://github.com/pkali/scorch_src/issues/40
* New weapon - Long Schlong!
* New splash screen.
* Game mechanics improved.
* [O] key skips to the Game Over screen.
* The game works on Atari 800.
* Huge amount of optimizations to squeeze the game into 48K.

And now the new adventure begins!


###### Build 148
2022-07-17
WHAT DOES THE FOX SAY?

Fox (x0f, @pfusik) says plots and points can be optimized by 18 clock cycles each and thanks to his 6502 wizardry the game is noticeably nicer. Thank you!
Other changes:
- https://github.com/pkali/scorch_src/issues/99, https://github.com/pkali/scorch_src/issues/98 - tank number 6 has got a color now! No one is monochrome now! 
- https://github.com/pkali/scorch_src/issues/110 much improved laser - previously it was almost useless, now it looks and works much better
- fixed an interesting roller bug
- Auto Defense angle fix
- multiple improvements in AI routines, preparation for the final opponents.
 
###### Build 147
2022-07-10
LOST build. We were watching [LOST party](https://www.lostparty.pl/2022/) streams so maybe a little less done, but still some nice improvements.
- new weapons by @Pecusx - Napalm and Hot Napalm. Fire penetrates all shields, so beware!
- status bar showing outdated info on the beginning of the round fix
- various small optimizations incl. memory usage, soildown, weapon ranges
- improved shapes of Heavy and Force Shields

Issues closed:
- revert to the old but slightly improved version of showing angles (#105)
- zero page loading eliminated (#106)
- active player name appear over his tank when aiming (#107)
- configurable mountain heights (The Netherlands, Belgium, Czechia, Switzerland, Nepal) (#86)
- angle speeds up when joystick / keyboard are pressed (#75)

###### Build 146
2022-07-03
Super heavy rewrite build.
Not much changed visually since the last build, but really large parts of the code were rewritten, optimized and improved. A fresh swath of buggies certainly introduced, too. 
- completely new tank falling routine by @Pecusx - over 300 bytes saved, complexity reduced, more just energy deduction when falling.
- silly angle system rewritten to a proper, primary school angling. BTW - I had to dig into 8th grade trig to make it work. About 200 bytes saved, complexity reduced. Next build will have improved angle speed UI. I will also allow for an easier improvement of tank visuals.
- Weapon price and quantity balance - this is our honest attempt to make game more fun. We'll accept any critique and improvement proposals.
- New AI opponent - Tosser! Not much better than Poolshark, but still beats sharks most of the time.
- AI opponents can purchase defensive weapons which make playing against AI somewhat more challenging.
- Improved Laser. It is still not ideal, but better. Still hard to aim :]
- Few small parachute-related bugs fixed
- Death's Head bug fix

Issues closed:
- https://github.com/pkali/scorch_src/issues/87 Angles are reasonable now. PROFIT!!!


###### Build 145
2022-06-26
Possibly last round of weapon additions!

@Pecusx added 
- working White Flag -- it is a way to give up while not making opponents richer!
- Battery - a must for every tank with low energy.
- Strong Parachute - like a normal parachute, but stronger (it has energy and can work more than once)
- Nuclear Winter - a quick and efficient solution to global worming, err, warning, WARMING!

@mikerro added new SFX and in-game-tunes.
- Pressing [S] turns on/off SFX (when aiming). Pressing [M] turns on/off in-game tunes.

Tickets closed:
- https://github.com/pkali/scorch_src/issues/54 - holding a joystick up or down speeds up force change. It makes playing with a joystick much nicer.
- https://github.com/pkali/scorch_src/issues/76 - a beginning of visual tweaks by @6502adam
- infinite defensive weapons purchase bug fixed, to the chagrin of some...

###### Build 144
2022-06-19
Father's day release comes with the most anticipated new feature: defensive weapons. Thanks to @Pecus we have 5 completely new weapons and a more reasonably working parachute. The stub of the instruction manual describing these weapons is available here: https://github.com/pkali/scorch_src/wiki/Instruction-manual.

The new inventory system has been added. Call it by pressing the "I" key or short-pressing fire. Select the weapon to use by moving the joystick or cursor keys right. Switch between offensive and defensive weapons by moving the joystick left. Fire/escape to quit inventory.

Another significant playability change is #54 - it is not finished yet, but keeping the joystick up or down makes force increase/decrease faster. Also - short press of fire calls Inventory, long press fires the shell. The timings are experimental, please let me know if this needs a modification/improvement.

Tickets closed:
* https://github.com/pkali/scorch_src/issues/92 - less unnecessary cleaning of the offensive texts
* https://github.com/pkali/scorch_src/issues/89 - improved collisions with tank
* https://github.com/pkali/scorch_src/issues/71 - ditto
* https://github.com/pkali/scorch_src/issues/11, https://github.com/pkali/scorch_src/issues/26, https://github.com/pkali/scorch_src/issues/8, https://github.com/pkali/scorch_src/issues/20 - new inventory system

###### Build 143
2022-06-05
Rewrite build. We redone several important parts of the game to allow for bug fixes and requested features. Generally it was a great success, but some new bugs appeared. This build is nice for the eye, but beware, no mercy for testers again :)
Only visible changes listed, because you are possibly not as excited as we are for the new Flight routine and ground collisions by @Pecusx.
- https://github.com/pkali/scorch_src/issues/84, https://github.com/pkali/scorch_src/issues/63 - tanks now say good bye properly!
- https://github.com/pkali/scorch_src/issues/74 - Press [ESC] to quit the game at any point, with a confirmation when the round has already started. Please note the keyboard is not checked all the time, so press it for a while, especially when AI tanks are ru(i/n)ning the show.
- https://github.com/pkali/scorch_src/issues/56 - there should be no occurrences of frivolous weapon purchases. Please report all tanks getting their munitions from uncertified sources!
- https://github.com/pkali/scorch_src/issues/47 - It seems that the bad sequence of turns has been ameliorated. Fix is trivial, finding the culprit - far from it. Please pay special attention to fairness of shooting in case the fix is still longing for the fjords.
- ATTRACT mode works how it should - screensaver saves screen only when HUMAN should input something.

###### Build 142
2022-05-30
Late build. The bugs we tried to squelch turned out to be more difficult than usual. Some progress has been made though even if it is not yet visible.
- 4x4 font rewritten by @Pecusx as a prep for Y standarization. It makes the messages to appear faster. This is a good change.
- https://github.com/pkali/scorch_src/issues/5 and #80 fixed (again) - no funkybomb traces staying on the screen
- https://github.com/pkali/scorch_src/issues/70 too strong Shooters fixed
- https://github.com/pkali/scorch_src/issues/63 - tank say goodbye when (mostly) visible
- several other small changes and improvements that will pay off in the following releases.

###### Build 141
2022-05-22
Debug build. Thanks to all testers for finding numerous bugs. We tried to fix some of them and we have introduced some new for your enjoyment.
- https://github.com/pkali/scorch_src/issues/73 Fast forward. Press [START] to speed up the game where it can be sped up. Not in many places, mind you.
- https://github.com/pkali/scorch_src/issues/72 Screen glitches improved
- https://github.com/pkali/scorch_src/issues/70 AI shoot with more force than their energy allows. We might still have to revise this one
- https://github.com/pkali/scorch_src/issues/69 Explosions wrapping around the screen
- https://github.com/pkali/scorch_src/issues/67 Screen glitches after intro
- https://github.com/pkali/scorch_src/issues/65 Saved ~90 bytes by removing cosinus table
- https://github.com/pkali/scorch_src/issues/62 Empty list of defensive weapons gets corrupted. Plunged it with a new defensive weapon - "White Flag". Honor of the tank crew prohibits them from buying it (yet)
- https://github.com/pkali/scorch_src/issues/61 [SHIFT] was repeating the last key
- https://github.com/pkali/scorch_src/issues/57 Fire too sensitive on a real machine. Switched to shadow registers. First recorded use of Atari OS :O
- https://github.com/pkali/scorch_src/issues/55 Glitches in the status bar. This one was surprisingly tough.

###### Build 140
2022-05-15
Huge internal changes by @Pecusx. The whole game screen has been inverted - ground is now background color, "sky" and empty areas are in fact pixels. This allowed for introducing better tank colorization, fully devised and lead by Adam. The process started and results are already promising - the colors of tanks and the status bar are closer. We might get even better ones in the next builds.
- few new sfx added (end of round, weapon change, soil eating weapons)
- added colors to tank name and level selection screen
- Bug https://github.com/pkali/scorch_src/issues/57 possibly alleviated by using TRIG0S instead of TRIG0. Please test - it did not show for me.
Other unlisted minor bugs and typos fixed.
"Nightly" version moved to `develop` branch. `master` will be updated with stablish and playablish builds only.

###### Build 139
2022-05-09
The post midnight release with great, heavy new features:
- https://github.com/pkali/scorch_src/issues/48, https://github.com/pkali/scorch_src/issues/10 - thanks to @mikerro we have a bunch of fresh sound effects. Not everything is perfectly implemented, but the game definitely got nicer! Thank you again Miker!
- https://github.com/pkali/scorch_src/issues/42 New weapon - Liquid Dirt by Pecus. Try it from directly from the weapon store!
- (fix) https://github.com/pkali/scorch_src/issues/53 - non-existing weapons are not displayed. This makes the defense menu empty when you are poor, but it is still better than the old way with "$0" prices
- (fix) https://github.com/pkali/scorch_src/issues/49 - seppuku should always kill now

###### Build 138
2022-05-02
- new version of font from Adam
- 80's style background gradient
- roller procedure refactored in preparation to liquid dirt

###### Build 137
2022-04-29
Premature release due to a trip to Atlanta on weekend.
- https://github.com/pkali/scorch_src/issues/41 Make Riot Charge and Riot Blast weapons. YAY a new weapon after so many years! And it is really useful when you get covered by a ton of dirt
- land-slide optimization by @Pecusx: ~400 bytes and some cycles saved!
- nicer explosions (say that to the target)
- improved `wait` macro to be non-blocking (moving towards asynchronous code :)))
- various memory optimizations - over 9KiB free RAM for further use!

###### Build 136
2022-04-24
This is a very important release because we had a chance to work a bit as an original team (Pecus and pirx). Let's cheer for Pecus for joining the task force again! Changes:
- another sneaky memory corrupting bug found and fixed. The game seems to be as stable as an Ikea table! No bug number because it was super elusive.
- MIRV loops https://github.com/pkali/scorch_src/issues/6 - a very interesting one. It happened when MIRV killed tank exploded with LeapFrog or FunkyBomb.
- Nicer font https://github.com/pkali/scorch_src/issues/37 - Thank you Adam for dugging up the font you made in 2008 :)
- Explosions are 2 times faster and look equally good or maybe even a bit better. This was a drag because of the Death's Head
- Memory map reorganized to extract some free RAM. Currentish map here: https://github.com/pkali/scorch_src/wiki
- Adam shared an archive that preserved a couple of the old build comments! Added below.

###### Build 135
2022-04-17
Happy Easter! This is a "premature ejacu.." err... "premature optimization" build. I got into an optimization fewer and got the code messed up, having to revert to the base. One important ticket closed:
- https://github.com/pkali/scorch_src/issues/35 Two morons shooting each other for more than 5 minutes. Added a new option "Seppuku". It causes one of the tanks ashamed with their inefficiency to detonate the weapon on itself. This was quite a difficult addition, requiring me to understand large swaths of the code, always a great challenge. Smoother gameplay with AIs guaranteed or money back.
Other small fixes:
- https://github.com/pkali/scorch_src/issues/23 High flying MIRV leaves traces. Not anymore.
- https://github.com/pkali/scorch_src/issues/12 Make soil fall down faster after soil eating weapons. Soil eating range is OK, it is the soil down routine that is slow (but visually attractive).

###### Build 134
2022-04-10
- https://github.com/pkali/scorch_src/issues/34 - plot pointer visible only when missile is out of the screen
- https://github.com/pkali/scorch_src/issues/33 - Poor AIs do not purchase non-working weapons
- https://github.com/pkali/scorch_src/issues/32 - Basic is turned off right on the beginning of loading. Dracon reported problems with running the game in Altirra, this was the best idea I had about it. Maybe next will be removing LZSS routine by @dmsc from zero page 
- https://github.com/pkali/scorch_src/issues/31 - STA WSYNC removed from missile flight delay
- https://github.com/pkali/scorch_src/issues/30 - player level remembered between rounds, thx @KrzysRog
- https://github.com/pkali/scorch_src/issues/5 - funkybomb smoke stays on the edges of the screen

###### Build 133
2022-04-03
- bug: https://github.com/pkali/scorch_src/issues/7 tank stands on a single pixel spike. `WhereToSlideTable` vastly improved. 
- enhancement: https://github.com/pkali/scorch_src/issues/15 Add player colors to purchase screen. Still room to improvement!
- enhancement: https://github.com/pkali/scorch_src/issues/22 Redesign information panel (top 2 lines of the game screen). Now game might make some sense for a newcomer :)
- change: https://github.com/pkali/scorch_src/issues/28 remove white lines around out-of-the-screen point tracker. Now it is visible and looks better!
- enhancement: https://github.com/pkali/scorch_src/issues/25 Missiles are too fast. Thanks @bocianu and @mikerro for the hint. Speed of the shell is configurable now, 5 speeds available.
- enhancement: https://github.com/pkali/scorch_src/issues/27 Remember game settings between games.
- enhancement: https://github.com/pkali/scorch_src/issues/24 Remember player names between games. Thanks @bocianu

###### Build 132
2022-03-27
- fixed bug: https://github.com/pkali/scorch_src/issues/21 Wrong number of shells purchased
- fixed bug: https://github.com/pkali/scorch_src/issues/19 Inventory not cleared on next match. When fixing in a general way (cleaning all variables on game restart) I encountered a very old and nasty bug that made the game running basically by pure chance.
- fixed bug: https://github.com/pkali/scorch_src/issues/18 selecting players using fire sometimes selects more than one. Rewritten keyboard handling to prepare for enhancements like #17
- tables of constants moved to a separate file, variables declared with .DS directive in preparation for memory map optimization.

###### Build 131
2022-03-20
- fixed bug: https://github.com/pkali/scorch_src/issues/4 It was really hard one, because I had to unspaghetti our own lousy code :]
- it is now impossible to purchase non-existing weapons.
- numerous edits / optimizations during debugging process
- bug tracker moved to https://github.com/pkali/scorch_src/issues

###### Build 130
2022-03-13
- fixed bug: Decreasing of number of bullets after a shoot does not work correctly. It does look like it is fixed, although all  I did was moving decreasing before shooting. Displaying number of bullets immediately after shoot.
- fixed a very difficult bug - game was crashing from time to time, with corrupted code and/or screen. It was digger digging lower and lower, finally digging through the code. Right now the game is not crashing on me.

###### Build 129
2022-03-06
- added tune by emkay, lzss player by dmsc
- fixed bug "When result in points is >99 then only 2 first digits are displayed"

###### Build 128
2022-02-19
- fixed a bug making it harder to select AI level, unfortunately now player names can not include hyphen
- fixed numerous mistakes in handling bytes and words - possibly some of the crashes eliminated 
- adw addr #1 --> inw addr. 200 bytes shorter code (and maybe very slightly faster)

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
- fokk, just 6 years and we are back!!! This game is pretty addictive :)

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
Again you dear reader made us to do a significant improvement in Atari 8-bit Scorch. Build 113 released! There is a framework for AI ready and you can play with the most stupid opponent - the Mighty Moron!!! Give him a kick and play a little bit! 
- AI Opponents move barrels to the right position
  before firing a bullet.
- Purchase screen is not displayed for AI opponents.
- There is a 2 sec delay after displaying
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

##### Build 110
2003-07-21
Previous release was a mistake. Build 110 is more or less playable, the "only" problem for now is such: in every round there is the same sequence of shooting (1st, 2nd, 3rd tank and so on). It should be like the weakest tank shoots first.

##### Build 103
2003-07-09
For the first time Scorched Earth for Atari XL/XE (build 103) published.
Together with Pecus we were working on this piece of code for four years and it does not look like it is accelerating so we decided to publish what we have. Last few weeks I was translating source code comments and labels to English to let other people work on this project with us. In other words Scorched Earth becomes an open source project :)
Now it's your turn to help this idea happen!

...transmission error...former history missing...