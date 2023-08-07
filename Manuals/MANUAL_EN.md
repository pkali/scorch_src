# Basic instruction manual:

You can play using the keyboard (all functionality) or the joystick in the first port (all functionality necessary for gameplay).


## 1. Game Option Selection.
![Game options screen.](images/MainMenu.png)
On the first screen, you can configure gameplay options:

* **Players** - number of players (2 - 6) includes both human and computer-controlled players

* **Cash** - the initial amount of cash of each player (2K is the optimal value we chose, but for short games, it is worth choosing a higher value)

* **Gravity** - strength of gravity

* **Wind** - maximum wind strength in Beaufort scale (wind is drawn at the beginning of each round or during the round between turns, here we can choose how strong it can be):
    * 1B - maximum wind strength: 5
    * 3B - maximum wind strength: 20
    * 5B - maximum wind strength: 40
    * 7B - maximum wind strength: 70
    * 9B - maximum wind strength: 99

* **Rounds** - number of rounds in a game

* **Missiles** - missile speed (does not affect the flight path - only changes the apparent missile speed - does not change anything in the gameplay itself)

* **Seppuku** - frequency of suicides :) - if for a number of turns the game has not recorded hits (tanks are constantly shooting inaccurately), after one of such misses a tank commits suicide - here you determine how long they can "shooting for the stars" :) - if only people play the optimal setting is "norm", in the case of computer-controlled players ... you choose.

* **Mountain** - The height (and undulation) of the mountains from almost flat (NL - Kingdom of the Netherlands), to soaring and high (NP - Federal Democratic Republic of Nepal)

* **Walls** - the way the walls (edges of the screen) work:
    * **none** - projectiles that flew off the screen never return (black color of the screen frame)
    * **wrap** - the screen "wraps" and projectiles that flew to the right appear on the left side and vice versa (purple color of the screen frame)
    * **bump** - the right and left walls deflect projectiles that try to fly through them (dark blue color of the screen frame)
    * **boxy** - just like bump, except that the "ceiling" also bounces projectiles off (green color of the screen frame)
    * **rand** - at the beginning of each round, one of the above 4 ways the walls work is drawn.

    During gameplay, the current mode of the walls is represented by the color of the screen frame: none - black, wrap - purple, bump - dark blue, boxy - green.

Select options with cursor keys or a joystick.

The **TAB**, **SELECT** or second joystick button (supported Joy 2B+ standard or compatible), and on the Atari 5200 console, the **5** controller key change the color of the mountains (3 versions to choose from).  

If the cursor indicates the wind strength selection option **Wind**, pressing **TAB** changes the way the wind strength is drawn from "every round" to "every turn" and vice versa. Drawing every turn is indicated by the **?** sign next to the word **Wind**.  

If the cursor indicates the gravity selection option **Gravity**, pressing **TAB** changes the procedure of falling the ground to a less impressive but faster one, and vice versa. The selection of fast ground fall is indicated by the letter **f** next to the word **Gravity**.

If the cursor points to the option of selecting the height of the mountains **Mountain**, pressing **TAB** toggles the option of changing the height of the mountains every round. Drawing every round is indicated by the **?** sign next to the word **Mountain**.

The **RETURN** key or a joystick button moves to the next screen.


## 2. Players and robotank levels
![Name of players and game level screen.](images/DiffMenu.png)
Entering names of players and selecting levels of computer-controlled players.

The second screen is shown for each player. Here you can use the cursor keys or joystick to select whether the tank will be driven by a human (HUMAN option) or a computer (other options).  

The **TAB**, **SELECT** or second joystick button, and on the Atari 5200 console the **5** controller key allow you to choose which joystick port the player will use.  

The **INVERSE** or **OPTION** key allows you to select one of the 3 available tank shapes. On the Atari 5200 console, this is achieved by cycling through joystick ports with the **5** key.  
At the same time, you can enter the name of the selected player from the keyboard.  

When the **RETURN** key is pressed or the Joystick button is pressed briefly, the screen switches to the next player until the difficulty levels for each player are selected.

The player's name can also be entered with the joystick. After pressing and holding the button for more than 1s. you can use up/down movements to change the letter being entered, and left/right movements to change its position in the name. Releasing the button ends the name entry and returns to the level selection.

If name is not entered, it will be supplemented with the default one.


