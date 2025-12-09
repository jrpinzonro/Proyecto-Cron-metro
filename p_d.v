

`timescale 1ns / 1ps

`define SIMULATION
module peripheral_div_TB;
   reg clk;
   reg  reset;
   reg  start;
   reg [15:0] d_in;
   reg cs;
   reg [4:0] addr;       // addr de 5 bits
   reg rd;
   reg wr;
   wire [31:0] d_out;

   peripheral_div uut (
      .clk(clk),
      .reset(reset),
      .d_in(d_in),
      .cs(cs),
      .addr(addr),
      .rd(rd),
      .wr(wr),
      .d_out(d_out)
   );

   parameter PERIOD = 20;

   // Inicialización
   initial begin
      clk = 0;
      reset = 0;
      d_in = 0;
      addr = 5'h00;
      cs = 0;
      rd = 0;
      wr = 0;
   end

   // Generación de reloj
   initial         clk <= 0;
   always #(PERIOD/2) clk <= ~clk;

   initial begin
     forever begin
      // Reset
      @(negedge clk);
      reset = 1;
      @(negedge clk);
      reset = 0;
      #(PERIOD*4)

      // A operator
      cs   = 1; rd = 0; wr = 1;
      d_in = 16'h0031;
      addr = 5'h04;         // A
      #(PERIOD)
      cs = 0; rd = 0; wr = 0;
      #(PERIOD*3)

      // B operator
      cs   = 1; rd = 0; wr = 1;
      d_in = 16'h0007;
      addr = 5'h08;         // B
      #(PERIOD)
      cs = 0; rd = 0; wr = 0;
      #(PERIOD*3)

      // Init signal
      cs   = 1; rd = 0; wr = 1;
      d_in = 16'h0001;
      addr = 5'h0C;         // init
      #(PERIOD)
      cs = 0; rd = 0; wr = 0;

      // AQUÍ ESTÁ LA CORRECCIÓN: dar tiempo suficiente al divisor
      #(PERIOD*60)

      // read done
      cs   = 1; rd = 1; wr = 0;
      addr = 5'h14;         // done
      #(PERIOD)
      cs = 0; rd = 0; wr = 0;
      #(PERIOD)

      // read data
      cs   = 1; rd = 1; wr = 0;
      addr = 5'h10;         // result
      #(PERIOD);
      $display("Resultado decimal: %d", d_out);
      $display("Resultado binario: %b", d_out);
      cs = 0; rd = 0; wr = 0;
      #(PERIOD*20);
     end
   end

   initial begin : TEST_CASE
     $dumpfile("perip_div_TB.vcd");
     $dumpvars(-1, peripheral_div_TB);
     $dumpvars(0, peripheral_div_TB.uut);
     $dumpvars(0, peripheral_div_TB.uut.div1);
     #(PERIOD*100) $finish;
   end

endmodule


// Módulo peripheral_div
module peripheral_div (
  input clk,
  input reset,
  input [15:0] d_in,
  input cs,
  input [4:0] addr,
  input rd,
  input wr,
  output reg [31:0] d_out
);

  reg [15:0] A;
  reg [15:0] B;
  reg init;
  wire [31:0] result;
  wire done;
  reg [4:0] s;

  // Decodificador de direcciones
  always @(*) begin
    if (cs) begin
      case (addr)
        5'h04: s = 5'b00001; // A
        5'h08: s = 5'b00010; // B
        5'h0C: s = 5'b00100; // init
        5'h10: s = 5'b01000; // result
        5'h14: s = 5'b10000; // done
        default: s = 5'b00000;
      endcase
    end else
      s = 5'b00000;
  end

  // Escritura de registros
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      A    <= 0;
      B    <= 0;
      init <= 0;
    end else if (cs && wr) begin
      A    <= s[0] ? d_in    : A;
      B    <= s[1] ? d_in    : B;
      init <= s[2] ? d_in[0] : init;
    end
  end

  // Lectura de registros
  always @(posedge clk or posedge reset) begin
    if (reset)
      d_out <= 0;
    else if (cs && rd) begin
      case (s)
        5'b01000: d_out <= result;
        5'b10000: d_out <= {31'b0, done};
        default:  d_out <= 0;
      endcase
    end
  end

  // Instanciación del divisor
  div div1 (
    .reset(reset),
    .clk(clk),
    .init(init),
    .done(done),
    .result(result),
    .op_A(A),
    .op_B(B)
  );

endmodule

