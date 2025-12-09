module peripheral_sqr (
  input              clk,
  input              reset,
  input      [15:0]  d_in,
  input              cs,
  input      [4:0]   addr,
  input              rd,
  input              wr,
  output reg [31:0]  d_out
);

  reg [15:0] A;
  reg [15:0] B;
  reg        init;
  wire [31:0] result;
  wire        done;
  reg  [4:0]  s;

  // decodificador de direcciones
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
    end else begin
      s = 5'b00000;
    end
  end

  // escritura de registros
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

  // lectura de registros
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      d_out <= 0;
    end else if (cs && rd) begin
      case (s)
        5'b01000: d_out <= result;
        5'b10000: d_out <= {31'b0, done};
        default:  d_out <= 0;
      endcase
    end
  end

  // instancia del módulo de raíz cuadrada
  sqr sqr1 (
    .reset (reset),
    .clk   (clk),
    .init  (init),
    .done  (done),
    .result(result),
    .op_A  (A),
    .op_B  (B)     // no se usa dentro de sqr
  );

endmodule

