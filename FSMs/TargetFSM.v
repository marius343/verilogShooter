module TargetFSM(resetn, clk, spawn, kill, over, titleoff, fade, tar, hit, clear);
	input resetn, clk, spawn, kill, titleoff, over;
	output reg  fade, tar, hit, clear;
	
	//fade period
	reg [25:0] fadeclk;
	always @(posedge clk) begin
		if (spawn || kill) fadeclk <= 26'd0;
		else if (fadeclk == 26'd15000000) fadeclk <= 26'd15000000;
		else fadeclk <= fadeclk + 1'b1;
	end
	
	//FSM
	reg [3:0] current_state, next_state;
	localparam	S_WAIT	  = 4'd0,
					S_CLEAR    = 4'd1,
					S_FADE	  = 4'd2,
					S_TAR		  = 4'd3,
					S_HIT      = 4'd4;
					
	//State Table
	always@(*)
	begin
		case (current_state)
			S_WAIT:
				begin
					if(titleoff) next_state = S_CLEAR;
					else next_state = S_WAIT;
				end
			S_CLEAR:
				begin
					if(!titleoff || over) next_state = S_WAIT;
					else if(spawn) next_state = S_FADE;
					else next_state = S_CLEAR;
				end
			S_FADE:
				begin 
					if(!titleoff || over) next_state = S_WAIT;
					else if(fadeclk == 26'd15000000) next_state = S_TAR;
					else next_state = S_FADE;
				end
			S_TAR:
				begin
					if(!titleoff || over) next_state = S_WAIT;
					else if(kill) next_state = S_HIT;
					else next_state = S_TAR;
				end
			S_HIT:
				begin
					if(!titleoff || over) next_state = S_WAIT;
					else if(fadeclk == 26'd15000000) next_state = S_CLEAR;
					else next_state = S_HIT;
				end
			default: next_state = S_WAIT;
		endcase
	end
	
	//Enable Signals
	always @(*)
	begin
		fade = 1'b0;
		tar = 1'b0;
		hit = 1'b0;
		clear = 1'b0;
		case (current_state)
			S_CLEAR: clear = 1'b1;
			S_FADE: fade = 1'b1;
			S_TAR: tar = 1'b1;
			S_HIT: hit = 1'b1;
		endcase
	end
	
	//State FFs
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= S_WAIT;
		else
			current_state <= next_state;
	end

endmodule