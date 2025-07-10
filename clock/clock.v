module clock(input switch_1, switch_2, switch_3,output reg buzzer, output reg rs, output reg en, output reg [7:4] data, output wire redlight);
reg [7:0] one_sec,min9,hour9, ten_sec,min5,hour2;	//24hr clock
reg [7:0] one_sec_t,min9_t,hour9_t, ten_sec_t,min5_t,hour2_t;	//timer
//switch_1 -> cursor
//switch_2 -> increase by 1
reg [3:0] counter_alarm;	//for how much time does alarm rings
reg [7:0] one_sec_a,min9_a,hour9_a, ten_sec_a,min5_a,hour2_a;	//alarm
reg[26:0] delay,delay_t;

//display
reg [7:0] ten_sec_,min5_,hour2_,one_sec_,min9_,hour9_;
reg [3:0] nibs [1:51];
integer i=1;// navigate through the states of fsm
integer count=0;//delay for dispaly
//for am/pm
reg led,pm;

//clk of vaman -> 50ns
wire clk;

qlal4s3b_cell_macro u_qlal4s3b_cell_macro (
.Sys_Clk0 (clk),
);

//states
parameter s1_1_0 = 2'b00,s1_1_1 = 2'b01,s1_1_2 = 2'b10,s1_1_3 = 2'b11;
parameter s1_0 = 3'b000,s1_1 = 3'b001,s1_2 = 3'b010,s1_3 = 3'b011,s1_4 = 3'b100,s1_5 = 3'b101;

reg [1:0] fsm_1_1=s1_1_0;//switch_1 goes as 0, 1,1,1,....1, 0 then it goes to state s1_1_3
reg [1:0] fsm_2_1=s1_1_0;//switch_2 goes as 0, 1,1,1,....1, 0 then it goes to state s1_1_3
reg [1:0] fsm_3_1 = s1_1_3;//switch_3 goes as 0, 1,1,1,....1, 0 then it goes to state s1_1_3

reg [2:0]fsm_1=s1_0;//cursor fsm
reg [2:0] fsm_3 = s1_0; //fsm for modes
//s1_0 ->24hr clk, s1_1 -> 12hr clk, s1_2 -> timer, s1_3 -> alarm

integer stand = 0;//initialize for 1s then start clock
always@(posedge clk) begin
//1 second -> 12000000 clock cycles
if(stand<12000000) begin
	stand = stand+1;
	hour2 = 8'd1;
	hour9 = 8'd4;
	min5 = 8'd0;
	min9 = 8'd0;
	ten_sec = 8'd0;
	one_sec = 8'd0;
	hour2_t = 8'd0;
	hour9_t = 8'd0;
	min5_t = 8'd0;
	min9_t = 8'd2;
	ten_sec_t = 8'd0;
	one_sec_t = 8'd0;
	hour2_a = 8'd0;
	hour9_a = 8'd2;
	min5_a = 8'd4;
	min9_a = 8'd0;
	ten_sec_a = 8'd0;
	one_sec_a = 8'd0;
	buzzer = 1'b0;
	pm = 1'b0;
	counter_alarm = 4'd0;
	delay=27'd0;
	delay_t = 27'd0;
