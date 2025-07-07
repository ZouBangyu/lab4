`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/29 14:19:22
// Design Name: 
// Module Name: Reg
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


module Reg(
    input clk,
    input write_en,
    input [4:0] read_addr_1,
    input [4:0] read_addr_2,
    input [4:0] write_addr,
    input [31:0] write_data,
    output [31:0] read_data_1,
    output [31:0] read_data_2

);
    reg [31:0] regMem [31:0];

    // Initial block should be deleted in synthesis
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            regMem[i] <= 32'b0;
        end
    end
    // 

always @(negedge clk) begin
        if ((write_en) && (write_addr > 0)) begin
            $display("REGISTER WRITE: addr=%02h, data=%08h, time=%0d", 
                     write_addr, write_data, $time);
            regMem[write_addr] = write_data;
        end
    end
    assign read_data_1 = regMem[read_addr_1];
    assign read_data_2 = regMem[read_addr_2];
endmodule 
