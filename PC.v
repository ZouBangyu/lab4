`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/29 14:18:49
// Design Name: 
// Module Name: PC
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


module PC(
    input clk,
    input PCWrite,
    input [31:0] pc_next,
    output reg [31:0] pc_current
);
    initial pc_current = 32'b0;

    
    always @(posedge clk) begin
    if (PCWrite)
        pc_current <= pc_next;
    else
        pc_current <= pc_current;
    end

endmodule 

module AlterPC (
    input [31:0] pc_current,
    input [31:0] immediate,
    output [31:0] pc_destination
    
);
    assign pc_destination = pc_current + immediate;
endmodule 

module SelPC (
    input zero,
    input lt_zero,
    input [1:0] bType,
    input branch,
    output reg pcSrc
    
);
    
    initial pcSrc <= 1'b0;


    always @ (*) begin
        case (bType)
            2'b00:
                pcSrc = branch & zero;
            2'b01:
                pcSrc = branch & ~zero;
            2'b10:
                pcSrc = branch & ~lt_zero;
            2'b11:
                pcSrc = branch & lt_zero;
            default : pcSrc = 0;
        endcase
    end
endmodule 

module Jump (
    input jump,
    output reg pcSrc
    
);
    
    initial pcSrc <= 1'b0;


    always @ (*)
        pcSrc = jump;
endmodule 

module JumpReturn (
    input jump_return,
    output reg pcSrc
    
);
    
    initial pcSrc <= 1'b0;


    always @ (*)
        pcSrc = jump_return;
endmodule 
