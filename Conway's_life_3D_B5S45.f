

10 Constant Update-Timer  { Sets windows update rate - lower = faster refresh            }

variable array-x-size   { x dimension of array                                           }

variable array-y-size   { y dimension of array                                           }

variable array-z-size   { z dimension of array                                           }

variable array                           { variable to hold the array of live/dead cells }

variable new-array     { variable to hold the next generation's array of live/dead cells }

variable old-array     { variable to hold the last generation's array of live/dead cells }

variable older-array         { variable to hold the 2nd last generation's array of cells }

variable born            { variable to hold the number of cells born for each generation }

variable born_this_gen   { variable to hold the number of cells born at the start of the }
                                                                  {   current genaration }

variable die         { variable to hold the number of cells that die for each generation }

variable die_this_gen    { variable to hold the number of cells that die at the start of }
                                                                { the current genaration }

variable alive { variable to hold the number of cells that are alive for each generation }

variable generations                 { variable to hold the number of generations to run }

variable current_gen    { varibale to hold the number indicating the generation the game }
                                                                              {    is on }

variable alive_this_gen               { variable to hold the number of live cells in the }
                                                                  {   current generation }

variable array-file-id                          { Create Variable to hold file id handle }

variable born-file-id                           { Create Variable to hold file id handle }

variable alive-file-id                          { Create Variable to hold file id handle }

variable dead-file-id                           { Create Variable to hold file id handle }

variable currentx                                    { variable to store current x value }

variable currenty                                    { variable to store current y value }

variable currentz                                    { variable to store current z value }

variable z                                           { variable to store current z index }

variable neighbours                                   { variable to store num neighbours }

variable stability_variable                  { variable to check stability of the System }

variable start_time

variable end_time

5000 generations !                    { sets the number of generations to run the game for }

30 array-x-size !                                             { set initial x grid size }

30 array-y-size !                                             { set initial y grid size }

30 array-z-size !                                             { set initial y grid size }


{ -------------------------  Random number routine for testing ------------------------- }

CREATE SEED  123475689 ,

: Rnd ( n -- rnd )   { Returns single random number less than n }
   SEED              { Minimal version of SwiftForth Rnd.f      }
   DUP >R            { Algorithm Rick VanNorman  rvn@forth.com  }
   @ 127773 /MOD
   2836 * SWAP 16807 *
   2DUP > IF -
   ELSE - 2147483647 +
   THEN  DUP R> !
   SWAP MOD ;

{ ----------------------------------- Array Handling ---------------------------------- }


{ word to create an array of the correct size and fill it with 0s }
: make_array
  array-x-size @ array-y-size @ * array-z-size @ * allocate
  drop dup array-x-size @ array-y-size @ * array-z-size @ * 0 fill
  ;

{ word to create an array to store variables }
: make_array_variables
  4 generations @ * allocate
  drop dup 4 generations @ * 0 fill
  ;

{ word to display one of the variable arrays in the console }
: show_variable
  generations @ 0 do
    dup i 4 * + @ .
  loop
  drop
  ;

: array_! + c! ;                  { word to write to an array. precede with n array @ i }

: array_@ + c@ ;                        { word to read and array. precede with array @ i }

: xyz_array_! array-x-size @ array-y-size @ * * swap array-x-size @ * + + array @ + c! ;            { word to write and array. n x y z }

: xyz_array_@ array-x-size @ array-y-size @ * * swap array-x-size @ * + + array @ + c@ ;             	 { word to read and array. x y z }


{ ----------------------------------- File Handling ------------------------------------ }
{ The following code allows the array, birth, death and live cell data to be saved to file }
{ The File address after s" must be changed to match the desired location on the computer being used }

: make-array-file                               { Create a test file to read / write to  }
  s" C:\Users\tedje\Documents\Conway's Life\Array_File.dat" r/w create-file drop     \ Create the file
  array-file-id !                               { Store file handle for later use        }
;

: make-born-file                                { Create a test file to read / write to  }
  s" C:\Users\tedje\Documents\Conway's Life\Born_File.dat" r/w create-file drop     \ Create the file
  born-file-id !                                { Store file handle for later use        }
;

: make-dead-file                                { Create a test file to read / write to  }
  s" C:\Users\tedje\Documents\Conway's Life\Dead_File.dat" r/w create-file drop     \ Create the file
  dead-file-id !                                { Store file handle for later use        }
;

: make-alive-file                                { Create a test file to read / write to  }
  s" C:\Users\tedje\Documents\Conway's Life\Alive_File.dat" r/w create-file drop     \ Create the file
  alive-file-id !                                { Store file handle for later use        }
;

: close-file2                                    { Close the file pointed to by the file  }
  close-file drop
;

{ writing an array to a file }
: save_array
  make-array-file
  array-x-size @ array-y-size @ * array-z-size @ 0 do
    array @ I array_@ (.) array-file-id @ write-line drop
  loop
  array-file-id @ close-file2
  ;

{ save the alive, births and deaths per generation to file }
: save_variables
  make-born-file
  make-dead-file
  make-alive-file
  generations @ 0 do
    alive @ I 4 * + @ (.) alive-file-id @ write-line drop
    born @ I 4 * + @ (.) born-file-id @ write-line drop
    die @ I 4 * + @ (.) dead-file-id @ write-line drop
  loop
  alive-file-id @ close-file2
  dead-file-id @ close-file2
  born-file-id @ close-file2
  ;

{ save the game array as a grid }
: save_array_grid
  make-array-file
  array-x-size @ array-y-size @ * array-z-size @ * 0 do
    array @ I array_@ (.) array-file-id @ write-file drop
    s"  " array-file-id @ write-file drop
    I 0 >= if
      I 1 + array-x-size @ mod 0 = if
        s"  " array-file-id @ write-line drop
      then
    then
  loop
  array-file-id @ close-file2
  ;


{ -------------------------------------- Counter --------------------------------------- }

{ word to save top two numbers on stack as x, y and z coordinates }
: variablexyz currentz ! currenty ! currentx ! ;

{ loop that takes n1 n2 n3 from stack and leaves (n1-1, n2-1, n3-1) (n1, n2-1, n3-1) etc. on stack }
{ will give coordinates of all neighbours in a list}
: neighbour_loop
  variablexyz
  currentz @ 2 + dup 3 - do
    I z !
    currenty @ 2 + dup 3 - do
      currentx @ 2 + dup 3 - do
        I currentx @ = not J currenty @ = not or z @ currentz @ = not or if     \ ignores current cell
          I J z @
        then
      loop
    loop
  loop
  ;

{ word to determine if a cell is alive or dead }
{ adds 1 or 0 to neighbours variable depending on if its alive or dead }
: alive_dead
  case
    0 of drop endof
    1 of neighbours @ 1 + neighbours ! drop endof
    ." error" .
  endcase
  ;

{ word to count the number of neighbours of a cell at x y z }
: num_neighbours
  0 neighbours !
  neighbour_loop 26 0 do                              { iterate through all NEIGHBOURS  }
    dup 0 >= over array-z-size @ 1 - <= and if             { checks if on grid boundary }
      over dup 0 >= swap array-y-size @ 1 - <= and if
        rot dup 0 >= over array-x-size @ 1 - <= and if
          rot rot xyz_array_@ dup alive_dead           { determines state of NEIGHBOURS }
        else
          drop drop drop
        then
      else
        drop drop drop
      then
    else
      drop drop drop
    then
  loop
  neighbours @                                                  { return neighbour count }
  ;

{ ------------------------------------- The Game --------------------------------------- }

: ms@ counter ;                                                                  { timer }

{ word to count how many are born or have died }
: born_die
  array-x-size @ array-y-size @ * array-z-size @ * 0 do
    array @ i array_@
    new-array @ i array_@ -             { old (prev gen) array - new (current gen) array }
    case
      -1 of born_this_gen @ 1 + born_this_gen ! endof        { checks if a cell was born }
      1 of die_this_gen @ 1 + die_this_gen ! endof               { checks if a cell died }
      0 of endof                                           { cell remained alive or dead }
      ." error "
    endcase
  loop
  ;

{ word to count total alive this gen }
: no_alive
  array-x-size @ array-y-size @ * array-z-size @ * 0 do
    array @ i array_@
    alive_this_gen @ + alive_this_gen !
  loop
  ;

{ word to update the array for the next generation, it is called within 'life' below }
: generation
  0 alive_this_gen !
  0 born_this_gen !
  0 die_this_gen !
  current_gen @ 1 + current_gen !
  make_array new-array !
  array-x-size @ array-y-size @ * array-z-size @ * 0 do
    i array-x-size @ array-y-size @ * mod array-x-size @ mod i array-x-size @ array-y-size @ * mod array-x-size @ / i array-x-size @ array-y-size @ * / num_neighbours \ convert xyz to an index
    case
      0 of 0 new-array @ i array_! endof                                        \ rules of life. left in this form for ease of editting
      1 of 0 new-array @ i array_! endof
      4 of array @ i array_@ new-array @ i array_! endof
      5 of 1 new-array @ i array_! endof
      6 of 0 new-array @ i array_! endof
      7 of 0 new-array @ i array_! endof
      8 of 0 new-array @ i array_! endof
      3 of 0 new-array @ i array_! endof
      2 of 0 new-array @ i array_! endof
      0 new-array @ i array_!
    endcase
  loop
  born_die                           { counts number of cells that die and are born }
  old-array @ older-array !                                     { stores old arrays }
  array @ old-array !
  new-array @ array !
  no_alive                                            { counts number of live cells }
  alive_this_gen @ alive @ current_gen @ 4 * + !                                \ stores number of live cells in the alive array for each generation
  born_this_gen @ born @ current_gen @ 4 * + !                                  \ stores number of cells born in the born array for each generation
  die_this_gen @ die @ current_gen @ 4 * + !                                    \ stores number of cells that die in the die array for each generation
  ;

{ word to run the game of life }
: life
  ms@ start_time !                                                              \ start timer
  -1 current_gen !
  make_array_variables born !                                                   \ makes an array to store the number of cells born each generation
  make_array_variables die !                                                    \ makes an array to store the number of cells that die each generation
  make_array_variables alive !                                                  \ makes an array to store the number of live cells for each generation
  make_array old-array !
  make_array older-array !
  generations @ 0 do
    generation
  loop
  ms@ end_time !
  cr
  ." Simulation took " end_time @ start_time @ - . ." ms"                       \ display time for simulation to run
  cr
  ;


{ --------------------------------------- Seeds ---------------------------------------- }


{ the beacon is a stable oscillator with B7/S67 }
: beacon
  make_array array !                                      { create an initial empty array }
  1 15 15 1 xyz_array_!
  1 15 16 1 xyz_array_!
  1 16 15 1 xyz_array_!
  1 16 16 1 xyz_array_!
  1 15 15 2 xyz_array_!
  1 15 16 2 xyz_array_!
  1 16 15 2 xyz_array_!
  1 16 16 2 xyz_array_!
  1 17 17 3 xyz_array_!
  1 17 18 3 xyz_array_!
  1 18 17 3 xyz_array_!
  1 18 18 3 xyz_array_!
  1 17 17 4 xyz_array_!
  1 17 18 4 xyz_array_!
  1 18 17 4 xyz_array_!
  1 18 18 4 xyz_array_!
  ;

: blinker
  make_array array !                                      { create an initial empty array }
  1 18 18 0 xyz_array_!                               { this is a test setup of a blinker }
  1 18 19 0 xyz_array_!
  1 18 17 0 xyz_array_!
  ;

: random
  make_array array !
  array-x-size @ array-y-size @ * array-z-size @ * 0 do
    2 rnd 1 >= if
      1 array @ i array_!
    else
      0 array @ i array_!
    then
  loop
  ;
