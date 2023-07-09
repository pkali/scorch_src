    .align 40
    dta " Basic instruction manual:"
    .align 40
    dta "---------------------------"
    .align 40
    .align 40
    dta "You can play using the keyboard (all"
    .align 40
    dta "functionality) or controllers in all of"
    .align 40
    dta "the ports (all functionality necessary"
    .align 40
    dta "for gameplay)."
    .align 40
    .align 40
    dta " 1. Game Option Selection."
    .align 40
    dta "---------------------------"
    .align 40
    .align 40
    .align 40
    dta "On the first screen, you can configure"
    .align 40
    dta "gameplay options:"
    .align 40
    dta $5a, d" number of players (2 - 6) includes"
    .align 40
    dta "both human and computer-controlled"
    .align 40
    dta "players"
    .align 40
    dta $5a, d" the initial amount of cash of each"
    .align 40
    dta "player (2K is the optimal value we"
    .align 40
    dta "chose, but for short games, it is worth"
    .align 40
    dta "choosing a higher value)"
    .align 40
    dta $5a, d" gravity"
    .align 40
    dta $5a, d" maximum wind strength (wind is drawn"
    .align 40
    dta "at the beginning of each round or during"
    .align 40
    dta "the round between turns, here we can"
    .align 40
    dta "choose how strong it can be):"
    .align 40
    dta d"    ", $5a, d" 1B - maximum wind strength: 5"
    .align 40
    dta d"    ", $5a, d" 3B - maximum wind strength: 20"
    .align 40
    dta d"    ", $5a, d" 5B - maximum wind strength: 40"
    .align 40
    dta d"    ", $5a, d" 7B - maximum wind strength: 70"
    .align 40
    dta d"    ", $5a, d" 9B - maximum wind strength: 99"
    .align 40
    dta $5a, d" number of rounds in a game"
    .align 40
    dta $5a, d" missile speed (does not affect the"
    .align 40
    dta "flight path - only changes the apparent"
    .align 40
    dta "missile speed - does not change anything"
    .align 40
    dta "in the gameplay itself)"
    .align 40
    dta $5a, d" frequency of suicides :) - if for a"
    .align 40
    dta "number of turns the game has not"
    .align 40
    dta "recorded hits (tanks are constantly"
    .align 40
    dta "shooting inaccurately), after one of"
    .align 40
    dta "such misses a tank commits suicide -"
    .align 40
    dta "here you determine how long they can"
    .align 40
    dta """shooting for the stars"" :) - if only"
    .align 40
    dta "people play the optimal setting is"
    .align 40
    dta """norm"", in the case of"
    .align 40
    dta "computer-controlled players ... you"
    .align 40
    dta "choose."
    .align 40
    dta $5a, d" The height (and undulation) of the"
    .align 40
    dta "mountains from almost flat (NL - Kingdom"
    .align 40
    dta "of the Netherlands), to soaring and high"
    .align 40
    dta "(NP - Federal Democratic Republic of"
    .align 40
    dta "Nepal)"
    .align 40
    dta $5a, d" the way the walls (edges of the"
    .align 40
    dta "screen) work:"
    .align 40
    dta $5a, d" none - projectiles that flew off the"
    .align 40
    dta "screen do not return (black color of the"
    .align 40
    dta "screen frame)"
    .align 40
    dta $5a, d" wrap - the screen ""wraps"" and"
    .align 40
    dta "projectiles that flew to the right"
    .align 40
    dta "appear on the left side and vice versa"
    .align 40
    dta "(purple color of the screen frame)"
    .align 40
    dta $5a, d" bump - the right and left walls"
    .align 40
    dta "deflect projectiles that want to fly"
    .align 40
    dta "through them (dark blue color of the"
    .align 40
    dta "screen frame)"
    .align 40
    dta $5a, d" boxy - just like bump, except that the"
    .align 40
    dta """ceiling"" also reflects projectiles"
    .align 40
    dta "(green color of the screen frame)"
    .align 40
    dta $5a, d" rand - at the beginning of each round,"
    .align 40
    dta "one of the above 4 ways the walls work"
    .align 40
    dta "is drawn."
    .align 40
    .align 40
    dta "During gameplay, the current mode of the"
    .align 40
    dta "walls is represented by the color of the"
    .align 40
    dta "screen frame:"
    .align 40
    dta $5a, d" none - black,"
    .align 40
    dta $5a, d" wrap - purple,"
    .align 40
    dta $5a, d" bump - dark blue,"
    .align 40
    dta $5a, d" boxy - green."
    .align 40
    .align 40
    dta "Select options with cursor keys or a"
    .align 40
    dta "controller."
    .align 40
    .align 40
    dta "The [TAB], [SELECT] or second controller"
    .align 40
    dta "button (supported Joy 2B+ standard or"
    .align 40
    dta "compatible) key change the color of the"
    .align 40
    dta "mountains (3 versions to choose from)."
    .align 40
    dta "If the cursor indicates the wind"
    .align 40
    dta "strength selection option ""Wind"" change"
    .align 40
    dta "the way the wind strength is drawn from"
    .align 40
    dta """every round"" to ""every turn"" and vice"
    .align 40
    dta "versa. Drawing every turn is indicated"
    .align 40
    dta "by the ""?"" sign next to the word ""Wind""."
    .align 40
    dta "If the cursor indicates the gravity"
    .align 40
    dta "selection option ""Gravity"" changes the"
    .align 40
    dta "procedure of falling the ground to a"
    .align 40
    dta "less impressive but faster one, and vice"
    .align 40
    dta "versa. The selection of fast ground fall"
    .align 40
    dta "is indicated by the letter ""f"" next to"
    .align 40
    dta "the word ""Gravity""."
    .align 40
    .align 40
    dta "The [RETURN] key or a controller button"
    .align 40
    dta "moves to the next screen."
    .align 40
    .align 40
    dta " 2. Names of players and AI opponents"
    .align 40
    dta "--------------------------------------"
    .align 40
    .align 40
    .align 40
    dta "The second screen is shown for each"
    .align 40
    dta "player. Here you can use the cursor keys"
    .align 40
    dta "or controller to select whether the tank"
    .align 40
    dta "will be driven by a human (HUMAN option)"
    .align 40
    dta "or a computer (other options)."
    .align 40
    dta "The [TAB], [SELECT] or second controller"
    .align 40
    dta "button allows to choose which controller"
    .align 40
    dta "port the player will use."
    .align 40
    dta "The [INVERSE] or [OPTION] key allows you"
    .align 40
    dta "to select one of the 3 available tank"
    .align 40
    dta "shapes."
    .align 40
    dta "At the same time, you can enter the name"
    .align 40
    dta "of the selected player from the"
    .align 40
    dta "keyboard."
    .align 40
    dta "When the [RETURN] key is pressed or the"
    .align 40
    dta "controller button is pressed briefly,"
    .align 40
    dta "the screen switches to the next player"
    .align 40
    dta "until the difficulty levels for each"
    .align 40
    dta "player are selected."
    .align 40
    dta "The player's name can also be entered"
    .align 40
    dta "with the controller. After pressing and"
    .align 40
    dta "holding the button for more than 1s, you"
    .align 40
    dta "can use up/down movements to change the"
    .align 40
    dta "letter being entered, and left/right"
    .align 40
    dta "movements to change its position in the"
    .align 40
    dta "name. Releasing the button ends the name"
    .align 40
    dta "entry and returns to the level"
    .align 40
    dta "selection."
    .align 40
    .align 40
    dta "If the name is not entered, it will be"
    .align 40
    dta "supplemented with the default name."
    .align 40
    .align 40
    dta " 3. Shopping screen (before each round)"
    .align 40
    dta "----------------------------------------"
    .align 40
    .align 40
    .align 40
    .align 40
    dta "On this screen, you can make purchases"
    .align 40
    dta "of offensive and defensive weapons. Only"
    .align 40
    dta "those weapons that the player can afford"
    .align 40
    dta "are visible, along with information"
    .align 40
    dta "about the price and the number of units"
    .align 40
    dta "of a given weapon that will be obtained"
    .align 40
    dta "for that price. The information on the"
    .align 40
    dta "screen probably needs no more"
    .align 40
    dta "description. You move through the lists"
    .align 40
    dta "with the cursor keys (up and down) or"
    .align 40
    dta "with the controller, the [TAB] key or"
    .align 40
    dta "the left arrow, the left controller tilt"
    .align 40
    dta "or second controller button change the"
    .align 40
    dta "screen to defensive or offensive"
    .align 40
    dta "weapons, the [SPACE] key or the right"
    .align 40
    dta "arrow and also the controller to the"
    .align 40
    dta "right does the purchase of the indicated"
    .align 40
    dta "weapon."
    .align 40
    .align 40
    dta "The [RETURN] key or the controller"
    .align 40
    dta "button press switches to the defensive"
    .align 40
    dta "weapon activation screen. Here you can"
    .align 40
    dta "activate previously bought defensive (or"
    .align 40
    dta "offensive after switching with [TAB],"
    .align 40
    dta "etc) weapons."
    .align 40
    .align 40
    .align 40
    .align 40
    dta "This makes it possible to activate"
    .align 40
    dta "shields and others before the round"
    .align 40
    dta "starts."
    .align 40
    .align 40
    dta "Another [RETURN] key or controller"
    .align 40
    dta "button press switches to the next"
    .align 40
    dta "player's shopping screen."
    .align 40
    dta "(For computer players this screen is not"
    .align 40
    dta "shown.)"
    .align 40
    .align 40
    dta " 4. The main screen of the game"
    .align 40
    dta "--------------------------------"
    .align 40
    .align 40
    .align 40
    dta "The status line shows which player is"
    .align 40
    dta "currently allowed to take a shot and a"
    .align 40
    dta "set of other information:"
    .align 40
    dta $5a, d" player's tank name,"
    .align 40
    dta $5a, d" active controller number or difficulty"
    .align 40
    dta "level of computer-controlled player"
    dta d"(1-"
    dta d"Moron"*
    dta d" - 8-"
    dta d"Unknown"*
    dta d"),"
    dta d"                  "
    .align 40
    .align 40
    dta $5a, d" currently selected offensive weapon"
    .align 40
    dta "(symbol quantity and name),"
    .align 40
    dta $5a, d" the player's remaining energy points"
    .align 40
    dta "and if he has an active defensive weapon"
    .align 40
    dta "that has its energy - in parentheses the"
    .align 40
    dta "energy level,"
    .align 40
    dta $5a, d" the angle and the direction of the"
    .align 40
    dta "barrel set by the player,"
    .align 40
    dta $5a, d" the shot strength set by the player"
    .align 40
    dta "(the maximum shot strength is limited by"
    .align 40
    dta "the player's energy - it can not exceed"
    .align 40
    dta d"the energy ", $5a, d" 10 . This means that you"
    .align 40
    dta "can fire weaker shots only when having a"
    .align 40
    dta "small amount of energy,"
    .align 40
    dta $5a, d" the current round number,"
    .align 40
    dta $5a, d" wind speed and direction,"
    dta d"* ""computer"" symbol if "
    dta d"Auto Defense"*
    dta d"     "
    .align 40
    .align 40
    dta "is active,"
    .align 40
    dta $5a, d" in parentheses is the name of the"
    .align 40
    dta "active defensive weapon - if there is"
    .align 40
    dta "any activated by the player."
    .align 40
    .align 40
    dta "The basic controls are simple enough -"
    .align 40
    dta "cursor keys or controller: left/right -"
    .align 40
    dta "change the angle of the barrel, up/down"
    .align 40
    dta "- change the the force of the shot."
    .align 40
    dta "Other functions:"
    .align 40
    .align 40
    dta $5a, d" [SPACE] or controller button pressed"
    .align 40
    dta "briefly - firing a shot."
    .align 40
    dta $5a, d" [TAB] or [SELECT] or second controller"
    .align 40
    dta "button - selection of offensive weapons"
    .align 40
    dta "(this option is not available directly"
    .align 40
    dta "with one button controller - you need to"
    .align 40
    dta "select Inventory). |"
    .align 40
    dta $5a, d" [I] or longer holding the controller"
    .align 40
    dta "button - go to Inventory. It is a screen"
    .align 40
    dta "(actually two) with the same layout as"
    .align 40
    dta "the shopping menu, it also works"
    .align 40
    dta "similarly except that here you don't buy"
    .align 40
    dta "weapons, but choose one of the offensive"
    .align 40
    dta "ones to shoot or activate a defensive"
    .align 40
    dta "weapon. |"
    .align 40
    dta $5a, d" [A] or [OPTION] - go directly to the"
    .align 40
    dta "defensive weapons activation."
    .align 40
    dta $5a, d" [M] - disable/enable background music."
    .align 40
    dta "|"
    .align 40
    dta $5a, d" [S] - disable/enable effect sounds. |"
    .align 40
    dta $5a, d" [START] - speed up some game"
    .align 40
    dta "animations. |"
    .align 40
    dta $5a, d" [O] - end the current game and jump to"
    .align 40
    dta "the Game Over screen with a summary. The"
    .align 40
    dta "summary of the results does not take"
    .align 40
    dta "into account the current round of the"
    .align 40
    dta "game, but only the rounds completed"
    .align 40
    dta "earlier. This corresponds to pressing"
    .align 40
    dta "the [ESC] key with the difference that"
    .align 40
    dta "the summary and credits are displayed. |"
    .align 40
    dta $5a, d" [START] + [OPTION] - immediately force"
    .align 40
    dta "the end of the game (Game Over), just"
    .align 40
    dta "like [O] but without confirmation."
    .align 40
    dta $5a, d" [G] - changes the mountain shading |"
    .align 40
    dta $5a, d" [ESC] - during the entire game at any"
    .align 40
    dta "time (unless the computer is playing,"
    .align 40
    dta "then sometimes you have to wait a while)"
    .align 40
    dta "you can press the [ESC] key, which"
    .align 40
    dta "allows you to abort the game and return"
    .align 40
    dta "to the beginning (of course, there is"
    .align 40
    dta "protection against accidental pressing)."
    .align 40
    dta "|"
    .align 40
    dta $5a, d" [Y] - when asked to abort or terminate"
    .align 40
    dta "the game - confirmation |"
    .align 40
    dta $5a, d" [CTRL] + [HELP] - Toggle ""visual"
    .align 40
    dta "debug"" mode. It displays distances"
    .align 40
    dta "measured, laser aiming, and aiming"
    .align 40
    dta "technique. It leaves a mess on the"
    .align 40
    dta "screen, but it does not impair the game,"
    .align 40
    dta "just makes it a bit harder. |"
    .align 40
    .align 40
    dta " 5. Game mechanics - offensive weapons"
    .align 40
    dta "---------------------------------------"
    .align 40
    .align 40
    dta " Energy of tanks."
    .align 40
    dta "------------------"
    .align 40
    dta "At the beginning of each round, each"
    .align 40
    dta "tank has 99 ash units of energy."
    .align 40
    dta "Tanks' energy is depleted in 3 ways:"
    .align 40
    dta $5a, d" one unit after each shot"
    .align 40
    dta $5a, d" while falling (one pixel down -2"
    .align 40
    dta "units)."
    .align 40
    dta $5a, d" when a projectile hits the tank or"
    .align 40
    dta "next to it - and here the amount of"
    .align 40
    dta "energy subtracted depends on the"
    .align 40
    dta "distance from the center of the"
    .align 40
    dta "explosion and the type/power of the"
    .align 40
    dta "projectile."
    .align 40
    .align 40
    dta " How energy and money works:"
    .align 40
    dta "-----------------------------"
    .align 40
    dta "After each round the amount of money"
    .align 40
    dta "gained/lost is calculated, this is done"
    .align 40
    dta "on the basis of two variables"
    .align 40
    dta "accumulated by each tank during the"
    .align 40
    dta "round. These variables are:"
    .align 40
    .align 40
    dta "gain - energy ""captured"" from tanks hit"
    .align 40
    dta "(also if you hit yourself :) and here's"
    .align 40
    dta "the catch, if you have very little"
    .align 40
    dta "energy left it can be profitable to hit"
    .align 40
    dta "yourself with a powerful weapon"
    .align 40
    .align 40
    dta "lose - energy lost due to explosion/fall"
    .align 40
    dta "(and here it is important - to count the"
    .align 40
    dta "total loss of energy even if the tank"
    .align 40
    dta "has less at the moment of hit)."
    .align 40
    .align 40
    dta "In addition, the tank that won the round"
    .align 40
    dta "has a parameter gain (captured from hit"
    .align 40
    dta "tanks energy) increased by the remaining"
    .align 40
    dta "energy at the end of the round (because"
    .align 40
    dta "it did not die and should have it -"
    .align 40
    dta "although it also happens otherwise :) )"
    .align 40
    .align 40
    dta "Specifically:"
    .align 40
    .align 40
    dta " After each round:"
    .align 40
    dta "-------------------"
    .align 40
    dta d"money = money + (20 ", $5a, d" (gain+energy))."
    .align 40
    .align 40
    dta d"money = money - (10 ", $5a, d" lose)."
    .align 40
    .align 40
    dta "if money <0 then money=0."
    .align 40
    .align 40
    dta "(at the start of each round gain and"
    .align 40
    dta "lose have a value of 0)."
    .align 40
    .align 40
    dta "During a round, if another tank is hit"
    .align 40
    dta "as a result of a shot fired by a tank,"
    .align 40
    dta "the tank firing the shot ""gets the"
    .align 40
    dta "energy"" taken away from the hit tank."
    .align 40
    dta " tank taking a shot:"
    .align 40
    dta "---------------------"
    .align 40
    dta "gain = gain + EnergyDecrease."
    .align 40
    dta " tank hit:"
    .align 40
    dta "-----------"
    .align 40
    dta "lose = lose + EnergyDecrease."
    .align 40
    .align 40
    dta "Where EnergyDecrease is the loss of"
    .align 40
    dta "energy due to the hit."
    .align 40
    .align 40
    dta "Of course, at the same time the hit tank"
    .align 40
    dta "loses the amount of energy stored in"
    .align 40
    dta "EnergyDecrease, except that here the"
    .align 40
    dta "loss cannot exceed the energy you have."
    .align 40
    .align 40
    dta " How a hit works."
    .align 40
    dta "------------------"
    .align 40
    dta "Each weapon that results in an explosion"
    .align 40
    dta "has its own blast radius."
    .align 40
    .align 40
    dta "After the explosion, every tank in its"
    .align 40
    dta "range loses energy."
    .align 40
    .align 40
    dta "It works in such a way that if the hit"
    .align 40
    dta "is exactly on the center point of the"
    .align 40
    dta "tank EnergyDecrease receives the maximum"
    .align 40
    dta "value for the weapon, and for each pixel"
    .align 40
    dta "of distance from the center of the tank"
    .align 40
    dta "this value is reduced by 8."
    .align 40
    .align 40
    dta "For example, if a hit with the Baby"
    .align 40
    dta "Missile weapon hits the center of the"
    .align 40
    dta "tank perfectly, it will lose exactly 88"
    .align 40
    dta "units of energy (plus what it loses"
    .align 40
    dta "falling after the explosion)."
    .align 40
    dta "If you hit with the same weapon at a"
    .align 40
    dta "distance of 10 pixels from the center of"
    .align 40
    dta "the tank, the loss will be only 8 units."
    .align 40
    .align 40
    dta "And here are the values of maximum"
    .align 40
    dta "energy loss for individual weapons. If a"
    .align 40
    dta "weapon explodes several times, each"
    .align 40
    dta "explosion is calculated independently"
    .align 40
    dta "(additional values in the table):"
    .align 40
    .align 40
    dta "Offensive weapons and maximum energy"
    .align 40
    dta "loss:"
    .align 40
    dta $5a, d" Baby Missile: 88"
    .align 40
    dta $5a, d" Missile: 136"
    .align 40
    dta $5a, d" Baby Nuke: 200"
    .align 40
    dta $5a, d" Nuke: 240"
    .align 40
    dta $5a, d" LeapFrog: 136 112 112"
    .align 40
    dta $5a, d" Funky Bomb: 168 88 (* 5)"
    .align 40
    dta $5a, d" MIRV: 136 (* 5)"
    .align 40
    dta $5a, d" Death's Head: 240 (* 5)"
    .align 40
    dta $5a, d" Napalm: 40 (this weapon is different"
    .align 40
    dta "and the distance from the center is not"
    .align 40
    dta "determined, simply any tank in range of"
    .align 40
    dta "the flames loses 40 units of energy)"
    .align 40
    dta $5a, d" Hot Napalm: 80 (the rule is the same"
    .align 40
    dta "as in Napalm)"
    .align 40
    dta $5a, d" Baby Roller: 88"
    .align 40
    dta $5a, d" Roller: 168"
    .align 40
    dta $5a, d" Heavy Roller: 240"
    .align 40
    dta $5a, d" Riot Charge: 0 (no energy is"
    .align 40
    dta "subtracted, but a portion of the ground"
    .align 40
    dta "upward from the hit point in a 31-pixel"
    .align 40
    dta "radius is removed)"
    .align 40
    dta $5a, d" Riot Blast: 0 (as in Riot Charge, but"
    .align 40
    dta "in a radius of 61 pixels)"
    .align 40
    dta $5a, d" Riot Bomb: 0 (no energy is subtracted,"
    .align 40
    dta "but the ground in a radius of 17 pixels"
    .align 40
    dta "from the hit point is destroyed - as in"
    .align 40
    dta "the case of Missile. The weapon is"
    .align 40
    dta "useful for digging out after being"
    .align 40
    dta "buried, or for undermining an opponent)"
    .align 40
    dta $5a, d" Heavy Riot Bomb: 0 (as in Riot Bomb,"
    .align 40
    dta "but the explosion radius is 29 pixels"
    .align 40
    dta "from the point of impact - as in the"
    .align 40
    dta "case of Nuke)"
    .align 40
    dta $5a, d" Baby Digger: 0 (no energy is"
    .align 40
    dta "subtracted, but a portion of the ground"
    .align 40
    dta "is undermined in a radius of 60 pixels"
    .align 40
    dta "from the point of impact)"
    .align 40
    dta $5a, d" Digger: 0 (as above - greater"
    .align 40
    dta "undermining)"
    .align 40
    dta $5a, d" Heavy Digger: 0 (as above - greatest"
    .align 40
    dta "undermining)"
    .align 40
    dta $5a, d" Sandhog: 0 (as above - another way of"
    .align 40
    dta "undermining)"
    .align 40
    dta $5a, d" Heavy Sandhog: 0 (as above - largest"
    .align 40
    dta "dig)"
    .align 40
    dta $5a, d" Dirt Clod: 0 (no energy is subtracted,"
    .align 40
    dta "but a ground ball with a radius of 12"
    .align 40
    dta "pixels from the hit point is created."
    .align 40
    dta "The weapon is useful for burying the"
    .align 40
    dta "opponent)"
    .align 40
    dta $5a, d" Dirt Ball: 0 (as above, but the radius"
    .align 40
    dta "of the ball is 22 pixels)"
    .align 40
    dta $5a, d" Ton of Dirt: 0 (as above, but the"
    .align 40
    dta "radius of the ball is 31 pixels)"
    .align 40
    dta $5a, d" Liquid Dirt: 0 (floods the ground at"
    .align 40
    dta "the point of hit with liquid soil,"
    .align 40
    dta "filling in the depressions)"
    .align 40
    dta $5a, d" Stomp: 0 (no energy is subtracted, but"
    .align 40
    dta "all tanks within a radius depending on"
    .align 40
    dta "the force of the shot are pushed back,"
    .align 40
    dta "and after being pushed back they may"
    .align 40
    dta "fall or be buried. With a maximum force"
    .align 40
    dta "of 990 units, the radius of action is"
    .align 40
    dta "about 60 pixels)"
    .align 40
    dta $5a, d" Laser: 100 (but here it is also"
    .align 40
    dta "different - only in a case of a direct"
    .align 40
    dta "hit simply subtract 100 units of energy"
    .align 40
    dta "- that is, the tank always dies)"
    .align 40
    .align 40
    dta "Large points received by the player is"
    .align 40
    dta "the number of tanks that died earlier"
    .align 40
    dta "than him. If any of the other tanks"
    dta d"capitulated earlier ("
    dta d"White Flag"*
    dta d") is"
    dta d"     "
    .align 40
    .align 40
    dta "not added to those that died and does"
    .align 40
    dta "not give points."
    .align 40
    dta "Only these points determine the order in"
    .align 40
    dta "the summary."
    .align 40
    .align 40
    dta " 6. And now for defensive weapons:"
    .align 40
    dta "-----------------------------------"
    dta d"* "
    dta d"White Flag"*
    dta d" - causes the surrender"
    dta d"     "
    .align 40
    .align 40
    dta "of the player (can sometimes be useful"
    .align 40
    dta "in a hopeless situation). The advantage"
    .align 40
    dta "is that by surrendering you don't give a"
    .align 40
    dta "big point to your opponents and don't"
    .align 40
    dta "cause one of them to gain by killing us,"
    .align 40
    dta "you also limit the loss of your energy"
    .align 40
    dta "and also cash. An important note - this"
    .align 40
    dta "is the only defensive weapon that can be"
    .align 40
    dta "deactivated. All you have to do is"
    .align 40
    dta "re-enter inventory and once again select"
    .align 40
    dta "its activation."
    .align 40
    dta d"* "
    dta d"Battery"*
    dta d" - when activated, it"
    dta d"          "
    .align 40
    .align 40
    dta "recharges the tank's energy to full (99"
    .align 40
    dta "units). It is one of three defensive"
    .align 40
    dta "weapons that does not deactivate other"
    .align 40
    dta "defensive weapons when used."
    .align 40
    dta d"* "
    dta d"Hovercraft"*
    dta d" - a weapon that allows"
    dta d"     "
    .align 40
    .align 40
    dta "the tank to move. It has its own fuel"
    .align 40
    dta "supply in form of electric eels and in"
    .align 40
    dta "addition, it can be activated multiple"
    .align 40
    dta "times during the same turn, and after"
    .align 40
    dta "using it, you can activate another"
    .align 40
    dta "defensive weapon and fire a shot in the"
    .align 40
    dta "same turn. After using it, the tank"
    .align 40
    dta "rises above the mountains and using the"
    .align 40
    dta "cursor keys or a controller you can move"
    .align 40
    dta "the tank to a new position. [SPACE] or"
    .align 40
    dta "the controller button cause the tank to"
    .align 40
    dta "land in a new place. You can fly until"
    .align 40
    dta "the tank runs out of eels (presented on"
    .align 40
    dta "the status bar like the energy of a"
    .align 40
    dta "defensive weapon), if the eel fuel runs"
    .align 40
    dta "out the tank will fall down on its own."
    .align 40
    dta "It is not possible to land on other"
    .align 40
    dta "tanks."
    .align 40
    dta d"* "
    dta d"Parachute"*
    dta d" - does not protect"
    dta d"          "
    .align 40
    .align 40
    dta "against loss of energy due to a"
    .align 40
    dta "neighboring explosion, makes you not"
    .align 40
    dta "lose energy during ONE fall. After such"
    .align 40
    dta "a fall, it deactivates and a new"
    .align 40
    dta "parachute must be activated."
    .align 40
    dta d"* "
    dta d"Shield"*
    dta d" - the simplest shield works"
    dta d"    "
    .align 40
    dta d"exactly the opposite of "
    dta d"Parachute"*
    dta d","
    dta d"      "
    .align 40
    .align 40
    dta "it does not protect against energy loss"
    .align 40
    dta "while falling, instead it protects"
    .align 40
    dta "against energy loss caused by ONE"
    .align 40
    dta "adjacent explosion. It protects once, no"
    .align 40
    dta "matter how strong the explosion is"
    .align 40
    dta "(whether tis but a scratch or a direct"
    .align 40
    dta "hit with a nuke), and deactivates"
    .align 40
    dta "immediately afterward."
    .align 40
    dta d"* "
    dta d"Heavy Shield"*
    dta d" - a shield with its"
    dta d"      "
    .align 40
    .align 40
    dta "own energy (at the start of 99 units),"
    dta d"it works the same as "
    dta d"Shield"*
    dta d" (does"
    dta d"       "
    .align 40
    .align 40
    dta "not protect against falling) with the"
    .align 40
    dta "exception that it has its own energy"
    .align 40
    dta "resource. When exploding, the energy of"
    .align 40
    dta "this shield is reduced first, and if it"
    .align 40
    dta "reaches 0, the shield deactivates and"
    .align 40
    dta "further reduces the tank's energy. Due"
    .align 40
    dta "to this action, a tank with this type of"
    .align 40
    dta "shield can be ""killed"" by undermining"
    .align 40
    dta "it, because falling reduces the energy"
    .align 40
    dta "of the tank and not the shield."
    .align 40
    dta d"* "
    dta d"Force Shield"*
    dta d" - the strongest"
    dta d"          "
    .align 40
    .align 40
    dta "shield - works just like Heavy Shield"
    .align 40
    dta "only that it is combined with"
    dta d"Parachute"*
    dta d". What is important in this"
    dta d"    "
    .align 40
    .align 40
    dta "case, falling does not take energy away"
    .align 40
    dta "from the shield or the tank. It is only"
    .align 40
    dta "taken away by hits."
    .align 40
    dta d"* "
    dta d"Bouncy Castle"*
    dta d" - a"
    dta d"                     "
    .align 40
    .align 40
    dta "passive-aggressive weapon :). It works"
    .align 40
    dta "as follows - in a case of a direct tank"
    .align 40
    dta "hit (and shield), it causes the"
    .align 40
    dta "projectile to ""bounce"" in the opposite"
    .align 40
    dta "direction with the same force with which"
    .align 40
    dta "it was fired. In the absence of wind and"
    .align 40
    dta "a difference in level, the weapon then"
    .align 40
    dta "hits the tank that fired it. After such"
    .align 40
    dta "a bounce, it deactivates. As the weapon"
    .align 40
    dta "reacts in this way only to precise hits,"
    dta d"it is also works like "
    dta d"Heavy Shield"*
    dta d"      "
    .align 40
    .align 40
    dta "and has 99 units at the start (we will"
    .align 40
    dta "probably have to rethink this value and"
    .align 40
    dta "give a smaller one here)."
    .align 40
    dta d"* "
    dta d"Mag Deflector"*
    dta d" - the second"
    dta d"            "
    .align 40
    .align 40
    dta "passive-aggressive weapon :) . In case"
    .align 40
    dta "of a direct hit on a tank (and shield),"
    .align 40
    dta "it causes the hit point to move randomly"
    .align 40
    dta "to the left or right side of the"
    .align 40
    dta "protected tank, but not very far, so you"
    .align 40
    dta "can get ""shrapnel"" with stronger"
    dta d"weapons. As in the case of "
    dta d"Bouncy"*
    dta d"       "
    .align 40
    dta d"Castle"
    dta d", it is also a shield that"*
    dta d"        "
    .align 40
    dta d"corresponds to the action of "
    dta d"Heavy"*
    dta d"      "
    .align 40
    dta d"Shield"
    dta d" and has 99 units at the start"*
    dta d"    "
    .align 40
    .align 40
    dta "(probably here we will have also to"
    .align 40
    dta "rethink this value and give a smaller"
    .align 40
    dta "one)."
    .align 40
    dta d"* "
    dta d"Nuclear Winter"*
    dta d" - adds nothing,"
    dta d"        "
    .align 40
    .align 40
    dta "takes nothing away :) - in fact, it is"
    .align 40
    dta "not so much a defensive weapon as a"
    .align 40
    dta "double-edged one. It floods the area"
    .align 40
    dta "with ""radioactive"" fallout, which is"
    .align 40
    dta "ordinary soil. If you do not have at"
    .align 40
    dta "hand any weapon that digs up the"
    .align 40
    dta "terrain, and for that a shield"
    .align 40
    dta "(preferably disposable), then after such"
    .align 40
    dta """fallout"" you will have to shoot"
    .align 40
    dta "yourself - because being underground is"
    .align 40
    dta "otherwise impossible. Alternatively,"
    dta d"White Flag"*
    dta d" always remains."
    dta d"              "
    .align 40
    .align 40
    dta d"* "
    dta d"Long Schlong"*
    dta d" - a special weapon :)"
    dta d"    "
    .align 40
    .align 40
    dta "- Costs a lot, doesn't really help with"
    .align 40
    dta "anything (except possibly digging"
    .align 40
    dta "yourself out but only when slightly"
    .align 40
    dta "buried but it has a cool name and looks"
    .align 40
    dta "cool :) - It can be activated"
    .align 40
    dta "independently of other defensive weapons"
    .align 40
    dta "and remains active until the end of the"
    .align 40
    dta "round (it cannot be deactivated)."
    .align 40
    dta d"* "
    dta d"Lazy Boy"*
    dta d" - it is not actually a"
    dta d"       "
    .align 40
    .align 40
    dta "defensive weapon. It is an aiming aid."
    .align 40
    dta "When it is activated, the tank tries to"
    .align 40
    dta "aim at the nearest enemy and"
    .align 40
    dta "automatically adjusts the power of the"
    .align 40
    dta "shot and angle. If it has too little"
    .align 40
    dta "energy, it can sometimes aim wrong (it"
    dta d"uses a method like "
    dta d"Cyborg"*
    dta d" to aim)."
    dta d"      "
    .align 40
    dta d"Like "
    dta d"Battery"*
    dta d", it does not deactivate"
    dta d"    "
    .align 40
    .align 40
    dta "other defensive weapons when used. Note:"
    .align 40
    dta "There is no point in activating this"
    .align 40
    dta "weapon before the round, targeting will"
    .align 40
    dta "not take place because there is nothing"
    .align 40
    dta "to target yet."
    .align 40
    dta d"* "
    dta d"Lazy Darwin"*
    dta d" - works just like"
    dta d"         "
    .align 40
    dta d"Lazy Boy"*
    dta d" but targets the weakest"
    dta d"        "
    .align 40
    .align 40
    dta "opponent. In this weapon, after"
    .align 40
    dta "automatic targeting, ""visual targeting"""
    .align 40
    dta "remains active, so you can easily change"
    .align 40
    dta "the target and independently select"
    .align 40
    dta "another opponent by seeing if you hit"
    .align 40
    dta "him."
    .align 40
    dta d"* "
    dta d"Auto Defense"*
    dta d" - activates the mode"
    dta d"     "
    .align 40
    .align 40
    dta "of automatic activation of defensive"
    .align 40
    dta "weapons. After its activation, the tank"
    .align 40
    dta "automatically activates the strongest"
    .align 40
    dta "shield it has (consuming it, of course)"
    .align 40
    dta "at any time when there is no shield"
    .align 40
    dta "(also between shots of other players)."
    .align 40
    dta "At the same time, if the tank's energy"
    .align 40
    dta "level drops below 30 units, it"
    dta d"automatically activates "
    dta d"Battery"*
    dta d" if"
    dta d"      "
    .align 40
    .align 40
    dta "it has it. This weapon remains active"
    .align 40
    dta "until the end of the round and is"
    .align 40
    dta "indicated by the ""computer"" symbol"
    .align 40
    dta "before the name of the active defensive"
    .align 40
    dta "weapon in the status line. It is the"
    .align 40
    dta "second defensive weapon that does not"
    .align 40
    dta "deactivate other defensive weapons when"
    .align 40
    dta "used."
    .align 40
    dta d"* "
    dta d"Spy Hard"*
    dta d" - Help for the forgetful"
    dta d"     "
    .align 40
    .align 40
    dta ":) . When activated, it shows a preview"
    .align 40
    dta "of information about the next opponents"
    .align 40
    dta "one by one. Left/Right - changes the"
    .align 40
    dta """spied"" tank. Fire/Space/Return/Esc -"
    .align 40
    dta "ends the ""spying"". This is the last"
    .align 40
    dta "defensive weapon, which does not"
    .align 40
    dta "deactivate other defensive weapons when"
    .align 40
    dta "used."
    .align 40
    .align 40
    dta "Due to the different warhead tracking"
    dta d"system of "
    dta d"MIRV"*
    dta d" weapons, the "
    dta d"Bouncy"*
    dta d"      "
    .align 40
    dta d"Castle"
    dta d" and "*
    dta d"Mag Deflector"
    dta d" defensive"*
    dta d"      "
    .align 40
    .align 40
    dta "weapons only use the shielding function"
    .align 40
    dta "when hit by these weapons. In addition,"
    dta d"MIRV"*
    dta d" warheads do not bounce or fly"
    dta d"      "
    .align 40
    .align 40
    dta "through sidewalls when falling"
    .align 40
    .align 40
    dta "None of the shields protect against"
    dta d"Napalm"*
    dta d". "
    dta d"Bouncy Castle"*
    dta d" or "
    dta d"Mag"*
    dta d"            "
    .align 40
    dta d"Deflector"
    dta d" on a direct hit will deflect"*
    dta d"  "
    .align 40
    .align 40
    dta "it or carry it past, but just hit very"
    .align 40
    dta "close to a tank and its shield will not"
    .align 40
    dta "save it."
    .align 40
    dta d"White Flag"*
    dta d", "
    dta d"Hovercraft"*
    dta d" and"
    dta d"              "
    .align 40
    dta d"Nuclear Winter"*
    dta d" weapons, when"
    dta d"            "
    .align 40
    .align 40
    dta "selected, require activation, this is"
    .align 40
    dta "accomplished by ""firing a shot"" after"
    .align 40
    dta "the selection of that weapon. Of course,"
    .align 40
    dta "the shot of the offensive weapon is then"
    .align 40
    dta "not fired, but only the selected"
    .align 40
    dta "defensive weapon is activated."
    .align 40
    .align 40
    dta "You can only have one defensive weapon"
    dta d"active at a time (except "
    dta d"Long"*
    dta d"           "
    .align 40
    dta d"Schlong"
    dta d" of course :) ). You can always"*
    dta d"  "
    .align 40
    .align 40
    dta "change the decision and activate another"
    dta d"defensive weapon or deactivate "
    dta d"White"*
    dta d"    "
    .align 40
    dta d"Flag"
    dta d" before firing."*
    dta d"                     "
    .align 40
    .align 40
    .align 40
    dta "And of course, activating a weapon when"
    .align 40
    dta "you already have some other weapon"
    .align 40
    dta "activated causes the loss of the"
    .align 40
    dta "previous one (no returns :) )."
    .align 40
    .align 40
    dta " 7. ""Other"" weapons:"
    .align 40
    dta "---------------------"
    .align 40
    dta d"* "
    dta d"Best F...g Gifts"*
    dta d" - this is a 'loot"
    dta d"    "
    .align 40
    .align 40
    dta "box', not a weapon per se. Buying it"
    .align 40
    dta "draws one of the offensive or (rarely)"
    .align 40
    dta "defensive weapons and adds it to the"
    .align 40
    dta "player's arsenal. It is a lottery in"
    .align 40
    dta "which you can lose (if you draw a weapon"
    dta d"cheaper than the "
    dta d"Best F...g Gifts"*
    dta d"       "
    .align 40
    .align 40
    dta "price) but also gain. You can get a"
    .align 40
    dta "weapon otherwise not affordable at all"
    .align 40
    .align 40
    dta " 8. AI opponents:"
    .align 40
    dta "------------------"
    .align 40
    .align 40
    dta "The game has 8 difficulty levels of"
    .align 40
    dta "computer-controlled opponents. Or"
    .align 40
    dta "actually 7 different ones and one"
    .align 40
    dta """surprise"". Each has its own way of"
    .align 40
    dta "buying defensive and offensive weapons"
    .align 40
    dta "and a different method of target"
    .align 40
    dta "selection and targeting itself, as well"
    .align 40
    dta "as weapon selection. They are arranged"
    .align 40
    dta "in the list according to increasing"
    .align 40
    dta """skills"":"
    .align 40
    dta d"* "
    dta d"Moron"*
    dta d" - the dumbest of opponents"
    dta d"      "
    .align 40
    .align 40
    dta "(which does not mean the safest). Shoots"
    .align 40
    dta "completely at random using only one"
    dta d"weapon - "
    dta d"Baby Missile"*
    dta d". He doesn't"
    dta d"       "
    .align 40
    .align 40
    dta "buy anything and doesn't know how to use"
    .align 40
    dta "defensive weapons."
    .align 40
    dta d"* "
    dta d"Shooter"*
    dta d" - This opponent does not"
    dta d"      "
    .align 40
    .align 40
    dta "shoot blindly. He chooses one direction"
    .align 40
    dta "for himself. Based on his own position -"
    .align 40
    dta "he shoots in the direction from which"
    .align 40
    dta "there is more space assuming that this"
    .align 40
    dta "is where the other tanks are. He starts"
    .align 40
    dta "firing from a high angle and shot after"
    .align 40
    dta "shot changes this angle to a lower and"
    .align 40
    dta "lower angle trying to fire the entire"
    .align 40
    dta "area on the chosen side. He always fires"
    .align 40
    dta "with the best weapon he has (the highest"
    .align 40
    dta "on the list of weapons he has - that is,"
    .align 40
    dta "not necessarily the best). He does not"
    .align 40
    dta "use defensive weapons even though he"
    .align 40
    dta "buys them"
    .align 40
    dta d"* "
    dta d"Poolshark"*
    dta d" - When attacking, he"
    dta d"        "
    .align 40
    .align 40
    dta "sets the nearest tank as his target,"
    .align 40
    dta "then selects the angle of the shot, and"
    .align 40
    dta "tries to select its strength by drawing"
    .align 40
    dta "it from the selected range. He always"
    .align 40
    dta "shoots with the best weapon he has. He"
    .align 40
    dta "uses defensive weapons. With a"
    .align 40
    dta "probability of 1:3, he activates the"
    .align 40
    dta "best defensive weapon he owns (the"
    .align 40
    dta "highest on the list of weapons he owns -"
    .align 40
    dta "that is, not necessarily the best)"
    .align 40
    dta "before firing. If his energy level drops"
    dta d"below 30 units - he uses "
    dta d"Battery"*
    dta d" (of"
    dta d"    "
    .align 40
    .align 40
    dta "course, if he bought it before), if the"
    .align 40
    dta "energy drops below 5 and he has no"
    dta d"Battery"*
    dta d" he surrenders - "
    dta d"White"*
    dta d"           "
    .align 40
    dta d"Flag"
    dta d". At the beginning of the round he"*
    dta d"  "
    .align 40
    .align 40
    dta "makes 1 attemp to buy defensive weapons"
    .align 40
    dta "and 6 offensive weapons."
    .align 40
    dta d"* "
    dta d"Tosser"*
    dta d" - When attacking, he acts"
    dta d"      "
    .align 40
    dta d"exactly like "
    dta d"Poolshark"*
    dta d" however, he"
    dta d"      "
    .align 40
    .align 40
    dta "may have a ""better"" weapon inventory due"
    .align 40
    dta "to a different purchase tactic. He"
    .align 40
    dta "always activates the best defensive"
    .align 40
    dta "weapon he has before shooting. And just"
    dta d"like "
    dta d"Poolshark"*
    dta d" he uses "
    dta d"Battery"*
    dta d"          "
    .align 40
    dta d"and "
    dta d"White Flag"*
    dta d". At the beginning of"
    dta d"     "
    .align 40
    .align 40
    dta "the round, he assesses how much money he"
    .align 40
    dta "has and depending on that, he makes"
    .align 40
    dta "(money/5100) attempts to buy defensive"
    .align 40
    dta "weapons and then checks again how much"
    .align 40
    dta "money he has left and makes (money/1250)"
    .align 40
    dta "attempts to buy offensive weapons."
    .align 40
    dta d"* "
    dta d"Chooser"*
    dta d" - Takes as a target the"
    dta d"       "
    .align 40
    .align 40
    dta "weakest opponent (with the least amount"
    .align 40
    dta "of energy) and aims very precisely, but"
    .align 40
    dta "before the shot the energy of the shot"
    .align 40
    dta "is modified by the parameter of luck :)"
    .align 40
    dta ", that is, despite the precise aiming it"
    .align 40
    dta "does not always hit. He shoots with the"
    .align 40
    dta "best weapon he has unless the target is"
    .align 40
    dta "close. Then he changes his weapon to"
    dta d"Baby Missile"*
    dta d" to avoid hitting"
    dta d"           "
    .align 40
    .align 40
    dta "himself. He always activates the best"
    .align 40
    dta "defensive weapon he has before shooting"
    dta d"and, like "
    dta d"Poolshark"*
    dta d", uses"
    dta d"               "
    .align 40
    dta d"Battery"*
    dta d" and "
    dta d"White Flag"*
    dta d". He"
    dta d"              "
    .align 40
    dta d"purchases just like "
    dta d"Tosser"*
    dta d"."
    dta d"             "
    .align 40
    .align 40
    dta d"* "
    dta d"Spoiler"*
    dta d" - He shoots exactly like"
    dta d"      "
    .align 40
    dta d"Chooser"*
    dta d" except that he has more luck"
    dta d"    "
    .align 40
    .align 40
    dta ":) , which means that even if he doesn't"
    .align 40
    dta "hit the target of his choice, it can be"
    dta d"a more precise shot than "
    dta d"Chooser"*
    dta d". If"
    dta d"    "
    .align 40
    .align 40
    dta "he is unable to hit his chosen target,"
    .align 40
    dta "he tries to choose another target that"
    .align 40
    dta "he can accurately hit. He uses defensive"
    dta d"weapons exactly like "
    dta d"Chooser"*
    dta d". At the"
    dta d"    "
    .align 40
    .align 40
    dta "beginning of the round, he assesses how"
    .align 40
    dta "much money he has and depending on that,"
    .align 40
    dta "he makes (money/5100) attempts to buy"
    .align 40
    dta "defensive weapons and then checks again"
    .align 40
    dta "how much money he has left and makes"
    .align 40
    dta "(money/320) attempts to buy offensive"
    .align 40
    dta "weapons. When buying defensive weapons,"
    .align 40
    dta "he buys only strong and precise weapons"
    .align 40
    dta "- that is, weapons that won't"
    .align 40
    dta "accidentally hurt him."
    .align 40
    dta d"* "
    dta d"Cyborg"*
    dta d" - Takes aim at the weakest"
    dta d"     "
    .align 40
    .align 40
    dta "opponent (with the least amount of"
    .align 40
    dta "energy) but prefers human-controlled"
    .align 40
    dta "opponents. If he is unable to hit his"
    .align 40
    dta "chosen target, he tries to choose"
    .align 40
    dta "another target that he can accurately"
    .align 40
    dta "hit. Aims very accurately and in the"
    .align 40
    dta "vast majority of cases hits on the first"
    .align 40
    dta "shot. He fires the shot with the best"
    .align 40
    dta "weapon he has unless the target is"
    .align 40
    dta "close. Then he changes his weapon to"
    dta d"Baby Missile"*
    dta d" to avoid hitting"
    dta d"           "
    .align 40
    .align 40
    dta "himself. He uses defensive weapons"
    dta d"exactly like "
    dta d"Chooser"*
    dta d" but if he has"
    dta d"      "
    .align 40
    dta d"more than 2 pieces of "
    dta d"Battery"*
    dta d" he"
    dta d"        "
    .align 40
    .align 40
    dta "uses them if the energy decreases below"
    .align 40
    dta "60 units.. He shops exactly like"
    dta d"Spoiler"*
    dta d"."
    dta d"                                "
    .align 40
    .align 40
    dta d"* "
    dta d"Unknown"*
    dta d" - Before firing each shot,"
    dta d"    "
    .align 40
    .align 40
    dta "he randomly chooses a course of action"
    dta d"from "
    dta d"Poolshark"*
    dta d" to "
    dta d"Cyborg"*
    dta d" and"
    dta d"            "
    .align 40
    .align 40
    dta "applies his tactics. However, the"
    .align 40
    dta "tactics of weapon purchases are always"
    dta d"identical to "
    dta d"Tosser"*
    dta d"."
    dta d"                    "
    .align 40
    .align 40
    .align 40
    dta "Trying to buy a weapon (offensive or"
    .align 40
    dta "defensive) is as follows:"
    .align 40
    dta "First, one of the weapons is drawn"
    .align 40
    dta "(among all possible offensive or"
    .align 40
    dta "defensive weapons). Then a check is"
    .align 40
    dta "performed to see if the drawn weapon is"
    .align 40
    dta "in the list of weapons possible for"
    .align 40
    dta "purchase by the tank. If not, no weapon"
    .align 40
    dta "is bought in this trial, and if so, its"
    .align 40
    dta "price is checked. If the tank has that"
    .align 40
    dta "much money, the weapon is bought,"
    .align 40
    dta "otherwise the trial ends without making"
    .align 40
    dta "a purchase."
    .align 40
    dta d"Weapons purchased by: "
    dta d"Shooter"*
    dta d","
    dta d"          "
    .align 40
    dta d"Poolshark"*
    dta d", "
    dta d"Tosser"*
    dta d" and"
    dta d"                   "
    .align 40
    dta d"Chooser"*
    dta d":"
    dta d"                                "
    .align 40
    .align 40
    dta "Offensive weapons:"
    .align 40
    dta $5a, d" Missile"
    .align 40
    dta $5a, d" Baby Nuke"
    .align 40
    dta $5a, d" Nuke"
    .align 40
    dta $5a, d" LeapFrog"
    .align 40
    dta $5a, d" Funky Bomb"
    .align 40
    dta $5a, d" MIRV"
    .align 40
    dta $5a, d" Death's Head"
    .align 40
    dta $5a, d" Napalm"
    .align 40
    dta $5a, d" Hot Napalm"
    .align 40
    dta $5a, d" Baby Roller"
    .align 40
    dta $5a, d" Roller"
    .align 40
    dta $5a, d" Heavy Roller"
    .align 40
    .align 40
    dta "Defensive weapons:"
    .align 40
    dta $5a, d" Battery"
    .align 40
    dta $5a, d" Parachute"
    .align 40
    dta $5a, d" Strong Parachute"
    .align 40
    dta $5a, d" Mag Deflector"
    .align 40
    dta $5a, d" Shield"
    .align 40
    dta $5a, d" Heavy Shield"
    .align 40
    dta $5a, d" Force Shield"
    .align 40
    dta $5a, d" Bouncy Castle"
    .align 40
    dta "  "
    dta d"Weapons purchased by: "
    dta d"Spoiler"*
    dta d" and"
    dta d"       "
    .align 40
    dta d"Cyborg"*
    dta d":"
    dta d"                                 "
    .align 40
    .align 40
    dta "Offensive weapons:"
    .align 40
    dta $5a, d" Missile"
    .align 40
    dta $5a, d" Baby Nuke"
    .align 40
    dta $5a, d" Nuke"
    .align 40
    dta $5a, d" Hot Napalm"
    .align 40
    .align 40
    dta "Defensive weapons:"
    .align 40
    dta $5a, d" Battery"
    .align 40
    dta $5a, d" Strong Parachute"
    .align 40
    dta $5a, d" Mag Deflector"
    .align 40
    dta $5a, d" Heavy Shield"
    .align 40
    dta $5a, d" Force Shield"
    .align 40
    dta $5a, d" Bouncy Castle"
    .align 40
    .align 40
