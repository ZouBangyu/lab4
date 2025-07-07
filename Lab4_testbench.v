`include "top.v"
module simple_test;
reg clk;
integer cycle_count;

top cpu(.clk(clk));

initial begin
    clk = 0;
    cycle_count = 0;
    forever #5 clk = ~clk;
end

initial begin
    $display("===============================================");
    
    repeat(35) begin
        @(posedge clk);
        $display("Clock cycle %20d, PC = %08h", cycle_count, cpu.pc_IF);
        $display("ra = %08h, t0 = %08h, t1 = %08h", 
                 cpu.uut2.regMem[1],          // ra (x1)
                 cpu.uut2.regMem[5],          // t0 (x5) 
                 cpu.uut2.regMem[6]);         // t1 (x6)
        $display("t2 = %08h, t3 = %08h, t4 = %08h", 
                 cpu.uut2.regMem[7],          // t2 (x7) 
                 cpu.uut2.regMem[28],         // t3 (x28)
                 cpu.uut2.regMem[29]);        // t4 (x29)
        $display("===============================================");
        cycle_count = cycle_count + 1;
    end
    
    $display(">>> Simulation complete at %d", $time);
    $finish;
end
endmodule
