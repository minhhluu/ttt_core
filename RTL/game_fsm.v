`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Minh Luu
// 
// Create Date: 08/19/2025 01:43:31 PM
// Design Name: 
// Module Name: game_fsm
// Project Name: 
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
//            $display("[%0t] DEBUG: State transition: %0d -> %0d", $time, state, next_state);
            state <= next_state;

            case (state)
                P_APPLY: begin
//                    $display("[%0t] DEBUG: Executing P_APPLY - Applying move %0d", $time, p_tick);
//                    $display("[%0t] DEBUG: Cell %0d content before: %b", $time, p_tick, cell_position[p_tick*2+:2]);
                    
                    // Only apply move if cell is empty and within move limit
                    if (p_tick < 9 && cell_position[p_tick*2+:2] == 2'b00 && move_cnt < 9) begin
                        cell_position[p_tick*2+:2] <= 2'b01; // player move
                        move_cnt <= move_cnt + 1;
//                        $display("[%0t] DEBUG: Move %0d APPLIED successfully", $time, p_tick);
                    end else begin
                        $display("[%0t] DEBUG: Move %0d REJECTED", $time, p_tick);
                    end
                end
                
                AI_APPLY: begin
//                    $display("[%0t] DEBUG: Executing AI_APPLY - Applying AI move %0d", $time, ai_tick);
                    if (ai_tick < 9 && cell_position[ai_tick*2+:2] == 2'b00 && move_cnt < 9) begin
                        cell_position[ai_tick*2+:2] <= 2'b10; // bot move
                        move_cnt <= move_cnt + 1;
//                        $display("[%0t] DEBUG: AI Move %0d APPLIED successfully", $time, ai_tick);
                    end else begin
                        $display("[%0t] DEBUG: AI Move %0d REJECTED", $time, ai_tick);
                    end
                end

                GAME_OVER: begin
                    // Handle reset
                    if (p_confirm) begin
                        move_cnt <= 0;
                        cell_position <= 18'd0;
                        winner <= 2'b00;
                        $display("[%0t] DEBUG: Game reset", $time);
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
                $display("[%0t] DEBUG: State = IDLE", $time);
                if (player_choosen)
                    next_state = P_TURN_WAIT;
                else
                    next_state = AI_REQ;
            end

            P_TURN_WAIT: begin
                $display("[%0t] DEBUG: State = P_TURN_WAIT, player_turn = %b, p_confirm = %b", 
                         $time, player_turn, p_confirm);
                player_turn = 1;
                if (p_confirm) begin
                    $display("[%0t] DEBUG: p_confirm detected - going to P_VALIDATE", $time);
                    next_state = P_VALIDATE;
                end
            end

            P_VALIDATE: begin
                $display("[%0t] DEBUG: State = P_VALIDATE", $time);
                $display("[%0t] DEBUG: P_VALIDATE - p_tick=%0d, move_cnt=%0d, winner=%b", 
                         $time, p_tick, move_cnt, winner);
                $display("[%0t] DEBUG: Cell %0d content: %b", $time, p_tick, cell_position[p_tick*2+:2]);
                $display("[%0t] DEBUG: p_tick<9: %b, cell_empty: %b, move_cnt<9: %b, winner==00: %b",
                         $time, (p_tick<9), (cell_position[p_tick*2+:2] == 2'b00), (move_cnt<9), (winner == 2'b00));
                
                // Check if move is valid
                if (p_tick < 9 && cell_position[p_tick*2+:2] == 2'b00 && move_cnt < 9 && winner == 2'b00) begin
                    $display("[%0t] DEBUG: Move VALID - going to P_APPLY", $time);
                    next_state = P_APPLY;
                end else begin
                    $display("[%0t] DEBUG: Move INVALID - going back to P_TURN_WAIT", $time);
                    next_state = P_TURN_WAIT;
                end
            end

            P_APPLY: begin
                $display("[%0t] DEBUG: State = P_APPLY - going to P_CHECK", $time);
                next_state = P_CHECK;
            end

            P_CHECK: begin
                $display("[%0t] DEBUG: State = P_CHECK", $time);
                $display("[%0t] DEBUG: P_CHECK - detected_winner=%b, move_cnt=%0d", 
                         $time, detected_winner, move_cnt);
                if (detected_winner != 2'b00) begin
                    $display("[%0t] DEBUG: Winner detected - going to GAME_OVER", $time);
                    next_state = GAME_OVER;
                end
                else if (move_cnt >= 9) begin
                    $display("[%0t] DEBUG: Tie game - going to GAME_OVER", $time);
                    next_state = GAME_OVER;
                end
                else begin
                    $display("[%0t] DEBUG: No winner - going to AI_REQ", $time);
                    next_state = AI_REQ;
                end
            end

            AI_REQ: begin
//                $display("[%0t] DEBUG: State = AI_REQ", $time);
                if (move_cnt < 9 && winner == 2'b00) begin
                    ai_confirm = 1;
                    next_state = AI_WAIT;
                end else begin
                    next_state = GAME_OVER;
                end
            end

            AI_WAIT: begin
                $display("[%0t] DEBUG: State = AI_WAIT, ai_ack = %b", $time, ai_ack);
                if (ai_ack) begin
                    $display("[%0t] DEBUG: ai_ack detected - going to AI_APPLY", $time);
                    next_state = AI_APPLY;
                end
            end

            AI_APPLY: begin
                $display("[%0t] DEBUG: State = AI_APPLY - going to AI_CHECK", $time);
                next_state = AI_CHECK;
            end

            AI_CHECK: begin
                $display("[%0t] DEBUG: State = AI_CHECK", $time);
                if (detected_winner != 2'b00) begin
                    $display("[%0t] DEBUG: Winner detected - going to GAME_OVER", $time);
                    next_state = GAME_OVER;
                end
                else if (move_cnt >= 9) begin
//                    $display("[%0t] DEBUG: Tie game - going to GAME_OVER", $time);
                    next_state = GAME_OVER;
                end
                else begin
//                    $display("[%0t] DEBUG: No winner - going to P_TURN_WAIT", $time);
                    next_state = P_TURN_WAIT;
                end
            end

            GAME_OVER: begin
//                $display("[%0t] DEBUG: State = GAME_OVER, p_confirm = %b", $time, p_confirm);
                if (p_confirm) next_state = IDLE;
            end 
        endcase
    end

    // Set winner in sequential block when entering GAME_OVER
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            winner <= 2'b00;
        end else if (state != GAME_OVER && next_state == GAME_OVER) begin
            // Only set winner when transitioning to GAME_OVER
            if (detected_winner != 2'b00) begin
                winner <= detected_winner;
//                $display("[%0t] DEBUG: Winner set to %b", $time, detected_winner);
            end else if (move_cnt >= 9) begin
                winner <= 2'b11; // tie game
//                $display("[%0t] DEBUG: Winner set to tie (11)", $time);
            end
        end
    end

    // detect winner debugging
    always @(posedge clk) begin
        if (detected_winner != 2'b00) begin
            $display("[%0t] DEBUG: Win detected! Winner = %b", $time, detected_winner);
        end
        if (move_cnt == 3) begin
            $display("[%0t] DEBUG: 3 moves made. Board: %b", $time, cell_position);
            $display("[%0t] DEBUG: Cell 0: %b, Cell 1: %b, Cell 2: %b", 
                     $time, cell_position[1:0], cell_position[3:2], cell_position[5:4]);
        end
    end
endmodule