end else begin
		if(delay<27'd12000000) begin
   			delay=delay+27'd1;
		end else begin
			delay = 27'd0;
			//23:59:59
			if (ten_sec==8'd5 && one_sec==8'd9 && min5==8'd5 && min9==8'd9 && hour9==8'd3 && hour2==8'd2) begin
			   ten_sec<=8'd0;
			   one_sec<=8'd0;
			   min9<=8'd0;
			   min5<=8'd0;
			   hour9<=8'd0;
			   hour2<=8'd0;
			//a9:59:59, a<2 
  			end else if (ten_sec==8'd5 && one_sec==8'd9 && min5==8'd5 && min9==8'd9 && hour9==8'd9) begin
			   ten_sec<=8'd0;
			   one_sec<=8'd0;
   			   min9<=8'd0;
			   min5<=8'd0;
			   hour9<=8'd0;
			   hour2<= hour2+8'd1;
			//ab:59:59, b<9
			end else if (ten_sec==8'd5 && one_sec==8'd9 && min5==8'd5 && min9==8'd9) begin
			   ten_sec<=8'd0;
			   one_sec<=8'd0;
			   min9<=8'd0;
			   min5<=8'd0;
			   hour9<=hour9+8'd1;
			//ab:c9:59, c<5
			end else if (ten_sec==8'd5 && one_sec==8'd9 && min9==8'd9 ) begin
			   ten_sec<=8'd0;
			   one_sec<=8'd0;
			   min9<=8'd0;
			   min5 <= min5 + 8'd1;
			//ab:cd:59, d<9
  			end else if (ten_sec==8'd5 && one_sec==8'd9) begin
			   ten_sec<=8'd0;
			   one_sec<=8'd0;	
   			   min9 <= min9 + 8'd1;
   			//ab:cd:e9, e<5
			end else if(one_sec==8'd9) begin
			  one_sec<=8'd0;
			  ten_sec<=ten_sec+3'd1;
			//ab:cd:ef, f<9
  			end else if(one_sec<8'd9) begin
			  one_sec <= one_sec + 8'd1;
			end
			
			//blink redled if pm
			if(pm==1'b1) begin
				led = !led;
			end
			
			//time = alarm then buzzer rings
			if(hour2 == hour2_a && hour9 == hour9_a && min5 == min5_a && min9 == min9_a && ten_sec == ten_sec_a && one_sec == one_sec_a) begin
				buzzer = 1'b1;
			end
			
			//when timer becomes 00:00:01, after 1s we make buzzer ring, we want buzzer to stop ringing after sometime so this is needed
			if(hour2_t == 0 && hour9_t == 0 && min5_t == 0 && min9_t == 0 && ten_sec_t== 0 && (one_sec_t == 1||one_sec_t==0)) begin
				if(delay_t<1) delay_t = delay_t+27'd1;
				else begin
				delay_t = 27'd0;
				buzzer = 1'b1;
				if(counter_alarm == 10 && !(hour2 == hour2_a && hour9 == hour9_a && min5 == min5_a && min9 == min9_a && ten_sec == ten_sec_a && one_sec == one_sec_a)) begin
				buzzer = 1'b0;
				end
				end
			end
			
			//stop buzzer after 9-10s
			if(buzzer == 1'b1) begin 
				if(counter_alarm<4'd10) begin
					counter_alarm = counter_alarm + 4'd1;
				end else begin
					counter_alarm = 4'd0;
					buzzer = 1'b0;
				end	
			end

			//when it is not in timer mode, the clock of timer is set to clock of 24 hr
			if(fsm_3!=s1_2) begin
 				hour2_t = 0;
				hour9_t = 0;
				min5_t = 0;
				min9_t = 2;
				ten_sec_t = 0;
				one_sec_t = 0;
			end
			
			//24hr clock
			if(fsm_3 == s1_0) begin
				if(pm==1) begin 
					pm = 0;
					hour2 = hour2+8'd1;
					hour9 = hour9+8'd2;
					if(hour9>9) begin
					hour2 = hour2 + 8'd1;
					hour9 = hour9 - 8'd10;
					end
				end
			end
		
			//12hr clock
			if(fsm_3 == s1_1) begin
				//1a:bc:de, a>2
				if(hour2==8'd1 && hour8==8'd2) pm = 1'b1;
				if(hour2==8'd1 && hour9>8'd2) begin
					hour2 = 8'd0;
					hour9 = hour9-8'd2;
					pm = 1'b1;
				//2a:bc:de
				end else if(hour2==8'd2) begin
					hour2 = 8'd1;
					//when a>=2
					if(hour9>8'd1) begin
						hour2 = 8'd1;
						hour9 = hour9 - 8'd2;
					end else begin
					//when a<2
						hour2 = 8'd0;
						hour9 = hour9 + 8'd8;
					end
					pm = 1'd1;
				end else begin
					if(pm==1 && hour2==0 && hour9==0) begin
					pm = 0;
					end
					if(pm==0 && hour2==1 && hour9==2) begin
					pm = 1;
					end
				end
			end
	
			//timer
			if(fsm_3==s1_2) begin
				if(one_sec_t == 8'd0) begin
					//ab:cd:e0
					if(ten_sec_t!=8'd0) begin
						one_sec_t = 8'd9;
						ten_sec_t = ten_sec_t -8'd1;
					end else begin
						//ab:cd:00
						if(min9_t!=8'd0) begin
							ten_sec_t = 8'd5;
							one_sec_t = 8'd9;
							min9_t = min9_t-8'd1;
						end else begin
							//ab:c0:00
							if(min5_t != 8'd0) begin
								min9_t = 8'd9;
								ten_sec_t = 8'd5;
								one_sec_t = 8'd9;
								min5_t = min5_t-8'd1;
							end else begin
								//ab:00:00
								if(hour9_t != 8'd0) begin
									min5_t = 8'd5;
									min9_t = 8'd9;
									ten_sec_t = 8'd5;
									one_sec_t = 8'd9;
									hour9_t = hour9_t-8'd1;
								end else begin
									//a0:00:00
									if(hour2_t != 8'd0) begin
										min5_t = 8'd5;
										min9_t = 8'd9;
										ten_sec_t = 8'd5;
										one_sec_t = 8'd9;
										hour2_t = hour2_t-8'd1;
									end
								end
							end
						end
					end
				end else begin
				//ab:cd:ef
					one_sec_t = one_sec_t - 8'd1;
				end
			end
		
		end
end
end

always@(posedge clk)begin
//fsm to get a sequence 0,1,1,1,...,1,0 for switch_1,switch_2,switch_3
	case(fsm_1_1)
		s1_1_0 : begin
			if(!switch_1) fsm_1_1 = s1_1_1;
			else fsm_1_1 = s1_1_0;
		end
		s1_1_1 : begin
			if(switch_1) fsm_1_1 = s1_1_2;
			else fsm_1_1 = s1_1_1;
		end
		s1_1_2 : begin
			if(!switch_1) fsm_1_1 = s1_1_3;
			else fsm_1_1 = s1_1_2;
		end
		s1_1_3 : begin
			if(!switch_1) fsm_1_1 = s1_1_1;
			else fsm_1_1 = s1_1_2;
		end
	endcase
	case(fsm_2_1)
		s1_1_0 : begin
			if(!switch_2) fsm_2_1 = s1_1_1;
			else fsm_2_1 = s1_1_0;
		end
		s1_1_1 : begin
			if(switch_2) fsm_2_1 = s1_1_2;
			else fsm_2_1 = s1_1_1;
		end
		s1_1_2 : begin
			if(!switch_2) fsm_2_1 = s1_1_3;
			else fsm_2_1 = s1_1_2;
		end
		s1_1_3 : begin
			if(!switch_2) fsm_2_1 = s1_1_1;
			else fsm_2_1 = s1_1_2;
		end
	endcase
	case(fsm_3_1)
		s1_1_0 : begin
			if(!switch_3) fsm_3_1 = s1_1_1;
			else fsm_3_1 = s1_1_0;
		end
		s1_1_1 : begin
			if(switch_3) fsm_3_1 = s1_1_2;
			else fsm_3_1 = s1_1_1;
		end
		s1_1_2 : begin
			if(!switch_3) fsm_3_1 = s1_1_3;
			else fsm_3_1 = s1_1_2;
		end
		s1_1_3 : begin
			if(!switch_3) fsm_3_1 = s1_1_1;
			else fsm_3_1 = s1_1_2;
		end
	endcase

	//when switch_1 goes as 0,1,1,1...,1,0
	if(fsm_1_1 == s1_1_3) begin
		case(fsm_1)
			s1_0 : begin
				fsm_1 = s1_1;
			end
			s1_1 : begin
				fsm_1 = s1_2;
			end
			s1_2 : begin
				fsm_1 = s1_3;
			end
			s1_3 : begin
				fsm_1 = s1_4;
			end
			s1_4 : begin
				fsm_1 = s1_5;
			end
			s1_5 : begin
				fsm_1 = s1_0;
			end
		endcase
	end
	
	//when switch_2 goes as 0,1,1,1...,1,0
	if(fsm_2_1 == s1_1_3) begin
		if(fsm_3 == s1_0 || fsm_3 == s1_1) begin
			case(fsm_1)
				s1_0 : begin
					one_sec = one_sec + 8'd1;
					if(one_sec == 8'd10) begin
						one_sec = 8'd0;
					end
				end
				s1_1 : begin
					ten_sec = ten_sec + 8'd1;
					if(ten_sec == 8'd6) begin
						ten_sec = 8'd0;
					end
				end
				s1_2 : begin
					min9 = min9 + 8'd1;
					if(min9 == 8'd10) begin
						min9 = 8'd0;
					end
				end
				s1_3 : begin
					min5 = min5 + 8'd1;
					if(min5 == 8'd6) begin
						min5 = 8'd0;
					end
				end
				s1_4 : begin
					hour9 = hour9 + 8'd1;
					if(fsm_3 == s1_0)begin
						if((hour2<8'd2 && hour9==8'd10)||(hour2==8'd2 && hour9>8'd3)) begin
							hour9 = 8'd0;
						end
					end
					if(fsm_3 == s1_1) begin
						if((hour2<8'd1 && hour9==8'd10)||(hour2==8'd1 && hour9>8'd1)) begin
							hour9 = 8'd0;
						end
					end
				end
				s1_5 : begin
					hour2 = hour2 + 8'd1;
					if(fsm_3==s1_0) begin
						if(hour2 == 8'd3 ||(hour9>8'd3 && hour2>8'd1)) begin
							hour2 = 8'd0;
						end
					end
					if(fsm_3==s1_1) begin
						if(hour2 == 8'd2 || (hour9>8'd1 && hour2>8'd0)) begin
							hour2 = 8'd0;
						end
					end
				end
			endcase
		end
		
		if(fsm_3==s1_2) begin
			case(fsm_1)
				s1_0 : begin
					one_sec_t = one_sec_t + 8'd1;
					if(one_sec_t == 8'd10) begin
						one_sec_t = 8'd0;
					end
				end
				s1_1 : begin
					ten_sec_t = ten_sec_t + 8'd1;
					if(ten_sec_t == 8'd6) begin
						ten_sec_t = 8'd0;
					end
				end
				s1_2 : begin
					min9_t = min9_t + 8'd1;
					if(min9_t == 8'd10) begin
						min9_t = 8'd0;
					end
				end
				s1_3 : begin
					min5_t = min5_t + 8'd1;
					if(min5_t == 8'd6) begin
						min5_t = 8'd0;
					end
				end
				s1_4 : begin
					hour9_t = hour9_t + 8'd1;
					if((hour2_t<8'd2 && hour9_t==8'd10)||(hour2_t==8'd2 && hour9_t>8'd3)) begin
						hour9_t = 8'd0;
					end
				end
				s1_5 : begin
					hour2_t = hour2_t + 8'd1;
					if(hour2_t == 8'd3 ||(hour9_t>8'd3 && hour2_t>8'd1)) begin
						hour2_t = 8'd0;
					end
				end
			endcase
		end

		if(fsm_3==s1_3) begin
			case(fsm_1)
				s1_0 : begin
					one_sec_a = one_sec_a + 8'd1;
					if(one_sec_a == 8'd10) begin
						one_sec_a = 8'd0;
					end
				end
				s1_1 : begin
					ten_sec_a = ten_sec_a + 8'd1;
					if(ten_sec_a == 8'd6) begin
						ten_sec_a = 8'd0;
					end
				end
				s1_2 : begin
					min9_a = min9_a + 8'd1;
					if(min9_a == 8'd10) begin
						min9_a = 8'd0;
					end
				end
				s1_3 : begin
					min5_a = min5_a + 8'd1;
					if(min5_a == 8'd6) begin
						min5_a = 8'd0;
					end
				end	
				s1_4 : begin
					hour9_a = hour9_a + 8'd1;
					if((hour2_a<8'd2 && hour9_a==8'd10)||(hour2_a==8'd2 && hour9_a>8'd3)) begin
						hour9_a = 8'd0;
					end
				end
				s1_5 : begin
					hour2_a = hour2_a + 8'd1;
					if(hour2_a == 8'd3 ||(hour9_a>8'd3 && hour2_a>8'd1)) begin
						hour2_a = 8'd0;
					end
				end
			endcase
		end
	end

	//when switch_3 goes as 0,1,1,1...,1,0
	if(fsm_3_1 == s1_1_3) begin
		case(fsm_3)
			s1_0 : begin
				fsm_3 = s1_1;
			end
			s1_1 : begin
				fsm_3 = s1_2;
			end
			s1_2 : begin
				fsm_3 = s1_3;
			end
			s1_3 : begin
				fsm_3 = s1_0;
			end
		endcase

	end
end

always @(posedge clk) begin
	//ascii conversion for 24hr and 12hr
	if(fsm_3==s1_0||fsm_3==s1_1) begin
		ten_sec_= ten_sec + 8'd48;
		one_sec_ = one_sec + 8'd48;
		min5_ = min5 + 8'd48;
		hour2_ = hour2 + 8'd48;
		min9_ = min9 + 8'd48;
		hour9_ = hour9 + 8'd48;
	end
	
	//ascii conversion for timer
	if(fsm_3==s1_2) begin
		ten_sec_= ten_sec_t + 8'd48;
		one_sec_ = one_sec_t + 8'd48;
		min5_ = min5_t + 8'd48;
		hour2_ = hour2_t + 8'd48;
		min9_ = min9_t + 8'd48;
		hour9_ = hour9_t + 8'd48;
	end
	
	//ascii conversion for alarm
	if(fsm_3==s1_3) begin
		ten_sec_= ten_sec_a + 8'd48;
		one_sec_ = one_sec_a + 8'd48;
		min5_ = min5_a + 8'd48;
		hour2_ = hour2_a + 8'd48;
		min9_ = min9_a + 8'd48;
		hour9_ = hour9_a + 8'd48;
	end

	nibs[1]=4'h3;//nibs[1] to nibs[13] initialization
	nibs[2]=4'h3;
	nibs[3]=4'h3;
	nibs[4]=4'h2;
	nibs[5]=4'h2;
	nibs[6]=4'h8;
	nibs[7]=4'h0;
	nibs[8]=4'hC;
	nibs[9]=4'h0;
	nibs[10]=4'h6;
	nibs[11]=4'h0;
	nibs[12]=4'h1;
	nibs[13]=4'h8;
	nibs[14]=4'h0;//nibs[14] and nibs[15] for curser
	nibs[15]=1'b1;
	nibs[16]=hour2_[7:4];//nibs[16] and nibs[17] for hour2
	nibs[17]=hour2_[3:0];
	nibs[18]=hour9_[7:4];//nibs[18] and nibs[19] for hour9
	nibs[19]=hour9_[3:0];
	nibs[20]=4'h3;//nibs[20] and nibs[21] for :(3A is the hexadecimal form of :)
	nibs[21]=4'hA;
	nibs[22]=min5_[7:4];//mins
	nibs[23]=min5_[3:0];
	nibs[24]=min9_[7:4];
	nibs[25]=min9_[3:0];
	nibs[26]=4'h3;//nibs[26] and nibs[27] for :(3A is the hexadecimal form of :)
	nibs[27]=4'hA;
	nibs[28]=ten_sec_[7:4];//nibs[28] and nibs[29] for ten_sec									
	nibs[29]=ten_sec_[3:0];
	nibs[30]=one_sec_[7:4];//nibs[30] and nibs[31] for one_sec
	nibs[31]=one_sec_[3:0];
	nibs[32]=4'h2;
	nibs[33]=4'h0;//empty spaces for the rest.
	nibs[34]=4'hC;
	nibs[35]=4'h0;
	nibs[36]=4'h2;
	nibs[37]=4'h0;
	nibs[38]=4'h2;
	nibs[39]=4'h0;
	nibs[40]=4'h2;
	nibs[41]=4'h0;
	nibs[42]=4'h2;
	nibs[43]=4'h0;
	nibs[44]=4'h2;
	nibs[45]=4'h0;
	nibs[46]=4'h2;
	nibs[47]=4'h0;
	nibs[48]=4'h2;
	nibs[49]=4'h0;
	nibs[50]=4'h2;
	nibs[51]=4'h0;
	
		
	if (i<15) begin 
	    rs<=1'b0;
	    data=nibs[i];
	    en<=1'b1;
	    if (count == 800) begin 
	       en<=1'b0;
	       count<=0;
	       i<=i+1;
	    end else count<=count+1;
	end
   	if (i==15) begin
	       if (count==60000) begin
	       		count<=0;
	       	        i<=i+1;
	       end else count<=count+1;
	end
    
	if ((i>15 && i<34)||(i>35 && i<=51)) begin
		rs<=1'b1;
		data=nibs[i];
		en<=1'b1;
		if (count==800) begin
			en<=1'b0;
			count<=0;
			i<=i+1;
		end else count<=count+1;
	end
	
	if (i>=34 && i<=35) begin
		rs<=1'b0;
		data = nibs[i];
		en<=1'b1;
		if (count==800) begin
			en<=1'b0;
			count<=0;
			i<=i+1;
		end else count<=count+1;
	end 
	
	if(i>51) i<=13;
end  

assign redled=led;
endmodule
