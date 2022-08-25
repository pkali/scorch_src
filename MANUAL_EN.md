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
    * none - projectiles that flew off the screen do not return
    * wrap - the screen "wraps" and projectiles that flew to the right appear on the left side (and vice versa)
    * bump - the right and left walls deflect projectiles that want to fly through them
    * boxy - just like bump, except that the "ceiling" also reflects projectiles
    * rand - at the beginning of each round, one of the above 4 ways the walls work is drawn.

    During gameplay, the current mode of the walls is represented by the color of the screen frame: none - black, wrap - purple, bump - blue, boxy - green.

Select options with cursor keys or a joystick.

The [RETURN] key or a joystick button moves to the next screen.

## 2. Entering the name of players and selecting the level of computer-controlled players

The second screen is shown for each player. Here you can use the cursor keys or joystick to select whether the tank will be driven by a human (HUMAN option) or a computer (other options). At the same time, you can enter the name of the selected player from the keyboard.
When you press the [RETURN] key or the joystick button, the screen switches to the next player until the difficulty levels for each player are selected.

If the name is not entered (because, for example, you use a joystick only), it will be supplemented with the default name.

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
* [SPACE] or joystick button pressed briefly - firing a shot.
* [TAB] or [SELECT] - selection of offensive weapons (this option is not available directly with the joystick - you need to select Inventory).
* [I] or longer holding the joystick button - go to Inventory. It is a screen (actually two) with the same layout as the shopping menu, it also works similarly except that here you don't buy weapons, but choose one of the offensive ones to shoot or activate a defensive weapon.
* [A] or [OPTION] - go directly to the defensive weapons activation.
* [M] key - disable/enable background music.
* [S] key - disable/enable effect sounds.
* [START] - speed up some game animations.
* [O] - end the current game and jump to the Game Over screen with a summary. The summary of the results does not take into account the current round of the game, but only the rounds completed earlier. This corresponds to pressing the [ESC] key with the difference that the summary and credits are displayed.
* [START] + [OPTION] - immediately force the end of the game (Game Over), just like [O] but without confirmation.
* [ESC] - during the entire game at any time (unless the computer is playing, then sometimes you have to wait a while) you can press the [ESC] key, which allows you to abort the game and return to the beginning (of course, there is protection against accidental pressing).

## 5. Game mechanics 

And here's a rundown of the description of how each weapon works, scoring rules, etc:

### First, what we know about tank energy
- Tanks have energy (and Ogres have layers - like an onion) - 99 units at the start of a round.
- Energy of tanks is depleted in 3 ways:
    * one unit after firing each shot,
    * while falling (one pixel down takes 2 units of energy),
    * when a projectile hits a tank or its proximity. The amount of energy subtracted depends on the distance from the center of the explosion and the type/power of the projectile.

### How energy subtraction works (and makes money!)

After each round, the amount of money gained/lost is calculated. This is done on the basis of two variables accumulated by each tank during the round. These variables are:

`gain` - energy "captured" from hit tanks (also when you hit yourself :) and here's the catch, if you have very little energy left it may be profitable to hit yourself with a powerful weapon!

`lose` - energy lost due to explosion/fall (important - the total potential loss of energy is taken into account even if the tank has less at the time of the hit).

In addition, the tank that won the round has a `gain` parameter (captured energy from tanks hit) increased by the energy remaining at the end of the round (because it did not die and should have it - although the survival of the fittest is not guaranteed :) )

Specifically:

### After each round:
`money = money + (2 * (gain + energy))`

`money = money - lose`

`if money < 0 then money = 0`

(at the start of each round `gain` and `lose` have a value of 0)

During a round, if another tank is hit as a result of a shot fired by a tank, the tank firing the shot "gets the energy" taken away from the hit tank.

### For tank firing a shot:

`gain = gain + EnergyDecrease`

### Tank being hit:

`lose = lose + EnergyDecrease`

Where `EnergyDecrease` is the loss of energy due to a hit.

Of course, at the same time, the hit tank loses the amount of energy stored in `EnergyDecrease`, except that here the loss can not exceed the energy held.

