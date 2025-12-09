module temp_project_top (
    input  wire         i_clk,     
    input  wire         i_rst,     

    output reg  [15:0]  o_display_temp,
    output reg  [15:0]  o_display_humid,
    output reg  [16*8-1:0] o_txt_line1,
    output reg  [16*8-1:0] o_txt_line2
);
    
    wire [15:0] s_temp;
    wire [15:0] s_humid;
    wire        s_valid;

    temp_sensor_model u_sensor (
        .i_clk   (i_clk),
        .i_rst   (i_rst),
        .o_temp  (s_temp),
        .o_humid (s_humid),
        .o_valid (s_valid)
    );

    function [15:0] f_to_two_ascii;
        input [7:0] value;
        integer d1;
        integer d0;
        begin
            d1 = value / 10;
            d0 = value % 10;
            f_to_two_ascii = {8'd48 + d1[7:0], 8'd48 + d0[7:0]}; 
        end
    endfunction

    reg [7:0] temp_int;
    reg [7:0] humid_int;
    reg [7:0] t_d1, t_d0;
    reg [7:0] h_d1, h_d0;

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            o_display_temp  <= 16'd0;
            o_display_humid <= 16'd0;
            o_txt_line1     <= {16{8'h20}}; 
            o_txt_line2     <= {16{8'h20}};
        end else begin
            
            if (s_valid) begin
                o_display_temp  <= s_temp;
                o_display_humid <= s_humid;
            end

            temp_int  = o_display_temp[7:0];
            humid_int = o_display_humid[7:0];

            {t_d1, t_d0} = f_to_two_ascii(temp_int);
            {h_d1, h_d0} = f_to_two_ascii(humid_int);

            o_txt_line1 = {
                "T","E","M","P","=",
                t_d1, t_d0,
                " ","C",
                " "," "," "," "," "," "
            };

            o_txt_line2 = {
                "H","U","M"," ","=",
                h_d1, h_d0,
                " ","%",
                " "," "," "," "," "," "
            };
        end
    end

endmodule
