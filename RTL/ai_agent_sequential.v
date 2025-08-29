`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2025 09:25:12 PM
// Design Name: 
// Module Name: ai_agent_sequential
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ai_agent_sequential (
    input        clk, rst,
    input        start,
    input  [17:0] cell_position,
    output reg [3:0] ai_tick,
    output reg       done
);

    // State machine for sequential evaluation  
    localparam  IDLE = 0, 
                INIT_EVAL = 1, 
                EVALUATE = 2, 
                COMPARE = 3, 
                CHOOSE_BEST = 4, 
                FALLBACK = 5, 
                DONE = 6;

    reg [3:0] state, next_state;
    
    // Evaluation pipeline registers
    reg [3:0] eval_counter;      // 0-8 for positions 0-8
    reg [17:0] test_board;       // Board with test move
    reg [3:0] current_score;     // Score of current move
    reg [3:0] best_score;        // Best score found
    reg [3:0] best_move;         // Best move position
    reg move_valid;              // Current move is valid
    reg found_fallback;          // Found first available move
    integer j;

    // Function declarations (same as before)
    function [3:0] evaluate_position;
        input [17:0] board;
        reg win_result;
        begin
            evaluate_position = 4'd1;
            win_result = check_win(board, 2'b10);
            if (win_result) evaluate_position = 4'd15;
            if (board[9:8] == 2'b10) evaluate_position = evaluate_position + 4'd3;
            if (board[1:0] == 2'b10 || board[5:4] == 2'b10 || 
                board[13:12] == 2'b10 || board[17:16] == 2'b10)
                evaluate_position = evaluate_position + 4'd2;
            if (board[3:2] == 2'b10 || board[7:6] == 2'b10 || 
                board[11:10] == 2'b10 || board[15:14] == 2'b10)
                evaluate_position = evaluate_position + 4'd1;
        end
    endfunction

    function check_win;
        input [17:0] board;
        input [1:0] player;
        begin
            check_win = 0;
            // ... (same win checking logic) ...
        end
    endfunction

    // State machine sequential logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            eval_counter <= 0;
            best_score <= 0;
            best_move <= 0;
            ai_tick <= 0;
            done <= 0;
            found_fallback <= 0;
        end else begin
            state <= next_state;
            
            case (state)
                INIT_EVAL: begin
                    eval_counter <= 0;
                    best_score <= 0;
                    best_move <= 0;
                    $display("[%0t][AI_AGENT] AI agent starting processing", $time);
                    $display("[%0t][AI_AGENT] Current board: %b", $time, cell_position);
                end
                
                EVALUATE: begin
                    // Evaluate one move per clock cycle
                    if (move_valid) begin
                        current_score <= evaluate_position(test_board);
                        $display("[%0t][AI_AGENT] Move %0d score = %0d", $time, eval_counter, current_score);
                    end
                end
                
                COMPARE: begin
                    // Compare and update best move
                    if (move_valid && current_score > best_score) begin
                        best_score <= current_score;
                        best_move <= eval_counter;
                        $display("[%0t][AI_AGENT] New best move: %0d (score: %0d)", $time, eval_counter, current_score);
                    end
                    eval_counter <= eval_counter + 1;
                end
                
                DONE: begin
                    if (best_score > 0) begin
                        ai_tick <= best_move;
                        $display("[%0t][AI_AGENT] AI final decision - Move: %0d, Score: %0d", $time, best_move, best_score);
                    end
                    done <= 1;
                end
                
                default: begin
                    // Handle other states
                end
            endcase
        end
    end

    // Combinational logic for next state and outputs
    always @(*) begin
        next_state = state;
        move_valid = 0;
        test_board = cell_position;
        
        case (state)
            IDLE: begin
                if (start) next_state = INIT_EVAL;
            end
            
            INIT_EVAL: begin
                next_state = (eval_counter < 9) ? EVALUATE : CHOOSE_BEST;
            end
            
            EVALUATE: begin
                // Check if current position is valid
                move_valid = (cell_position[eval_counter*2 +: 2] == 2'b00);
                if (move_valid) begin
                    test_board[eval_counter*2 +: 2] = 2'b10;
                    $display("[%0t][AI_AGENT] AI testing move %0d", $time, eval_counter);
                end
                next_state = COMPARE;
            end
            
            COMPARE: begin
                if (eval_counter < 8) begin
                    next_state = EVALUATE;
                end else begin
                    next_state = DONE;
                end
            end
            
            DONE: begin
                if (!done) next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Fallback strategy (if no good move found)
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            found_fallback <= 0;
        end else if (state == DONE && best_score == 0 && !found_fallback) begin
            // Try to take center
            if (cell_position[9:8] == 2'b00) begin
                ai_tick <= 4;
                $display("[%0t][AI_AGENT] AI choosing center (fallback)", $time);
                found_fallback <= 1;
            end
            // Otherwise find first available
            else if (!found_fallback) begin
                for (j = 0; j < 9; j = j + 1) begin
                    if (cell_position[j*2 +: 2] == 2'b00) begin
                        ai_tick <= j;
                        $display("[%0t][AI_AGENT] AI choosing first available: %0d (fallback)", $time, j);
                        found_fallback <= 1;
                    end
                end
            end
        end
    end

endmodule