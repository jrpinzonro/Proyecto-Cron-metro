`timescale 1ns/1ps

module tb_peripheral_mult;

  reg clk;
  reg reset;
  reg cs;
  reg rd;
  reg wr;
  reg [4:0] addr;
  reg [15:0] d_in;
  wire [31:0] d_out;

  
  peripheral_mult uut (
    .clk(clk),
    .reset(reset),
    .d_in(d_in),
    .cs(cs),
    .addr(addr),
    .rd(rd),
    .wr(wr),
    .d_out(d_out)
  );


  always #5 clk = ~clk;

  initial begin
    $dumpvars(0, tb_peripheral_mult);
$dumpvars(0, tb_peripheral_mult.uut);           
$dumpvars(0, tb_peripheral_mult.uut.mult1);    


  
    clk   = 0;
    reset = 1;
    cs    = 0;
    rd    = 0;
    wr    = 0;
    addr  = 0;
    d_in  = 0;

    #20 reset = 0;

    
    @(posedge clk);
    cs   = 1; wr = 1; addr = 5'h04; d_in = 16'd7;
    @(posedge clk);
    wr = 0; cs = 0;

  
    @(posedge clk);
    cs   = 1; wr = 1; addr = 5'h08; d_in = 16'd9;
    @(posedge clk);
    wr = 0; cs = 0;

    
    @(posedge clk);
    cs   = 1; wr = 1; addr = 5'h0C; d_in = 16'd1;
    @(posedge clk);
    wr = 0; cs = 0;

    
    repeat(50) begin
      @(posedge clk);
      cs = 1; rd = 1; addr = 5'h14; 
      @(posedge clk);
      if (d_out[0] == 1) begin
        $display("DONE activo en ciclo %t", $time);
        rd = 0; cs = 0;
        disable check_done;
      end
      rd = 0; cs = 0;
    end


    @(posedge clk);
    cs = 1; rd = 1; addr = 5'h10;
    @(posedge clk);
    $display("Resultado leído: %d", d_out);
    rd = 0; cs = 0;

    #50 $finish;
  end

  task check_done;
    begin end
  endtask

endmodule
