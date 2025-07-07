module HazardDetectionUnit(
  input        idex_memRead,
  input  [4:0] idex_rd,
  input  [4:0] ifid_rs1, ifid_rs2,
  output reg   PCWrite,
  output reg   IFIDWrite,
  output reg   stall
);

initial begin
    PCWrite = 1;
    IFIDWrite = 1;
    stall = 0;
  end

  always @(*) begin
      // FIXED: Add check for rd != 0 to avoid false hazards
      if (idex_memRead && (idex_rd != 0) &&
          (idex_rd == ifid_rs1 || idex_rd == ifid_rs2)) begin
        // stall one cycle
        PCWrite    = 0;
        IFIDWrite  = 0;
        stall      = 1;
      end else begin
        PCWrite    = 1;
        IFIDWrite  = 1;
        stall      = 0;
      end
    end
endmodule
