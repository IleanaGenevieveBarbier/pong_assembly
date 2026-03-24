# Pong Game in x86 Assembly

A Pong game written in 16-bit x86 Assembly (MASM/TASM syntax) that runs in text mode using direct video memory access (0xB800).

This project demonstrates low-level programming concepts such as BIOS interrupts, keyboard input handling, memory manipulation, and basic game loop design.

## Features

- Two-player gameplay (keyboard controlled)
- Real-time paddle movement
- Ball physics and collision detection
- Score tracking system
- Win condition handling
- Menu and restart functionality
- Text-mode rendering (80x25)

## Controls

| Key        | Action                  |
|------------|------------------------|
| W / S      | Move left paddle       |
| Up / Down  | Move right paddle      |
| SPACE      | Start game             |
| ESC        | Exit game              |

## Requirements

- MASM or TASM assembler
- DOS environment (DOSBox recommended)

## Build Instructions

### Using TASM

```
tasm pong.asm
tlink pong.obj
```

### Using MASM

```
masm pong.asm;
link pong.obj;
```

## Running the Game

Run the executable inside DOSBox:

```
dosbox pong.exe
```

## How It Works

### Display

The game uses text mode (80x25) and writes directly to video memory at address 0xB800. Each screen cell consists of two bytes: a character and its color attribute.

### Game Loop

The main loop performs the following steps:

1. Read keyboard input using BIOS interrupt (int 16h)
2. Update ball position
3. Check collisions with walls and paddles
4. Update scores if needed
5. Render paddles, ball, and UI
6. Apply a short delay for frame control

### Core Procedures

- `check_input` handles player input
- `update_ball` manages movement and collisions
- `draw_paddles` renders paddles
- `draw_ball` renders the ball
- `draw_ui` draws the center line and scores
- `check_win_condition` checks if a player has won
- `reset_ball` resets ball position after scoring

## Win Condition

The first player to reach 10 points wins. A message is displayed indicating the winner, and the game returns to the menu.
