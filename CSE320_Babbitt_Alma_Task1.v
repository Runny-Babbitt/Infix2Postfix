`define HOLD 2'b00
`define INSERT_END 2'b01
`define INSERT_FRONT 2'b10
`define POP 2'b11

module FlexibleInsertStack
#(parameter N = 32, parameter W = 8)
(
    input clk, Reset,
    input [1:0] CMD,
    input [W-1:0] DataIn,
    output reg Empty,
    output reg Full,
    output reg [W-1:0] Top,

    output reg [N*W-1:0] R, //Stack
    output reg [N*W-1:0] RN, //Next Stack
    output reg [N-1:0] E, //Enable pointer
    output reg [N-1:0] EN, //Next Enable pointer
    output reg [W-1:0] P //Popped word
);    
    integer i;
    always @(posedge clk)
        if(Reset)
            begin
                R <= 0;//Initialize stacks with zeros
                E <= 0;
            end 
        else
            begin
                R <= RN;
                E <= EN;
            end
    always @(*)
            begin
               if(Reset)
                    begin
                        RN <= 0; //Initialize stacks with zeros
                        EN <= {1'b1, {N-1{1'b0}}}; // ie EN = 1000
                        Top <= 0;
                        Full <= 0;
                    end 
                else
                    begin
                        Top <= R[N*W-1:N*W-W];
                        Empty <= (E[N-1]);
                        Full <= (E==0);
                 end
            //Insert Front
                if(CMD == `INSERT_FRONT && ~Full)
                    begin
                        RN <= {DataIn,R[W*N-1:W]}; 
                        EN <= {1'b0,E[N-1:1]};
                    end
            //Insert  end
                else if(CMD == `INSERT_END && ~Full)
                    begin
                        for(i=N-1; i >= 0; i=i-1)
                            begin
                                if(E[i])
                                    RN[W*i+:W] <= DataIn;
                                else    
                                    RN[W*i+:W] <= R[W*i+:W];
                            end
                        EN <= {1'b0,E[N-1:1]};
                    end
    
                else if(CMD == `POP && ~Empty)
                    begin
                        if(Full) 
                            EN <= {E[N-2:0],1'b1};
                        else
                            EN <= {E[N-2:0],1'b0};
                        
                    
                        
                        RN <= {R[W*N-W-1:0], {W{1'b0}}};
                        P <= {R[W*N-1: W*N-W]}; 
                    end
                else if(CMD == `HOLD)
                    begin
                        RN <= R;
                        EN <= E;
                    end
            end   
endmodule

`timescale 1ns/1ns

module Test_FlexibleInsertStack;
    reg clk;
    reg Reset;
    reg [1:0] CMD;
    reg [7:0] DataIn;
    wire Empty;
    wire Full;
    wire [7:0] Top;
    wire [255:0] R;
    wire [255:0] RN;
    wire [31:0] E;
    wire [31:0] EN;
    wire [7:0] P;

    // Instantiate the FlexibleInsertStack module
    FlexibleInsertStack #(32, 8) uut (
        .clk(clk),
        .Reset(Reset),
        .CMD(CMD),
        .DataIn(DataIn),
        .Empty(Empty),
        .Full(Full),
        .Top(Top),
        .R(R),
        .RN(RN),
        .E(E),
        .EN(EN),
        .P(P)
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // Toggle the clock every 5 ns
    end

    // Initializations
    initial begin
        clk = 0;
        Reset = 0;
        CMD = `HOLD;
        DataIn = 8'h00;
        #10 Reset = 1; // Assert reset for 10 ns
        #10 Reset = 0; // Release reset

        // Test cases
        // You can add more test cases here

        // Example: Insert data at the front
        CMD = `INSERT_FRONT;
        DataIn = 8'h42;
        #10;
        CMD = `HOLD;
        #10;

        // Example: Insert data at the end
        CMD = `INSERT_END;
        DataIn = 8'hFF;
        #10;
        CMD = `HOLD;
        #10;

        // Example: Pop data
        CMD = `POP;
        #10;
        CMD = `HOLD;
        #10;

        // Finish simulation
        $finish;
    end

    // Add waveform dumping, if needed
    // You can use $dumpvars to create a VCD file for simulation waveform analysis

endmodule