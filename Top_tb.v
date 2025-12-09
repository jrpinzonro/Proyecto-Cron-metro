module top_tb;
  reg clk, soft_reset, hard_reset, start;
  wire [7:0] seg;
  wire [5:0] seg_sel;
  wire [3:0] d, e, f, g, h, i;  

  top uut (
    .clk(clk),
    .soft_reset(soft_reset),
    .hard_reset(hard_reset),
    .start(start),
    .seg(seg),
    .seg_sel(seg_sel),
    .d(d), .e(e), .f(f), .g(g), .h(h), .i(i)
  );

  always #10 clk = ~clk;

  initial begin
    $dumpfile("top.vcd");
    $dumpvars(0, top_tb);

    clk = 0; soft_reset = 1; hard_reset = 0; start = 0;
    #50 hard_reset = 1; 

    #200 start = 1; #20 start = 0; 
    #200000 start = 1; #20 start = 0; 
    #200000 start = 1; #20 start = 0; 

    #500000 soft_reset = 0; #20 soft_reset = 1;

    #500000000 $finish;
  end

  initial begin
    $monitor("t=%0t | d=%d e=%d f=%d g=%d h=%d i=%d | seg_sel=%b | seg=%b",
             $time, d, e, f, g, h, i, seg_sel, seg);
  end
endmodule

