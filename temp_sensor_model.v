module temp_sensor_model (
    input  wire        i_clk,
    input  wire        i_rst,
    output reg  [15:0] o_temp,
    output reg  [15:0] o_humid,
    output reg         o_valid   
);

    reg [23:0] cnt;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            cnt    <= 24'd0;
            o_temp <= 16'd0;
            o_humid<= 16'd50; 
            o_valid<= 1'b0;
        end else begin
            if (cnt == 24'd5_000_000) begin
                cnt     <= 24'd0;
                o_valid <= 1'b1;

                if (o_temp[7:0] == 8'd99)
                    o_temp <= 16'd0;
                else
                    o_temp <= o_temp + 16'd1;

            end else begin
                cnt     <= cnt + 1;
                o_valid <= 1'b0;
            end
        end
    end

endmodule