## 3. Shopping screen (before each round)
![Shopping offensives screen.](images/PurOffensive.png)
![Shopping defensives screen.](images/PurDefensive.png)
In this screen you can make purchases of offensive and defensive weapons. Only those weapons that the player can afford are visible, along with information about the price and the number of units of a given weapon that will be obtained for that price. The information on the screen probably needs no more description. You move through the lists with the cursor keys (up and down) or with the joystick, the **TAB** key or the left arrow, the left joystick tilt or second joystick button change the screen to defensive or offensive weapons, the **SPACE** key or the right arrow and also the joystick to the right does the purchase of the indicated weapon.

The **RETURN** key or the joystick button press switches to the defensive weapon activation screen. Here you can activate previously bought defensive (or offensive after switching with **TAB**, etc) weapons. 

![Defensives activation screen.](images/ActDefensive.png)
This makes it possible to activate shields and others before the round starts.
 
**RETURN** key or joystick button press switches to the next player's shopping screen.
(For computer players this screen is not shown.)


## 4. The main screen of the game
![Main game screen.](images/StatusLine.png)
The status line shows which player is currently allowed to take a shot and a set of other information:

* **Player** - player's tank name,

* active joystick number or difficulty level of computer-controlled player (1-**Moron** - 8-**Unknown**),

* currently selected offensive weapon (symbol quantity and name),

* **Energy** - the player's remaining energy points and if he has an active defensive weapon that has its energy - in parentheses the energy level,

* **Angle** - the angle and the direction of the barrel set by the player,

