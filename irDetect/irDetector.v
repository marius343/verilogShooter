module irDetector(SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, GPIO_1, CLOCK_50, VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK, VGA_R, VGA_G, VGA_B, KEY, AUD_ADCDAT, AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, AUD_XCK, AUD_DACDAT, I2C_SCLK, I2C_SDAT, x_output, y_output, plotOut, colourOut, Rcounter);
	 input [9:0] SW;
	 input [3:0] KEY;
	 input [24:0] Rcounter;
	 output [9:0] LEDR;
	 input CLOCK_50;
	 //audio module
	 input AUD_ADCDAT;
	 inout AUD_BCLK;
	 inout AUD_ADCLRCK;
	 inout AUD_DACLRCK;
	 output	AUD_XCK;
    output	AUD_DACDAT;
	 inout	I2C_SDAT;
	 output	I2C_SCLK;
	 output [8:0] x_output;
	 output [7:0] y_output;
	 output [2:0] colourOut;
	 output plotOut;
	 output [7:0] VGA_R, VGA_G, VGA_B;
	 output VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK;
	 wire ld_x, ld_y, ld_colour, ld_position, counter1111, count_up;
	 wire resetCount, resetScreen, plot, resetplot, resetRegisters, draw, triggerOut; // trigger out is for trigger being pressed
	 wire [8:0] posx, resetx, x_coordinate;
	 wire [7:0] posy, resety, y_coordinate;
	 wire [2:0] colour, resetColour;
	 output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 input [35:0] GPIO_1; //Expension cable input
	 reg [3:0] reciever1Output, reciever2Output, reciever3Output, reciever4Output, reciever5Output, reciever6Output;
	 wire [5:0] irInput; //temporary wire
	 
	 assign irInput [5:0] = {reciever6Output[0], reciever5Output[0], reciever4Output[0], reciever3Output[0], reciever2Output[0], reciever1Output[0]}; //IR input should be calibrated so its: (top-left, top-middle, top-right, bottom-left, bottom-middle, bottom-right)
	 wire enable;
	 assign enable = irInput[0] | irInput[1] | irInput[2] | irInput[3] | | irInput[4] | | irInput[5];

	 always @(*)
    begin
        case (GPIO_1[35]|SW[5]) //"" corner
            1'd0:
                reciever1Output <= 4'b0000;
            1'd1:
					 reciever1Output <= 4'b0001;
            default: reciever1Output <= 4'b0000;
        endcase
		   case (GPIO_1[31]|SW[4]) //"" corner
            1'd0:
                reciever2Output <= 4'b0000;
            1'd1:
					 reciever2Output <= 4'b0001;
            default: reciever2Output <= 4'b0000;
        endcase
		   case (GPIO_1[27]|SW[3]) //"" corner
            1'd0:
                reciever3Output <= 4'b0000;
            1'd1:
					 reciever3Output <= 4'b0001;
            default: reciever3Output <= 4'b0000;
        endcase
		   case (GPIO_1[25]|SW[2]) //"" corner
            1'd0:
                reciever4Output <= 4'b0000;
            1'd1:
					 reciever4Output <= 4'b0001;
            default: reciever4Output <= 4'b0000;
        endcase
		  case (GPIO_1[21]|SW[1]) //"" corner
            1'd0:
                reciever5Output <= 4'b0000;
            1'd1:
					 reciever5Output <= 4'b0001;
            default: reciever5Output <= 4'b0000;
        endcase
		  case ({1'b0, GPIO_1[17]} | {1'b0, SW[0] }) //"" corner
            2'd0:
                reciever6Output <= 4'b0000;
            2'd1:
					 reciever6Output <= 4'b0001;
				2'b11://this case is for testing something only
					 reciever6Output <= 4'b0011;	 
            default: reciever6Output <= 4'b0000;
        endcase
    end

	//displays output of IR detector as a 0 or 1
	hex_decoder h0(.hex_digit(reciever1Output[3:0]), .segments(HEX0[6:0]));
	hex_decoder h1(.hex_digit(reciever2Output[3:0]), .segments(HEX1[6:0]));
	hex_decoder h2(.hex_digit(reciever3Output[3:0]), .segments(HEX2[6:0]));
	hex_decoder h3(.hex_digit(reciever4Output[3:0]), .segments(HEX3[6:0]));
	hex_decoder h4(.hex_digit(reciever5Output[3:0]), .segments(HEX4[6:0]));
	hex_decoder h5(.hex_digit(reciever6Output[3:0]), .segments(HEX5[6:0]));
	
	//delete me
	wire [9:0] tmpWire;
	
	 
