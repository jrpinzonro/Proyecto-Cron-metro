`timescale 1ns / 1ps
`define SIMULATION

module peripheral_sqr_TB;

   reg         clk;
   reg         reset;
   reg [15:0]  d_in;
   reg         cs;
   reg [4:0]   addr;
   reg         rd;
   reg         wr;
   wire [31:0] d_out;

   peripheral_sqr uut (
      .clk  (clk),
      .reset(reset),
      .d_in (d_in),
      .cs   (cs),
      .addr (addr),
      .rd   (rd),
      .wr   (wr),
      .d_out(d_out)
   );

   parameter PERIOD = 20;

   // reloj
   initial clk = 0;
   always #(PERIOD/2) clk = ~clk;

   // inicialización
   initial begin
      reset = 0;
      d_in  = 0;
      addr  = 5'h00;
      cs    = 0;
      rd    = 0;
      wr    = 0;
   end

   initial begin
      // reset
      @(negedge clk);
      reset = 1;
      @(negedge clk);
      reset = 0;
      #(PERIOD*4);

      // escribir A = 49 decimal = 0x0031
      cs   = 1; rd = 0; wr = 1;
      d_in = 16'h0090;
      addr = 5'h04;        // A
      #(PERIOD);
      cs = 0; rd = 0; wr = 0;
      #(PERIOD*3);

      // escribir B (no usado, puede ser 0)
      cs   = 1; rd = 0; wr = 1;
      d_in = 16'h0000;
      addr = 5'h08;        // B
      #(PERIOD);
      cs = 0; rd = 0; wr = 0;
      #(PERIOD*3);

      // init = 1
      cs   = 1; rd = 0; wr = 1;
      d_in = 16'h0001;
      addr = 5'h0C;        // init
      #(PERIOD);
      cs = 0; rd = 0; wr = 0;

      // esperar iteraciones suficientes (8 iteraciones → margen grande)
      #(PERIOD*80);

      // leer done
      cs   = 1; rd = 1; wr = 0;
      addr = 5'h14;
      #(PERIOD);
      cs = 0; rd = 0; wr = 0;
      #(PERIOD);

      // leer result
      cs   = 1; rd = 1; wr = 0;
      addr = 5'h10;
      #(PERIOD);
      $display("Resultado decimal (sqrt): %d", d_out);
      $display("Resultado binario (sqrt): %b", d_out);
      cs = 0; rd = 0; wr = 0;
      #(PERIOD*10);

      $finish;
   end

   initial begin : TEST_CASE
      $dumpfile("perip_sqr_TB.vcd");
      $dumpvars(-1, peripheral_sqr_TB);
      $dumpvars(0, peripheral_sqr_TB.uut);
      $dumpvars(0, peripheral_sqr_TB.uut.sqr1);
   end

endmodule

