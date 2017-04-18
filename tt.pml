#define LEN 5
#define NUM_HOLES (LEN)*(LEN+1)/2

bool winners[NUM_HOLES];// = {false};
// did everyone win?
bool awon = false;

// TODO: FIX ARRAY ERRORS BEFORE ANYTHING ELSE!!!!!

//typedef Hole {
//  byte x;
//  byte y;
//  bool in_play;
//}

// are the coordinates x and y on the board?
// ...only the shadow knows
inline is_hole(x, y) {
    ((x >= 0) && (y >= 0) && (x + y < LEN) && (!board[x][y]))
}

/*
 * jump peg in location (x, y) to the location
 * (new_x, new_y)
 */
inline jump(x, y, new_x, new_y) {
    board[x][y] = false;
    board[new_x][new_y] = true;
    board[(x+new_x)/2][(y+new_y)/2] = false;
}

inline can_jump_to(x, y, jx, jy) {
    // the hole (jx, jy) is free and there's a pin inbetween the jumping
    // pin and the hole
    is_hole(jx, jy) && board[(x+jx)/2][(y+jy)/2] == true;
}

// TODO: Cleanup
inline can_jump(x, y) {
    (board[x][y] && 
    (can_jump_to(x, y, x+2, y) ||
    can_jump_to(x, y, x-2, y) ||
    can_jump_to(x, y, x, y+2) ||
    can_jump_to(x, y, x, y-2) ||
    can_jump_to(x, y, x+2, y-2) ||
    can_jump_to(x, y, x-2, y+2)))
}

/*
 * this process tests if the board is solvable with
 * board at the given coordinates
 */
proctype Board(byte hole_x, hole_y) {
    /*bool board[LEN][LEN];
    // initialize the pegs
    board[hole_x][hole_y] = false;*/

    bool game_over = false;
    do
    :: true -> 
       byte x = 0;
       byte y = 0;
       // lvx is last valid x
       byte lvx = 0;
       byte lvy = 0;
       bool any_valid = false;
       do
       :: x < LEN -> 
           y = 0;
           do
           :: y < LEN - x ->//&& can_jump(x, y) ->
               // we take the pin!
               any_valid = true;
               goto breakout;
           :: y < LEN - x ->//&& can_jump(x, y) ->
               // we see a valid pin, but press onward
               any_valid = true;
               lvx = x;
               lvy = y;
               y++;
           :: y == LEN - x ->
               break;
           od;
           x++;
       :: x == LEN -> break;
       od;
       breakout:
       // did we actually find a valid pin?
       if
       :: x == LEN ->
           // we didn't end on a valid pin
           if
           :: any_valid ->
               x = lvx;
               y = lvy;
           :: else ->
               // there aren't any more valid pins
               break; // stop playing this game
           fi;
       fi;


       // now we actually jump
       if
       :: can_jump_to(x, y, x+2, y) -> jump(x, y, x+2, y);
       :: can_jump_to(x, y, x-2, y) -> jump(x, y, x-2, y);
       :: can_jump_to(x, y, x, y+2) -> jump(x, y, x, y+2);
       :: can_jump_to(x, y, x, y-2) -> jump(x, y, x, y-2);
       :: can_jump_to(x, y, x+2, y-2) -> jump(x, y, x+2, y-2);
       :: can_jump_to(x, y, x-2, y+2) -> jump(x, y, x-2, y+2);
       fi;
    od;

    // now that the game is over, we have stuff to do
    byte num_pins = 0;
    x = 0;
    y = 0;
    do
    :: x < LEN ->
        y = 0;
        do
        :: y < LEN - x ->
            if
            :: board[x][y] -> num_pins++;
            fi;
            y++;
        :: else -> break;
        od;
        x++;
    :: else -> break;
    od;

    if
    :: num_pins == 1 ->
        winners[_pid] = true;
    fi;

    all_won();
    printf("Process %d finished", _pid);
}

init {
    byte x;
    byte y;
    for (x : 0 .. LEN) {
        for (y : 0 .. LEN - x) {
            // for each coordinate, spin a process with
            // a starting hole at this coordinate
            run Board(x, y);
        }
    }
}

inline all_won() {
    i = 0;
    bool lawon = true;
    do
    :: i < NUM_HOLES ->
        lawon = lawon && winners[i];
        i++;
    :: else ->
        break;
    od;
    awon = lawon;
}



ltl all_possible {
    !never(awon);
}
