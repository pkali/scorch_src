# Basic instruction manual:

You can play using the keyboard (all functionality) or the joystick in the first port (all functionality necessary for gameplay).

## 1. Game Option Selection.

On the first screen, you can configure gameplay options:
* number of players (2 - 6) includes both human and computer-controlled players
* the initial amount of cash of each player (2K is the optimal value we chose, but for short games, it is worth choosing a higher value)
* gravity
* maximum wind strength (wind is drawn at the beginning of each round, here you can choose how strong it can be)
* number of rounds in a game
* missile speed (does not affect the flight path - only changes the apparent missile speed - does not change anything in the gameplay itself)
* frequency of suicides :) - if for a number of turns the game has not recorded hits (tanks are constantly shooting inaccurately), after one of such misses a tank commits suicide - here you determine how long they can "shooting for the stars" :) - if only people play the optimal setting is "norm", in the case of computer-controlled players ... you choose.
* The height (and undulation) of the mountains from almost flat (NL - Kingdom of the Netherlands), to soaring and high (NP - Federal Democratic Republic of Nepal)
* the way the walls (edges of the screen) work:
    * none - projectiles that flew off the screen do not return (black color of the screen frame)
    * wrap - the screen "wraps" and projectiles that flew to the right appear on the left side and vice versa (purple color of the screen frame)
    * bump - the right and left walls deflect projectiles that want to fly through them (dark blue color of the screen frame)
    * boxy - just like bump, except that the "ceiling" also reflects projectiles (green color of the screen frame)
    * rand - at the beginning of each round, one of the above 4 ways the walls work is drawn.

    During gameplay, the current mode of the walls is represented by the color of the screen frame: none - black, wrap - purple, bump - dark blue, boxy - green.

Select options with cursor keys or a joystick.

The [RETURN] key or a joystick button moves to the next screen.

## 2. Entering the name of players and selecting the level of computer-controlled players

The second screen is shown for each player. Here you can use the cursor keys or joystick to select whether the tank will be driven by a human (HUMAN option) or a computer (other options). At the same time, you can enter the name of the selected player from the keyboard.
When the [RETURN] key is pressed or the Joystick button is pressed briefly, the screen switches to the next player until the difficulty levels for each player are selected.
The player's name can also be entered with the joystick. After pressing and holding the button for more than 1s. you can use up/down movements to change the letter being entered, and left/right movements to change its position in the name. Releasing the button ends the name entry and returns to the level selection.

If the name is not entered, it will be supplemented with the default name.

## 3. Shopping screen (before each round)

On this screen, you can make purchases of offensive and defensive weapons. Only those weapons that the player can afford are visible, along with information about the price and the number of units of a given weapon that will be obtained for that price. The information on the screen probably needs no more description. You move through the lists with the cursor keys (up and down) or with the joystick, the [TAB] key or the left arrow or the left joystick tilt change the screen to defensive or offensive weapons, the [SPACE] key or the right arrow and also the joystick to the right does the purchase of the indicated weapon.

The [RETURN] key or the joystick button press switches to the defensive weapon activation screen. Here you can activate previously bought defensive (or offensive after switching with [TAB], etc) weapons. This makes it possible to activate shields and others before the round starts.

Another [RETURN] key or joystick button press switches to the next player's shopping screen.
(For computer players this screen is not shown.)

## 4. The main screen of the game

