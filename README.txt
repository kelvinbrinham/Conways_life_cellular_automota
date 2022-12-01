
____________________________________________
CONWAY'S GAME OF Life ------------- D3      |
Edward Jenks and Kelvin Brinham             |
____________________________________________|

This GitHub contains the code used to run our investigation into Conway's life.

----------------
Running the Game
----------------

The core code for the game is contained in 'Conway's_life.f'.
This is setup with the traditional ruleset on a 400 x 400 grid with 1000 generations.
The number of generations or grid size can easily be varied with the variables in the top section of the code.

To populate the grid with live cells to start a simulation we have included the following words:
methuselah ( -- )         >> A methuselah seed
glider ( -- )             >> A glider
pi ( -- )                 >> The pi heptomino
block ( -- )              >> A 2x2 stable block
blinker ( -- )            >> A period 2 blinker
caterer ( -- )            >> A period 3 oscillator
random ( -- )             >> A random array with ~ 50% occupancy
linedraw ( n -- )         >> An n long horizontal lines

Most of these seeds are set to center themselves regardless of gridsize.

To begin and display the game we have two words:
life ( -- )              >> Run the game with wrapping walls
life_abs ( -- )          >> Run the game with absorbing walls

The absorbing walls are achieved with a 'buffer' around the displayed grid of 8 cells on each edge.
Delays between generations can be toggled in 'life' of 'life_abs' which are in 'The Game' section.

An example of what you would type into your console to run a simulation of a pi heptomino would be:
pi life_abs   >> For absorbing edges
pi life       >> For wrapping edges

To save/view arrays we have two words:
show ( adrr -- )          >> Displays array at addr in console
save_array ( -- )         >> Saves the game array to file
save_array_grid ( -- )    >> Saves the game array to file in a grid

Cell births/deaths and number alive per generation are tracked.
To save/view these we have two words:
show_variable ( addr -- )   >> Shows the variable array at addr
save_variables ( -- )       >> Saves all variables to file (file address may have to be changed)

--------------------
Alternative Rulesets
--------------------

The rules of the game can easily be changed in 'generation' and 'generation_abs' in 'The Game' section of the code.
In these same words, the if=s also an IF THEN statement commented out.
This statement can be varied to change synchronicity, the faction of cells the rules are applied to.
The form of the logical condition is:
X rnd Y

To select an X and Y you need to know that
S = (X-Y)/X

For example, X = 10 and Y = 1 gives S = 0.9

-------
3D Life
-------

In this GitHub there are two additional files.
Both of these are 3D versions of the game with different rulesets.
'Conway's_life_3D_B5S45.f'  =  3D life with B5/S45
'Conway's_life_3D_B6S567.f'  =  3D life with B6/S567
Our research points these out as interesting 3D life rules, but we are also investigating others.
This 3D version is run in the same way as the 2D game, but it has no display of the grid.
It only has simple wall conditions.

Number of generations and grid size can be varied in the same way as the 2D game.

The words they have to set up arrays are:
random ( -- )         >> sets up a random array with ~ 50% occupancy
beacon ( -- )         >> sets up a period 2 oscillator for the rules B7/S67

To run the simulation use the word 'life'.
For example:
random life

Variables/arrays can be saved in the same way as the 2D system.

3D versions of Conway's Life are not as well explored as the 2D system.
We will therefore be exploring a range of rulesets to make plots in order to see if it goes through phase transitions.
