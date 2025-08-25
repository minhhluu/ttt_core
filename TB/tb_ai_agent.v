`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Minh Luu
// 
// Create Date: 08/23/2025 03:15:18 PM
// Design Name: 
// Module Name: tb_ai_agent
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench for AI's behavior
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_ai_agent;

    reg clk;
    reg rst;
    reg start;
    reg [17:0] cell_position;
    wire [3:0] ai_tick;
    wire done;
    integer timeout;

    // Instantiate the AI agent
    ai_agent uut_ai (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cell_position(cell_position),
        .ai_tick(ai_tick),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task to display board in readable format
    task display_board;
        input [17:0] board;
        begin
            $display("Current Board:");
            $display(" %s | %s | %s ", get_symbol(board[17:16]), get_symbol(board[15:14]), get_symbol(board[13:12]));
            $display("-----------");
            $display(" %s | %s | %s ", get_symbol(board[11:10]), get_symbol(board[9:8]), get_symbol(board[7:6]));
            $display("-----------");
            $display(" %s | %s | %s ", get_symbol(board[5:4]), get_symbol(board[3:2]), get_symbol(board[1:0]));
            $display("");
        end
    endtask

    // Function to convert cell value to symbol
    function [7:0] get_symbol;
        input [1:0] cell_value;
        begin
            case (cell_value)
                2'b00: get_symbol = " ";  // Empty
                2'b01: get_symbol = "X";  // Player
                2'b10: get_symbol = "O";  // AI
                default: get_symbol = "?";
            endcase
        end
    endfunction

    // Task to test AI move
    task test_ai_move;
        input [17:0] board_state;
        input [7:0] test_name;
        begin
            $display("=== %s ===", test_name);
            cell_position = board_state;
            display_board(cell_position);
            
            start = 1;
            @(posedge clk);
            start = 0;
            
            // Wait longer for AI to respond
            timeout = 0;
            while (!done && timeout < 50) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            
            if (done) begin
                $display("[VALID] AI chose position: %0d", ai_tick);
            end else begin
                $display("[INVALID] AI did not respond within 50 cycles");
            end
            $display("");
        end
    endtask

    initial begin
        $dumpfile("tb_ai_agent.vcd");
        $dumpvars(0, tb_ai_agent);

        // Initialize
        clk = 0;
        rst = 0;
        start = 0;
        cell_position = 18'd0;

        // Apply reset
        #10 rst = 1;
        #10;

        // Test 1: Empty board - should take center
        test_ai_move(18'b000000000000000000, "TEST 1: Empty Board");

        // Test 2: Center taken - should take corner
        test_ai_move(18'b000000000000000001, "TEST 2: Center Taken");

        // Test 3: AI can win - complete diagonal
        // Board: O |   |  
        //        ---|---|---
        //          | O |  
        //        ---|---|---
        //        X | X | O
        test_ai_move(18'b00_00_00_00_10_00_01_10_00, "TEST 3: AI Can Win");

        // Test 4: Block player from winning
        // Board: X | X |  
        //        ---|---|---
        //          |   |  
        //        ---|---|---
        //          |   |  
        test_ai_move(18'b01_01_00_00_00_00_00_00_00, "TEST 4: Block Player");

        // Test 5: Mixed board - strategic move
        // Board: X | O |  
        //        ---|---|---
        //        O | X |  
        //        ---|---|---
        //          |   |  
        test_ai_move(18'b01_00_00_10_01_00_00_10_01, "TEST 5: Mixed Board");

        $display("=== ALL TESTS COMPLETED ===");
        #100 $finish;
    end

    // Monitor AI responses
    always @(done) begin
        if (done) begin
            $display("[%0t] AI Response: ai_tick=%0d, done=1", $time, ai_tick);
        end
    end

endmodule
