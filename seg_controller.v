module seg_controller(
                      clk, hard_reset,
                      d, e, f, g, h, i,
                      seg, 
                      seg_sel); 

input clk;
input hard_reset;
input [3:0] d;
input [3:0] e;
input [3:0] f;
input [3:0] g;
input [3:0] h;
input [3:0] i;
output [7:0] seg;
output [5:0] seg_sel;
wire [9:0] dp_count;
wire [3:0] a;
wire dot;

counter U1_counter( 
                  .clk(clk), .hard_reset(hard_reset),
                  .dp_count(dp_count)); 
                  
dp_fsm U0_dp_fsm(
          .clk(clk), .hard_reset(hard_reset), .dot(dot),
          .dp_count(dp_count), .d(d), .e(e), .f(f), .g(g), .h(h), .i(i),
			 .a(a), .seg_sel(seg_sel));

dec_7seg U2_dec_7seg( 
                    .a(a), .dot(dot),
                    .seg(seg)); 

endmodule
