
`ifdef RTL
    `define CYCLE_TIME 10.0
`endif
`ifdef GATE
    `define CYCLE_TIME 10.0
`endif
`define PAT_NUM 200

module PATTERN(
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
/* Input to design */
output reg       clk, rst_n;
output reg       in_valid;
output reg [2:0] guy;
output reg [1:0] in0, in1, in2, in3, in4, in5, in6, in7;
/* Output to pattern */
input            out_valid;
input      [1:0] out;

/* define clock cycle */
real CYCLE = `CYCLE_TIME;
always #(CYCLE/2.0) clk = ~clk;

/* parameter and integer*/
integer patnum = `PAT_NUM;
integer max_step = 63;
integer i_pat, i, j, a;
integer num, obs_none, seed, max, row, step, obs_last;
integer golden_out;
integer latency;
integer total_latency;

/* reg declaration */
reg [2:0] obs_pos,guy_pos;
reg [1:0] guy_type,obs_type;
reg [15:0] map [0:63];
reg [1:0] obs_row [0:63];

initial 
begin
    reset_task;
    for (i_pat = 0; i_pat < patnum; i_pat = i_pat+1)
    begin
        check_out_task;    
        check_out_valid_task;
        guy_task;
        input_task;
        wait_out_valid_task;
        check_out_cycle_task;
        check_jump_high_to_low_task;
        check_jump_same_height_task;
        compute_ans_task; 
        check_ans_task;
        $display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32mexecution cycle : %3d\033[m",i_pat ,latency);
    end
    YOU_PASS_task;  
end

task reset_task; begin 
    rst_n = 'b1;
    in_valid = 'b0;
    in0 = 'bx;
    in1 = 'bx;
    in2 = 'bx;
    in3 = 'bx;
    in4 = 'bx;
    in5 = 'bx;
    in6 = 'bx;
    in7 = 'bx;
    guy = 'bx;
    total_latency = 0;


    force clk = 0;

    #CYCLE; rst_n = 0; 
    #CYCLE; rst_n = 1;
    
    if(out_valid !== 1'b0 || out !=='b0) begin //out!==0
        $display("****************************************************************************************************************");  
        $display("                                              SPEC 3 IS FAIL!                                                   ");    
        $display("****************************************************************************************************************");
        $finish;
    end
	#CYCLE; release clk;
end endtask

task input_task; 
begin
	in_valid = 1'b1;
    max=$urandom(seed)%2000;
    seed=$urandom_range(0,max);
    row=0;
    guy=3'dx;
    obs_last=0;
    for(i=0;i<64;i=i+1)
    begin
        for(j=0;j<8;j=j+1)
        begin
            map[i][j]=2'b00;
        end
    end
    while(row<max_step && a<63) 
    begin
        max=$urandom(seed)%128;
        seed=$urandom_range(max,0);
        if(obs_pos==obs_last)
        begin
            if(obs_pos==7) obs_pos=obs_pos-2;
            else if(obs_pos==6) obs_pos=obs_pos-2;
            else if(obs_pos==5) obs_pos=obs_pos-2;
            else if(obs_pos==4) obs_pos=obs_pos-2;
            else if(obs_pos==3) obs_pos=obs_pos+1;
            else if(obs_pos==2) obs_pos=obs_pos+3;
            else if(obs_pos==1) obs_pos=obs_pos+5;
            else  obs_pos=obs_pos+2;
        end
        obs_type=$urandom_range(2,1);

        num= obs_pos>obs_last ? obs_pos-obs_last : obs_last-obs_pos;
        step= obs_type==2'b01 ? $urandom_range(num,8) : $urandom_range(num-1,8);
        row=row+step+2; 
        obs_none=0;
        while(obs_none<step+1 && a<63)
        begin
        {in0,in1,in2,in3,in4,in5,in6,in7}={8{2'b00}};
        obs_none=obs_none+1;
        a=a+1;
        @(negedge clk);
        end

        if(a<63) 
        begin
            if (obs_pos==0) {in0,in1,in2,in3,in4,in5,in6,in7}={obs_type,{7{2'b11}}};
            else if (obs_pos==1) {in0,in1,in2,in3,in4,in5,in6,in7}={{1{2'b11}},obs_type,{6{2'b11}}};
            else if (obs_pos==2) {in0,in1,in2,in3,in4,in5,in6,in7}={{2{2'b11}},obs_type,{5{2'b11}}};
            else if (obs_pos==3) {in0,in1,in2,in3,in4,in5,in6,in7}={{3{2'b11}},obs_type,{4{2'b11}}};
            else if (obs_pos==4) {in0,in1,in2,in3,in4,in5,in6,in7}={{4{2'b11}},obs_type,{3{2'b11}}};
            else if (obs_pos==5) {in0,in1,in2,in3,in4,in5,in6,in7}={{5{2'b11}},obs_type,{2{2'b11}}};
            else if (obs_pos==6) {in0,in1,in2,in3,in4,in5,in6,in7}={{6{2'b11}},obs_type,{1{2'b11}}};
            else if (obs_pos==7) {in0,in1,in2,in3,in4,in5,in6,in7}={{7{2'b11}},obs_type};
        end
        map[row][15:0]={in0,in1,in2,in3,in4,in5,in6,in7};
        a=a+1;
        @(negedge clk);
        obs_last=obs_pos;
        obs_pos=$urandom(seed)%8;
    end

        in_valid=1'b0;
        guy='bx;
        in0='bx;
        in1='bx;
        in2='bx;
        in3='bx;
        in4='bx;
        in5='bx;
        in6='bx;
        in7='bx;
        @(negedge clk);
end endtask

task guy_task; 
begin
@(negedge clk);
  in_valid=1;
  in0= 'b00;
  in1= 'b00;
  in2= 'b00;
  in3= 'b00;
  in4= 'b00;
  in5= 'b00;
  in6= 'b00;
  in7= 'b00;
  a=0;
  a=a+1;
  
  obs_pos=$urandom() % 8;

  case(obs_pos)
  0:guy=$urandom_range(2,0);
  1:guy=$urandom_range(0,3);
  2:guy=$urandom_range(0,4);
  3:guy=$urandom_range(1,5);
  4:guy=$urandom_range(2,6);
  5:guy=$urandom_range(3,7);
  6:guy=$urandom_range(4,7);
  7:guy=$urandom_range(5,7);
  endcase
  guy_pos=guy;
  @(negedge clk);
end endtask

task check_out_task; begin
    if(out_valid === 0 && out !== 'b0) begin
        $display ("---------------------------------------------------------------------------------------------------------------");
        $display ("                                             SPEC 4 IS FAIL!                                                   ");
        $display ("---------------------------------------------------------------------------------------------------------------");
        $finish;
    end
end endtask

task check_out_valid_task; begin
    if(out_valid === 1'b1 && in_valid === 1'b1) begin
        $display ("---------------------------------------------------------------------------------------------------------------");
        $display ("                                             SPEC 5 IS FAIL!                                                   ");
        $display ("---------------------------------------------------------------------------------------------------------------");
        $finish;
    end
end endtask

task wait_out_valid_task; begin
    latency = 0;
    while(out_valid !== 1'b1) begin
	  latency = latency + 1;
      if( latency == 30000) begin
          $display("****************************************************************************************************************");     
          $display("                                            SPEC 6 IS FAIL!                                                     ");
          $display("****************************************************************************************************************");
	    $finish;
      end
     @(negedge clk);
   end
   total_latency = total_latency + latency;
end endtask

task check_out_cycle_task; begin
    clk = 0;
    while(out_valid === 1) begin
	  clk = clk + 1;
      if( clk>63 ||clk<63) begin
          $display("**************************************************************************************************************");     
          $display("                                            SPEC 7 IS FAIL!                                                   ");
          $display("**************************************************************************************************************");
	    $finish;
      end
     @(negedge clk);
   end
end endtask

task compute_ans_task; 
begin
    if (obs_type===2'b01)
    begin
        if(obs_pos>guy_pos) 
        begin
            for(i=row;i<row+step-1;i=i+1)
            golden_out[i]={2'd1};
            golden_out[row+step-1]={2'd3};
        end
        else if(obs_pos<guy_pos)
        begin
            for(i=row;i<row+step-1;i=i+1)
            golden_out[i]={2'd2};
            golden_out[row+step-1]={2'd3};
        end
    end
    else 
        begin
            if(obs_pos>guy_pos) 
            begin
                for(i=row;i<row+step+1;i=i+1)
                golden_out[i]={2'd1};
            end
            else if(obs_pos<guy_pos)
            begin
                for(i=row;i<row+step+1;i=i+1)
                golden_out[i]={2'd2};
            end
            else
            begin
                for(i=0;i<row+step+1;i=i+1)
                golden_out[i]={2'd0};
            end
        end
end endtask

task check_ans_task; begin
    if(out !== golden_out) begin
        $display ("-------------------------------------------------------------------------------------------------------------- ");
        $display ("                                             SPEC 8-1 IS FAIL!                                                 ");
        $display ("                                        Golden Out :          %d                                               ",golden_out); //show ans
        $display ("                                          Your Out :          %d                                               ", out); //show output
        $display ("---------------------------------------------------------------------------------------------------------------");
        $display ("---------------------------------------------------------------------------------------------------------------");
        $finish;
    end
	@(negedge clk);
end endtask

task check_jump_high_to_low_task; begin
    clk = 0;
    while(out === 2'd3 && guy_type===2'b01) 
    begin
        if (obs_type===2'b00)
	    clk = clk + 1;
        if( clk === 2 && out !==2'b00) begin
          $display("**************************************************************************************************************");     
          $display("                                            SPEC 8-2 IS FAIL!                                                 ");
          $display("                                    Out should be 2'b00 for 2 cycles                                          ");
          $display("**************************************************************************************************************");
	    $finish;
      end
     @(negedge clk);
   end
end endtask

task check_jump_same_height_task; begin
    clk = 0;
    while(out === 2'd3 && guy_type===2'b01) 
    begin
	    if (obs_type===2'b01)
        clk = clk + 1;
        if( clk === 1 && out !==2'b00) begin
          $display("**************************************************************************************************************");     
          $display("                                            SPEC 8-3 IS FAIL!                                                 ");
          $display("                                    Out should be 2'b00 for 1 cycle                                           ");
          $display("**************************************************************************************************************");
	    $finish;
      end
      @(negedge clk);
    end
    while(out === 2'd3 && guy_type===2'b00) 
    begin
        if (obs_type===2'b00)
	    clk = clk + 1;
        if( clk === 1 && out !==2'b00) begin
          $display("**************************************************************************************************************");     
          $display("                                            SPEC 8-3 IS FAIL!                                                 ");
          $display("                                    Out should be 2'b00 for 1 cycle                                           ");
          $display("**************************************************************************************************************");
	    $finish;
      end
      @(negedge clk);
    end
end endtask

task YOU_PASS_task; begin
    $display ("--------------------------------------------------------------------");
    $display ("                         Congratulations!                           ");
    $display ("                  You have passed all patterns!                     ");
    $display ("                  Total latency : %d cycles                         ", total_latency);
    $display ("--------------------------------------------------------------------");        
    $finish;
end endtask


endmodule