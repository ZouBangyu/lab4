`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/29 14:19:34
// Design Name: 
// Module Name: top
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
// Include necessary modules and definitions
`include "PC.v"
`include "InstrMem.v"
`include "Control.v"
`include "Reg.v"
`include "ImmGen.v"
`include "ALU.v"
`include "PipeReg.v"
`include "DataMem.v"
`include "HazardDetectionUnit.v"
`include "ForwardingUnit.v"
`include "Mux.v"
module top(
    input clk

);
    wire [31:0] pc_next, pc_branch, pc_jump, write_data, write_data_jump;
    wire [31:0] pc_IF, pc_ID, pc_EX, pc_MEM, pc_WB;
    wire [31:0] instruction_IF, instruction_ID;
    wire branch_ID, branch_EX, branch_MEM;
    wire jump_ID, jump_EX, jump_MEM, jump_WB;
    wire jump_return_ID, jump_return_EX, jump_return_MEM, jump_return_WB;
    wire memRead_ID, memRead_EX, memRead_MEM;
    wire memToReg_ID, memToReg_EX, memToReg_MEM, memToReg_WB;
    wire memWrite_ID, memWrite_EX, memWrite_MEM;
    wire ALUsrc_ID, ALUsrc_EX;
    wire regWrite_ID, regWrite_EX, regWrite_MEM, regWrite_WB;
    wire [31:0] read_data_1_ID, read_data_1_EX;
    wire [31:0] read_data_2_ID, read_data_2_EX, read_data_2_MEM;
    wire [3:0] funct3_EX;
    wire [31:0] immediate_ID, immediate_EX;
    wire [4:0] rd_EX, rd_MEM, rd_WB;
    wire [1:0] bType_EX, bType_MEM;
    wire zero_EX, zero_MEM;
    wire lt_zero_EX, lt_zero_MEM;
    wire asByte_EX, asByte_MEM;
    wire asUnsigned_EX, asUnsigned_MEM;
    wire [1:0] ALUop_ID, ALUop_EX;
    wire [31:0] ALU_result_EX, ALU_result_MEM, ALU_result_WB;
    wire [3:0] ALUctrl;
    wire [31:0] alter_destination_EX, alter_destination_MEM;
    wire pcSrc, pcSrc_branch, pcSrc_jump;
    wire [31:0] read_data_MEM, read_data_WB;

    wire PCWrite, IFIDWrite, stall;
    wire stall_branch, stall_memRead, stall_memToReg, stall_memWrite, stall_ALUsrc, stall_regWrite, stall_jump, stall_jump_return;
    wire [1:0] stall_ALUop_sig;
    
    wire [1:0] forwardA, forwardB;
    wire [31:0] forwardedA, forwardedB;
    wire [4:0] rs1_EX, rs2_EX;

    PC uut (clk, PCWrite, pc_next, pc_IF);
    InstrMem uut0 (pc_IF, instruction_IF);

    // Hazard Detection
    HazardDetectionUnit hdu(
        .idex_memRead (memRead_EX),
        .idex_rd      (rd_EX),
        .ifid_rs1     (instruction_ID[19:15]),
        .ifid_rs2     (instruction_ID[24:20]),
        .PCWrite      (PCWrite),    
        .IFIDWrite    (IFIDWrite),  
        .stall        (stall)      
    );


    // ID
    Control uut1 (instruction_ID[6:0], branch_ID, memRead_ID, memToReg_ID, ALUop_ID, memWrite_ID, ALUsrc_ID, regWrite_ID, jump_ID, jump_return_ID);
    Reg uut2 (clk, regWrite_WB, instruction_ID[19:15], instruction_ID[24:20], rd_WB, write_data_jump, read_data_1_ID, read_data_2_ID);
    ImmGen uut3 (instruction_ID, immediate_ID);

    assign stall_branch = stall ? 1'b0 : branch_ID;
    assign stall_memRead = stall ? 1'b0 : memRead_ID;
    assign stall_memToReg = stall ? 1'b0 : memToReg_ID;
    assign stall_ALUop_sig = stall ? 2'b00 : ALUop_ID;
    assign stall_memWrite = stall ? 1'b0 : memWrite_ID;
    assign stall_ALUsrc = stall ? 1'b0 : ALUsrc_ID;
    assign stall_regWrite = stall ? 1'b0 : regWrite_ID;
    assign stall_jump = stall ? 1'b0 : jump_ID;
    assign stall_jump_return = stall ? 1'b0 : jump_return_ID;
    // EX

    AlterPC uut4 (pc_EX, immediate_EX, alter_destination_EX);
    ALUcontrol uut5 (funct3_EX, ALUop_EX, ALUctrl, bType_EX, asByte_EX, asUnsigned_EX);

    ALU uut7 (
        .a      (forwardedA),
        .b      (ALUsrc_EX ? immediate_EX : forwardedB),
        .ALUctrl(ALUctrl),
        .zero   (zero_EX),
        .lt_zero(lt_zero_EX),
        .result (ALU_result_EX)
    );

    // MEM
    Jump uut8 (jump_MEM, pcSrc_jump);
    JumpReturn uut9 (jump_return_MEM, pcSrc);
    Mux32bit uut10 (pc_IF + 4, alter_destination_MEM, pcSrc_branch, pc_branch);
    Mux32bit uut11 (pc_branch, alter_destination_MEM, pcSrc_jump, pc_jump);
    Mux32bit uut12 (pc_jump, ALU_result_MEM, pcSrc, pc_next);
    SelPC uut13 (zero_MEM, lt_zero_MEM, bType_MEM, branch_MEM, pcSrc_branch);

    DataMem uut14 (clk, memWrite_MEM, ALU_result_MEM, ALU_result_MEM, read_data_2_MEM, read_data_MEM, asByte_MEM, asUnsigned_MEM);

    // WB
    Mux32bit uut15 (ALU_result_WB, read_data_WB, memToReg_WB, write_data);
    Mux32bit uut16 (write_data, pc_WB + 4, jump_WB, write_data_jump);

    MUX4to1 muxA (
        .a(read_data_1_EX),     // 00: no forwarding
        .b(write_data_jump),    // 01: forward from WB stage
        .c(ALU_result_MEM),     // 10: forward from MEM stage
        .d(32'b0),              // 11: unused
        .sel(forwardA),
        .out(forwardedA)
    );

    MUX4to1 muxB (
        .a(read_data_2_EX),     // 00: no forwarding  
        .b(write_data_jump),    // 01: forward from WB stage
        .c(ALU_result_MEM),     // 10: forward from MEM stage
        .d(32'b0),              // 11: unused
        .sel(forwardB),
        .out(forwardedB)
    );

    // Pipeline Registers
    IF_ID uut17(
        .clk(clk),
        .write_enable(IFIDWrite),
        .pc_in(pc_IF),
        .pc_out(pc_ID),
        .instruction_in(instruction_IF),  
        .instruction_out(instruction_ID)
    );
    
    ID_EX uut18 (
        .clk(clk), 
        .branch_in(stall_branch), .memRead_in(stall_memRead), .memToReg_in(stall_memToReg), 
        .ALUop_in(stall_ALUop_sig), .memWrite_in(stall_memWrite), .ALUsrc_in(stall_ALUsrc), 
        .regWrite_in(stall_regWrite), .jump_in(stall_jump), .jump_return_in(stall_jump_return),
        .branch_out(branch_EX), .memRead_out(memRead_EX), .memToReg_out(memToReg_EX), 
        .ALUop_out(ALUop_EX), .memWrite_out(memWrite_EX), .ALUsrc_out(ALUsrc_EX), 
        .regWrite_out(regWrite_EX), .jump_out(jump_EX), .jump_return_out(jump_return_EX),
        .pc_in(pc_ID), .pc_out(pc_EX), 
        .read_data_1_in(read_data_1_ID), .read_data_1_out(read_data_1_EX), 
        .read_data_2_in(read_data_2_ID), .read_data_2_out(read_data_2_EX), 
        .immediate_in(immediate_ID), .immediate_out(immediate_EX), 
        .funct3_in({instruction_ID[30], instruction_ID[14:12]}), .funct3_out(funct3_EX), 
        .rd_in(instruction_ID[11:7]), .rd_out(rd_EX),
        .rs1_in(instruction_ID[19:15]), .rs1_out(rs1_EX),
        .rs2_in(instruction_ID[24:20]), .rs2_out(rs2_EX)
    );


    // EX/MEM Pipeline Register
    EX_MEM uut19 (
        .clk(clk), 
        .branch_in(branch_EX), .memRead_in(memRead_EX), .memToReg_in(memToReg_EX), 
        .memWrite_in(memWrite_EX), .regWrite_in(regWrite_EX), .jump_in(jump_EX), .jump_return_in(jump_return_EX),
        .branch_out(branch_MEM), .memRead_out(memRead_MEM), .memToReg_out(memToReg_MEM), 
        .memWrite_out(memWrite_MEM), .regWrite_out(regWrite_MEM), .jump_out(jump_MEM), .jump_return_out(jump_return_MEM),
        .pc_in(pc_EX), .pc_out(pc_MEM), 
        .branch_destination_in(alter_destination_EX), .branch_destination_out(alter_destination_MEM), 
        .zero_in(zero_EX), .zero_out(zero_MEM), .lt_zero_in(lt_zero_EX), .lt_zero_out(lt_zero_MEM), 
        .bType_in(bType_EX), .bType_out(bType_MEM), .asByte_in(asByte_EX), .asByte_out(asByte_MEM), 
        .asUnsigned_in(asUnsigned_EX), .asUnsigned_out(asUnsigned_MEM), 
        .ALU_result_in(ALU_result_EX), .ALU_result_out(ALU_result_MEM), 
        .read_data_2_in(read_data_2_EX), .read_data_2_out(read_data_2_MEM), 
        .rd_in(rd_EX), .rd_out(rd_MEM)
    );
    

    ForwardingUnit fwd_u (
    .rs1            (rs1_EX),               
    .rs2            (rs2_EX),               
    .exmem_rd       (rd_MEM),               
    .memwb_rd       (rd_WB),                
    .exmem_regWrite (regWrite_MEM),         
    .memwb_regWrite (regWrite_WB),          
    .forwardA       (forwardA),
    .forwardB       (forwardB)
);

    MEM_WB uut20 (clk, memToReg_MEM, regWrite_MEM, jump_MEM, 
        memToReg_WB, regWrite_WB, jump_WB, 
        pc_MEM, pc_WB, read_data_MEM, read_data_WB, ALU_result_MEM, ALU_result_WB, rd_MEM, rd_WB);
endmodule