Note that the screen representation of money has an extra 0 added at the end so you actually have 10 times more cash than the above calculation shows :)

## How the hit works.

Each weapon that results in an explosion has a radius of fire (`ExplosionRadius`).

After the explosion, every tank in its range loses energy.

The way it works is that the distance of the hit tank from the center of the explosion is calculated, the `ExplosionRadius` reduced by this distance is multiplied by 8 and the result is `EnergyDecrease`.

That is, in the case of hitting a tank centrally:
`EnergyDecrease = ExplosionRadius * 8`
and with each pixel farther from the center, 8 fewer units are lost.

I don't know if it's understandable - I do understand it :)

For example, if a tank is hit centrally with a Baby Missile - it is subtracted 88 units of energy (11 * 8), which also means that when this missile hits at a distance of 12 pixels from the tank - it does not lose energy at all.

And here are the `ExplosionRadius` values for each weapon:

| Weapon | `ExplosionRadius` |
| --- | --- |
| Baby Missile | 11 |
| Missile | 17 |
| Baby Nuke | 25 |
| Nuke | 30 |
| LeapFrog| 17 15 13 |
| Funky Bomb | 21 11 (* 5) |
| MIRV | 17 (* 5) |
| Death's Head | 30 (* 5) |
| Napalm | x 40 (this weapon is different and the distance from the center is not determined, simply any tank within range of the flames loses 40 units of energy - the ExplosionRadius variable is not used) |
| Hot Napalm | x 80 (the same principle as in Napalm) |
| Baby Roller | 11 |
| Roller | 21 |
| Heavy Roller | 30 |
| Riot Charge | 31 |
| Riot Blast | 0 (in reality - 61 but with these weapons it is not taken into account when counting energy loss only the width of the ground to fall) |
| Riot Bomb | 17 |
| Heavy Riot Bomb | 29 |
| Baby Digger | 0 (60 - as in Riot Blast) |
| Digger | 0 (60 - as above) |
| Heavy Digger | 0 (60 - as above) |
| Baby Sandhog | 0 (60 - as above) |
| Sandhog | 0 (60 - as above) |
| Heavy Sandhog | 0 (60 - as above) |
| Dirt Clod | 12 |
| Dirt Ball | 22 |
| Ton of Dirt |  31 |
| Liquid Dirt | 0 (maybe it's worth changing?) |
| Dirt Charge | 0 (61 - as above) |
| Laser | x 100 (but here it is also different - equally 100 only in the case of a direct hit, the `ExplosionRadius` variable is not used, so there is no multiplication by 8 - we simply subtract 100 units of energy - that is, the tank always dies).|

The big points received by the player are the number of tanks that died earlier than him. If any of the other tanks capitulated earlier (using **White Flag**), it is not counted and does not give big points.

Only these big points determine the order in the summary.

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

Due to the different operations of **MIRV**, defensive weapons **Bouncy Castle** and **Mag Deflector** only use the shielding function when hit by these weapons. In addition, **MIRV** heads do not bounce or fly through sidewalls during descent!

None of the shields protect against **Napalm**. **Bouncy Castle** or **Mag Deflector** on a direct hit will deflect it or carry it past, but just hit very close to a tank and its shield will not save it.

**White Flag**, **Hovercraft** and **Nuclear Winter** weapons, when selected, require activation, this is accomplished by "firing a shot" after the selection of that weapon. Of course, the shot of the offensive weapon is then not fired, but only the selected defensive weapon is activated.

You can only have one defensive weapon active at a time (except **Long Schlong** of course :) ). You can always change the decision and activate another defensive weapon or deactivate **White Flag** before firing.

And of course, activating a weapon when you already have some other weapon activated causes the loss of the previous one (no returns :) ).

## 7. "Other" weapons:

* **Buy me!** - this is a 'loot box', not a weapon per se. Buying it draws one of the offensive or (rarely) defensive weapons and adds it to the player's arsenal. It is a lottery in which you can lose (if you draw a weapon cheaper than the **Buy Me!** price) but also gain. You can get a weapon otherwise not affordable at all! 