The status line shows which player is currently allowed to take a shot and a set of other information:
* player's tank name,
* currently selected offensive weapon,
* the player's remaining energy points and if he has an active defensive weapon that has its energy - in parentheses the energy level,
* the angle and the direction of the barrel set by the player,
* the shot strength set by the player (the maximum shot strength is limited by the player's energy - it can not exceed the energy * 10 . This means that you can fire weaker shots only when having a small amount of energy,
* the current round number,
* wind speed and direction,
* in parentheses is the name of the active defensive weapon - if there is any activated by the player.

The keyboard controls here are simple, cursor keys or joystick: left/right - change the angle of the barrel, up/down - change the the force of the shot.

| A800 | 5200 | function |
| --- | --- | --- |
| [SPACE] | [0] | or joystick button pressed briefly - firing a shot. |
| [TAB] or [SELECT] | [5] | selection of offensive weapons (this option is not available directly with the joystick - you need to select Inventory) |
| [I] | [9] | or longer holding the joystick button - go to Inventory. It is a screen (actually two) with the same layout as the shopping menu, it also works similarly except that here you don't buy weapons, but choose one of the offensive ones to shoot or activate a defensive weapon. |
| [A] or [OPTION] | [7] | go directly to the defensive weapons activation.
| [M] | [PAUSE] | disable/enable background music. |
| [S] | [RESET] | disable/enable effect sounds. |
| [START] | N/A | speed up some game animations. |
| [O] | [3] | end the current game and jump to the Game Over screen with a summary. The summary of the results does not take into account the current round of the game, but only the rounds completed earlier. This corresponds to pressing the [ESC] key with the difference that the summary and credits are displayed. |
| [START] + [OPTION] | N/A | immediately force the end of the game (Game Over), just like [O] but without confirmation.
| [ESC] | [*] | during the entire game at any time (unless the computer is playing, then sometimes you have to wait a while) you can press the [ESC] key, which allows you to abort the game and return to the beginning (of course, there is protection against accidental pressing). |

## 5. Game mechanics - offensive weapons

### Energy of tanks.
- At the beginning of each round, each tank has 99 ash units of energy.
- Tanks' energy is depleted in 3 ways:
    * one unit after each shot is fired
    * while falling (one pixel down - 2 units).
    * when a projectile hits the tank or next to it - and here the amount of energy subtracted depends on the distance from the center of the explosion and the type/power of the projectile.

### How energy subtraction works (and earning money!).
After each round the amount of money gained/lost is calculated, this is done on the basis of two variables accumulated by each tank during the round. These variables are:

`gain` - energy "captured" from tanks hit (also if you hit yourself :) and here's the catch, if you have very little energy left it can be profitable to hit yourself with a powerful weapon!

`lose` - energy lost due to explosion/fall (and here it is important - to count the total loss of energy even if the tank has less at the moment of hit).

In addition, the tank that won the round has a parameter gain (captured from hit tanks energy) increased by the remaining energy at the end of the round (because it did not die and should have it - although it also happens otherwise :) )

Specifically:

### After each round:
`money = money + (20 * (gain+energy))`.

`money = money - (10 * lose)`.

`if money <0 then money=0`.

(at the start of each round `gain` and `lose` have a value of 0).

During a round, if another tank is hit as a result of a shot fired by a tank, the tank firing the shot "gets the energy" taken away from the hit tank.
### tank taking a shot:
`gain = gain + EnergyDecrease`.
### tank hit:
`lose = lose + EnergyDecrease`.

Where `EnergyDecrease` is the loss of energy due to the hit.

Of course, at the same time the hit tank loses the amount of energy stored in `EnergyDecrease`, except that here the loss cannot exceed the energy you have.

## How a hit works.

Each weapon that results in an explosion has its own blast radius.

After the explosion, every tank in its range loses energy.

It works in such a way that if the hit is exactly on the center point of the tank `EnergyDecrease` receives the maximum value for the weapon, and for each pixel of distance from the center of the tank this value is reduced by 8.

For example, if a hit with the Baby Missile weapon hits the center of the tank perfectly, it will lose exactly 88 units of energy (plus what it loses falling after the explosion).
If you hit with the same weapon at a distance of 10 pixels from the center of the tank, the loss will be only 8 units.

And here are the values of maximum energy loss for individual weapons. If a weapon explodes several times, each explosion is calculated independently (additional values in the table):

