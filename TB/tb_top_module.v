`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2025 11:13:47 AM
// Design Name: 
// Module Name: tb_top_module
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

`timescale 1ns / 1ps

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
    game_fsm uut (
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
    ai_agent ai_agent_inst (
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
                $display("✅ [%0t] AI_ACK asserted - AI completed move", $time);
                $display("✅ [%0t] AI selected move: %0d", $time, ai_tick);
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
                $display("[%0t] Winner changed: %b", $time, winner);
                prev_winner <= winner;
            end

            if (player_turn !== prev_player_turn) begin
                $display("[%0t] Turn changed: %s", $time, player_turn ? "Player" : "AI");
                prev_player_turn <= player_turn;
            end

            if (move_cnt !== prev_move_cnt) begin
                $display("[%0t] Move count: %0d", $time, move_cnt);
                prev_move_cnt <= move_cnt;
            end
        end
    end

    // Test stimulus
    initial begin
        clk = 0;
        rst = 0;
        p_tick = 0;
        p_confirm = 0;

        $display("[%0t] Starting simulation...", $time);
        
        #10 rst = 1;
        $display("[%0t] Reset released", $time);
        
        #10;

        // Example test sequence - player makes first move
        p_tick = 4'd0;  // Player selects position 0
        p_confirm = 1;
        #10 p_confirm = 0;
        $display("[%0t] Player move confirmed at position 0", $time);

        // Wait for AI to make its move
        #(100);  // Wait for AI processing time

        // Make another player move
        p_tick = 4'd1;  // Player selects position 1
        p_confirm = 1;
        #10 p_confirm = 0;
        $display("[%0t] Player move confirmed at position 1", $time);

        #(100);  // Wait for AI processing time

        // Add more test moves as needed
        $display("[%0t] Test sequence completed", $time);
        #100 $finish;
    end

endmodule
