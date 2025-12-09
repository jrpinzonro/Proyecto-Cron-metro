module sqr (
    input              reset,
    input              clk,
    input              init,
    output reg         done,
    input      [15:0]  op_A,
    input      [15:0]  op_B, 
    output reg [31:0]  result
  
);

localparam START     = 3'b000;
localparam SHIFT_DEC = 3'b001;
localparam LOAD_TMP  = 3'b010;
localparam CHECK     = 3'b011;
localparam LOAD_A2   = 3'b100;
localparam CHECK_Z   = 3'b101;
localparam END1      = 3'b110;


reg [2:0]  state;
reg [31:0] A;        
reg [15:0] R;        
reg [15:0] tmp;      
reg [4:0]  count;    


wire [15:0] A_upper = A[31:16];
wire [15:0] A_lower = A[15:0];

wire [16:0] subtrahend = {1'b0, (tmp << 1) + 16'h0001};
wire [16:0] diff_full  = {1'b0, A_upper} - subtrahend;

wire        msb_neg    = diff_full[16];     
wire [15:0] A2_new     = diff_full[15:0];    


wire Z = (count == 0);


always @(posedge clk or posedge reset) begin
    if (reset) begin
        state  <= START;
        done   <= 0;
        result <= 0;
        A      <= 0;
        R      <= 0;
        tmp    <= 0;
        count  <= 0;
    end else begin
        case (state)

            START: begin
                done   <= 0;
                result <= 0;
                if (init) begin
                 
                    A     <= {16'b0, op_A};  
                    R     <= 16'b0;
                    tmp   <= 16'b0;
                    count <= 5'd8;           
                    state <= SHIFT_DEC;
                end else begin
                    state <= START;
                end
            end

           
            SHIFT_DEC: begin
                A     <= A << 2;
                R     <= R << 1;            
                if (count != 0)
                    count <= count - 1;
                state <= LOAD_TMP;
            end

           
            LOAD_TMP: begin
                tmp   <= R;
                state <= CHECK;
            end

          
            CHECK: begin
                if (msb_neg)
                    state <= CHECK_Z;  
                else
                    state <= LOAD_A2; 
            end

      
            LOAD_A2: begin
                R[0]     <= 1'b1;
                A[31:16] <= A2_new;
                state    <= CHECK_Z;
            end

         
            CHECK_Z: begin
                if (Z)
                    state <= END1;
                else
                    state <= SHIFT_DEC;
            end

   
            END1: begin
                done   <= 1;
                result <= {16'b0, R};
                state  <= END1;
            end

            default: state <= START;

        endcase
    end
end

`ifdef BENCH
reg [8*10:1] state_name;
always @(*) begin
    case (state)
        START     : state_name = "START";
        SHIFT_DEC : state_name = "SHIFT_DEC";
        LOAD_TMP  : state_name = "LOAD_TMP";
        CHECK     : state_name = "CHECK";
        LOAD_A2   : state_name = "LOAD_A2";
        CHECK_Z   : state_name = "CHECK_Z";
        END1      : state_name = "END1";
        default   : state_name = "UNDEF";
    endcase
end
`endif

endmodule

