`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2025 01:48:37 PM
// Design Name: 
// Module Name: ai_agent
// Author: Minh Luu  
// Target Devices: 
// Tool Versions: 
// Description: This is a separate FSM/logic that makes decisions when it sees ai_confirm.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ai_agent (
    input        clk, rst,
    input        start,
    input  [17:0] cell_position,
    output reg [3:0] ai_tick,
    output reg       done
);

    // Simplified minimax with fixed depth = 1 (one move ahead)
    reg [17:0] test_board;
    reg [3:0] best_move;
    reg [3:0] best_score;
    reg [3:0] current_score;
    integer i;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ai_tick <= 0;
            done <= 0;
            best_move <= 0;
            best_score <= 0;
        end else if (start) begin
            done <= 0;
            best_score <= 0;
            
            $display("[%0t][AI_AGENT] AI agent starting processing", $time);
            $display("[%0t][AI_AGENT] Current board: %b", $time, cell_position);
            
            // Look one move ahead
            for (i = 0; i < 9; i = i + 1) begin
                if (cell_position[i*2 +: 2] == 2'b00) begin
                    $display("[%0t][AI_AGENT] AI testing move %0d", $time, i);
                
                    // Try this move
                    test_board = cell_position;
                    test_board[i*2 +: 2] = 2'b10;  // AI move
                    
                    // Evaluate this position
                    current_score = evaluate_position(test_board);
                    
                    $display("[%0t][AI_AGENT] Move %0d score = %0d", $time, i, current_score);
                    
                    if (current_score > best_score) begin
                        $display("[%0t][AI_AGENT] New best move: %0d (score: %0d)", $time, i, current_score);
                        best_score <= current_score;
                        best_move <= i[3:0];
                    end
                end
            end
            $display("[%0t][AI_AGENT] AI final decision - Move: %d, Score: %d", $time, best_move, best_score);
            
            // Fallback strategy
            if (best_score == 0) begin
                if (cell_position[9:8] == 2'b00) begin
                    ai_tick <= 4'd4;  // Center
                    $display("[%0t][AI_AGENT] AI choosing center (fallback)", $time);
                end else begin
                    // First available
                    for (i = 0; i < 9; i = i + 1) begin
                        if (cell_position[i*2 +: 2] == 2'b00) begin
                            ai_tick <= i[3:0];
                            $display("[%0t][AI_AGENT] AI choosing first available: %0d (fallback)", $time, i);
                        end
                    end
                end
            end else begin
                ai_tick <= best_move;
                $display("[%0t][AI_AGENT] AI final decision - Move: %0d, Score: %0d", $time, best_move, best_score);
            end
            
            done <= 1;
        end else begin
            done <= 0;
        end
    end

    // Simple position evaluation
    function [3:0] evaluate_position;
        input [17:0] board;
        reg win_count;
        reg block_count;
        integer i;
        begin
            evaluate_position = 4'd1;  // Base score
            
            // Check if this move wins
            // (Add your win checking logic here)
            
            // Center bonus
            if (board[9:8] == 2'b10)  // AI has center
                evaluate_position = evaluate_position + 4'd2;
                
            // Corner bonus
            if (board[1:0] == 2'b10 || board[5:4] == 2'b10 || 
                board[13:12] == 2'b10 || board[17:16] == 2'b10)
                evaluate_position = evaluate_position + 4'd1;
        end
    endfunction

endmodule
