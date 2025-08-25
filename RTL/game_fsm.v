`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2025 01:43:31 PM
// Design Name: 
// Module Name: game_fsm
// Author: Minh Luu 
// Target Devices: 
// Tool Versions: 
// Description: main game flow
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
    *cell_position:
    2'b00 - empty cell
    2'b01 - player's mark
    2'b10 - bot's mark
    2'b11 - (not use, reserved)
    
    States explain the game flow: 
    IDLE: Starting state, decides who goes first
    P_TURN_WAIT: Waiting for player to make a move
    P_VALIDATE: Checking if player's move is valid
    P_APPLY: Actually placing player's mark on the board
    P_CHECK: Checking if player won or game is tied
    AI_REQ: Requesting AI to make a move
    AI_WAIT: Waiting for AI to respond
    AI_APPLY: Placing AI's mark on the board
    AI_CHECK: Checking if AI won or game is tied
    GAME_OVER: Game has ended, waiting for reset
     
*/

module game_fsm(
    input wire rst, clk,

    // player 
    input wire [3:0] p_tick, // Player's selected position (0-8 for 3x3 grid)
    input wire p_confirm, // Player confirms their move OR resets game. Mapping to physical button/switch

    // bot
    output reg ai_confirm, // Output signal to tell bot it's their turn
    input wire [3:0] ai_tick, // bot's selected position (0-8)
    input wire ai_ack, // bot's response flag, confirms their move is ready

    // status
    output reg [17:0] cell_position, // Represents the 3x3 grid (9 cells × 2 bits each), 4 cases*
    output reg [1:0] winner, // 4 cases: (00 none, 01 player, 10 bot, 11 tie)
    output reg player_turn, // 1 = player's turn, 0 = AI's turn
    output reg [3:0] move_cnt // Counts total moves (0-9)
    );

    // internal signal for win detection
    wire [1:0] detected_winner;

    // instantiate the win checker
    win_checker win_checker_inst (
        .cell_position(cell_position),
        .winner(detected_winner)
    );
    
    // state register
    reg [3:0] state, next_state;
    
    // first player choosen flag
    reg player_choosen;

    // moving flag 
    reg move_valid;

    localparam  IDLE = 0, 
                P_TURN_WAIT = 1, 
                P_VALIDATE = 2, 
                P_APPLY = 3, 
                P_CHECK = 4, 
                AI_REQ = 5, 
                AI_WAIT = 6, 
                AI_APPLY = 7, 
                AI_CHECK = 8, 
                GAME_OVER = 9;

    // ----------------------------
    // 1) Sequential: state + registers
    // ----------------------------
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            move_cnt <= 0;
            cell_position <= 18'd0;
            winner <= 2'b00;
        end else begin
            state <= next_state;

            case (state)
                P_APPLY: begin
                    cell_position[p_tick*2+:2] <= 2'b01; // player move
                    move_cnt <= move_cnt + 1;
                end

                AI_APPLY: begin
                    cell_position[ai_tick*2+:2] <= 2'b10; // bot move
                    move_cnt <= move_cnt + 1;
                end

                GAME_OVER: begin
                    if (p_confirm) begin
                        move_cnt <= 0;
                        cell_position <= 18'd0;
                        winner <= 2'b00;
                    end

                    // set the winner when game ends
                    if (detected_winner != 2'b00) begin
                        winner <= detected_winner;
                    end else if (move_cnt == 9) begin
                        winner <= 2'b11; // tie game
                    end
                end
            endcase
        end
    end

    // ----------------------------
    // 2) Combinational: next_state + pure outputs
    // ----------------------------
    always @(*) begin
        next_state = state;
        ai_confirm = 0;
        player_turn = 0;

        case (state)
            IDLE: begin
                if (player_choosen)
                    next_state = P_TURN_WAIT;
                else
                    next_state = AI_REQ;
            end

            P_TURN_WAIT: begin
                player_turn = 1;
                if (p_confirm) next_state = P_VALIDATE;
            end

            P_VALIDATE: begin
                // check if selected cell is empty?
                if (cell_position[p_tick*2+:2] == 2'b00) begin
                    move_valid = 1;
                    next_state = P_APPLY;
                end else begin
                    move_valid = 0;
                    // stay in this state or go back to wait state
                    if (!p_confirm) next_state = P_TURN_WAIT;
                    else next_state = P_VALIDATE;
                end
            end

            P_CHECK: begin
                if (detected_winner != 2'b00) 
                    next_state = GAME_OVER;
                else if (move_cnt == 9)
                    next_state = GAME_OVER;
                else
                    next_state = AI_REQ;
            end

            AI_REQ: begin
                ai_confirm = 1;
                next_state = AI_WAIT;
            end

            AI_WAIT: begin
                if (ai_ack) next_state = AI_APPLY;
            end

            AI_CHECK: begin
                if (detected_winner != 2'b00)
                    next_state = GAME_OVER;
                else if (move_cnt == 9)
                    next_state = GAME_OVER;
                else
                    next_state = P_TURN_WAIT;
            end

            GAME_OVER: if (p_confirm) next_state = IDLE;
        endcase
    end

endmodule
