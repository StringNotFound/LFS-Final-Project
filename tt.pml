// LEN is defined at compile time with the -D flag
#ifndef LEN
#define LEN 5
#define X 0
#define Y 0
#endif

// how many holes are in the board given LEN?
#define NUM_HOLES (LEN)*(LEN+1)/2

// access index (x, y) of the board array
// (board is actually a 1D array)
#define board2d(x, y) \
    board[x + y * LEN]

/*
 * returns true if there's a hole at the
 * index (x, y) and if that index is within
 * the bounds of the board
 */
#define is_hole(x, y) \
    ((x >= 0) && \
     (y >= 0) && \
     ((x + y) < LEN) && \
     (!board2d(x,y)))

/*
 * jumps the pin at (x,y) to position
 * (new_x, new_y)
 */
#define jump(x, y, new_x, new_y) \
    board2d(x, y) = false;\
    board2d(new_x, new_y) = true;\
    board2d(((x+new_x)/2), ((y+new_y)/2)) = false;\
    x_jump = x;\
    x_jump_to = new_x;\
    y_jump = y;\
    y_jump_to = new_y;

/*
 * returns true if the pin at position
 * (fx, fy) can jump to the position
 * (jx, jy)
 */
#define can_jump_to(fx, fy, jx, jy)\
    (is_hole(jx, jy) && \
     board2d(((fx+jx)/2), ((fy+jy)/2)))

/*
 * returns true if there is a pin at (x,y)
 * and if it can jump to any position
 */
#define can_jump(x, y) \
    (board2d(x, y) && \
     (can_jump_to(x, y, (x+2), y) || \
      can_jump_to(x, y, (x-2), y) || \
      can_jump_to(x, y, x, (y+2)) || \
      can_jump_to(x, y, x, (y-2)) || \
      can_jump_to(x, y, (x+2), (y-2)) || \
      can_jump_to(x, y, (x-2), (y+2))))

// keep track of whether we've won
bool won = false;

/*
 * this process tests if the board is solvable with
 * board at the given coordinates
 */
proctype Board(byte hole_x, hole_y) {

    int x_jump = 0;
    int x_jump_to = 0;
    int y_jump = 0;
    int y_jump_to = 0;
    // initialize the board to all true except for the hole
    bool board[LEN * LEN];
    byte j = 0;
    do
        :: j < LEN * LEN -> 
            board[j] = true; 
            j++;
        :: else -> break;
    od;
    board2d(hole_x, hole_y) = false;

    // play the game
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
           :: y < LEN - x && can_jump(x, y) ->
               // we take the pin!
               any_valid = true;
               goto breakout;
           :: y < LEN - x && can_jump(x, y) ->
               // we see a valid pin, but press onward
               any_valid = true;
               lvx = x;
               lvy = y;
               y++;
           :: y < LEN - x && !can_jump(x, y) ->
               // this pin ain't doin' nothin'
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
              // ...and we didn't encounter any
              // valid pins during our search
           :: any_valid ->
               x = lvx;
               y = lvy;
           :: else ->
               // there aren't any more valid pins
               break; // stop playing this game
           fi;
       :: else ->
           // we did end on a valid pin
           skip;
       fi;


       // now we actually jump
       if
       :: can_jump_to(x, y, (x+2), y) -> jump(x, y, (x+2), y);
       :: can_jump_to(x, y, (x-2), y) -> jump(x, y, (x-2), y);
       :: can_jump_to(x, y, x, (y+2)) -> jump(x, y, x, (y+2));
       :: can_jump_to(x, y, x, (y-2)) -> jump(x, y, x, (y-2));
       :: can_jump_to(x, y, (x+2), (y-2)) -> jump(x, y, (x+2), (y-2));
       :: can_jump_to(x, y, (x-2), (y+2)) -> jump(x, y, (x-2), (y+2));
       fi;
    od;


    // now that the game is over, we need to see if we won
    byte num_pins = 0;
    x = 0;
    y = 0;
    do
    :: x < LEN ->
        y = 0;
        do
        :: y < LEN - x ->
            if
            :: board2d(x, y) -> num_pins++;
            :: else -> skip;
            fi;
            y++;
        :: else -> break;
        od;
        x++;
    :: else -> break;
    od;

    // if there's one pin left, we've won!
    if
    :: num_pins == 1 ->
        won = true;
    :: else ->
        skip;
    fi;

}

init {
    // X and Y must be defined at compilation with the D flag
    run Board(X,Y);

    // assert that the board never wins (should fail if there's
    // a possible solution)
    assert(!won);
}
