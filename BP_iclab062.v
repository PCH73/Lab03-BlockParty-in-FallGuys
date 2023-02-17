module BP(
  clk,
  rst_n,
  in_valid,
  guy,
  in0,
  in1,
  in2,
  in3,
  in4,
  in5,
  in6,
  in7,
  
  out_valid,
  out
);

input             clk, rst_n;
input             in_valid;
input       [2:0] guy;
input       [1:0] in0, in1, in2, in3, in4, in5, in6, in7;
output reg        out_valid;
output reg  [1:0] out;

//==============================================//
//             Parameter and Integer            //
//==============================================//
parameter S_IDLE = 2'd0;
parameter S_IN   = 2'd1;
parameter S_OUT  = 2'd2;

//==============================================//
//            FSM State Declaration             //
//==============================================//
reg [1:0] c_state,n_state;

//==============================================//
//                 reg declaration              //
//==============================================//
reg [125:0] road;
reg [125:0] map;
reg [1:0] obs_type,a;
reg [2:0] obs_pos,guy_pos;
reg [5:0] counter;
reg [1:0] walk;
reg [5:0] count,count_a,count_b;
wire [2:0] step_abs;
wire [5:0] diff;


//==============================================//
//             Current State Block              //
//==============================================//

always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) c_state <= S_IDLE ; /* initial state */
    else c_state <= n_state;
end

//==============================================//
//              Next State Block                //
//==============================================//
always@(*) 
begin
    if (!rst_n) n_state=S_IDLE;
    else 
        begin
        case(c_state)
            S_IDLE:
                begin
                if (in_valid) n_state=S_IN;
                else n_state=S_IDLE;
                end
            S_IN:
                begin 
                  if (in_valid) n_state=S_IN;
                  else n_state=S_OUT;
                end
            S_OUT:
                begin
                if (counter<64) n_state=S_OUT; 
                else n_state=S_IDLE;
                end
            default:n_state=S_IDLE;
        endcase
        end
end


//==============================================//
//                  Input Block                 //
//==============================================//

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) obs_type<=0;
  else if (in_valid)
  begin
    if (in0!=2'b11 && in0!=2'b00) obs_type<=in0;
    else if (in1!=2'b11 && in1!=2'b00) obs_type<=in1;
    else if (in2!=2'b11 && in2!=2'b00) obs_type<=in2;
    else if (in3!=2'b11 && in3!=2'b00) obs_type<=in3;
    else if (in4!=2'b11 && in4!=2'b00) obs_type<=in4;
    else if (in5!=2'b11 && in5!=2'b00) obs_type<=in5;
    else if (in6!=2'b11 && in6!=2'b00) obs_type<=in6;
    else if (in7!=2'b11 && in7!=2'b00) obs_type<=in7;
    /*else obs_type<=obs_type;*/
  end
  /*else obs_type<=obs_type;*/
end

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) obs_pos<=0;
  else if (in_valid)
  begin
    if (c_state==S_IDLE) obs_pos<=guy;
    else if (in0!=2'b11 && in0!=2'b00) obs_pos<=3'd0;
    else if (in1!=2'b11 && in1!=2'b00) obs_pos<=3'd1;
    else if (in2!=2'b11 && in2!=2'b00) obs_pos<=3'd2;
    else if (in3!=2'b11 && in3!=2'b00) obs_pos<=3'd3;
    else if (in4!=2'b11 && in4!=2'b00) obs_pos<=3'd4;
    else if (in5!=2'b11 && in5!=2'b00) obs_pos<=3'd5;
    else if (in6!=2'b11 && in6!=2'b00) obs_pos<=3'd6;
    else if (in7!=2'b11 && in7!=2'b00) obs_pos<=3'd7;
    else obs_pos<=obs_pos;
  end
  else obs_pos<=obs_pos;
end

always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) guy_pos<=0;
  else if (c_state==S_IDLE) guy_pos<=guy;
  else if (n_state==S_IN) guy_pos<=obs_pos;
  else guy_pos<=guy_pos;
end

/*always @(posedge clk or negedge rst_n)
begin
  if (!rst_n) guy_pos<=0;
  else if (c_state==S_IDLE) guy_pos<=guy;
  else if (in_valid) guy_pos<=obs_pos;
  else guy_pos<=guy_pos;
end*/

//==============================================//
//              Calculation Block               //
//==============================================//

assign step_abs=(obs_pos > guy_pos)?obs_pos-guy_pos:guy_pos-obs_pos;
assign diff=count_a-count_b-1;

