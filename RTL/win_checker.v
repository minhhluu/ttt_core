`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Minh Luu
// 
// Create Date: 08/20/2025 12:27:46 PM
// Design Name: 
// Module Name: win_checker
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This module just takes board state (cell_position) and returns a winner
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/* 
check rows (left -> right) logic:
- all rows must be filled, not empty
- all rows are equal
-> if these 2 conditions are satisfied  -> find out who is the winner

cell_position:
    2'b00 - empty cell
    2'b01 - player's mark
    2'b10 - bot's mark
    2'b11 - (not use, reserved)
*/

module win_checker (
    input  [17:0] cell_position,
    output reg [1:0] winner
);

    always @(*) begin
        winner = 2'b00; // Default: no winner
        
        // Check ROWS (left-to-right)
        // Top row: cells 6,7,8 → bits [13:12][15:14][17:16]  
        if (cell_position[13:12] != 2'b00 &&
            cell_position[13:12] == cell_position[15:14] &&
            cell_position[15:14] == cell_position[17:16])
            winner = cell_position[13:12];
    
        // Middle row: cells 3,4,5 → bits [7:6][9:8][11:10]
        else if (cell_position[7:6] != 2'b00 &&
                 cell_position[7:6] == cell_position[9:8] &&
                 cell_position[9:8] == cell_position[11:10])
            winner = cell_position[7:6];
    
        // Bottom row: cells 0,1,2 → bits [1:0][3:2][5:4] ← THIS IS THE WIN!
        else if (cell_position[1:0] != 2'b00 &&           // Cell 0
                 cell_position[1:0] == cell_position[3:2] &&   // Cell 0 == Cell 1
                 cell_position[3:2] == cell_position[5:4])     // Cell 1 == Cell 2
            winner = cell_position[1:0];  // Return the winner (2'b01 = Player)
    
        // Check COLUMNS (top-to-bottom)
        // Left column: cells 6,3,0 → bits [13:12][7:6][1:0]
        else if (cell_position[13:12] != 2'b00 &&
                 cell_position[13:12] == cell_position[7:6] &&
                 cell_position[7:6] == cell_position[1:0])
            winner = cell_position[13:12];
    
        // Middle column: cells 7,4,1 → bits [15:14][9:8][3:2]
        else if (cell_position[15:14] != 2'b00 &&
                 cell_position[15:14] == cell_position[9:8] &&
                 cell_position[9:8] == cell_position[3:2])
            winner = cell_position[15:14];
    
        // Right column: cells 8,5,2 → bits [17:16][11:10][5:4]
        else if (cell_position[17:16] != 2'b00 &&
                 cell_position[17:16] == cell_position[11:10] &&
                 cell_position[11:10] == cell_position[5:4])
            winner = cell_position[17:16];
    
        // Check DIAGONALS
        // Main diagonal (top-left to bottom-right): cells 6,4,2 → bits [13:12][9:8][5:4]
        else if (cell_position[13:12] != 2'b00 &&
                 cell_position[13:12] == cell_position[9:8] &&
                 cell_position[9:8] == cell_position[5:4])
            winner = cell_position[13:12];
    
        // Anti-diagonal (top-right to bottom-left): cells 8,4,0 → bits [17:16][9:8][1:0]
        else if (cell_position[17:16] != 2'b00 &&
                 cell_position[17:16] == cell_position[9:8] &&
                 cell_position[9:8] == cell_position[1:0])
            winner = cell_position[17:16];
    end

endmodule
