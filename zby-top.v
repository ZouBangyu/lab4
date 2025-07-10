`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 3025/13/35 25：71：83
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


module Pipeline_Processor(clk);
    input clk;
    
    wire [31:0] pc_next,inst,immediate,immediate_shifted,writedata,readdata1,readdata2,aluin,aluresult,readdatamem,pc_4,pc_b,add_3;
    wire [31:0] IF_ID_pc_next, IF_ID_pc, IF_ID_inst;
    wire [31:0] ID_EX_pc_next, ID_EX_pc, ID_EX_data1, ID_EX_data2, ID_EX_imm,EX_MEM_Imm,MEM_WB_Imm;
    wire [31:0] EX_MEM_pc_next, EX_MEM_aluresult, EX_MEM_data2;
    wire [31:0] MEM_WB_pc_next, MEM_WB_readmem, MEM_WB_aluresult;
    wire [31:0] mux5_out,mux6_out,aluin1,aluin2,datatomem;
    wire [4:0]  ID_EX_rd, EX_MEM_rd, MEM_WB_rd,ID_EX_Rs1_Addr,ID_EX_Rs2_Addr,EX_MEM_Rs2_Addr;
    wire [3:0] alucon,ID_EX_aluinst;
    wire [1:0] aluop,memtoreg,ID_EX_aluop, ID_EX_memtoreg, EX_MEM_memtoreg, MEM_WB_memtoreg, Forward_A, Forward_B;
    wire [2:0] EX_MEM_funct3;
    wire [9:0] control_out,control_in;
    wire branch,pc_select,memread,memwrite,alusrc,jump,regwrite,zero,pc_write,IF_Flush,IF_ID_Write,mux_sel;
    wire ID_EX_branch, ID_EX_memread, ID_EX_memwrite, ID_EX_alusrc, ID_EX_jump, ID_EX_regwrite;
    wire EX_MEM_branch, EX_MEM_memread, EX_MEM_memwrite, EX_MEM_regwrite, EX_MEM_zero, MEM_WB_regwrite,MEM_WB_Memread;
    wire mem_sel,Forward_eq_A,Forward_eq_B;
    reg [31:0] pc;
    
    initial pc = 0;
    
    assign immediate_shifted = {immediate[30:0],1'b0};
    
    assign regwrite = control_out[0];
    assign jump = control_out[1];
    assign alusrc = control_out[2];    
    assign memwrite = control_out[3];    
    assign memread = control_out[4];
    assign branch = control_out[5];
    assign memtoreg = control_out[7:6];
    assign aluop = control_out[9:8];
    
    always @(posedge clk) begin
        if(pc_write == 1'b1) pc <= pc_next;
    end
    
    Hazard_detection hazard(IF_ID_inst[19:15],IF_ID_inst[24:20],ID_EX_rd,EX_MEM_rd,ID_EX_memread,EX_MEM_memread,control_in[5],control_in[3],ID_EX_regwrite,pc_write,IF_ID_Write,mux_sel);
    Forwarding_unit forwarding(IF_ID_inst[19:15],IF_ID_inst[24:20],ID_EX_Rs1_Addr,ID_EX_Rs2_Addr,EX_MEM_rd,MEM_WB_rd,EX_MEM_Rs2_Addr,EX_MEM_regwrite,MEM_WB_regwrite,EX_MEM_memread,EX_MEM_memwrite,branch,Forward_A,Forward_B,mem_sel,Forward_eq_A,Forward_eq_B,ID_EX_memread,ID_EX_memwrite);
    instmem InstructionMemory(pc,inst);
    control Control(IF_ID_inst[6:0],control_in);
    Registers registers(IF_ID_inst[19:15],IF_ID_inst[24:20],MEM_WB_rd,writedata,MEM_WB_regwrite,readdata1,readdata2,clk);
    Comparator comparator({IF_ID_inst[2],IF_ID_inst[14:12]},mux5_out,mux6_out,zero);
    immgen ImmGen(IF_ID_inst,immediate);
    ALU alu(aluin1,aluin2,alucon,aluresult);
    ALUcontrol alucontrol(ID_EX_aluop,ID_EX_aluinst,alucon);
    Datamm Datamemory(clk,EX_MEM_funct3,EX_MEM_aluresult,datatomem,EX_MEM_memwrite,EX_MEM_memread,readdatamem);
    IF_ID_State_Reg IF_ID(clk,pc,pc_4,inst,IF_ID_pc,IF_ID_pc_next,IF_ID_inst,IF_Flush,IF_ID_Write);
    ID_EX_State_Reg ID_EX(clk,regwrite,memtoreg,memread,memwrite,jump,alusrc,aluop,IF_ID_pc,IF_ID_pc_next,readdata1,readdata2,immediate,IF_ID_inst[11:7],{IF_ID_inst[30],IF_ID_inst[14:12]},ID_EX_regwrite,ID_EX_memtoreg,ID_EX_memread,ID_EX_memwrite,ID_EX_jump,ID_EX_alusrc,ID_EX_aluop,ID_EX_pc,ID_EX_pc_next,ID_EX_data1,ID_EX_data2,ID_EX_imm,ID_EX_rd,ID_EX_aluinst,IF_ID_inst[19:15],IF_ID_inst[24:20],ID_EX_Rs1_Addr,ID_EX_Rs2_Addr);
    EX_MEM_State_Reg EX_MEM(clk,ID_EX_regwrite,ID_EX_memtoreg,ID_EX_memread,ID_EX_memwrite,ID_EX_pc_next,aluresult,ID_EX_data2,ID_EX_aluinst[2:0],ID_EX_rd,ID_EX_Rs2_Addr,ID_EX_imm,EX_MEM_regwrite,EX_MEM_memtoreg,EX_MEM_memread,EX_MEM_memwrite,EX_MEM_pc_next,EX_MEM_aluresult,EX_MEM_data2,EX_MEM_funct3,EX_MEM_rd,EX_MEM_Rs2_Addr,EX_MEM_Imm);
    MEM_WB_State_Reg MEM_WB(clk,EX_MEM_regwrite,EX_MEM_memtoreg,EX_MEM_pc_next,readdatamem,EX_MEM_aluresult,EX_MEM_rd,EX_MEM_memread,EX_MEM_Imm,MEM_WB_regwrite,MEM_WB_memtoreg,MEM_WB_pc_next,MEM_WB_readmem,MEM_WB_aluresult,MEM_WB_rd,MEM_WB_Memread,MEM_WB_Imm);
    
    
    mux_4_to_2 Mux1(pc_4,pc_b,add_3,pc_b,{jump,pc_select},pc_next);
    mux_2_to_1 Mux5(readdata1,EX_MEM_aluresult,Forward_eq_A,mux5_out);
    mux_2_to_1 Mux6(readdata2,EX_MEM_aluresult,Forward_eq_B,mux6_out);
    mux_4_to_2 Mux4(MEM_WB_aluresult,MEM_WB_readmem,MEM_WB_pc_next,MEM_WB_Imm,MEM_WB_memtoreg,writedata);
    //mux_4_to_2 Mux4(MEM_WB_readmem,MEM_WB_pc_next,MEM_WB_Imm,MEM_WB_aluresult,MEM_WB_memtoreg,writedata);
    mux_2_to_1_10b Mux7(10'b0000000000,control_in,mux_sel,control_out);
    mux_4_to_2 Mux8(ID_EX_data1,writedata,EX_MEM_aluresult,0,Forward_A,aluin1);
    mux_4_to_2 Mux9(aluin,writedata,EX_MEM_aluresult,0,Forward_B,aluin2);
    mux_2_to_1 Mux10(EX_MEM_data2,writedata,mem_sel,datatomem);
    mux_2_to_1 Mux2(ID_EX_data2,ID_EX_imm,ID_EX_alusrc,aluin);   

    adder Add1(pc,32'h00000004,pc_4);
    adder Add2(IF_ID_pc,immediate_shifted,pc_b);
    adder Add3(readdata1,immediate,add_3);
    
    and (pc_select, branch, zero);
    or  (IF_Flush,pc_select,jump);
endmodule

module adder(a,b,sum);
    input [31:0] a,b;
    output reg [31:0] sum;
    
    always @ (*) begin
        sum = a + b;
    end
endmodule

module mux_2_to_1(a,b,s,out);
    input [31:0] a,b;
    input s;
    output [31:0] out;
    
    reg [31:0] out;
    
    always @ (*) begin
        case (s)
            1'b0: out = a;
            1'b1: out = b;
            default out = 0;
        endcase
    end
endmodule

module mux_2_to_1_10b(a,b,s,out);
    input [9:0] a,b;
    input s;
    output [9:0] out;
    
    reg [9:0] out;
    
    always @ (*) begin
        case (s)
            1'b0: out = a;
            1'b1: out = b;
            default out = 0;
        endcase
    end
endmodule

module mux_4_to_2(a,b,c,d,s,out);
    input [31:0] a,b,c,d;
    input [1:0] s;
    output [31:0] out;
    
    reg [31:0] out;
    
    always @ (*) begin
        case (s)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            2'b11: out = d;
            default out = 0;
        endcase
    end
endmodule

module Hazard_detection(IF_ID_rs1,IF_ID_rs2,ID_EX_rd,EX_MEM_rd,ID_EX_Memread,EX_MEM_Memread,branch,memwrite,ID_EX_Regwrite,pc_write,IF_ID_Write,mux_sel);
    input [4:0] IF_ID_rs1,IF_ID_rs2,ID_EX_rd,EX_MEM_rd;
    input ID_EX_Memread,EX_MEM_Memread,branch,memwrite,ID_EX_Regwrite;
    output pc_write,IF_ID_Write,mux_sel;
    reg pc_write,IF_ID_Write,mux_sel;
    
    initial begin
        pc_write=1'b1;
        IF_ID_Write=1'b1;
        mux_sel=1'b1;
    end
    
    always @ (*) begin
        if(ID_EX_Memread && !memwrite) begin
            if(ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2) begin
                pc_write = 0;
                IF_ID_Write = 0;
                mux_sel = 0;
            end
            else begin
                pc_write = 1;
                IF_ID_Write = 1;
                mux_sel = 1;
            end
        end
        else if(branch && ID_EX_Regwrite) begin
            if((ID_EX_rd!=0) && (ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2)) begin
                pc_write = 0;
                IF_ID_Write = 0;
                mux_sel = 0;
            end
            else begin
                pc_write = 1;
                IF_ID_Write = 1;
                mux_sel = 1;
            end
        end
        else if (branch && EX_MEM_Memread) begin
            if ((EX_MEM_rd!=0) && (IF_ID_rs1 == EX_MEM_rd || IF_ID_rs2 == EX_MEM_rd)) begin
                pc_write=0;
                IF_ID_Write=0;
                mux_sel=0;
            end
            else begin
                pc_write=1;
                IF_ID_Write=1;
                mux_sel=1;
            end
        end
        else begin
            pc_write=1;
            IF_ID_Write=1;
            mux_sel=1;
        end
    end
endmodule

module Forwarding_unit(IF_ID_rs1,IF_ID_rs2,ID_EX_rs1,ID_EX_rs2,EX_MEM_rd,MEM_WB_rd,MEM_Writeaddr,EX_MEM_Regwrite,MEM_WB_Regwrite,EX_MEM_Memread,EX_MEM_Memwrite,branch,Forwarding_A,Forwarding_B,mem_sel,Forwarding_eq_A,Forwarding_eq_B,ID_EX_MemRead,ID_EX_MemWrite);
    input [4:0] IF_ID_rs1,IF_ID_rs2,ID_EX_rs1,ID_EX_rs2,EX_MEM_rd,MEM_WB_rd,MEM_Writeaddr;
    input EX_MEM_Regwrite,MEM_WB_Regwrite,EX_MEM_Memread,EX_MEM_Memwrite,branch,ID_EX_MemRead,ID_EX_MemWrite;
    output [1:0] Forwarding_A,Forwarding_B;
    output mem_sel,Forwarding_eq_A,Forwarding_eq_B;
    
    reg [1:0] Forwarding_A,Forwarding_B;
    reg mem_sel,Forwarding_eq_A,Forwarding_eq_B;
    
    initial begin
        Forwarding_A = 2'b00;
        Forwarding_B = 2'b00;
        Forwarding_eq_A = 1'b0;
        Forwarding_eq_B = 1'b0;
        mem_sel = 1'b0;
    end
    
    always @ (*) begin
        if(EX_MEM_Regwrite && (EX_MEM_rd!=0) && ID_EX_rs1 == EX_MEM_rd && !EX_MEM_Memread && !ID_EX_MemRead && !ID_EX_MemWrite)
            Forwarding_A = 2'b10;
        else if(MEM_WB_Regwrite && (MEM_WB_rd!=0) && ID_EX_rs1 == MEM_WB_rd)
            Forwarding_A = 2'b01;
        else
            Forwarding_A = 2'b00;
            
        if(EX_MEM_Regwrite && (EX_MEM_rd!=0) && ID_EX_rs2 == EX_MEM_rd && !EX_MEM_Memread && !ID_EX_MemRead && !ID_EX_MemWrite)
            Forwarding_B = 2'b10;
        else if(MEM_WB_Regwrite && (MEM_WB_rd!=0) && ID_EX_rs2 == MEM_WB_rd)
            Forwarding_B = 2'b01;
        else
            Forwarding_B = 2'b00;
        
        if(EX_MEM_Memwrite && MEM_WB_rd == MEM_Writeaddr)
            mem_sel = 1;
        else
            mem_sel = 0;
            
        if(EX_MEM_Regwrite && (EX_MEM_rd!=0) && EX_MEM_rd == IF_ID_rs1 && branch)
            Forwarding_eq_A = 1;
        else
            Forwarding_eq_A = 0;
            
        if(EX_MEM_Regwrite && (EX_MEM_rd!=0) && EX_MEM_rd == IF_ID_rs2 && branch)
            Forwarding_eq_B = 1;
        else
            Forwarding_eq_B = 0;
    end
endmodule

module ALUcontrol(ALUOp,Inst, ALUcon);
    input [1:0] ALUOp;
    input [3:0] Inst;
    output [3:0] ALUcon;
    
    reg [3:0] ALUcon;
    
    always @ (ALUOp,Inst) begin
        case (ALUOp)
            2'b00: begin
                    ALUcon = 4'b0010;//lw, sw, lb, lbu, sb
            end
            2'b01: begin
                case (Inst[2:0])
                    3'b101: ALUcon = 4'b1110;//bge
                    3'b000: ALUcon = 4'b1000;//beq
                    3'b001: ALUcon = 4'b1001;//bne
                    3'b100: ALUcon = 4'b1100;//blt
                    //default ALUcon = 4'b0000;
                endcase
            end
            2'b10: begin
                case (Inst)
                    4'b0000: ALUcon = 4'b0010;//add
                    4'b1000: ALUcon = 4'b1000;//sub
                    4'b0111: ALUcon = 4'b0111;//and
                    4'b0110: ALUcon = 4'b0110;//or
                    4'b0001: ALUcon = 4'b0001;//sll
                    4'b0101: ALUcon = 4'b0101;//srl
                    4'b1101: ALUcon = 4'b1101;//sra
                    //default ALUcon = 4'b0000; 
                endcase
            end
            2'b11: begin
                case (Inst[2:0])
                    3'b000: ALUcon = 4'b0010;//addi
                    3'b111: ALUcon = 4'b0111;//andi
                    3'b001: ALUcon = 4'b0001;//slli
                    3'b101: ALUcon = 4'b0101;//srli
                    //default ALUcon = 4'b0000; 
                endcase
            end
            default ALUcon = 4'b0000;
        endcase
    end
endmodule

module ALU(i1,i2,s,o);
    parameter add = 4'b0010;
    parameter sub_beq = 4'b1000;
    parameter bne = 4'b1001;
    parameter AND = 4'b0111;
    parameter OR = 4'b0110;
    parameter bge = 4'b1110;
    parameter blt = 4'b1100;
    parameter sll = 4'b0001;
    parameter srl = 4'b0101;
    parameter sra = 4'b1101;
    
    input [31:0] i1,i2;
    input [3:0] s;
    output [31:0] o;
    
    reg [31:0] o;
    
    always @ (i1,i2,s) begin
        case (s)
            add: begin o = i1 + i2; end
            sub_beq,bne: begin o = i1 - i2; end
            AND: begin o = i1&i2; end
            OR: begin o = i1|i2; end
            sll: begin o = i1<<i2; end
            srl: begin o = i1>>i2; end
            sra: begin o = $signed(($signed(i1))>>>i2); end
            default begin o = 0; end
        endcase
    end
endmodule

module Registers(rr1,rr2,wr,wd,regwrite,rd1,rd2,clk);
    input [4:0] rr1,rr2,wr;
    input regwrite,clk;
    input [31:0] wd;
    output [31:0] rd1,rd2;
    
    reg [31:0] regfile [31:0];
    integer i;
    
    initial begin
        for (i=0;i<32;i=i+1)
            regfile[i] <= 0;
    end
    
    always @ (negedge clk) begin
        if (regwrite && wr!=0) begin regfile[wr] = wd; end
    end
    
    assign rd1 = regfile[rr1];
    assign rd2 = regfile[rr2];
endmodule

module Comparator(s,rs1,rs2,result);
    input [3:0] s;
    input [31:0] rs1,rs2;
    output result;
    
    reg result;
    
    initial result = 1'b1;
    always @ (*) begin
        case(s)
            4'b0000: result = (rs1==rs2) ? 1'b1:1'b0;//beq
            4'b0001: result = (rs1==rs2) ? 1'b0:1'b1;//bne
            4'b0100: result = ($signed(rs1) < $signed(rs2)) ? 1'b1:1'b0;//blt
            4'b0101: result = ($signed(rs1) < $signed(rs2)) ? 1'b0:1'b1;//bge
            default result = 1'b1;
        endcase
    end
endmodule

module Datamm(clk,funct3,address,wd,mmw,mmr,rd);
    parameter lw_sw = 3'b010;
    parameter lb_sb = 3'b000;
    parameter lbu = 3'b100;
    
    input [31:0] address,wd;
    input [2:0] funct3;
    input clk,mmw,mmr;
    output [31:0] rd;
    
    reg [7:0] ram [127:0];
    reg [31:0] rd;
    
    always @ (negedge clk) begin
        if (mmw) begin
            case(funct3)
                lw_sw: begin ram[address] <= wd[7:0]; ram[address+1] <= wd[15:8]; ram[address+2] <= wd[23:16]; ram[address+3] <= wd[31:24]; end
                lb_sb: begin ram[address] <= wd[7:0]; end
                default ram[address] <= ram[address];
            endcase
        end
    end
    
    always @ (*) begin
        if (mmr) begin
            case(funct3)
                lw_sw: begin rd <= {ram[address+3],ram[address+2],ram[address+1],ram[address]}; end
                lb_sb: begin rd <= {{24{ram[address][7]}},ram[address]}; end
                lbu: begin rd <= {{24{1'b0}},ram[address]}; end
                default rd <= rd;
            endcase
        end
    end
endmodule

module control(inst,control_in);
    input [6:0] inst;
    //output branch,memread,memwrite,alusrc,regwrite,jump;
    //output [1:0] aluop,memtoreg;
    output [9:0] control_in;
    
    reg [9:0] control_in;
    
    initial begin
        control_in <= 0;
    end
    
    always @ (inst) begin
        case (inst) 
            7'b0110011: begin//add,sub,and,or,sll,srl,sra
                control_in[5] <= 0;
                control_in[4] <= 0;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b00;
                control_in[2] <= 0;
                control_in[0] <= 1;
                control_in[1] <= 0;
                control_in[9:8] <= 2'b10;
            end
            7'b0010011: begin//addi,andi,slli,srli
                control_in[5] <= 0;
                control_in[4] <= 0;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b00;
                control_in[2] <= 1;
                control_in[0] <= 1;
                control_in[1] <= 0;
                control_in[9:8] <= 2'b11;
            end
            7'b0000011: begin//lw,lb,lbu
                control_in[5] <= 0;
                control_in[4] <= 1;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b01;
                control_in[2] <= 1;
                control_in[0] <= 1;
                control_in[1] <= 0;
                control_in[9:8] <= 2'b00;
            end
            7'b0100011: begin//sw,sb
                control_in[5] <= 0;
                control_in[4] <= 0;
                control_in[3] <= 1;
                control_in[7:6] <= 2'b00;
                control_in[2] <= 1;
                control_in[0] <= 0;
                control_in[1] <= 0;
                control_in[9:8] <= 2'b00;
            end
            7'b1100011: begin//beq,bne,bge,blt
                control_in[5] <= 1;
                control_in[4] <= 0;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b00;
                control_in[2] <= 0;
                control_in[0] <= 0;
                control_in[1] <= 0;
                control_in[9:8] <= 2'b01;
            end
            7'b1101111: begin//jal
                control_in[5] <= 1;
                control_in[4] <= 0;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b10;
                control_in[2] <= 1;
                control_in[0] <= 1;
                control_in[1] <= 1;
                control_in[9:8] <= 2'b00;                
            end
            7'b1100111: begin//jalr
                control_in[5] <= 0;
                control_in[4] <= 0;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b10;
                control_in[2] <= 1;
                control_in[0] <= 1;
                control_in[1] <= 1;
                control_in[9:8] <= 2'b00;
            end
            default begin
                control_in[5] <= 0;
                control_in[4] <= 0;
                control_in[3] <= 0;
                control_in[7:6] <= 2'b00;
                control_in[2] <= 0;
                control_in[0] <= 0;
                control_in[1] <= 0;
                control_in[9:8] <= 2'b00;
            end
        endcase
    end
endmodule

module immgen(inst,imm);
    inout [31:0] inst;
    output [31:0] imm;
    
    reg [31:0] imm;
    
    always @ (inst) begin
        case (inst[6:0])
            7'b0010011: begin//addi
                imm[11:0] = inst[31:20];
                imm[31:12] = {20{inst[31]}};
            end
            7'b0000011: begin//lw
                imm[11:0] = inst[31:20];
                imm[31:12] = {20{inst[31]}};
            end
            7'b0100011: begin//sw
                imm[4:0] = inst[11:7];
                imm[11:5] = inst[31:25];
                imm[31:12] = {20{inst[31]}};
            end
            7'b1100011: begin//beq.bne
                imm[3:0] = inst[11:8];
                imm[9:4] = inst[30:25];
                imm[10] = inst[7];
                imm[31:11] = {21{inst[31]}};
            end
            7'b1100111: begin//jalr
                imm[11:0] = inst[31:20];
                imm[31:12] = {20{inst[31]}};
            end
            7'b1101111: begin//jal
                imm = {{21{inst[31]}}, inst[19:12], inst[20], inst[30:21]};
            end
            default begin imm[31:0] = 0; end
        endcase
    end
endmodule

module IF_ID_State_Reg(clk,crntPC,nextPC,Instrct,crntPC_out,nextPC_out,Instrct_out,IF_Flush,IF_ID_Write);
    input clk,IF_Flush,IF_ID_Write;
    input [31:0] crntPC;
    input [31:0] nextPC;
    input [31:0] Instrct;
    output reg  [31:0]      crntPC_out;
    output reg  [31:0]      nextPC_out;
    output reg  [31:0]      Instrct_out;


    initial begin
        crntPC_out = 0; nextPC_out = 0; Instrct_out = 0;
    end

    always @ (posedge clk) begin
        if(IF_Flush == 1'b1) begin
            Instrct_out <= 0;
        end
        else if(IF_ID_Write == 1'b1) begin
            crntPC_out      <= crntPC;
            nextPC_out      <= nextPC;
            Instrct_out     <= Instrct;
        end
        
    end
    
endmodule

module ID_EX_State_Reg(clock,RegWrite,MemtoReg,MemRead,MemWrite,Jump,ALUSrc,ALUOp,crntPC,nextPC,Reg_rs1,Reg_rs2,Imm_Gen,Reg_rd,ALU_Instrct,RegWrite_out,MemtoReg_out,MemRead_out,MemWrite_out,Jump_out,ALUSrc_out,ALUOp_out,crntPC_out,nextPC_out,Reg_rs1_out,Reg_rs2_out,Imm_Gen_out,Reg_rd_out,ALU_Instrct_out,rs1_addr,rs2_addr,rs1_addr_out,rs2_addr_out);
    input       clock,MemRead,MemWrite,Jump,ALUSrc;
    input       RegWrite;   
    input [1:0]  MemtoReg;      
    input [1:0]  ALUOp;      
    input [31:0] crntPC;
    input [31:0] nextPC;
    input [31:0] Reg_rs1;
    input [31:0] Reg_rs2;
    input [31:0] Imm_Gen;
    input [4:0]  Reg_rd;
    input [3:0]  ALU_Instrct;
    input [4:0] rs1_addr;
    input [4:0] rs2_addr;
    output reg              RegWrite_out;   
    output reg  [1:0]       MemtoReg_out;   
    output reg              MemRead_out;    
    output reg              MemWrite_out;   
    output reg              Jump_out;       
    output reg              ALUSrc_out;     
    output reg  [1:0]       ALUOp_out;      
    output reg  [31:0]      crntPC_out;
    output reg  [31:0]      nextPC_out;
    output reg  [31:0]      Reg_rs1_out;
    output reg  [31:0]      Reg_rs2_out;
    output reg  [31:0]      Imm_Gen_out;
    output reg  [4:0]       Reg_rd_out;
    output reg  [3:0]       ALU_Instrct_out;
    output reg [4:0]        rs1_addr_out;
    output reg [4:0]        rs2_addr_out;

    initial begin
        RegWrite_out = 0; MemtoReg_out = 0; MemRead_out = 0; MemWrite_out = 0;  Jump_out = 0; ALUSrc_out = 0; 
        ALUOp_out = 0; crntPC_out = 0; nextPC_out = 0; Reg_rs1_out = 0; Reg_rs2_out = 0; Imm_Gen_out = 0; Reg_rd_out = 0; ALU_Instrct_out = 0; rs1_addr_out = 0; rs2_addr_out  = 0;
    end

    always @ (posedge clock) begin
        RegWrite_out    <= RegWrite;
        MemtoReg_out    <= MemtoReg;
        MemRead_out     <= MemRead;
        MemWrite_out    <= MemWrite;
        Jump_out        <= Jump;
        ALUSrc_out      <= ALUSrc;
        ALUOp_out       <= ALUOp;
        crntPC_out      <= crntPC;
        nextPC_out      <= nextPC;
        Reg_rs1_out     <= Reg_rs1;
        Reg_rs2_out     <= Reg_rs2;
        Reg_rd_out      <= Reg_rd;
        Imm_Gen_out     <= Imm_Gen;
        ALU_Instrct_out <= ALU_Instrct;
        rs1_addr_out    <= rs1_addr;
        rs2_addr_out    <= rs2_addr;
    end

endmodule

module EX_MEM_State_Reg(
    input                   clock,
    input                   RegWrite,   
    input       [1:0]       MemtoReg,   
    input                   MemRead,    
    input                   MemWrite,
    input       [31:0]      nextPC,
    input       [31:0]      ALUResult,
    input       [31:0]      Reg_rs2,
    input       [2:0]       Funct3,
    input       [4:0]       Reg_rd,
    input       [4:0]       rs2_addr,
    input       [31:0]      imm,
    output reg              RegWrite_out,   
    output reg  [1:0]       MemtoReg_out,   
    output reg              MemRead_out,    
    output reg              MemWrite_out,   
    output reg  [31:0]      nextPC_out,
    output reg  [31:0]      ALUResult_out,
    output reg  [31:0]      Reg_rs2_out,
    output reg  [2:0]       Funct3_out,
    output reg  [4:0]       Reg_rd_out,
    output reg  [4:0]       rs2_addr_out,
    output reg  [31:0]      imm_out
);

    initial begin
        RegWrite_out = 0; MemtoReg_out = 0; MemRead_out = 0; MemWrite_out = 0; nextPC_out = 0; 
        ALUResult_out = 0;Reg_rs2_out = 0; Funct3_out = 0; Reg_rd_out = 0;imm_out = 0;
    end

    always @ (posedge clock) begin
        RegWrite_out    <= RegWrite;
        MemtoReg_out    <= MemtoReg;
        MemRead_out     <= MemRead;
        MemWrite_out    <= MemWrite;
        nextPC_out      <= nextPC;
        ALUResult_out   <= ALUResult;
        Reg_rs2_out     <= Reg_rs2;
        Funct3_out      <= Funct3;
        Reg_rd_out      <= Reg_rd;
        rs2_addr_out    <= rs2_addr;
        imm_out         <= imm;
    end

endmodule

module MEM_WB_State_Reg(
    input                   clock,
    input                   RegWrite,   
    input       [1:0]       MemtoReg,   
    input       [31:0]      nextPC,
    input       [31:0]      ReadData,
    input       [31:0]      ALUResult,
    input       [4:0]       Reg_rd,
    input                   MemRead,
    input       [31:0]      imm,
    output reg              RegWrite_out,   
    output reg  [1:0]       MemtoReg_out,   
    output reg  [31:0]      nextPC_out,
    output reg  [31:0]      ReadData_out,
    output reg  [31:0]      ALUResult_out,
    output reg  [4:0]       Reg_rd_out,
    output reg              MemRead_out,
    output reg  [31:0]      imm_out
);

    initial begin
        RegWrite_out = 0; MemtoReg_out = 0; nextPC_out = 0; ReadData_out = 0; ALUResult_out = 0; Reg_rd_out = 0;MemRead_out = 0;imm_out = 0;
    end
    
    always @ (posedge clock) begin
        RegWrite_out    <= RegWrite;
        MemtoReg_out    <= MemtoReg;
        nextPC_out      <= nextPC;
        ReadData_out    <= ReadData;
        ALUResult_out   <= ALUResult;
        Reg_rd_out      <= Reg_rd;
        MemRead_out     <= MemRead;
        imm_out         <= imm;
    end

endmodule

module instmem(pc,inst);
    input [31:0] pc;
    output [31:0] inst;
    
    reg [31:0] rom [127:0];
    reg [31:0] inst;
    
    initial begin
        rom[0] <= 32'b00111001100100000000001100010011;
        rom[1] <= 32'b00000000011000000010001000100011;
        rom[2] <= 32'b00000000010000000000001010000011;
        rom[3] <= 32'b00000000010100000010000000100011;
        rom[4] <= 32'b00000010000000110000000001100011;
        rom[5] <= 32'b00000000000000000010111000000011;
        rom[6] <= 32'b00000001110000101001110001100011;
        rom[7] <= 32'b00000001110000101000001110110011;
        rom[8] <= 32'b00000001110000111111001100110011;
        rom[9] <= 32'b00000000000000111111001100010011;
        rom[10] <= 32'b01000000000000110000001010110011;
        rom[11] <= 32'b00000000011000101101010001100011;
        rom[12] <= 32'b00000000000000000000001110110011;//
        rom[13] <= 32'b00000000110000000000000011101111;
        rom[14] <= 32'b00000001010000000000000011101111;
        rom[15] <= 32'b00000000000000000000111000110011;
        rom[16] <= 32'b00000000011111100110111000110011;
        rom[17] <= 32'b00000000000000001000000001100111;
        rom[18] <= 32'b00000100100000000000001100010011;
        rom[19] <= 32'b00001010110000000000001010010011;
    end
    
    always @ (*) begin
        inst = rom[(pc>>2)];
    end

endmodule
