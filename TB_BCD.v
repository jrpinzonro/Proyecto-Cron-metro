module tb_uart;

    // Señales del DUT
    reg         clk   = 0;
    reg         rst   = 1;
    reg  [31:0] d_in  = 0;
    reg         cs    = 0;
    reg  [4:0]  addr  = 0;
    reg         rd    = 0;
    reg         wr    = 0;
    wire [31:0] d_out;
    wire        uart_tx;
    reg         uart_rx = 1;  // línea en reposo (nivel alto)
    wire        ledout;

    // Instancia del periférico
    peripheral_uart #(
        .clk_freq(25000000),
        .baud(115200)
    ) dut (
        .clk    (clk),
        .rst    (rst),
        .d_in   (d_in),
        .cs     (cs),
        .addr   (addr),
        .rd     (rd),
        .wr     (wr),
        .d_out  (d_out),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx),
        .ledout (ledout)
    );

    // Generador de reloj: periodo 20 ns (50 MHz)
    always #10 clk = ~clk;

    initial begin
        // Para ver señales en GTKWave
        $dumpfile("sim.vcd");
        $dumpvars(0, tb_uart);

        // Reset
        #50;
        rst = 0;

        // Ejemplo: escribir un dato al UART
        // Direccion 0x08 -> dato a transmitir
        addr = 5'h08;
        cs   = 1;
        wr   = 1;
        d_in = 32'h00000055; // ejemplo: 0x55

        #20;
        wr   = 0;
        cs   = 0;

        // Ahora escribir control en 0x10 (por ejemplo poner tx_wr = 1)
        #100;
        addr = 5'h10;
        cs   = 1;
        wr   = 1;
        d_in = 32'h00000001; // uart_ctrl[0] = tx_wr = 1

        #20;
        wr   = 0;
        cs   = 0;

        // Esperar a que termine transmisión
        #200000;

        $finish;
    end

endmodule

