// To make into calculator, add condition where
// if the expression has two or more operators or two or more operands
// in a row, then send error message.

`include "CSE320_Babbitt_Alma_Task1.v"
`define HOLD 2'b00
`define INSERT_END 2'b01
`define INSERT_FRONT 2'b10
`define POP 2'b11

// States of the Controller
`define IDLE 2'b00
`define READ 2'b01
`define GETTOKEN 2'b10
`define DONE 2'b11

// Symbols and Operators
`define DOT "."
`define LEFT_PARENS "("
`define RIGHT_PARENS ")"
`define OPERAND "0","1","2","3","4","5","6","7","8","9"
`define OPERATOR "!", "/", "*", "+", "-"
module Infix2Postfix
#(parameter N = 32, parameter W = 8)(
    input clk, ST, Reset,
    input [W-1:0] InputSymbol,
    output reg Ready
);
    wire [W-1:0] InTop, OpTop, ReTop; //Infix, operator and result top word
    reg [1:0] PS, NS;
    reg [1:0] InCMD;
    reg [1:0] OpCMD;
    reg [1:0] ReCMD; // Infix, operator, and result stack CMD
    reg [W-1:0] WordtoInsert;
    reg [W-1:0] InDataIn, OpDataIn, ReDataIn; //Infix, operator and result data input
    wire InEmpty, OpEmpty, ReEmpty; //Infix, operator and result empty signal
    wire InFull, OpFull, ReFull; //Infix, operator and result Full signal


    function integer Precedence(input [W-1:0] Symbol);
        case(Symbol)
            "!": Precedence = 3;
            "*","/": Precedence = 2;
            "+","-": Precedence = 1;
        endcase;
    endfunction;
  
    FlexibleInsertStack #(.N(N), .W(W)) InStack
    (
        .clk(clk),
        .Reset(Reset),
        .CMD(InCMD),
        .DataIn(InDataIn),
        .Empty(InEmpty),
        .Top(InTop)
    );
    
    FlexibleInsertStack #(.N(N), .W(W)) OpStack
    (
        .clk(clk),
        .Reset(Reset),
        .CMD(OpCMD),
        .DataIn(OpDataIn),
        .Empty(OpEmpty),
        .Top(OpTop)
    );
    
    FlexibleInsertStack #(.N(N), .W(W)) ReStack
    (
        .clk(clk),
        .Reset(Reset),
        .CMD(ReCMD),
        .DataIn(ReDataIn),
        .Empty(ReEmpty),
        .Top(ReTop)
    );

    always @(posedge clk || Reset)
        if(Reset) begin//Set all stacks and enables to zero.
            PS <= `IDLE;
            Ready = 1;
            end
        else
            PS <= NS;

    always @(*)
        case(PS)
            `IDLE: begin 
                if(ST)begin
                    NS <= `READ;
                    Ready = 0;
                    end
                else    
                    NS <= `IDLE;
                end//IDLE
            `READ: begin
                if(InputSymbol == `DOT)begin
                    InCMD = `HOLD;
                    OpCMD = `HOLD;
                    ReCMD = `HOLD;
                    NS <= `GETTOKEN;
                    end
                else if(InputSymbol > 0) begin
                    InDataIn <= InputSymbol;
                    InCMD = `INSERT_END;
                    OpCMD = `HOLD;
                    ReCMD = `HOLD;
                    end//else if
                else begin
                    InCMD = `HOLD;
                    OpCMD = `HOLD;
                    ReCMD = `HOLD;
                    end//else
                end//READ
            `GETTOKEN:
                case(InTop)
                    `OPERAND: begin
                        WordtoInsert <= InTop;
                        ReDataIn <= InTop;

                        InCMD = `POP;
                        OpCMD = `HOLD;
                        ReCMD = `INSERT_END;
                        end//OPERAND
                    `OPERATOR: begin
                    if(Precedence(InTop) > Precedence(OpTop) | OpEmpty | OpTop == `LEFT_PARENS)begin
                            WordtoInsert <= InTop;
                            OpDataIn <= WordtoInsert;

                            InCMD = `POP;
                            OpCMD = `INSERT_FRONT;
                            ReCMD = `HOLD;
                            end//Precedence
                        else begin
                            WordtoInsert <= OpTop;
                            ReDataIn <= WordtoInsert;

                            InCMD = `HOLD;
                            OpCMD = `POP;
                            ReCMD = `INSERT_END;
                            end//else
                        end//OPERATOR
                    `LEFT_PARENS: begin
                        WordtoInsert <= InTop;
                        OpDataIn <= WordtoInsert;

                        InCMD = `POP;
                        OpCMD = `INSERT_FRONT;
                        ReCMD = `HOLD;
                        end//LEFT_PARENS
                    `RIGHT_PARENS: begin
                        if(OpTop == `LEFT_PARENS)begin
                            InCMD = `POP;
                            OpCMD = `POP;
                            ReCMD = `HOLD; 
                            end//OpTop != LEFT_PARENS
                        else begin
                            WordtoInsert <= OpTop;
                            ReDataIn <= WordtoInsert;

                            InCMD = `HOLD;
                            OpCMD = `POP;
                            ReCMD = `INSERT_END;                       
                            end//else
                        end//RIGHT_PARENS
                    default: begin
                    if(InEmpty)begin
                        if(~OpEmpty) begin
                            WordtoInsert <= OpTop;
                            ReDataIn <= WordtoInsert;

                            InCMD = `HOLD;
                            OpCMD = `POP;
                            ReCMD = `INSERT_END;
                            end//~OpEmpty
                        else begin
                            InCMD = `HOLD;
                            OpCMD = `HOLD;
                            ReCMD = `HOLD;
                            NS <= `DONE;  
                            end//else

                        end//InEmpty
                    end//default
                endcase //Case InTop
            `DONE: begin
                Ready = 1;
                NS <= `IDLE;
                end//DONE
        endcase //Case PS
    endmodule //Module InFix2Postfix

module Infix2Postfix2_TB
  #(parameter N = 32, parameter W = 8);

   	reg clk, ST, Reset;
   	reg [W-1:0] InputSymbol;
  	wire        Ready;


   reg [N*W-1:0] InputInfixExpression;
   reg 		 EOS;
   
   integer 	 cycle = 0;
   integer 	 i;
   
     Infix2Postfix #(.N(N), .W(W)) SimpleCalc
     (.clk(clk), .ST(ST), .Reset(Reset), .InputSymbol(InputSymbol), .Ready(Ready));
   

    always
     begin
   	#1 clk = 1'b0;
	#1 clk = 1'b1;
   	if (clk)
	  cycle = cycle + 1;
     end
    
    initial
     begin
        clk = 1'b0;
	    ST = 1'b0;
	    Reset = 1'b1; 
		#1
		Reset = 1'b0;

		$dumpfile("IntoPost.vcd");
            $dumpvars;
        ///////////////////////////////////////////////////////////////////////////////////////
        // UNCOMMENT BELOW EXPRESSIONS ONE BY ONE TO SIMULATE AND OBTAIN THE POSTFIX EXPRESIION
        ///////////////////////////////////////////////////////////////////////////////////////
	 

       InputInfixExpression = "9+8*(7-2*(6+5*4*(3+2*9)/8)).    ";
	//   InputInfixExpression = "9+8*(7-2).                      ";	
	//  InputInfixExpression = "0.                 ";
	 //  InputInfixExpression = "3*4+8-2/3*2+7/9.                ";
    //   InputInfixExpression = "2+3*5.                          ";
	 //  InputInfixExpression = "3*5/(5*6)+2.                 ";

     wait(Ready == 1'b1);
	@(negedge clk);  // t = 2, clk 1 -> 0. Inside cycle 1
	Reset = 1'b0;
	ST = 1'b1; // This will cause Ready = 0, and NextState to be READ
	EOS = 1'b0;

    for (i = N-1; ((i >= 0) && (!EOS)); i=i-1)
	  begin
	     @(negedge clk);
	     InputSymbol = InputInfixExpression[i*W +: W];
	     if (InputSymbol == `DOT)
	       begin
		  EOS = 1'b1;
		  @(negedge clk);
	       end
	  end

	@(negedge clk);
	wait(Ready == 1'b1);
	$strobe("Infix Expression = %s\nPostfix Expression = %s", InputInfixExpression, SimpleCalc.ReStack.R);
	$finish;
	end // initial begin

endmodule //TB