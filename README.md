# 🎮 Tic-Tac-Toe Game System (v0.2)

A complete Verilog implementation of a Tic-Tac-Toe game with FSM-based game flow, AI opponent, and win detection.

  - [🔧 Features](#-features)
  - [📂 Project Structure](#-project-structure)
  - [📝 Testbench](#-testbench-diagrams)
  - [🧩 Module Descriptions](#-module-descriptions)
  - [🎯 Tic-Tac-Toe Board Layout](#-tic-tac-toe-board-layout)
  - [🧪 Cell Mapping Bits](#-cell-mapping-bits)
  - [🏆 Winning Lines](#-winning-lines)
    - [`win_checker.v` - Win Condition Detector](#1-win_checkerv---win-condition-detector)
    - [`ai_agent.v` - AI Decision Maker](#2-ai_agentv---ai-decision-maker)
    - [`game_fsm.v` - Game State Machine](#3-game_fsmv---game-state-machine)
    - [`top_module.v` - Top-Level Integration](#4-top_modulev---top-level-integration)



## 🔧 Features

- ✅ Turn-based gameplay (Player vs AI/AI vs AI)
- ✅ Win detection for all possible winning combinations
- ✅ Move validation (no illegal moves)
- ✅ AI agent with strategic logic
- ✅ Complete game flow management
- ✅ Asynchronous reset
- ✅ Comprehensive testbench for verification

## 📂 Project Structure

```

tic_tac_toe/
├── RTL/
│   ├── ai_agent.v          # AI decision-making module
│   ├── game_fsm.v          # Main game state machine
│   ├── win_checker.v       # Win detection logic
│   └── top_module.v        # Top-level module
├── TB/
│   ├── tb_top_module.v     # Testbench for full system
|   ├── tb_game_fsm.v       # Testbench for FSM states
│   └── tb_ai_agent.v       # Testbench for AI's behavior
└── README.md

```
## 📝 Testbench Diagrams

### TB - `tb_top_module.v`
![TB Top Module](https://i.postimg.cc/vQjz8TGk/tb-top-module.png)

### TB - `tb_ai_agent.v`
![TB AI Agent](https://i.postimg.cc/RMqdzKxw/tb-ai-agent.png)

## 🧩 Module Descriptions
```
┌─────────────────────────────────────────────────────────────────────┐
│                         TIC-TAC-TOE TOP MODULE                      │
│                                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐  │
│  │                 │    │                 │    │                 │  │
│  │   game_fsm      │◄───┤   ai_agent      │    │   win_checker   │  │
│  │ (State Machine) │    │ (AI Logic)      │    │ (Win Detection) │  │
│  │                 │    │                 │    │                 │  │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘  │
│        ▲      │                                                     │
│        │      └─────────────────────────────────────────────────────┘
│        │
│  ┌─────┴────┐
│  │ Player   │
│  │ Inputs   │
│  │ (p_tick, │
│  │p_confirm)│
│  └──────────┘
└─────────────────────────────────────────────────────────────────────┘

```
## 🎯 Tic-Tac-Toe Board Layout
```
┌─────┬─────┬─────┐
│  6  │  7  │  8  │  ← Top row
├─────┼─────┼─────┤
│  3  │  4  │  5  │  ← Middle row  
├─────┼─────┼─────┤
│  0  │  1  │  2  │  ← Bottom row
└─────┴─────┴─────┘
       Column
Left  Middle  Right
```

## 🧪 Cell Mapping Bits
```
┌──────────────────────┬──────────────────────┬──────────────────────┐
│ 6 • Top-Left         │ 7 • Top-Middle       │ 8 • Top-Right        │
│      [13:12]         │      [15:14]         │      [17:16]         │
├──────────────────────┼──────────────────────┼──────────────────────┤
│ 3 • Mid-Left         │ 4 • Mid-Middle       │ 5 • Mid-Right        │
│      [7:6]           │      [9:8]           │      [11:10]         │
├──────────────────────┼──────────────────────┼──────────────────────┤
│ 0 • Bot-Left         │ 1 • Bot-Middle       │ 2 • Bot-Right        │
│      [1:0]           │      [3:2]           │      [5:4]           │
└──────────────────────┴──────────────────────┴──────────────────────┘
```

## 🏆 Winning Lines
```
ROWS:
┌─────┬─────┬─────┐    ┌─────┬─────┬─────┐    ┌─────┬─────┬─────┐
│  6  │  7  │  8  │    │  ○  │  ○  │  ○  │    │     │     │     │
├─────┼─────┼─────┤    ├─────┼─────┼─────┤    ├─────┼─────┼─────┤
│     │     │     │    │  3  │  4  │  5  │    │  ○  │  ○  │  ○  │
├─────┼─────┼─────┤    ├─────┼─────┼─────┤    ├─────┼─────┼─────┤
│     │     │     │    │     │     │     │    │  0  │  1  │  2  │
└─────┴─────┴─────┘    └─────┴─────┴─────┘    └─────┴─────┴─────┘

COLUMNS:
┌─────┬─────┬─────┐    ┌─────┬─────┬─────┐    ┌─────┬─────┬─────┐
│  ○  │     │     │    │     │  ○  │     │    │     │     │  ○  │
├─────┼─────┼─────┤    ├─────┼─────┼─────┤    ├─────┼─────┼─────┤
│  ○  │     │     │    │     │  ○  │     │    │     │     │  ○  │
├─────┼─────┼─────┤    ├─────┼─────┼─────┤    ├─────┼─────┼─────┤
│  ○  │     │     │    │     │  ○  │     │    │     │     │  ○  │
└─────┴─────┴─────┘    └─────┴─────┴─────┘    └─────┴─────┴─────┘

DIAGONALS:
┌─────┬─────┬─────┐    ┌─────┬─────┬─────┐
│  ○  │     │     │    │     │     │  ○  │
├─────┼─────┼─────┤    ├─────┼─────┼─────┤
│     │  ○  │     │    │     │  ○  │     │
├─────┼─────┼─────┤    ├─────┼─────┼─────┤
│     │     │  ○  │    │  ○  │     │     │
└─────┴─────┴─────┘    └─────┴─────┴─────┘
```
#### 1. `win_checker.v` - Win Condition Detector

```verilog
module win_checker (
    input  [17:0] cell_position,
    output reg [1:0] winner
);
```
- Purpose: Detects if a player or AI has won, or if the game is a tie.
- Mechanism:
    - Scans all 8 winning combinations (3 rows, 3 columns, 2 diagonals)
    - Outputs winner:
        - `2'b00`: No winner (game in progress)
        - `2'b01`: Player wins
        - `2'b10`: AI wins
        - `2'b11`: Tie (board full, no winner)

#### 2. `ai_agent.v` - AI Decision Maker
```verilog
module ai_agent (
    input        clk, rst,
    input        start,
    input  [17:0] cell_position,
    output reg [3:0] ai_tick,
    output reg       done
);
```
- Purpose: Decides the AI’s next move.
- Strategy (Rule-Based):
    - Take the center (position 4) if available.
    - Otherwise, select the first empty cell (scanning 0 to 8).

- Signals:
    - `start`: Triggered by game FSM to request AI move
    - `done`: AI signals move is ready
    - `ai_tick`: Output position (0–8)
     
     
#### 3. `game_fsm.v` - Game State Machine
```verilog
module game_fsm(
    input wire rst, clk,
    input wire [3:0] p_tick, 
    input wire p_confirm,
    output reg ai_confirm,
    input wire [3:0] ai_tick,
    input wire ai_ack,
    output reg [17:0] cell_position,
    output reg [1:0] winner,
    output reg player_turn,
    output reg [3:0] move_cnt
);
```
- Purpose: Manages the entire game flow using FSM.
- States:
    - `IDLE`: Starting state, decides who goes first
    - `P_TURN_WAIT`: Waiting for player to make a move
    - `P_VALIDATE`: Checking if player's move is valid
    - `P_APPLY`: Actually placing player's mark on the board
    - `P_CHECK`: Checking if player won or game is tied
    - `AI_REQ`: Requesting AI to make a move
    - `AI_WAIT`: Waiting for AI to respond
    - `AI_APPLY`: Placing AI's mark on the board
    - `AI_CHECK`: Checking if AI won or game is tied
    - `GAME_OVER`: Game has ended, waiting for reset
     
#### 4. `top_module.v` - Top-Level Integration
```verilog
module top_module (
    input wire clk,
    input wire rst,
    input wire [3:0] p_tick,
    input wire p_confirm,
    output wire [17:0] cell_position,
    output wire [1:0] winner,
    output wire player_turn,
    output wire [3:0] move_cnt
);
```
- Purpose: Top-level module that wires all components together.
- Signal Flow:
    - Player inputs → `game_fsm`
    - `game_fsm` → requests AI move via ai_confirm
    - `ai_agent` → computes move and responds via ai_tick and ai_ack
    - `win_checker` → embedded in game_fsm for result detection
     
