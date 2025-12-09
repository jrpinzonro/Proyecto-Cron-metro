`timescale 1ns/1ps

module tb_temp_project;

    reg clk;
    reg rst;

    wire [15:0] w_display_temp;
    wire [15:0] w_display_humid;
    wire [16*8-1:0] w_txt_line1;
    wire [16*8-1:0] w_txt_line2;

    // generación de reloj: periodo 20 ns (50 MHz, por ejemplo)
    initial clk = 1'b0;
    always #10 clk = ~clk;

    // reset inicial
    initial begin
        rst = 1'b1;
        #100;
        rst = 1'b0;
    end

    // instancia del top
    temp_project_top u_top (
        .i_clk        (clk),
        .i_rst        (rst),
        .o_display_temp  (w_display_temp),
        .o_display_humid (w_display_humid),
        .o_txt_line1  (w_txt_line1),
        .o_txt_line2  (w_txt_line2)
    );

    // opcional: mostrar por consola cuando cambia la lectura
    always @(posedge clk) begin
        if (!rst) begin
            $display("t=%0t ns  TEMP=%0d  HUM=%0d", $time, w_display_temp[7:0], w_display_humid[7:0]);
        end
    end

    // dumping para GTKWave o similar
    initial begin
        $dumpfile("tb_temp_project.vcd");
        $dumpvars(0, tb_temp_project);
        #2_000_000_000; // tiempo de simulación
        $finish;
    end

endmodule
