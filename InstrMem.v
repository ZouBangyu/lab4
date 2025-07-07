module InstrMem(
    input [31:0] PC,
    output [31:0] instruction
);
    reg [31:0] memori_instr [99:0];
    
    initial begin
        // Using your exact binary instructions
        memori_instr[0]  = 32'b00111001100100000000001100010011; // addi x6, x0, 0x399 (t1)
        memori_instr[1]  = 32'b00000000011000000010001000100011; // sw x6, 4(x0)
        memori_instr[2]  = 32'b00000000010000000000001010000011; // lb x5, 4(x0) (t0)
        memori_instr[3]  = 32'b00000000010100000010000000100011; // sw x5, 0(x0)
        memori_instr[4]  = 32'b00000010000000110000000001100011; // beq x6, x0, wrong_branch
        memori_instr[5]  = 32'b00000000000000000010111000000011; // lw x28, 0(x0) (t3)
        memori_instr[6]  = 32'b00000001110000101001110001100011; // bne x5, x28, wrong_branch
        memori_instr[7]  = 32'b00000001110000101000001110110011; // add x7, x5, x28 (t2)
        memori_instr[8]  = 32'b00000001110000111111001100110011; // and x6, x7, x28 (t1)
        memori_instr[9]  = 32'b00000000000000111111001100010011; // andi x6, x7, 0 (t1)
        memori_instr[10] = 32'b01000000000000110000001010110011; // sub x5, x6, x0 (t0)
        memori_instr[11] = 32'b00000000011000101101010001100011; // bge x5, x6, right_branch
        memori_instr[12] = 32'b00000000000000000000001110110011; // add x7, x0, x0 (t2) - wrong_branch
        memori_instr[13] = 32'b00000000110000000000000011101111; // jal x1, jump_test - right_branch
        memori_instr[14] = 32'b00000001010000000000000011101111; // jal x1, Exit
        memori_instr[15] = 32'b00000000000000000000111000110011; // add x28, x0, x0 (t3)
        memori_instr[16] = 32'b00000000011111100110111000110011; // or x28, x28, x7 (t3) - jump_test
        memori_instr[17] = 32'b00000000000000001000000001100111; // jalr x0, x1, 0
        memori_instr[18] = 32'b00000100100000000000001100010011; // addi x6, x0, 0x48 (t1)
        memori_instr[19] = 32'b00001010110000000000001010010011; // addi x5, x0, 0xac (t0) - Exit
        
        // Initialize remaining memory locations to NOPs
        for (integer i = 20; i < 100; i = i + 1) begin
            memori_instr[i] = 32'h00000013; // NOP
        end
    end

    assign instruction = memori_instr[PC >> 2];
endmodule