always@(*)
begin
  if(!rst_n) walk=2'b0;
  else if(guy_pos==obs_pos) begin walk=2'b00;end
  else if(guy_pos < obs_pos) begin walk=2'b01;end
  else if(guy_pos > obs_pos) begin walk=2'b10;end
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) count<=2'b0;
  else if(n_state==S_IDLE) begin count<=0;end
  else if(n_state==S_IN) begin count<=count+1;end
  
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) count_a<=2'b0;
  else if(n_state==S_IDLE) begin count_a<=0;end
  else if(in0!=0) begin count_a<=count;end
  
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) count_b<=0;
  else if(n_state==S_IDLE) begin count_b<=0;end
  else if(in0!=0) begin count_b<=count_a;end
  
end

always@(*) 
begin
if (!rst_n) begin road=126'b0;end
else if (a==1)//see_obstacle
  begin  
  if (obs_type==2'b01)//jump
    begin
    road[125:124]={2'b11};
    if (walk==2'b01)//right
    begin
      case(step_abs)
      3'd7:road[123:110]={7{2'b01}};
      3'd6:road[123:112]={6{2'b01}};
      3'd5:road[123:114]={5{2'b01}};
      3'd4:road[123:116]={4{2'b01}};
      3'd3:road[123:118]={3{2'b01}};
      3'd2:road[123:120]={2{2'b01}};
      3'd1:road[123:122]={1{2'b01}};

      endcase
    end
    else if(walk==2'b00) begin road[125:124]=2'b11;end
    else if(walk==2'b10)//left
    begin
      case(step_abs) 
      3'd7:road[123:110]={7{2'b10}};
      3'd6:road[123:112]={6{2'b10}};
      3'd5:road[123:114]={5{2'b10}};
      3'd4:road[123:116]={4{2'b10}};
      3'd3:road[123:118]={3{2'b10}};
      3'd2:road[123:120]={2{2'b10}};
      3'd1:road[123:122]={1{2'b10}};
      
      endcase
    end
    
    end
  else if(obs_type==2'b10)//stop
    begin
    road[125:124]={2'b00};
    if (walk==2'b01)//right
    begin 
      case(step_abs)
      3'd7:road[123:110]={7{2'b01}};
      3'd6:road[123:112]={6{2'b01}};
      3'd5:road[123:114]={5{2'b01}};
      3'd4:road[123:116]={4{2'b01}};
      3'd3:road[123:118]={3{2'b01}};
      3'd2:road[123:120]={2{2'b01}};
      3'd1:road[123:122]={1{2'b01}};
        
      endcase
    end
    else if (walk==2'b00) begin road[125:124]={2'b00};end
    else if (walk==2'b10)//left
    begin
      case(step_abs)
      3'd7:road[125:110]={7{2'b10}};
      3'd6:road[125:112]={6{2'b10}};
      3'd5:road[125:114]={5{2'b10}};
      3'd4:road[125:116]={4{2'b10}};
      3'd3:road[125:118]={3{2'b10}};
      3'd2:road[125:120]={2{2'b10}};
      3'd1:road[125:122]={1{2'b10}};

      endcase
    end
      
    end
  end
end

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n) a<=0;
  else if (n_state==S_IDLE) a<=0;
  else if (n_state==S_IN && in0!=0) a<=a+1;
  else if (n_state==S_IN && in0==0) a<=0;
end

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n) begin road<=126'b0;end
  else if (n_state==S_IDLE) begin road<=126'b0;end
  else if (n_state==S_IN) begin road<={road[1:0],road[125:2]};end
  //else if (n_state==S_IN) road[125:110]<=road[125:110]|map[125:110];
  else if (c_state==S_OUT) begin road<={road[1:0],road[125:2]};end//notice
  /*else road<=road;*/
end

always@(posedge clk or negedge rst_n)
begin
  if (!rst_n) counter<=0;
  else if(n_state==S_IDLE)counter<= 0;
  else if(n_state==S_OUT)counter<=counter+1;
  else counter<=counter;
end


//==============================================//
//                Output Block                  //
//==============================================//
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n) out_valid <= 0; /* remember to reset */
    else if(n_state == S_IDLE)
    begin
      out_valid<=0;
    end
    else if (n_state==S_OUT) out_valid <= 1;
    else out_valid <= 0;
end

always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) out <= 2'b0; /* remember to reset */
  else if (n_state==S_IDLE) out<=2'b0;
  else if (n_state==S_OUT) out<={road[1:0]};
  //else out <= 2'b0;
end

endmodule