| Offensive weapons | maximum energy loss |
| --- | --- |
| Baby Missile | 88 |
| Missile | 136 |
| Baby Nuke | 200 |
| Nuke | 240 |
| LeapFrog| 136 120 104 |
| Funky Bomb | 168 88 (* 5) |
| MIRV | 136 (* 5) |
| Death's Head | 240 (* 5) |
| Napalm | 40 (this weapon is different and the distance from the center is not determined, simply any tank in range of the flames loses 40 units of energy) |
| Hot Napalm | 80 (the rule is the same as in Napalm) |
| Baby Roller | 88 |
| Roller | 168 |
| Heavy Roller | 240 |
| Riot Charge | 0 (no energy is subtracted, but a portion of the ground upward from the hit point in a 31-pixel radius is removed) |
| Riot Blast | 0 (as in Riot Charge, but in a radius of 61 pixels) |
| Riot Bomb | 0 (no energy is subtracted, but the ground in a radius of 17 pixels from the hit point is destroyed - as in the case of Missile. The weapon is useful for digging out after being buried, or for undermining an opponent) |
| Heavy Riot Bomb | 0 (as in Riot Bomb, but the explosion radius is 29 pixels from the point of impact - as in the case of Nuke) |
| Baby Digger | 0 (no energy is subtracted, but a portion of the ground is undermined in a radius of 60 pixels from the point of impact) |
| Digger | 0 (as above - greater undermining) |
| Heavy Digger | 0 (as above - greatest undermining) |
| Baby Sandhog | (as above - another way of undermining) |
| Sandhog | 0 (as above - larger dig) |
| Heavy Sandhog | 0 (as above - largest dig) |
| Dirt Clod | 0 (no energy is subtracted, but a ground ball with a radius of 12 pixels from the hit point is created. The weapon is useful for burying the opponent) |
| Dirt Ball | 0 (as above, but the radius of the ball is 22 pixels) |
| Ton of Dirt | 0 (as above, but the radius of the ball is 31 pixels) |
| Liquid Dirt | 0 (floods the ground at the point of hit with liquid soil, filling in the depressions) |
| Laser | x 100 (but here it is also different - equally 100 only in the case of a direct hit simply subtract 100 units of energy - that is, the tank always dies) |

Large points received by the player is the number of tanks that died earlier than him. If any of the other tanks capitulated earlier (**White Flag**) is not added to those that died and does not give points.
Only these points determine the order in the summary

## 6. And now for defensive weapons:

* **White Flag** - causes the surrender of the player (can sometimes be useful in a hopeless situation). The advantage is that by surrendering you don't give a big point to your opponents and don't cause one of them to gain by killing us, you also limit the loss of your energy and also cash. An important note - this is the only defensive weapon that can be deactivated. All you have to do is re-enter inventory and once again select its activation.
* **Battery** - when activated, it recharges the tank's energy to full (99 units) and at the same time is the only defensive weapon that does not deactivate other defensive weapons when used.
* **Hovercraft** - a weapon that allows the tank to move. It has its own fuel supply in form of electric eels and in addition, it can be activated multiple times during the same turn, and after using it, you can activate another defensive weapon and fire a shot in the same turn. After using it, the tank rises above the mountains and using the cursor keys or a joystick you can move the tank to a new position. [SPACE] or the joystick button cause the tank to land in a new place. You can fly until the tank runs out of eels (presented on the status bar like the energy of a defensive weapon), if the eel fuel runs out the tank will fall down on its own. It is not possible to land on other tanks.
* **Parachute** - does not protect against loss of energy due to a neighboring explosion, makes you not lose energy during ONE fall. After such a fall, it deactivates and a new parachute must be activated.
* **Shield** - the simplest shield works exactly the opposite of **Parachute**, it does not protect against energy loss while falling, instead it protects against energy loss caused by ONE adjacent explosion. It protects once, no matter how strong the explosion is (whether tis but a scratch or a direct hit with a nuke), and deactivates immediately afterward.
* **Heavy Shield** - a shield with its own energy (at the start of 99 units), it works the same as **Shield** (does not protect against falling) with the exception that it has its own energy resource. When exploding, the energy of this shield is reduced first, and if it reaches 0, the shield deactivates and further reduces the tank's energy. Due to this action, a tank with this type of shield can be "killed" by undermining it, because falling reduces the energy of the tank and not the shield.
* **Force Shield** - the strongest shield - works just like Heavy Shield only that it is combined with **Parachute**. What is important in this case, falling does not take energy away from the shield or the tank. It is only taken away by hits.
* **Bouncy Castle** - a passive-aggressive weapon :). It works as follows - in a case of a direct tank hit (and shield), it causes the projectile to "bounce" in the opposite direction with the same force with which it was fired. In the absence of wind and a difference in level, the weapon then hits the tank that fired it. After such a bounce, it deactivates. As the weapon reacts in this way only to precise hits, it is also works like **Heavy Shield** and has 99 units at the start (we will probably have to rethink this value and give a smaller one here).
* **Mag Deflector** - the second passive-aggressive weapon :) . In case of a direct hit on a tank (and shield), it causes the hit point to move randomly to the left or right side of the protected tank, but not very far, so you can get "shrapnel" with stronger weapons. As in the case of **Bouncy Castle**, it is also a shield that corresponds to the action of **Heavy Shield** and has 99 units at the start (probably here we will have also to rethink this value and give a smaller one).
* **Nuclear Winter** - adds nothing, takes nothing away :) - in fact, it is not so much a defensive weapon as a double-edged one. It floods the area with "radioactive" fallout, which is ordinary soil. If you do not have at hand any weapon that digs up the terrain, and for that a shield (preferably disposable), then after such "fallout" you will have to shoot yourself - because being underground is otherwise impossible. Alternatively, **White Flag** always remains.
* **Long Schlong** - a special weapon :) - Costs a lot, doesn't really help with anything (except possibly digging yourself out but only when slightly buried but it has a cool name and looks cool :) - It can be activated independently of other defensive weapons and remains active until the end of the round (it cannot be deactivated).
* **Lazy Boy** - it is not actually a defensive weapon. It is an aiming aid. When it is activated, the tank tries to aim at the nearest enemy and automatically adjusts the power of the shot and angle. If it has too little energy, it can sometimes aim wrong (it uses a method like **Cyborg** to aim). Like **Battery**, it does not deactivate other defensive weapons when used. Note: There is no point in activating this weapon before the round, targeting will not take place because there is nothing to target yet.
* **Lazy Darwin** - works exactly like **Lazy Boy** but targets the weakest opponent.

