module DataMem(
    input clk,
    input write_en,
    input [31:0] read_addr,
    input [31:0] write_addr,
    input [31:0] write_data,
    output [31:0] read_data,
    input asByte,
    input asUnsigned
);
    reg [7:0] memori [31:0];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            memori[i] = 8'h00;
        end
    end
    
    wire [31:0] signed_value, unsigned_value, byte_value, word_value;
    
    always @(posedge clk) begin
        if (write_en && (~asByte)) begin
            // Word write - little endian
            memori[write_addr] = write_data[7:0];
            memori[write_addr + 1] = write_data[15:8];
            memori[write_addr + 2] = write_data[23:16];
            memori[write_addr + 3] = write_data[31:24];
        end
        else if (write_en && asByte) begin
            // Byte write
            memori[write_addr] = write_data[7:0];
        end
    end
    
    // Read operations - CRITICAL FIX
    assign unsigned_value = {24'b0, memori[read_addr]};
    assign signed_value = {{24{memori[read_addr][7]}}, memori[read_addr]};
    assign word_value = {memori[read_addr + 3], memori[read_addr + 2], 
                        memori[read_addr + 1], memori[read_addr]};
    
    // FIXED: Proper mux instantiation
    assign byte_value = asUnsigned ? signed_value : unsigned_value;
    assign read_data = asByte ? word_value : byte_value;
endmodule
