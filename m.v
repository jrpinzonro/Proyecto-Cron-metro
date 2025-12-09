module mult (
	input              reset,
	input              clk,
	input              init,
	input      [15:0]  op_A,
	input      [15:0]  op_B,
	output reg         done,
	output reg [31:0]  result

);
//maquina de estados
parameter START  = 3'b000;
parameter CHECK  = 3'b001;
parameter SHIFT  = 3'b010;
parameter ADD    = 3'b011;
parameter END    = 3'b100;
parameter STARTO = 3'b101;
 
reg [2:0]  state;
reg [15:0] A;
reg [15:0] B;

initial begin
	result = 0;
	done   = 0;
end
 
 
	reg [4:0] count;

always @(posedge clk or posedge reset)
begin
	if (reset) begin
		done   <= 0;
		result <= 0;
		state   = START;
	end else begin
		case(state)
			START: begin				
				count  =  0;
				done   <= 0;
				result =  0;
				if(init)
					state = STARTO;
				else
					state = STARTO;
			end
    
			STARTO:begin
			<	A      <= op_A;
				B      <= op_B;
				done   <= 0;
				result =  0;
				state  =  CHECK;
			end

			CHECK: begin
				if(B[0])
					state = ADD;
				else
					state = SHIFT;
			end
        
			SHIFT: begin
				B    = B >> 1;
				A    = A << 1;
				done = 0;			
				if(B==0)
					state = END;
				else
					state = CHECK;
			end
     
			ADD: begin
				result <= result + A;
				done    = 0;			 
				state   = SHIFT;
			end

			END:begin
				done = 1;
				count = count + 1;
				state = (count>29) ? START : END ; 
			end

			default: state = START;
     
		endcase
	end
end

`ifdef BENCH
reg [8*40:1] state_name;
always @(*) begin
  case(state)
    START    : state_name = "START";
    STARTO  : state_name = "STARTO";
    CHECK    : state_name = "CHECK";
    SHIFT    : state_name = "SHIFT";
    ADD      : state_name = "ADD";
    END      : state_name = "END";
  endcase
end
`endif


endmodule