Due to the different operations of **MIRV**, defensive weapons **Bouncy Castle** and **Mag Deflector** only use the shielding function when hit by these weapons. In addition, **MIRV** heads do not bounce or fly through sidewalls during descent!

None of the shields protect against **Napalm**. **Bouncy Castle** or **Mag Deflector** on a direct hit will deflect it or carry it past, but just hit very close to a tank and its shield will not save it.

**White Flag**, **Hovercraft** and **Nuclear Winter** weapons, when selected, require activation, this is accomplished by "firing a shot" after the selection of that weapon. Of course, the shot of the offensive weapon is then not fired, but only the selected defensive weapon is activated.

You can only have one defensive weapon active at a time (except **Long Schlong** of course :) ). You can always change the decision and activate another defensive weapon or deactivate **White Flag** before firing.

And of course, activating a weapon when you already have some other weapon activated causes the loss of the previous one (no returns :) ).

## 7. "Other" weapons:

* **Buy me!** - this is a 'loot box', not a weapon per se. Buying it draws one of the offensive or (rarely) defensive weapons and adds it to the player's arsenal. It is a lottery in which you can lose (if you draw a weapon cheaper than the **Buy Me!** price) but also gain. You can get a weapon otherwise not affordable at all! 

## 8. difficulty levels of computer-controlled opponents:

The game has 8 difficulty levels of computer-controlled opponents. Or actually 7 different ones and one "surprise". Each has its own way of buying defensive and offensive weapons and a different method of target selection and targeting itself, as well as weapon selection. They are arranged in the list according to increasing "skills":

* **Moron** - the dumbest of opponents (which does not mean the safest). Shoots completely at random using only one weapon - **Baby Missile**. He doesn't buy anything and doesn't know how to use defensive weapons.

* **Shooter** - This opponent does not shoot blindly. He chooses one direction for himself. Based on his own position - he shoots in the direction from which there is more space assuming that this is where the other tanks are. He starts firing from a high angle and shot after shot changes this angle to a lower and lower angle trying to fire the entire area on the chosen side. He always fires with the best weapon he has (the highest on the list of weapons he has - that is, not necessarily the best). He does not use defensive weapons even though he buys them! At the beginning of the round, he makes 1 attempt to buy defensive weapons (only from the **Battery** - **Strong Parachute** range) and 4 offensive weapons (from the **Missile** - **Heavy Roller** range).

