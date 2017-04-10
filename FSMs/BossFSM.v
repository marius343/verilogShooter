module BossFSM(resetn, clk, spawn, kill, over, titleoff, fade, tar, hit, clear);
	input resetn, clk, spawn, kill, titleoff;
	output reg fade, tar, hit, clear;
	output over;
	reg [2:0] hitcount;
	
	//BOSS PERIOD
	reg [27:0] flashclk;
	always @(posedge clk) begin
		if (fadeclk == 26'd9999999) flashclk <= 28'd0;
		else if (flashclk == 28'd100000000) flashclk <= 28'd0;
		else flashclk <= flashclk + 1'b1;
	end
	
	//fade period
	reg [25:0] fadeclk;
	always @(posedge clk) begin
		if (spawn || kill || flashclk == 28'd100000000) fadeclk <= 26'd0;
		else if (fadeclk == 26'd10000000) fadeclk <= 26'd10000000;
		else fadeclk <= fadeclk + 1'b1;
	end
	
	//FSM
	reg [2:0] current_state, next_state;
	localparam  S_CLEAR    = 3'd0,
					S_FADEIN	  = 3'd1,
					S_TAR		  = 3'd2,
					S_HIT      = 3'd3,
					S_HITCOUNT = 3'd4,
					S_FADEOUT  = 3'd5,
					S_WAIT	  = 3'd6;
	
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
					else if(spawn) next_state = S_FADEIN;
					else next_state = S_CLEAR;
				end
			S_FADEIN:
				begin 
					if(!titleoff || over) next_state = S_WAIT;
					else if(fadeclk == 26'd10000000) next_state = S_TAR;
					else next_state = S_FADEIN;
				end
			S_TAR:
				begin
					if(!titleoff || over) next_state = S_WAIT;
					else if(flashclk == 28'd100000000) next_state = S_FADEOUT;
					else if(kill) next_state = S_HIT;
					else next_state = S_TAR;
				end
			S_HIT:
				begin
					if(!titleoff || over) next_state = S_WAIT;
					else if(fadeclk == 26'd10000000) next_state = S_HITCOUNT;
					else next_state = S_HIT;
				end
			S_HITCOUNT:
				begin
					next_state = S_CLEAR;
				end
			S_FADEOUT:
				begin 
					if(!titleoff || over) next_state = S_WAIT;
					else if(fadeclk == 26'd10000000) next_state = S_CLEAR;
					else next_state = S_FADEOUT;
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
			S_FADEIN: fade = 1'b1;
			S_TAR: tar = 1'b1;
			S_HIT: hit = 1'b1;
			S_HITCOUNT: hit = 1'b1;
			S_FADEOUT: fade = 1'b1;
		endcase
	end
	
	//Hit counter
	always @(posedge clk) begin
		if (!resetn || over || !titleoff) hitcount <= 3'd0;
		else if (current_state == S_HITCOUNT) hitcount <= hitcount + 1'b1;
	end
	assign over = (hitcount == 3'd3) ? 1'b1 : 1'b0;

	
	//State FFs
	always@(posedge clk)
	begin: state_FFs
		if(!resetn)
			current_state <= S_WAIT;
		else
			current_state <= next_state;
	end
	
endmodule