datapath u1(
    .clk(CLOCK_50),
    .resetn(KEY[0] | resetRegisters), .resetCounter(resetCount), 
    .x_coordinate(x_coordinate[8:0]), .y_coordinate(y_coordinate[7:0]),
	 .draw(draw), .triggerIn(GPIO_1[1]),
    .ld_x(ld_x), .ld_y(ld_y), .ld_colour(ld_colour),
    .ld_position(ld_position),
    .position_x(posx[8:0]), 
	 .position_y(posy[7:0]), 
	 .outColour(colour[2:0]),
	 .counter1111(counter1111), .count_up(count_up), .triggerOut(triggerOut)
    );
	 
control u2(
    .clk(CLOCK_50),
    .resetn(KEY[0]),
    .go(enable), .irInput(irInput[5:0]),
	 .counter1111(counter1111), .count_up(count_up),
    .ld_x(ld_x), .ld_y(ld_y), .ld_colour(ld_colour),
    .ld_position(ld_position), .draw(draw),
	 .resetCounter(resetCount), .plot(plot), .resetRegisters(resetRegisters),
	 .x(x_coordinate[8:0]), .y(y_coordinate[7:0]), .LEDR(tmpWire[9:0]), .Rcounter(Rcounter[24:0]) //Change LEDR back
    );	 
	 
vga_adapter u3(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(VGAcolour[2:0]),
			.x(VGAx[8:0]), .y(VGAy[7:0]), .plot(VGAplot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R[7:0]),
			.VGA_G(VGA_G[7:0]),
			.VGA_B(VGA_B[7:0]),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC), 
			.VGA_CLK(VGA_CLK));
			
	// Internal Wires
	wire				audio_in_available;
	wire		[7:0]	left_channel_audio_in;
	wire		[7:0]	right_channel_audio_in;
	wire				write_audio_out;

	wire				audio_out_allowed;
	wire		[7:0]	left_channel_audio_out;
	wire		[7:0]	right_channel_audio_out;
	wire 				read_audio_in;
	
	assign x_output = VGAx[8:0];
	assign y_output = VGAy[7:0];
	assign plotOut = VGAplot;
	assign colourOut = VGAcolour[2:0];