* **Poolshark** - When attacking, he sets the nearest tank as his target, then selects the angle of the shot, and tries to select its strength by drawing it from the selected range. He always shoots with the best weapon he has. He uses defensive weapons. With a probability of 1:3, he activates the best defensive weapon he owns (the highest on the list of weapons he owns - that is, not necessarily the best) before firing. If his energy level drops below 30 units - he uses **Battery** (of course, if he bought it before), if the energy drops below 5 and he has no **Battery** he surrenders - **White Flag**. At the beginning of the round he makes 1 attemp to buy defensive weapons and 6 offensive weapons.

** **Tosser** - When attacking, he acts exactly like **Poolshark** however, he may have a "better" weapon inventory due to a different purchase tactic. He always activates the best defensive weapon he has before shooting. And just like **Poolshark** he uses **Battery** and **White Flag**. At the beginning of the round, he assesses how much money he has and depending on that, he makes (money/5100) attempts to buy defensive weapons and then checks again how much money he has left and makes (money/1250) attempts to buy offensive weapons.

** **Chooser** - Takes as a target the weakest opponent (with the least amount of energy) and aims very precisely, but before the shot the energy of the shot is modified by the parameter of luck :) , that is, despite the precise aiming it does not always hit. He shoots with the best weapon he has unless the target is close. Then he changes his weapon to **Baby Missile** to avoid hitting himself. He always activates the best defensive weapon he has before shooting and, like **Poolshark**, uses **Battery** and **White Flag**. He purchases just like **Tosser**.

* **Spoiler** - He shoots exactly like **Chooser** except that he has more luck :) , which means that even if he doesn't hit the target of his choice, it can be a more precise shot than **Chooser**. He uses defensive weapons exactly like **Chooser**. At the beginning of the round, he assesses how much money he has and depending on that, he makes (money/5100) attempts to buy defensive weapons and then checks again how much money he has left and makes (money/320) attempts to buy offensive weapons. When buying defensive weapons, he buys only strong and precise weapons - that is, weapons that won't accidentally hurt him.

** **Cyborg** - Takes aim at the weakest opponent (with the least amount of energy) but prefers human-controlled opponents. Aims very accurately and in the vast majority of cases hits on the first shot. He fires the shot with the best weapon he has unless the target is close. Then he changes his weapon to **Baby Missile** to avoid hitting himself. He uses defensive weapons exactly like **Chooser**. He shops exactly like **Spoiler**.

* **Unknown** - Before firing each shot, he randomly chooses a course of action from **Poolshark** to **Cyborg** and applies his tactics. However, the tactics of weapon purchases are always identical to **Tosser**.

Trying to buy a weapon (offensive or defensive) is as follows:
First, one of the weapons is drawn (among all possible offensive or defensive weapons). Then a check is performed to see if the drawn weapon is in the list of weapons possible for purchase by the tank. If not, no weapon is bought in this trial, and if so, its price is checked. If the tank has that much money, the weapon is bought, otherwise the trial ends without making a purchase.

Table of weapons purchased by: **Shooter**, **Poolshark**, **Tosser** and **Chooser**.

| Offensive weapons | Defensive weapons |
| --- | --- |
| Missile | Battery |
| Baby Nuke | Parachute |
| Nuke | Strong Parachute |
| LeapFrog | Mag Deflector |
| Funky Bomb | Shield |
| MIRV | Heavy Shield |
| Death's Head | Force Shield |
| Napalm | Bouncy Castle |
| Hot Napalm | |
| Baby Roller | |
| Roller | |
| Heavy Roller | |

Table of weapons purchased by: **Spoiler** and **Cyborg**.

| Offensive weapons | Defensive weapons |
| --- | --- |
| Missile | Battery |
| Baby Nuke | Strong Parachute |
| Nuke | Mag Deflector |
| Hot Napalm | Heavy Shield |
| | Force Shield |
| | Bouncy Castle |