* **Force** - the shot strength set by the player (the maximum shot strength is limited by the player's energy - it can not exceed the energy * 10 . This means that you can fire weaker shots only when having a small amount of energy,

* **Round** - the current round number,

* **Wind** - wind speed and direction,

* "computer" symbol if **Auto Defense** is active,

* in parentheses is the name of the active defensive weapon - if there is any activated by the player.

The keyboard controls here are simple, cursor keys or joystick: left/right - change the angle of the barrel, up/down - change the the force of the shot.


| A800         | Function           |
|--------------|--------------------|
| **SPACJA**/**FIRE**  | shoot       (see ↓)|
| **TAB**/**SELECT**   | weapon change   (↓)|
| **I**            | inventory       (↓)|
| **A**/**OPTION**     | defensives      (↓)|
| **M**            | music on/off       |
| **S**            | sound on/off       |
| **START**        | turbo mode      (↓)|
| **O**            | game over       (↓)|
| **START**+**OPTION** | immediate quit  (↓)|
| **G**            | color scheme    (↓)|
| **ESC**          | return          (↓)|
| **Y**            | confirm         (↓)|
| **CTRL**+**HELP**    | visual debug    (↓)|

* **shoot** or joystick button pressed briefly - firing a shot.
* **weapon change** or second joystick button - selection of offensive weapons (this option is not available directly with one button joystick - you need to select Inventory)
* **inventory** or longer holding the joystick button - go to Inventory. It is a screen (actually two) with the same layout as the shopping menu, it also works similarly except that here you don't buy weapons, but choose one of the offensive ones to shoot or activate a defensive weapon.
* **defensives** - go directly to the defensive weapons activation.
* **turbo mode** - speed up some game animations.
* **game over** - end the current game and jump to the Game Over screen with a summary. The summary of the results does not take into account the current round of the game, but only the rounds completed earlier. This corresponds to pressing the **ESC** key with the difference that the summary and credits are displayed.
* **immediate quit** - force the end of the game (Game Over), just like **game over** but without confirmation.
* **color scheme** - changes the mountain and background shading
* **return** - during the entire game at any time (unless the computer is playing, then sometimes you have to wait a while) you can press the **ESC** key, which allows you to abort the game and return to the previous menu (of course, there is protection against accidental pressing).
* **confirm** - when asked to abort or terminate the game - confirmation
* **vis. debug** - Toggle **visual debug** mode. It displays distances measured, laser aiming, and aiming technique. It leaves a mess on the screen, but it does not impair the game.


## 5. Game mechanics - offensive weapons

Large points received by the player is the number of tanks that died earlier. If any of the other tanks capitulated earlier (with **White Flag**) it is not added to those that died and does not grant points.
Only these points determine the order in the summary.


### Energy of tanks.
* At the beginning of each round, each tank has 99 units of energy.
* Energy of tanks is depleted in 3 ways:
    * one unit after each shot is fired
    * while falling (one pixel down - 2 units).
    * when a projectile hits the tank or next to it - and here the amount of energy subtracted depends on the distance from the center of the explosion and the type/power of the projectile.


### Energy and money.
How energy subtraction and earning money works:

After each round the amount of money gained/lost is calculated, this is done on the basis of two variables accumulated by each tank during the round. These variables are:

**gain** - energy "captured" from tanks hit (also if you hit yourself :) and here's the catch, if you have very little energy left it can be profitable to hit yourself with a powerful weapon!

**loss** - energy lost due to explosion/fall (and here it is important - to count the total loss of energy even if the tank has less at the moment of hit).

In addition, the tank that won the round has a parameter gain (captured from hit tanks energy) increased by the remaining energy at the end of the round (because it did not die and should have it - although it also happens otherwise :) )

Specifically:


### After each round:
**money = money + (20 * (gain+energy))**

**money = money - (10 * loss)**

**if money < 0 then money = 0**

(at the start of each round **gain** and **loss** have a value of 0).

During a round, if another tank is hit as a result of a shot fired by a tank, the tank firing the shot "gets the energy" taken away from the hit tank.

### tank taking a shot:
**gain = gain + EnergyDecrease**

### tank hit:
**loss = loss + EnergyDecrease**

Where **EnergyDecrease** is the loss of energy due to the hit.

Of course, at the same time the hit tank loses the amount of energy stored in **EnergyDecrease**, except that here the loss cannot exceed the energy you have.


## How a hit works.

Each weapon that results in an explosion has its own blast radius.

After the explosion, every tank in its range loses energy.

It works in such a way that if the hit is exactly on the center point of the tank `EnergyDecrease` receives the maximum value for the weapon, and for each pixel of distance from the center of the tank this value is reduced by 8.

For example, if a hit with the Baby Missile weapon hits the center of the tank perfectly, it will lose exactly 88 units of energy (plus what it loses falling after the explosion).
If you hit with the same weapon at a distance of 10 pixels from the center of the tank, the loss will be only 8 units.

And here are the values of maximum energy loss for individual weapons. If a weapon explodes several times, each explosion is calculated independently (additional values in the table):


| Offensive weapon | Max loss    |
|------------------|-------------|
| Baby Missile     | 88          |
| Missile          | 136         |
| Baby Nuke        | 200         |
| Nuke             | 240         |
| LeapFrog         | 136 112 112 |
| Funky Bomb       | 168 88 (*5) |
| MIRV             | 136 (*5)    |
| Death's Head     | 240 (*5)    |
| Napalm           | 40  (see ↓) |
| Hot Napalm       | 80      (↓) |
| Baby Roller      | 88          |
| Roller           | 168         |
| Heavy Roller     | 240         |
| Riot Charge      | 0       (↓) |
| Riot Blast       | 0       (↓) |
| Riot Bomb        | 0       (↓) |
| Heavy Riot Bomb  | 0       (↓) |
| Baby Digger      | 0       (↓) |
| Digger           | 0       (↓) |
| Heavy Digger     | 0       (↓) |
| Sandhog          | 0       (↓) |
| Heavy Sandhog    | 0       (↓) |
| Dirt Clod        | 0       (↓) |
| Dirt Ball        | 0       (↓) |
| Ton of Dirt      | 0       (↓) |
| Liquid Dirt      | 0       (↓) |
| Dirt Charge      | 0       (↓) |
| Stomp            | 0       (↓) |
| Laser            | 100     (↓) |

Remarks:
* **Napalm** - this weapon is different and the distance from the center is not determined, simply any tank in range of the flames loses 40 units of energy.

* **Hot Napalm** - the rule is the same as in **Napalm**, 80 units.

* **Riot Charge** - no energy is subtracted, but a portion of the soil upward from the hit point in a 31-pixel radius is removed.

* **Riot Blast** - as in Riot Charge, but in a radius of 61 pixels.

* **Riot Bomb** - no energy is subtracted, but the soil in a radius of 17 pixels from the hit point is destroyed - as in the case of **Missile**. The weapon is useful for digging out after being buried, or for digging under an opponent.

* **Heavy Riot Bomb** as in **Riot Bomb**, but the explosion radius is 29 pixels from the point of impact - as in the case of **Nuke**

* **Baby Digger** - no energy is subtracted, but a portion of the soil is dig in a radius of 60 pixels from the point of impact.

* **Digger** - as above - more digging.

* **Heavy Digger** - as above - even more digging.

* **Sandhog** - as above - another way of digging

* **Heavy Sandhog** - as above - the largest dig 

* **Dirt Clod** - no energy is subtracted, but a soil ball with a radius of 12 pixels from the hit point is created. The weapon is useful for burying the opponent.

* **Dirt Ball** - as above, but the radius of the ball is 22 pixels.

* **Ton of Dirt** - as above, but the radius of the ball is 31 pixels.

* **Liquid Dirt** - (floods the ground at the point of hit with liquid soil, filling in the depressions.

* **Stomp** - no energy is subtracted, but all tanks within a radius depending on the force of the shot are pushed back, and after being pushed back they may fall or be buried. With a maximum force of 990 units, the radius of action is about 60 pixels.

* **Laser** - 100 energy units deducted, but only in the case of a direct hit - that is, the hit tank always dies.


## 6. And now for defensive weapons:

* **White Flag** - causes the surrender of the player (can sometimes be useful in a hopeless situation). The advantage is that by surrendering you don't give a big point to your opponents and don't cause one of them to gain by killing us, you also limit the loss of your energy and also cash. An important note - this is the only defensive weapon that can be deactivated. All you have to do is re-enter inventory and once again select its activation.

* **Battery** - when activated, it recharges the tank's energy to full (99 units). It is one of three defensive weapons that does not deactivate other defensive weapons when used.

* **Hovercraft** - a weapon that allows the tank to move. It has its own fuel supply in form of electric eels and in addition, it can be activated multiple times during the same turn, and after using it, you can activate another defensive weapon and fire a shot in the same turn. After using it, the tank rises above the mountains and using the cursor keys or a joystick you can move the tank to a new position. **SPACE** or the joystick button cause the tank to land in a new place. You can fly until the tank runs out of eels (presented on the status bar like the energy of a defensive weapon), if the eel fuel runs out the tank will fall down on its own. It is not possible to land on other tanks.

* **Parachute** - does not protect against loss of energy due to a neighboring explosion, makes you not lose energy during ONE fall. After such a fall, it deactivates and a new parachute must be activated.

* **Shield** - the simplest shield works exactly the opposite of **Parachute**, it does not protect against energy loss while falling, instead it protects against energy loss caused by ONE adjacent explosion. It protects once, no matter how strong the explosion is (whether tis but a scratch or a direct hit with a nuke), and deactivates immediately afterward.

* **Heavy Shield** - a shield with its own energy (at the start of 99 units), it works the same as **Shield** (does not protect against falling) with the exception that it has its own energy resource. When exploding, the energy of this shield is reduced first, and if it reaches 0, the shield deactivates and further reduces the tank's energy. Due to this action, a tank with this type of shield can be "killed" by undermining it, because falling reduces the energy of the tank and not the shield.

* **Force Shield** - the strongest shield - works just like Heavy Shield only that it is combined with **Parachute**. What is important in this case, falling does not take energy away from the shield or the tank. It is only taken away by hits.

* **Bouncy Castle** - a passive-aggressive weapon :). It works as follows - in a case of a direct tank hit (and shield), it causes the projectile to "bounce" in the opposite direction with the same force with which it was fired. In the absence of wind and a difference in level, the weapon then hits the tank that fired it. After such a bounce, it deactivates. As the weapon reacts in this way only to precise hits, it is also works like **Heavy Shield** and has 99 units at the start.

* **Mag Deflector** - the second passive-aggressive weapon :) . In case of a direct hit on a tank (and shield), it causes the hit point to move randomly to the left or right side of the protected tank, but not very far, so you can get "shrapnel" with stronger weapons. As in the case of **Bouncy Castle**, it is also a shield that corresponds to the action of **Heavy Shield** and has 99 units at the start.

* **Nuclear Winter** - adds nothing, takes nothing away :) - in fact, it is not so much a defensive weapon as a double-edged one. It floods the area with "radioactive" fallout, which is ordinary soil. If you do not have at hand any weapon that digs up the terrain, and for that a shield (preferably disposable), then after such "fallout" you will have to shoot yourself - because being underground is otherwise impossible. Alternatively, **White Flag** always remains.

* **Long Schlong** - a special weapon :) - Costs a lot, doesn't really help with anything (except possibly digging yourself out but only when slightly buried but it has a cool name and looks cool :) - It can be activated independently of other defensive weapons and remains active until the end of the round (it cannot be deactivated).

* **Lazy Boy** - it is not actually a defensive weapon. It is an aiming aid. When it is activated, the tank tries to aim at the nearest enemy and automatically adjusts the power of the shot and angle. If it has too little energy, it can sometimes aim wrong (it uses a method like **Cyborg** to aim). Like **Battery**, it does not deactivate other defensive weapons when used. Note: There is no point in activating this weapon before the round, targeting will not take place because there is nothing to target yet.

* **Lazy Darwin** - works just like **Lazy Boy** but targets the weakest opponent. In this weapon, after automatic targeting, "visual targeting" remains active, so you can easily change the target and independently select another opponent by seeing if you hit him.

* **Auto Defense** - activates the mode of automatic activation of defensive weapons. After its activation, the tank automatically activates the strongest shield it has (consuming it, of course) at any time when there is no shield (also between shots of other players). At the same time, if the tank's energy level drops below 30 units, it automatically activates **Battery** if it has it. This weapon remains active until the end of the round and is indicated by the "computer" symbol before the name of the active defensive weapon in the status line. It is the second defensive weapon that does not deactivate other defensive weapons when used.

* **Spy Hard** - Help for the forgetful :) . When activated, it shows a preview of information about the next opponents one by one. Left/Right - changes the "spied" tank. Fire/Space/Return/Esc - ends the "spying". This is the last defensive weapon, which does not deactivate other defensive weapons when used.

Due to the different warhead tracking system of **MIRV** weapons, the **Bouncy Castle** and **Mag Deflector** defensive weapons only use the shielding function when hit by these weapons. In addition, **MIRV** warheads do not bounce or fly through sidewalls when falling!

None of the shields protect against **Napalm**. **Bouncy Castle** or **Mag Deflector** on a direct hit will deflect it or carry it past, but just hit very close to a tank and its shield will not save it.

**White Flag**, **Hovercraft** and **Nuclear Winter** weapons, when selected, require activation, this is accomplished by "firing a shot" after the selection of that weapon. Of course, the shot of the offensive weapon is then not fired, but only the selected defensive weapon is activated.

You can only have one defensive weapon active at a time (except **Long Schlong** of course :) ). You can always change the decision and activate another defensive weapon or deactivate **White Flag** before firing.

And of course, activating a weapon when you already have some other weapon activated causes the loss of the previous one (no returns :) ).


## 7. "Other" weapons:

* **Best F...g Gifts** - this is a 'loot box', not a weapon per se. Buying it draws one of the offensive or (rarely) defensive weapons and adds it to the player's arsenal. It is a lottery in which you can lose (if you draw a weapon cheaper than the **Best F...g Gifts** price) but also gain. You can get a weapon otherwise not affordable at all! There is a small probability of drawing by **Best F...g Gifts** itself :). You can then try to use it in battle.


## 8. AI opponents levels:

The game has 8 difficulty levels of computer-controlled opponents. Or actually 7 different ones and one "surprise". Each has its own way of buying defensive and offensive weapons and a different method of target selection and targeting itself, as well as weapon selection. They are arranged in the list according to increasing "skills":

* **Moron** - the dumbest of opponents (which does not mean the safest). Shoots completely at random using only one weapon - **Baby Missile**. He doesn't buy anything and doesn't know how to use defensive weapons.

* **Shooter** - This opponent does not shoot blindly. He chooses one direction for himself. Based on his own position - he shoots in the direction from which there is more space assuming that this is where the other tanks are. He starts firing from a high angle and shot after shot changes this angle to a lower and lower angle trying to fire the entire area on the chosen side. He always fires with the best weapon he has (the highest on the list of weapons he has - that is, not necessarily the best). He does not use defensive weapons even though he buys them! At the beginning of the round, he makes 1 attempt to buy defensive weapons (only from the **Battery** - **Strong Parachute** range) and 4 offensive weapons (from the **Missile** - **Heavy Roller** range).

* **Poolshark** - When attacking, he sets the nearest tank as his target, then selects the angle of the shot, and tries to select its strength by drawing it from the selected range. He always shoots with the best weapon he has. He uses defensive weapons. With a probability of 1:3, he activates the best defensive weapon he owns (the highest on the list of weapons he owns - that is, not necessarily the best) before firing. If his energy level drops below 30 units - he uses **Battery** (of course, if he bought it before), if the energy drops below 5 and he has no **Battery** he surrenders - **White Flag**. At the beginning of the round he makes 1 attemp to buy defensive weapons and 6 offensive weapons.

* **Tosser** - When attacking, he acts exactly like **Poolshark** however, he may have a "better" weapon inventory due to a different purchase tactic. He always activates the best defensive weapon he has before shooting. And just like **Poolshark** he uses **Battery** and **White Flag**. At the beginning of the round, he assesses how much money he has and depending on that, he makes (money/5100) attempts to buy defensive weapons and then checks again how much money he has left and makes (money/1250) attempts to buy offensive weapons.

* **Chooser** - Takes as a target the weakest opponent (with the least amount of energy) and aims very precisely, but before the shot the energy of the shot is modified by the parameter of luck :) , that is, despite the precise aiming it does not always hit. He shoots with the best weapon he has unless the target is close. Then he changes his weapon to **Baby Missile** to avoid hitting himself. He always activates the best defensive weapon he has before shooting and, like **Poolshark**, uses **Battery** and **White Flag**. He purchases just like **Tosser**.

* **Spoiler** - He shoots exactly like **Chooser** except that he has more luck, which means that even if he doesn't hit the target of his choice, it can be a more precise shot than **Chooser**. If he is unable to hit his chosen target, he tries to choose another target that he can accurately hit. He uses defensive weapons exactly like **Chooser**. At the beginning of the round, he assesses how much money he has and depending on that, he makes (money/5100) attempts to buy defensive weapons and then checks again how much money he has left and makes (money/320) attempts to buy offensive weapons. When buying defensive weapons, he buys only strong and precise weapons - that is, weapons that won't accidentally hurt him.

* **Cyborg** - Takes aim at the weakest opponent (with the least amount of energy) but prefers human-controlled opponents. If he is unable to hit his chosen target, he tries to choose another target that he can accurately hit. Aims very accurately and in the vast majority of cases hits on the first shot. He fires the shot with the best weapon he has unless the target is close. Then he changes his weapon to **Baby Missile** to avoid hitting himself. He uses defensive weapons exactly like **Chooser** but if he has more than 2 pieces of **Battery** he uses them if the energy decreases below 60 units.. He shops exactly like **Spoiler**.

* **Unknown** - Before firing each shot, he randomly chooses a course of action from **Poolshark** to **Cyborg** and applies his tactics. However, the tactics of weapon purchases are always identical to **Tosser**.

Buying a weapon (offensive or defensive) works as follows:
First, one of the weapons is drawn (among all possible offensive or defensive weapons). Then a check is performed to see if the drawn weapon is in the list of weapons possible for purchase by the tank. If not, no weapon is bought in this trial, and if so, its price is checked. If the tank has that much money, the weapon is bought, otherwise the trial ends without making a purchase.

Table of weapons purchased by: **Shooter**, **Poolshark**, **Tosser** and **Chooser**.

| Offensive    | Defensive        |
|--------------|------------------|
| Missile      | Battery          |
| Baby Nuke    | Parachute        |
| Nuke         | Strong Parachute |
| LeapFrog     | Mag Deflector    |
| Funky Bomb   | Shield           |
| MIRV         | Heavy Shield     |
| Death's Head | Force Shield     |
| Napalm       | Bouncy Castle    |
| Hot Napalm   |                  |
| Baby Roller  |                  |
| Roller       |                  |
| Heavy Roller |                  |

Table of weapons purchased by: **Spoiler** and **Cyborg**.

| Offensive    | Defensive        |
|--------------|------------------|
| Missile      | Battery          |
| Baby Nuke    | Strong Parachute |
| Nuke         | Mag Deflector    |
| Hot Napalm   | Heavy Shield     |
|              | Force Shield     |
|              | Bouncy Castle    |