/*				
	Audio_Controller a1(
		// Inputs
		.CLOCK_50(CLOCK_50),
		.reset(~KEY[0]),

		.clear_audio_in_memory(),	
		.read_audio_in(read_audio_in),

		.clear_audio_out_memory(),
		.left_channel_audio_out(left_channel_audio_out[7:0]),
		.right_channel_audio_out(right_channel_audio_out[7:0]),
		.write_audio_out(write_audio_out),

		.AUD_ADCDAT(AUD_ADCDAT),

		// Bidirectionals
		.AUD_BCLK(AUD_BCLK),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_DACLRCK(AUD_DACLRCK),

		// Outputs
		.left_channel_audio_in(left_channel_audio_in[7:0]),
		.right_channel_audio_in(right_channel_audio_in[7:0]),
		.audio_in_available(audio_in_available),

		.audio_out_allowed(audio_out_allowed),

		.AUD_XCK(AUD_XCK),
		.AUD_DACDAT(AUD_DACDAT)
	);
	
	avconf #(.USE_MIC_INPUT(1)) avc (
	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);



	gunshotSound g1(.trigger(GPIO_1[1]), .CLOCK_50(CLOCK_50), .audioOut(), .enable(), .resetn(KEY[0]), .LEDR(LEDR[9:0]));
	*/

	DE2_Audio_Example u56(
	// Inputs
	.CLOCK_50(CLOCK_50),
	.CLOCK_27(),
	.KEY(4'b1111),

	.AUD_ADCDAT(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK(AUD_BCLK),
	.AUD_ADCLRCK(AUD_ADCLRCK),
	.AUD_DACLRCK(AUD_DACLRCK),

	.I2C_SDAT(I2C_SDAT),

	// Outputs
	.AUD_XCK(AUD_XCK),
	.AUD_DACDAT(AUD_DACDAT),

	.I2C_SCLK(I2C_SCLK),
	.SW(SW[9:6]),
	.trigger(GPIO_1[1]),
	.LEDR(LEDR[9:0]),
	.hit(~KEY[3])
);
		
	wire [8:0] VGAx;
	wire [7:0] VGAy;
	wire [2:0] VGAcolour;  
	wire VGAplot;

	assign VGAx[8:0] = KEY[2] ? posx[8:0] : resetx[8:0];
	assign VGAy[7:0] =  KEY[2] ? posy[7:0] : resety[7:0];
	assign VGAcolour[2:0] =  KEY[2] ? colour[2:0] : resetColour[2:0];
	assign VGAplot =  KEY[2] ? plot : resetplot;
	  
	  
//fill u420(.clock(CLOCK_50), .colour(resetColour[2:0]), .x_pos(resetx[8:0]), .y_pos(resety[7:0]), .go(~KEY[2]), .resetn(KEY[0]), .plot(resetplot));	


	
	 
endmodule

module datapath(
    input clk,
    input resetn, resetCounter,
    input [8:0] x_coordinate,
	 input [7:0] y_coordinate,
	 input draw, triggerIn,
    input ld_x, ld_y, ld_colour,
    input ld_position, count_up,
    output reg [8:0] position_x, //we need an 9 bit output for x
	 output reg [7:0] position_y, //we need a 8 bit output for y
	 output reg [2:0] outColour,
	 output counter1111, triggerOut
    );
    
    // input registers
    reg [8:0] x;
	 reg [7:0] y;
	 reg [2:0] colour;

    // output of the alu
    reg [8:0] current_x;
	 reg [7:0] current_y;

    
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 9'b0; 
				y <= 8'b0; 
				colour <= 3'b0; 
        end
        else begin
            if(ld_x)
                x <= x_coordinate;
            if(ld_y)
                y <= y_coordinate;
            if(ld_colour && draw)
                colour <= triggerOut? 3'b100 : 3'b101;
				if(ld_colour && ~draw)
                colour <= 3'b000;
        end
    end
 
    triggerDetector u454(.triggerIn(triggerIn), .triggerOut(triggerOut), .resetn(resetn), .clock(clk)); 
 
    //X Position register
    always@(posedge clk) begin
        if(!resetn) begin
            position_x <= 9'b0; 
        end
        else 
            if(ld_position)
                position_x <= current_x;
    end
	 
	 //Y Position register
    always@(posedge clk) begin
        if(!resetn) begin
            position_y <= 8'b0; 
        end
        else 
            if(ld_position)
                position_y <= current_y;
    end

	 //Colour Register
	 always@(posedge clk) begin
        if(!resetn) begin
            outColour <= 3'b0; 
        end
        else 
            if(ld_position)
               outColour <= colour[2:0];
    end
	 
	 
	//seven bit counter for 1st rectangle where bits are -yyyyxx
	wire doneY;
	wire [6:0] countY;

	assign doneY = (countY== 7'b1111111)?1'b1:1'b0; 
	sevenBitCounter u4(.clock(clk), .count(countY[6:0]), .enable(count_up & ~doneY), .clear(resetCounter), .reset(~resetn));
	
	
	
	
	//seven Bit counter for second rectangle where bits are -xxxyy
	wire doneX;
	wire [6:0] countX;
	assign doneX = (countX== 7'b1111111)?1'b1:1'b0; 
	sevenBitCounter u44(.clock(clk), .count(countX[6:0]), .enable(count_up & doneY), .clear(resetCounter), .reset(~resetn));
	 
	 
	 
	 assign counter1111 = doneY & doneX; 
    // The position ALU 
    always @(*)
    begin : ALU
		if(!doneY) begin //This case is for the rectangle bigger in the Y direction
		current_x <= ((x[8:0] + countY[1:0]) <= 9'd320)?(x[8:0] + countY[1:0]):x[8:0]; //checks to see if x is out of bounds, if not it assigns the current value of x according to the counter
		current_y <= ((y[7:0] + countY[5:2]) <= 8'd240)?(y[7:0] + countY[5:2]):y[7:0];
		end
		else begin
		current_x <= ((x[8:0] - 9'd6 + countX[5:2]) <= 9'd320)?(x[8:0] - 9'd6 + countX[5:2]):x[8:0]; //checks to see if x is out of bounds, if not it assigns the current value of x according to the counter
		current_y <= ((y[7:0] + 8'd6 + countX[1:0]) <= 8'd240)?(y[7:0] + 8'd6 + countX[1:0]):y[7:0];
		end
    end
    
	 
	 
	 
endmodule

module control(
    input clk,
    input resetn,
    input go,
	 input counter1111, 
	 input [5:0] irInput,
	 input [5:0] targetID,
	 input [24:0] Rcounter,
	 output reg [5:0] hitID,
	 output [9:0] LEDR,
    output reg ld_x, ld_y, ld_colour, draw,
    output reg ld_position, count_up,
	 output reg resetCounter, resetRegisters, plot,
	 output [8:0] x,
	 output [7:0] y
    );

    reg [4:0] current_state, next_state; 
	 reg clearTimer, enableTimer;
    wire oneHertz;
	 reg [7:0] y_coordinate;
	 reg [8:0] x_coordinate;
	 
	 
	 
	 wire [19:0] count20;
	assign oneHertz = (count20== 20'd810000)?1'b1:1'b0;
	twentyBitRegister u200(.clock(clk), .count(count20[19:0]), .clear(oneHertz), .reset(~resetn), .enable(1'b1));

	 aimMover u69420(.x_coordinate(x_coordinate[8:0]), .y_coordinate(y_coordinate[7:0]), .x_out(x[8:0]), .y_out(y[7:0]), .clk(clk), .oneHertz(oneHertz), .resetn(resetn), .freeze(~go));
	 	 
	 assign LEDR [4:0] = current_state [4:0];
	 assign LEDR [9] = go;
	 assign LEDR [7] = resetn;
	 
    localparam  WAIT_1     			= 5'd0,
					 SET_WHITE           = 5'd1,
					 GET_POS             = 5'd2,
					 LOAD_POS_1          = 5'd3, //1 in this case means for drawing the square
					 PLOT_1              = 5'd4,
					 COUNT_UP_1          = 5'd5,
					 WAIT_2              = 5'd6;
					 
					 

    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                WAIT_1: next_state = (Rcounter == 25'd85000)? SET_WHITE : WAIT_1;  //THIS LINE decides when the crosshair is drawn, right now it's drawn when your refresh counter reaches 85,000. See if u can change it to improve flickering            
					 SET_WHITE : next_state = GET_POS;
					 GET_POS: next_state = LOAD_POS_1;
					 LOAD_POS_1 : next_state = PLOT_1 ;
					 PLOT_1 : next_state = COUNT_UP_1  ;
					 COUNT_UP_1  : next_state =  counter1111 ?  WAIT_2 :  LOAD_POS_1; //Keeps loading positions untill counter has reached 1111
					 WAIT_2 : next_state = WAIT_1;
					 
		// we will be done our two operations, start over after
            default:     next_state = WAIT_1;
        endcase
    end // state_table
   

	//Output logic for x irInput
	always @(*)
	begin: squarePosition_x
			case (irInput) //IR input should be calibrated so its: (top-left, top-middle, top-right, bottom-left, bottom-middle,  bottom-right)
			6'b000001 : x_coordinate <= 9'd302;
			6'b000010 : x_coordinate <= 9'd159;
			6'b000100 : x_coordinate <= 9'd10;
			6'b001000 : x_coordinate <= 9'd302;
			6'b010000 : x_coordinate <= 9'd159;
			6'b100000 : x_coordinate <= 9'd10;
			//Next cases are for 2nd row from left
			6'b110000 : x_coordinate <= 9'd79;
			6'b110100 : x_coordinate <= 9'd79;
			6'b110110 : x_coordinate <= 9'd79;
			6'b100110 : x_coordinate <= 9'd79;
			6'b000110 : x_coordinate <= 9'd79;
			//NExt cases are for 2nd row from right
			6'b011000 : x_coordinate <= 9'd239;
			6'b011001 : x_coordinate <= 9'd239;
			6'b011011 : x_coordinate <= 9'd239;
			6'b001011 : x_coordinate <= 9'd239;
			6'b000011 : x_coordinate <= 9'd239;
			//other cases
			6'b100100 : x_coordinate <= 9'd10;
			6'b001001 : x_coordinate <= 9'd302;
			default: x_coordinate <= 9'd159;
		endcase	
	end	
	
	
	//Output logic for y irInput
	always @(*)
	begin: squarePosition_y
			case (irInput) //IR input should be calibrated so its: (top-left, top-middle, top-right, bottom-left, bottom-middle,  bottom-right)
			6'b000001 : y_coordinate <= 8'd222;
			6'b000010 : y_coordinate <= 8'd222;
			6'b000100 : y_coordinate <= 8'd222;
			6'b001000 : y_coordinate <= 8'd10;
			6'b010000 : y_coordinate <= 8'd10;
			6'b100000 : y_coordinate <= 8'd10;
			//Next cases are for 2nd row from left
			6'b110000 : y_coordinate <= 8'd10;
			6'b110100 : y_coordinate <= 8'd112;
			6'b110110 : y_coordinate <= 8'd112;
			6'b100110 : y_coordinate <= 8'd112;
			6'b000110 : y_coordinate <= 8'd222;
			//NExt cases are for 2nd row from right
			6'b011000 : y_coordinate <= 8'd10;
			6'b011001 : y_coordinate <= 8'd112;
			6'b011011 : y_coordinate <= 8'd112;
			6'b001011 : y_coordinate <= 8'd112;
			6'b000011 : y_coordinate <= 8'd222;
			//other cases
			6'b100100 : y_coordinate <= 8'd112;
			6'b001001 : y_coordinate <= 8'd112;
			default: y_coordinate <= 8'd112;
		endcase	
	end	
	
	 reg hertz;
	 
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_colour = 1'b0;
        ld_position = 1'b0;
        resetCounter = 1'b0;
		  resetRegisters = 1'b0;
		  plot = 1'b0;
		  count_up = 1'b0;
		  draw = 1'b0;
		  clearTimer = 1'b0;
		  enableTimer = 1'b0;
		  hertz = 1'b0;

        case (current_state)
				WAIT_1: begin
                resetRegisters = 1'b1;
            end
            SET_WHITE: begin
                draw = 1'b1;
					 ld_colour = 1'b1;
					 resetCounter = 1'b1;
            end
				GET_POS : begin
                ld_x = 1'b1;
					 ld_y = 1'b1;
            end
				LOAD_POS_1 : begin
                ld_position = 1'b1;
            end
				PLOT_1 : begin
					 plot = 1'b1;
                
            end
				COUNT_UP_1 : begin
                count_up = 1'b1;
            end
				WAIT_2: begin
                hertz = 1'b1;
            end
				
				
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

	
	
	//Hit detection always block (top-left, top-middle, top right, bottom-left, bottom- middle, bottom-right)
	always @(*)
	begin: Hit_detection
			case (irInput) //IR input should be calibrated so its: (top-left, top-middle, top-right, bottom-left, bottom-middle,  bottom-right)
			6'b000001 : hitID[0] <= (targetID[0] == 1'b1)? 1'b1 : 1'b0;
			6'b000010 : hitID[1] <= (targetID[1] == 1'b1)? 1'b1 : 1'b0;
			6'b000100 : hitID[2] <= (targetID[2] == 1'b1)? 1'b1 : 1'b0;
			6'b001000 : hitID[3] <= (targetID[3] == 1'b1)? 1'b1 : 1'b0;
			6'b010000 : hitID[4] <= (targetID[4] == 1'b1)? 1'b1 : 1'b0;
			6'b100000 : hitID[5] <= (targetID[5] == 1'b1)? 1'b1 : 1'b0;
			
			default: hitID <= 6'd0;
		endcase	
	end
	
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= WAIT_1;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module sevenBitCounter(clock, count, enable, clear, reset);
	input clock, enable, clear, reset;
	output [6:0] count;
	reg [6:0] count;
	
	//Always block using for 7 bit counter
	always@(posedge clock)
	begin
		if(clear| reset)
			count <= 7'd0;
		else if (enable)
			count <= count + 1'b1;
	end


endmodule

module aimMover(x_coordinate, y_coordinate, x_out, y_out, clk, oneHertz, resetn, freeze);
	input [7:0] y_coordinate;
	input [8:0] x_coordinate;
	input clk, resetn, oneHertz, freeze;
	output[7:0] y_out;
	output [8:0] x_out;
	
	assign x_out = x[8:0];
	assign y_out = y[7:0];
	reg [8:0] speed_x;
	reg [7:0] speed_y;
	
	//Always block for x speed
	always@(*)
		begin //The aiming reticule for x travels at 2p/sec if coordinate differnce is less than 80 pixels, 4p/sec if < 240 pixels, and 6p/sec if > 240
			if (freeze == 1'b1)
				speed_x <= 9'd0;
			else if((x < x_coordinate) && (x_coordinate - x < 9'd240))
				speed_x <= (x_coordinate - x > 9'd80)? 9'd4:9'd2;
			else if((x < x_coordinate) && (x_coordinate - x >= 9'd240))
				speed_x <= 9'd6;
			else if ((x > x_coordinate) && (x - x_coordinate < 9'd240))
				speed_x <= (x - x_coordinate > 9'd80)? 9'd4 : 9'd2;	
			else if ((x > x_coordinate) && (x - x_coordinate >= 9'd240))
				speed_x <= 9'd6;
	end
	
	always@(*)
		begin //the aiming for y travels at 2p/sec if the coordinate differnce is less than 113 pixels or 4p/sec of greater than 113 pixels
			if (freeze == 1'b1)
				speed_y <=9'd0;
			else if(y < y_coordinate)
				speed_y <= (y_coordinate - y > 8'd113)? 8'd4 : 8'd2;
			else if (y > y_coordinate)
				speed_y <= (y - y_coordinate > 8'd113)? 8'd4 : 8'd2;	
	end
	
	
	
	
	reg [8:0] x;
	reg  [7:0] y;
	reg [8:0] update_x;
	reg  [7:0] update_y;
	
	 //Updater for x_cordinate
	 always@(posedge oneHertz)
    begin: x_updater
        if(x < x_coordinate)
            update_x <= (x + 9'd2 > x_coordinate)? x_coordinate : (x + speed_x);
        else if (x > x_coordinate)
            update_x <= (x - 9'd2 < x_coordinate)? x_coordinate : (x - speed_x);
    end 
	 
	//Updater for y_cordinate
	 always@(posedge oneHertz)
    begin: y_updater
		  if (y < y_coordinate)	
				update_y <= (y + 8'd2 >y_coordinate) ? y_coordinate: (y + speed_y );
		  else if (y > y_coordinate)	
				update_y <= (y - 8'd2 < y_coordinate) ? y_coordinate: (y - speed_y);
    end 
	 
	 
	    //X Position register
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 9'b0; 
        end
        else 
            if(oneHertz)
                x <= update_x;
    end
	 
	 //Y Position register
    always@(posedge clk) begin
        if(!resetn) begin
            y <= 8'b0; 
        end
        else 
            if(oneHertz)
                y <= update_y;
    end
	

endmodule 

 
module triggerDetector(triggerIn, triggerOut, resetn, clock);
	input triggerIn, resetn, clock;
	output triggerOut;
	reg [3:0] current_state, next_state, activate; 
	wire timerDone, go;
	
	localparam   WAIT_1     			= 5'd0,
					 TRIGGER_PRESSED     = 5'd1,
					 WAIT_2              = 5'd2;
					
	assign go = triggerIn;	
	assign triggerOut = activate;
	
	//Timer for 0.5s
	wire [24:0] count24;
	assign timerDone = (count24== 25'd50000000)?1'b1:1'b0;
	twentyFiveBitRegister u88(.clock(clock), .count(count24[24:0]), .clear(timerDone), .enable(activate), .reset(~resetn));
	
	//State table
				
	always@(*)
    begin: state_table_2 
            case (current_state)
                WAIT_1: next_state = go ? TRIGGER_PRESSED : WAIT_1;               
					 TRIGGER_PRESSED : next_state = timerDone? WAIT_2 : TRIGGER_PRESSED;
					 WAIT_2 : next_state = go? WAIT_2 : WAIT_1;
            default:     next_state = WAIT_1;
        endcase
    end 
	
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals_2
        // By default make all our signals 0
        activate = 1'b0;

        case (current_state)
            TRIGGER_PRESSED: begin
                activate = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 // current_state registers
    always@(posedge clock)
    begin: state_FFs_2
        if(!resetn)
            current_state <= WAIT_1;
        else
            current_state <= next_state;
    end // state_FFS

endmodule
 
 
 
module twentyBitRegister(clock, count, clear, reset, enable);
	input clock, clear, reset, enable;
	output [19:0] count;
	reg [19:0] count;
	
	//Always block for 20 bit counter
	always@(posedge clock)
	begin
		if(clear| reset)
			count <= 20'd0;
		else if (enable)
			count <= count + 1'b1;
	end
			
			
endmodule
 
module twentyFiveBitRegister(clock, count, clear, reset, enable);
	input clock, clear, reset, enable;
	output [24:0] count;
	reg [24:0] count;
	
	//Always block for 20 bit counter
	always@(posedge clock)
	begin
		if(clear| reset)
			count <= 25'd0;
		else if (enable)
			count <= count + 1'b1;
	end
			
			
endmodule
 
module gunshotSound(trigger, CLOCK_50, audioOut, enable, resetn, LEDR, hit);
	input trigger, CLOCK_50, resetn, hit;
	output [7:0] audioOut;
	output enable;
	reg [16:0] address;
	wire [7:0] RAMoutput;
	reg [10:0] delay_cnt, delay_cnt1;
	wire [10:0] delay;
	reg change, change2, activate;
	reg [3:0] current_state, next_state;
	assign delay = 11'd1133;
	reg resetAddress, enable1;
	//tmp
	output [9:0] LEDR;
	assign LEDR [3:0] = current_state;
	assign LEDR [8] = trigger;
	assign LEDR [9] = enable;
	
	// gunshot registers
	always @(posedge CLOCK_50)
		if(~activate)begin
			delay_cnt <= 1'b0;
			change <= 1'b0;
			end
		else if(delay_cnt == delay) begin
			delay_cnt <= 0;
			change <= 1'b1;
		end 
		else begin
			delay_cnt <= delay_cnt + 1;
			change <= 1'b0;
		end
		
	always @(posedge change)
	begin
		if(activate & ~resetAddress)
			address <= address + 17'd1;
		else
			address <= 17'd17860;
	end
	
	//gorilla registers
	always @(posedge CLOCK_50)
		if(~activate)begin
			delay_cnt1 <= 1'b0;
			change2 <= 1'b0;
			end
		else if(delay_cnt1 == delay) begin
			delay_cnt1 <= 0;
			change2 <= 1'b1;
		end 
		else begin
			delay_cnt1 <= delay_cnt1 + 1;
			change2 <= 1'b0;
		end
		
	always @(posedge change2)
	begin
		if(activate & ~resetAddress2)
			address2 <= address2 + 18'd1;
		else
			address2 <= 18'd0;
	end
	
	
	localparam   WAIT_1     			= 3'd0,
					 PLAY_SOUND    		= 3'd1,
					 PLAY_SOUND1    		= 3'd2,
					 
					 PLAY_SOUND2    		= 3'd3,
					 WAIT_2					= 3'd4;
					
	//State table
				
	always@(*)
    begin: state_table_2 
            case (current_state)
                WAIT_1: next_state = trigger ? (hit ? PLAY_SOUND1 : PLAY_SOUND) : WAIT_1;               
					 PLAY_SOUND : next_state = (address == 17'd89855)?  WAIT_2 : PLAY_SOUND;
					 PLAY_SOUND1 : next_state = (address == 17'd89855)?  PLAY_SOUND2: PLAY_SOUND1; 
					 PLAY_SOUND2 : next_state = (address2 == 18'd91046)? WAIT_2 : PLAY_SOUND2;
					 WAIT_2: next_state = trigger ? WAIT_2 : WAIT_1;
            default:     next_state = WAIT_1;
        endcase
    end 
	
	reg resetAddress2;
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals_2
        // By default make all our signals 0
        activate = 1'b1;
		  
		  resetAddress = 1'b0;
		  resetAddress2 = 1'b0;
		  enable1 = 1'b0;
        case (current_state)
				WAIT_1: begin
				resetAddress = 1'b1;
				resetAddress2 = 1'b1;
				end
				PLAY_SOUND : begin
				enable1 = 1'b1;
				resetAddress2 = 1'b1;
				end
				PLAY_SOUND1 : begin
				enable1 = 1'b1;
				resetAddress2 = 1'b1;
				end
				PLAY_SOUND2 : begin
				enable1 = 1'b1;
				
				end
				WAIT_2: begin
                resetAddress = 1'b1;
					 resetAddress2 = 1'b1;
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
	 
	 // current_state registers
    always@(posedge CLOCK_50)
    begin: state_FFs_2
        if(!resetn)
            current_state <= WAIT_1;
        else
            current_state <= next_state;
    end // state_FFS
	
	gunRAM h34(
	.address(address[16:0]),
	.clock(CLOCK_50),
	.data(16'b0),
	.wren(1'b0),
	.q(RAMoutput[7:0]));
	
	/*
	gorillaRAM h334(
	.address(address2[16:0]),
	.clock(CLOCK_50),
	.data(16'b0),
	.wren(1'b0),
	.q(RAMoutput2[7:0]));
	*/
	
	reg [16:0] address2;
	wire [7:0] RAMoutput2;
	
	
	assign audioOut = RAMoutput[7:0];
	assign enable = enable1;
	
	

endmodule  
 

 
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
