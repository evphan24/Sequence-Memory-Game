module sequenceGame(iResetn, iClock, start, oX, oY, oColour, oPlot, key0, key1, key2, key3, level);
   parameter X_SCREEN_PIXELS	= 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire 	    iClock, key0, key1, key2, key3;
	input wire iResetn, start;
   output wire [7:0] oX;        
   output wire [6:0] oY;

   output wire [2:0] oColour;     
   output wire 	     oPlot;     
	
	wire plotSquares, grid_drawn, done_pattern, startPattern, startInput, done_input, clear, won, lost, lose;
	output wire [3:0] level;
	
	control c0(iResetn, iClock, start, grid_drawn, done_pattern, done_input, lost, oX, oY, plotSquares, startPattern, level, startInput, clear, won, lose);
	datapath d0(iResetn, iClock, plotSquares, startPattern, startInput, key0, key1, key2, key3, clear, won, lose, level, oPlot, oX, oY, oColour, grid_drawn, done_pattern, done_input, lost);

endmodule

module control(iResetn, iClock, start, grid_drawn, done_pattern, done_input, lost, oX, oY, plotSquares, startPattern, level, startInput, clear, won, lose);
	input iResetn, iClock, start, grid_drawn, done_pattern, done_input, lost;
	input [7:0] oX;
	input [6:0] oY;
	
	
	output reg plotSquares, startPattern, startInput, clear, won, lose;
	output reg [3:0] level;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    reg [3:0] current_state, next_state;

    localparam  S_IDLE = 4'd0,
					 S_WAIT = 4'd1,
					 S_SQUARES = 4'd2,
					 S_DISPLAY1 = 4'd3,
					 S_INPUT1 = 4'd4,
					 S_CLEAR = 4'd5,
					 S_WON = 4'd6,
					 S_CLEAR2 = 4'd7,
					 S_LCLEAR = 4'd8,
					 S_LOST = 4'd9,
					 S_LCLEAR2 = 4'd10,
					 S_DISPLAY2 = 4'd11,
					 S_INPUT2 = 4'd12;
	
    
    always@(*)
    begin: state_table
            case (current_state)
                S_IDLE: next_state = start == 1'b0 ? S_WAIT : S_IDLE;
					 S_WAIT: next_state = start == 1'b1 ? S_SQUARES : S_WAIT;
					 S_SQUARES: next_state = grid_drawn == 1'b1 ? S_DISPLAY1 : S_SQUARES;
					 S_DISPLAY1: next_state = done_pattern == 1'b1 ? S_INPUT1 : S_DISPLAY1;
					 S_INPUT1: begin
							if (done_input == 1'b1)
								next_state = S_DISPLAY2;
							else if (lost == 1'b1)
								next_state = S_LCLEAR;
							else
								next_state = S_INPUT1;
						end
					 S_CLEAR: next_state = (oX == 8'd155) && (oY == 7'd115) ? S_WON : S_CLEAR;
					 S_WON: next_state = start == 1'b1 ? S_CLEAR2 : S_WON;
					 S_CLEAR2: next_state = (oX == 8'd155) && (oY == 7'd115) ? S_WAIT : S_CLEAR2;
					 S_LCLEAR: next_state = (oX == 8'd155) && (oY == 7'd115) ? S_LOST : S_LCLEAR;
					 S_LOST: next_state = start == 1'b1 ? S_LCLEAR2 : S_LOST;
					 S_LCLEAR2: next_state = (oX == 8'd155) && (oY == 7'd115) ? S_WAIT : S_LCLEAR2;
					 S_DISPLAY2: next_state = done_pattern == 1'b1 ? S_INPUT2 : S_DISPLAY2;
					 S_INPUT2: begin
							if (done_input == 1'b1)
								next_state = S_CLEAR;
							else if (lost == 1'b1)
								next_state = S_LCLEAR;
							else
								next_state = S_INPUT2;
						end
            default:     next_state = S_IDLE;
        endcase
    end 

  
    always @(*)
    begin: enable_signals
		  plotSquares = 1'b0;
		  startPattern = 1'b0;
		  startInput = 1'b0;
		  clear = 1'b0;
		  won = 1'b0;
		  lose = 1'b0;

        case (current_state)
            S_IDLE: begin
					level = 4'd0;
                end
				S_WAIT: begin
					end
				S_SQUARES: begin
					plotSquares = 1'b1;
					end
				S_DISPLAY1: begin
					startPattern = 1'b1;
					level = 4'd1;
					end
				S_INPUT1: begin
					startInput = 1'b1;
					level = 4'd1;
					end
				S_CLEAR: begin
					clear = 1'b1;
					level = 4'd1;
				end
				S_WON: begin
					won = 1'b1;
				end
				S_CLEAR2: begin
					clear = 1'b1;
					level = 4'd1;
				end
				S_LCLEAR: begin
					clear = 1'b1;
					level = 4'd1;
				end
				S_LOST: begin;
					lose = 1'b1;
				end
				S_LCLEAR2: begin
					clear = 1'b1;
					level = 4'd1;
				end
				S_DISPLAY2: begin
					startPattern = 1'b1;
					level = 4'd2;
				end
				S_INPUT2: begin
					startInput = 1'b1;
					level = 4'd2;
				end
       
        endcase
    end 

  
    always@(posedge iClock)
    begin: state_FFs
        if(iResetn == 1'b0)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end 
endmodule 

module datapath(iResetn, iClock, plotSquares, startPattern, startInput, key0, key1, key2, key3, clear, won, lose, level, oPlot, oX, oY, oColour, grid_drawn, done_pattern, done_input, lost);
	input iResetn, iClock, plotSquares, startPattern, startInput, key0, key1, key2, key3, clear, won, lose;
	input [3:0] level;
	output reg oPlot;
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	output wire grid_drawn, done_pattern, done_input, lost;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	 
	 wire [7:0] squares_x, pattern_x, input_x, box_x, mf_x;
	 wire [6:0] squares_y, pattern_y, input_y, box_y, mf_y;
	 wire [2:0] squares_colour, pattern_colour, input_colour, box_colour, mf_colour;
	 wire squares_plot, pattern_plot, input_plot, mf_plot;
	 reg face, enable;
	 
	 squaresGrid s0(iResetn, iClock, plotSquares, squares_x, squares_y, squares_colour, squares_plot, grid_drawn);
	 displayPattern dp0(iResetn, iClock, startPattern, level, pattern_x, pattern_y, pattern_colour, pattern_plot, done_pattern);
	 patternInput pi0(iResetn, iClock, startInput, level, input_x, input_y, input_colour, input_plot, key0, key1, key2, key3, lost, done_input);
	 dynamicBox DB2(iClock, iResetn, 8'd0, 7'd48, 3'd0, 8'd160, 7'd72, clear, box_x, box_y, box_colour);
	 movingFace mf0(iResetn, iClock, enable, mf_x, mf_y, mf_colour, mf_plot, won, lose);
	 
	always@(posedge iClock) begin
		if (plotSquares == 1'b1) begin
			oX <= squares_x;
			oY <= squares_y;
			oColour <= squares_colour;
			oPlot <= squares_plot;
		end
		else if (startPattern == 1'b1) begin
			oX <= pattern_x;
			oY <= pattern_y;
			oColour <= pattern_colour;
			oPlot <= pattern_plot;
		end
		else if (startInput == 1'b1) begin
			oX <= input_x;
			oY <= input_y;
			oColour <= input_colour;
			oPlot <= input_plot;
		end
		else if (clear == 1'b1) begin
			oX <= box_x;
			oY <= box_y;
			oColour <= box_colour;
			oPlot <= clear;
		end
		else if (won == 1'b1) begin
			oX <= mf_x;
			oY <= mf_y;
			oColour <= mf_colour;
			oPlot <= won;
			enable <= 1'b1;
		end
		else if (lose == 1'b1) begin
			oX <= mf_x;
			oY <= mf_y;
			oColour <= mf_colour;
			oPlot <= lose;
			enable <= 1'b1;
		end
		else 
			oPlot <= 1'b0;
	end
	 

endmodule
