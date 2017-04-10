module TitleFSM(resetn, clk, start, win, lose, title1, title2, winend, loseend, titleoff);
	input resetn, clk, start, win, lose;
	output reg  title1, title2, winend, loseend, titleoff;
	
	//title flash
	reg [25:0] flashclk;
	always @(posedge clk) begin
		if (!resetn) flashclk <= 26'd0;
		else if (flashclk == 26'd20000000) flashclk <= 26'd0;
		else flashclk <= flashclk + 1'b1;
	end
	
	reg [3:0] current_state, next_state;
	localparam  S_TITLE1   = 4'd0,
					S_TITLE2   = 4'd1,
					S_WAIT1    = 4'd2,
					S_WAIT2	  = 4'd3,
					S_WAIT3    = 4'd4,
					S_END		  = 4'd5,
					S_WAIT_T1  = 4'd6,
					S_RESET    = 4'd7;
					
	//State Table
	always@(*)
	begin
		case (current_state)
			S_TITLE1:
				begin
					if(flashclk == 26'd0) next_state = S_TITLE2;
					else if(start) next_state = S_WAIT1;
					else next_state = S_TITLE1;
				end
			S_TITLE2:
				begin
					if(flashclk == 26'd0) next_state = S_TITLE1;
					else if(start) next_state = S_WAIT1;
					else next_state = S_TITLE2;
				end
			S_WAIT1:
				begin
					if(start) next_state = S_WAIT1;
					else next_state = S_WAIT2;
				end
			S_WAIT2:
				begin
					if(win|lose) next_state = S_WAIT3;
					else next_state = S_WAIT2;
				end
			S_WAIT3:
				begin
					if(win|lose) next_state = S_WAIT3;
					else next_state = S_END;
				end
			S_END:
				begin
					if(start) next_state = S_WAIT_T1;
					else next_state = S_END;
				end
			S_WAIT_T1:
				begin
					if(start) next_state = S_WAIT_T1;
					else next_state = S_TITLE1;
				end
			default: next_state = S_TITLE1;
		endcase
	end
	
	//Enable Signals
	always @(*)
	begin
		title1 = 1'b0;
		title2 = 1'b0;
		titleoff = 1'b0;
		winend = 1'b0;
		loseend = 1'b0;
		case (current_state)
			S_TITLE1: title1 = 1'b1;
			S_TITLE2: title2 = 1'b1;
			S_WAIT1: title1 = 1'b1;
			S_WAIT2: titleoff = 1'b1;
			S_WAIT3: 
			begin
				if(win) winend = 1'b1;
				if(lose) loseend = 1'b1;
			end
			S_END: 
			begin
				if(win) winend = 1'b1;
				if(lose) loseend = 1'b1;
			end
		endcase
	end
	
	//State FFs
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= S_TITLE1;
		else
			current_state <= next_state;
	end
	
endmodule