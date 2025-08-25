`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Minh Luu
// 
// Create Date: 08/19/2025 03:33:24 PM
// Design Name: 
// Module Name: tb_game_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: testbench for main flow
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_game_fsm;

    // Inputs
    reg rst;
    reg clk;
    reg [3:0] p_tick;
    reg p_confirm;
    reg [3:0] ai_tick;
    reg ai_ack;

    // Outputs
    wire [17:0] cell_position;
    wire [1:0] winner;
    wire player_turn;
    wire [3:0] move_cnt;

    // Instantiate the Unit Under Test (UUT)
    game_fsm uut (
        .rst(rst),
        .clk(clk),
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

    // Clock generation
    always #5 clk = ~clk;

    // Task to simulate player making a move
    task player_move;
        input [3:0] pos;
        begin
            @(posedge clk);
            p_tick = pos;
            p_confirm = 1;
            @(posedge clk);
            p_confirm = 0;
        end
    endtask

    // Task to simulate bot move
    task bot_move;
        input [3:0] pos;
        begin
            wait (ai_confirm); // Wait for AI request
            ai_tick = pos;
            ai_ack = 1;
            @(posedge clk);
            ai_ack = 0;
        end
    endtask

    // Task to simulate game reset
    task reset_game;
        begin
            @(posedge clk);
            p_confirm = 1;
            repeat(2) @(posedge clk);
            p_confirm = 0;
        end
    endtask

    // Initial stimulus
    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        p_tick = 0;
        p_confirm = 0;
        ai_tick = 0;
        ai_ack = 0;

        // Reset
        #10 rst = 1;

        // Player chooses to go first
        // (In your design, player_choosen is not an input. You might want to make it controllable,
        // or hardcode in the FSM to start with player or bot)

        // Simulate a few moves
        player_move(0);  // Player move at position 0
        bot_move(4);     // Bot move at position 4

        player_move(1);  // Player move at position 1
        bot_move(8);     // Bot move at position 8

        player_move(2);  // Player move at position 2 → Win

        // Wait for game over
        #20;

        // Reset the game
        reset_game;

        // Finish simulation
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time = %0t | State = %0d | Player Turn = %b | Move Cnt = %0d | Winner = %b | Cell Position = %b",
                 $time, uut.state, player_turn, move_cnt, winner, cell_position);
    end

endmodule
