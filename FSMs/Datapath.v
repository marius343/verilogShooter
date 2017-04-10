module Datapath(clk, resetn, title1, title2, winend, loseend, titleoff, fade, tar, hit, clear, colour, x, y, outCounter);
	input clk, resetn;
	
	//Controls
	input title1, title2, winend, loseend, titleoff;
	input [6:0] fade, tar, hit, clear;
	
	//outputs to VGA
	output reg [2:0] colour;
	output [8:0] x;
	output [7:0] y;
	output [24:0] outCounter;
	assign outCounter = Rcounter;
	
	//xo/xo positions
	reg [8:0] xo;
	reg [7:0] yo;
	wire [8:0] x_135 = 9'd0, x_246 = 9'd260;
	wire [7:0] y_12 = 8'd0, y_34 = 8'd80, y_56 = 8'd160;
	
	coordinator XY(resetn, xo, yo, clk, titleoff, x, y);
	
	//Colour states
	wire [2:0] c_title1, c_title2, c_win, c_lose, colour_b, colour_f, colour_h, colour_t;
	wire [16:0] address;
	assign address = y * 17'd320 + x + 17'd2;
	
	Title1 CT1(address, clk, 3'd0, 1'b0, c_title1);
	Title2 CT2(address, clk, 3'd0, 1'b0, c_title2);
	Ending CE(address, clk, 3'd0, 1'b0, c_win);
	Ending2 CE2(address, clk, 3'd0, 1'b0, c_lose);
	blank  CB(address, clk, 3'd0, 1'b0, colour_b);
	fade   CF(address, clk, 3'd0, 1'b0, colour_f);
	target CT(address, clk, 3'd0, 1'b0, colour_t);
	hit    CH(address, clk, 3'd0, 1'b0, colour_h);
	
	
	
	//Refresher clock
	reg [24:0] Rcounter;
	always @(posedge clk) begin
		if (!resetn) Rcounter <= 25'd0;
		else if (Rcounter == 25'd90000)
		Rcounter <= 25'd0;
		else Rcounter <= Rcounter + 1'b1;
	end
	assign refresh = (Rcounter == 25'd90000) ? 1'b1 : 1'b0;
	
	//Sequential Coordinate Refresher
	always @(posedge clk) begin
		if (xo == x_135 && yo == y_12 && refresh) begin
			xo <= x_246;
			yo <= y_12;
		end
		if (xo == x_246 && yo == y_12 && refresh) begin
			xo <= x_135;
			yo <= y_34;
		end
		if (xo == x_135 && yo == y_34 && refresh) begin
			xo <= x_246;
			yo <= y_34;
		end
		if (xo == x_246 && yo == y_34 && refresh) begin
			xo <= x_135;
			yo <= y_56;
		end
		if (xo == x_135 && yo == y_56 && refresh) begin
			xo <= x_246;
			yo <= y_56;
		end
		if (xo == x_246 && yo == y_56 && refresh) begin
			xo <= 9'd60;
			yo <= 8'd0;
		end
		if (xo == 9'd60 && yo == 8'd0 && refresh || !resetn) begin
			xo <= x_135;
			yo <= y_12;
		end
	end
	
	//Sequential Colour Refresher
	always @(posedge clk) begin
		if (title1) colour <= c_title1;
		if (title2) colour <= c_title2;
		if (winend) colour <= c_win;
		if (loseend) colour <= c_lose;
		if (xo == x_135 && yo == y_12 && titleoff) begin
			if (clear[1]) colour <= colour_b;
			if (fade[1]) colour <= colour_f;
			if (tar[1]) colour <= colour_t;
			if (hit[1]) colour <= colour_h;
		end
		if (xo == x_246 && yo == y_12 && titleoff) begin
			if (clear[2]) colour <= colour_b;
			if (fade[2]) colour <= colour_f;
			if (tar[2]) colour <= colour_t;
			if (hit[2]) colour <= colour_h;
		end
		if (xo == x_135 && yo == y_34 && titleoff) begin
			if (clear[3]) colour <= colour_b;
			if (fade[3]) colour <= colour_f;
			if (tar[3]) colour <= colour_t;
			if (hit[3]) colour <= colour_h;
		end
		if (xo == x_246 && yo == y_34 && titleoff) begin
			if (clear[4]) colour <= colour_b;
			if (fade[4]) colour <= colour_f;
			if (tar[4]) colour <= colour_t;
			if (hit[4]) colour <= colour_h;
		end
		if (xo == x_135 && yo == y_56 && titleoff) begin
			if (clear[5]) colour <= colour_b;
			if (fade[5]) colour <= colour_f;
			if (tar[5]) colour <= colour_t;
			if (hit[5]) colour <= colour_h;
		end
		if (xo == x_246 && yo == y_56 && titleoff) begin
			if (clear[6]) colour <= colour_b;
			if (fade[6]) colour <= colour_f;
			if (tar[6]) colour <= colour_t;
			if (hit[6]) colour <= colour_h;
		end
		if (xo == 9'd60 && yo == 8'd0 && titleoff) begin
			if (clear[0]) colour <= colour_b;
			if (fade[0]) colour <= colour_f;
			if (tar[0]) colour <= colour_t;
			if (hit[0]) colour <= colour_h;
		end
	end
	
endmodule

//COORDINATE UPDATER
module coordinator(resetn, xo, yo, clk, titleoff, x, y);
	input [8:0] xo;
	input [7:0] yo;
	input titleoff, clk, resetn;
	
	output reg [8:0] x;
	output reg [7:0] y;
	reg [8:0] x_s, x_t, x_b;
	reg [7:0] y_s, y_t, y_b;
	
	always @(posedge clk) begin
		if(!titleoff) begin
			x <= x_s;
			y <= y_s;
		end
		if((xo == 9'd0 || xo == 9'd260) && (yo == 8'd0 || yo == 8'd80 || yo == 8'd160) && titleoff) begin
			x <= x_t;
			y <= y_t;
		end
		if(xo == 9'd60 && yo == 8'd0 && titleoff) begin
			x <= x_b;
			y <= y_b;
		end
	end
	
	//Screen | title
	always @(posedge clk) begin
		if (!resetn) begin
			x_s <= 9'd0;
			y_s <= 8'd0;
		end
		//X
		if (x_s < 9'd319) begin
			x_s <= x_s + 1'b1;
		end
		if (x_s == 9'd319) x_s <= 9'd0;
		//Y
		if (x_s == 9'd319 && y_s < 8'd239) begin
			y_s <= y_s + 1'b1;
		end
		if (x_s == 9'd319 && y_s == 8'd239) begin
			y_s <= 8'd0;
		end
	end
	
	//Targets
	always @(posedge clk) begin
		if (x_t < xo || x_t > (xo + 9'd59)) begin
			x_t <= xo;
			y_t <= yo;
		end
		if (x_t < (xo + 9'd59)) x_t <= x_t + 1'b1;
		if (x_t == (xo + 9'd59)) x_t <= xo;
		if ((x_t == xo + 9'd59) && (y_t < yo + 8'd79)) y_t <= y_t + 1'b1;
		if ((x_t == xo + 9'd59) && (y_t == 8'd79)) y_t <= yo;
	end
	
	//Boss
	always @(posedge clk) begin
		if (x_b < xo || x_b > (xo + 9'd199)) begin
			x_b <= xo;
			y_b <= yo;
		end
		if (x_b < (xo + 9'd199)) x_b <= x_b + 1'b1;
		if (x_b == (xo + 9'd199)) x_b <= xo;
		if ((x_b == xo + 9'd199) && (y_b < yo + 8'd239)) y_b <= y_b + 1'b1;
		if ((x_b == xo + 9'd199) && (y_b == 8'd239)) y_b <= yo;
	end
	
endmodule
