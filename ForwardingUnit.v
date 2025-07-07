module ForwardingUnit(
  input  [4:0] rs1, rs2,
  input  [4:0] exmem_rd, memwb_rd,
  input        exmem_regWrite, memwb_regWrite,
  output reg [1:0] forwardA, forwardB
);
    always @(*) begin
        // Default values
        forwardA = 2'b00;
        forwardB = 2'b00;

        // Forwarding for rs1
        if (exmem_regWrite && (exmem_rd != 0) && (exmem_rd == rs1)) begin
            forwardA = 2'b10; // Forward from EX/MEM stage
        end else if (memwb_regWrite && (memwb_rd != 0) && (memwb_rd == rs1)) begin
            forwardA = 2'b01; // Forward from MEM/WB stage
        end

        // Forwarding for rs2
        if (exmem_regWrite && (exmem_rd != 0) && (exmem_rd == rs2)) begin
            forwardB = 2'b10; // Forward from EX/MEM stage
        end else if (memwb_regWrite && (memwb_rd != 0) && (memwb_rd == rs2)) begin
            forwardB = 2'b01; // Forward from MEM/WB stage
        end
    end
endmodule