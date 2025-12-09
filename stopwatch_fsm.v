module stopwatch_fsm(
                       clk,
                       hard_reset,
                       start,
			 soft_reset,
                       en
                       );
input clk;
input hard_reset;
input start;
input soft_reset;
output reg [1:0] en;

reg [1:0] state;
reg [1:0] nextstate;

parameter T0 = 2'b00;  
parameter T1 = 2'b01; 
parameter T2 = 2'b10; 


always@(posedge clk or negedge hard_reset) begin
  if(~hard_reset) state <= T0;
  else state <= nextstate;
  end
  
 
 always@(state or start or soft_reset) begin
    if(~soft_reset)
      nextstate = T0;
    else begin
      case (state)
        T0 : if (start) nextstate = T1;
             else nextstate = T0;
        T1 : if(start) nextstate=T2;
             else nextstate = T1;
        T2 : if(start) nextstate=T1;
             else nextstate = T2;
      default : nextstate = T0;
    endcase
  end
end

always@(state)begin
  case (state)
    T1: en = T1;
    T2 : en = T2;
    default : en =T0;
  endcase 
end
endmodule 
