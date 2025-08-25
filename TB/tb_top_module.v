`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Minh Luu
// 
// Create Date: 08/21/2025 11:13:47 AM
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench for full system
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_top_module;

    // Inputs
    reg clk;
    reg rst;
    reg [3:0] p_tick;
    reg p_confirm;

    // Outputs
    wire [17:0] cell_position;
    wire [1:0] winner;
    wire player_turn;
    wire [3:0] move_cnt;

    // Internal signals for AI connection
    wire ai_confirm;
    wire [3:0] ai_tick;
    wire ai_ack;

    // Debug registers to track previous values
    reg [17:0] prev_cell_position;
    reg [1:0] prev_winner;
    reg prev_player_turn;
    reg [3:0] prev_move_cnt;

    // Instantiate the game FSM
    game_fsm uut_main (
        .clk(clk),
        .rst(rst),
        .p_tick(p_tick),
        .p_confirm(p_confirm),
        .ai_confirm(ai_confirm),
        .ai_tick(ai_tick),
        .ai_ack(ai_ack),
        .cell_position(cell_position),
        .winner(winner),
        .player_turn(player_turn),
        .move_cnt(move_cnt)
    );

    // Instantiate the real AI agent
    ai_agent uut_ai_agent (
        .clk(clk),
        .rst(rst),
        .start(ai_confirm),
        .cell_position(cell_position),
        .ai_tick(ai_tick),
        .done(ai_ack)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initialize previous values
    initial begin
        prev_cell_position = 18'h0;
        prev_winner = 2'h0;
        prev_player_turn = 1'b0;
        prev_move_cnt = 4'h0;
    end

    // Debug: Monitor AI agent signals
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset debug tracking
        end else begin
            if (ai_confirm) begin
                $display("[%0t] AI_CONFIRM asserted - Game requesting AI move", $time);
                $display("[%0t] Current board state: %b", $time, cell_position);
            end
            if (ai_ack) begin
                $display("[%0t] AI_ACK asserted - AI completed move", $time);
                $display("[%0t] AI selected move: %0d", $time, ai_tick);
            end
        end
    end

    // Debug: Monitor game state changes
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            prev_cell_position <= 18'h0;
            prev_winner <= 2'h0;
            prev_player_turn <= 1'b0;
            prev_move_cnt <= 4'h0;
        end else begin
            if (cell_position !== prev_cell_position) begin
                $display("[%0t] Board updated: %b", $time, cell_position);
                prev_cell_position <= cell_position;
            end

            if (winner !== prev_winner) begin
                case (winner)
                    2'b01: $display("[%0t] Winner changed: PLAYER WINS!", $time);
                    2'b10: $display("[%0t] Winner changed: AI WINS!", $time);
                    2'b11: $display("[%0t] Winner changed: TIE GAME!", $time);
                    default: $display("[%0t] Winner changed: %b", $time, winner);
                endcase
                prev_winner <= winner;
            end

            if (player_turn !== prev_player_turn) begin
                $display("[%0t] Turn changed: %s", $time, player_turn ? "Player" : "AI");
                prev_player_turn <= player_turn;
            end

            if (move_cnt !== prev_move_cnt) begin
                if (move_cnt < 10) begin  // Only log valid moves
                    $display("[%0t] Move count: %0d", $time, move_cnt);
                    prev_move_cnt <= move_cnt;
                end
            end
        end
    end

    // Helper tasks
    task player_move;
        input [3:0] pos;
        begin
            $display("[%0t] Player making move at position %0d", $time, pos);
            
            // Wait until it's player's turn
            while (!player_turn) begin
                @(posedge clk);
            end
            
            // Now make the move
            @(posedge clk);
            p_tick = pos;
            p_confirm = 1;
            @(posedge clk);
            p_confirm = 0;
            
            // Wait for full processing cycle
            repeat(20) @(posedge clk);
        end
    endtask

    task reset_game;
        begin
            $display("[%0t] Resetting game...", $time);
            @(posedge clk);
            p_confirm = 1;
            repeat(3) @(posedge clk);
            p_confirm = 0;
            repeat(20) @(posedge clk);
        end
    endtask

    task display_board;
        reg [1:0] cell0, cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8;
        reg [7:0] sym0, sym1, sym2, sym3, sym4, sym5, sym6, sym7, sym8;
        begin
            cell0 = cell_position[1:0];   cell1 = cell_position[3:2];   cell2 = cell_position[5:4];
            cell3 = cell_position[7:6];   cell4 = cell_position[9:8];   cell5 = cell_position[11:10];
            cell6 = cell_position[13:12]; cell7 = cell_position[15:14]; cell8 = cell_position[17:16];
            
            sym8 = (cell8 == 2'b00) ? " " : (cell8 == 2'b01) ? "X" : "O";
            sym7 = (cell7 == 2'b00) ? " " : (cell7 == 2'b01) ? "X" : "O";
            sym6 = (cell6 == 2'b00) ? " " : (cell6 == 2'b01) ? "X" : "O";
            sym5 = (cell5 == 2'b00) ? " " : (cell5 == 2'b01) ? "X" : "O";
            sym4 = (cell4 == 2'b00) ? " " : (cell4 == 2'b01) ? "X" : "O";
            sym3 = (cell3 == 2'b00) ? " " : (cell3 == 2'b01) ? "X" : "O";
            sym2 = (cell2 == 2'b00) ? " " : (cell2 == 2'b01) ? "X" : "O";
            sym1 = (cell1 == 2'b00) ? " " : (cell1 == 2'b01) ? "X" : "O";
            sym0 = (cell0 == 2'b00) ? " " : (cell0 == 2'b01) ? "X" : "O";
            
            $display("Current Board:");
            $display(" %s | %s | %s ", sym8, sym7, sym6);
            $display("-----------");
            $display(" %s | %s | %s ", sym5, sym4, sym3);
            $display("-----------");
            $display(" %s | %s | %s ", sym2, sym1, sym0);
            $display("");
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize all inputs
        clk = 0;
        rst = 0;
        p_tick = 0;
        p_confirm = 0;

        $display("[%0t] Starting simulation...", $time);
        
        #10 rst = 1;
        $display("[%0t] Reset released", $time);
        
        #10;

        // --- TEST 1: Player wins (positions 0,1,2) ---
        $display("\n=== TEST 1: Player wins ===");
        player_move(0);
        repeat(10) @(posedge clk);
        display_board;
        
        player_move(1);
        repeat(10) @(posedge clk);
        display_board;
        
        player_move(2);
        repeat(10) @(posedge clk);
        display_board;
        
        repeat(40) @(posedge clk);
        if (winner == 2'b01) begin
            $display("[%0t][PASS]: Player wins detected", $time);
        end else begin
            $display("[%0t][FAIL]: Winner not detected", $time);
        end

        // --- TEST 2: Reset game ---
        $display("\n=== TEST 2: Reset game ===");
        reset_game;
        repeat(20) @(posedge clk);
        if (move_cnt == 0 && cell_position == 18'd0) begin
            $display("[%0t][PASS]: Game reset successfully", $time);
        end

        // --- TEST 3: AI should take center ---
        $display("\n=== TEST 3: AI should take center ===");
        player_move(0);
        repeat(20) @(posedge clk);
        display_board;
        
        repeat(40) @(posedge clk);
        if (cell_position[9:8] == 2'b10) begin
            $display("[%0t][PASS]: AI took center", $time);
        end else begin
            $display("[%0t][FAIL]: AI did not take center", $time);
        end

        // --- TEST 4: Invalid move ---
        $display("\n=== TEST 4: Invalid move (replay position 0) ===");
        $display("[%0t] Current move count: %0d", $time, move_cnt);
        player_move(0);  // Try to replay on occupied cell
        $display("[%0t] Move count after invalid move: %0d", $time, move_cnt);
        
        if (move_cnt == prev_move_cnt) begin
            $display("[%0t][PASS]: Invalid move rejected", $time);
        end else begin
            $display("[%0t][FAIL]: Invalid move accepted", $time);
        end

        $display("[%0t] All tests completed", $time);
        #100 $finish;
    end

endmodule
