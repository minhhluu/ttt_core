`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Minh Luu
// 
// Create Date: 08/20/2025 01:48:37 PM
// Design Name: 
// Module Name: ai_agent
// Project Name: 
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

    // Simple position evaluation with win detection
    function [3:0] evaluate_position;
        input [17:0] board;
        reg win_result;
        begin
            evaluate_position = 4'd1;  // Base score
            
            // Check if this move wins (highest priority)
            win_result = check_win(board, 2'b10);  // Check if AI wins
            if (win_result) begin
                evaluate_position = 4'd15;  // Highest score for winning move
            end
            
            // Center bonus (strategic position)
            if (board[9:8] == 2'b10)  // AI has center
                evaluate_position = evaluate_position + 4'd3;  // Increased from 2 to 3
                
            // Corner bonus (good strategic positions)
            if (board[1:0] == 2'b10 ||   // Corner 0
                board[5:4] == 2'b10 ||   // Corner 2
                board[13:12] == 2'b10 || // Corner 6
                board[17:16] == 2'b10)   // Corner 8
                evaluate_position = evaluate_position + 4'd2;  // Increased from 1 to 2
                
            // Edge bonus (moderate positions)
            if (board[3:2] == 2'b10 ||   // Edge 1
                board[7:6] == 2'b10 ||   // Edge 3
                board[11:10] == 2'b10 || // Edge 5
                board[15:14] == 2'b10)   // Edge 7
                evaluate_position = evaluate_position + 4'd1;
        end
    endfunction

    // Function to check if a player has won
    function check_win;
        input [17:0] board;
        input [1:0] player;  // 2'b01 = Player, 2'b10 = AI
        begin
            check_win = 0;
            
            // Check rows (left to right)
            // Top row: cells 6,7,8 → bits [13:12][15:14][17:16]
            if ((board[13:12] == player) && (board[15:14] == player) && (board[17:16] == player))
                check_win = 1;
                
            // Middle row: cells 3,4,5 → bits [7:6][9:8][11:10]
            else if ((board[7:6] == player) && (board[9:8] == player) && (board[11:10] == player))
                check_win = 1;
                
            // Bottom row: cells 0,1,2 → bits [1:0][3:2][5:4]
            else if ((board[1:0] == player) && (board[3:2] == player) && (board[5:4] == player))
                check_win = 1;
            
            // Check columns (top to bottom)
            // Left column: cells 6,3,0 → bits [13:12][7:6][1:0]
            else if ((board[13:12] == player) && (board[7:6] == player) && (board[1:0] == player))
                check_win = 1;
                
            // Middle column: cells 7,4,1 → bits [15:14][9:8][3:2]
            else if ((board[15:14] == player) && (board[9:8] == player) && (board[3:2] == player))
                check_win = 1;
                
            // Right column: cells 8,5,2 → bits [17:16][11:10][5:4]
            else if ((board[17:16] == player) && (board[11:10] == player) && (board[5:4] == player))
                check_win = 1;
            
            // Check diagonals
            // Main diagonal: cells 6,4,2 → bits [13:12][9:8][5:4]
            else if ((board[13:12] == player) && (board[9:8] == player) && (board[5:4] == player))
                check_win = 1;
                
            // Anti-diagonal: cells 8,4,0 → bits [17:16][9:8][1:0]
            else if ((board[17:16] == player) && (board[9:8] == player) && (board[1:0] == player))
                check_win = 1;
        end
    endfunction

    // Simplified minimax with fixed depth = 1 (one move ahead)
    reg [17:0] test_board;
    reg [3:0] best_move;
    reg [3:0] best_score;
    reg [3:0] current_score;
    reg found;
    integer i;
    integer j;
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            ai_tick <= 0;
            done <= 0;
            best_move <= 0;
            best_score <= 0;
            i <= 0;
            j <= 0;
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
                    // First available - use a flag to stop after first find
                    found = 0;
                    for (j = 0; j < 9 && !found; j = j + 1) begin
                        if (cell_position[j*2 +: 2] == 2'b00) begin
                            ai_tick <= j[3:0];
                            $display("[%0t][AI_AGENT] AI choosing first available: %0d (fallback)", $time, j);
                            found = 1;
                        end
                    end
                end
            end
            else begin
                ai_tick <= best_move;
                $display("[%0t][AI_AGENT] AI final decision - Move: %0d, Score: %0d", $time, best_move, best_score);
            end
            
            done <= 1;
        end else begin
            done <= 0;
        end
    end
endmodule
