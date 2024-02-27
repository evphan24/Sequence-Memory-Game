module displayPattern(iResetn, iClock, start, level, oX, oY, oColour, oPlot, done);
   parameter X_SCREEN_PIXELS	= 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire 	    iClock;
	input wire [3:0] level;
	input wire iResetn, start;
   output wire [7:0] oX;        
   output wire [6:0] oY;

   output wire [2:0] oColour;     
   output wire 	     oPlot, done;       
	
	wire plot1, enable, speed, done_count, clear, plot2;
	
	counter C0(iResetn, iClock, speed, enable, done_count, level);
	control_pattern cp(iResetn, iClock, start, done_count, level, done, plot1, enable, speed, clear, plot2);
	datapath_pattern dp(iResetn, iClock, plot1, plot2, clear, oPlot, oX, oY, oColour);

endmodule

module control_pattern(iResetn, iClock, start, done_count, level, done, plot1, enable, speed, clear, plot2);
	input iResetn, iClock, start, done_count;
	input [3:0] level;
	output reg done, plot1, clear, plot2;
	output reg enable, speed;


    reg [3:0] current_state, next_state;
	 reg [3:0] squares;

    localparam  S_IDLE = 4'd0,
					 S_WAIT = 4'd1,
					 S_BOX1 = 4'd2,
					 S_CLEAR1 = 4'd3,
					 S_DONE = 4'd4,
					 S_BOX2 = 4'd5,
   				 S_CLEAR2 = 4'd6;
	
    always@(*)
    begin: state_table
            case (current_state)
                S_IDLE: next_state = start == 1'b1 ? S_WAIT : S_IDLE;
					 S_WAIT: next_state = done_count == 1'b1 ? S_BOX1 : S_WAIT;
					 S_BOX1: next_state = done_count == 1'b1 ? S_CLEAR1 : S_BOX1;
					 S_CLEAR1: begin
							if (done_count == 1'b1) begin
								if (squares == level) 
									next_state = S_DONE;
								else 
									next_state = S_BOX2;
							end
							else
								next_state = S_CLEAR1;
						end
					S_BOX2: next_state = done_count == 1'b1 ? S_CLEAR2 : S_BOX2;
					S_DONE: next_state = S_IDLE;
					S_CLEAR2: begin
							if (done_count == 1'b1) begin
								if (squares == level) 
									next_state = S_DONE;
								else 
									next_state = S_DONE;
							end
							else
								next_state = S_CLEAR2;
						end
					
            default:     next_state = S_IDLE;
        endcase
    end 


    always @(*)
    begin: enable_signals
     
		  plot1 = 1'b0;
		  plot2 = 1'b0;
		  enable = 1'b1;
		  speed = 1'b0;
		  squares = 4'd0;
		  clear = 1'b0;
		  done = 1'b0;

        case (current_state)
            S_IDLE: begin
					squares = 4'd0;
					speed = 1'b0;
                end
				S_WAIT: begin
					speed = 1'b1;
					enable = 1'b0;
					end
				S_BOX1: begin
					plot1 = 1'b1;
					speed = 1'b0;
					enable = 1'b0;
					squares = 4'd1;
					end
				S_CLEAR1: begin
					speed = 1'b1;
					squares = 4'd1;
					clear = 1'b1;
					plot1 = 1'b1;
					enable = 1'b0;
					end
				S_DONE: begin
					done = 1'b1;
					end
				S_BOX2: begin
					plot2 = 1'b1;
					speed = 1'b0;
					enable = 1'b0;
					squares = 4'd2;
				end
				S_CLEAR2: begin
					speed = 1'b1;
					squares = 4'd2;
					clear = 1'b1;
					plot2 = 1'b1;
					enable = 1'b0;
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

module counter(iResetn, iClock, speed, enable, done_count, level);
	input iResetn, iClock, enable;
	input speed;
	input [3:0] level;
	output done_count;

	wire [25:0] clock_freq;
	assign clock_freq = 26'd50000000;
	reg [26:0] downCount;
	
	always@(posedge iClock) begin
		if (enable == 1'b1 || downCount == 27'b0) begin
			if(level == 4'd1) begin
				if (speed == 1'b0) 
					downCount <= clock_freq - 1'b1;
				else if (speed == 1'b1)
					downCount <= clock_freq * 2'd2 - 1'b1;
			end
			else if (level == 4'd2) begin
				if (speed == 1'b0) 
					downCount <= clock_freq - (clock_freq / 5'd20) - 1'b1;
				else if (speed == 1'b1)
					downCount <= clock_freq - (clock_freq / 5'd20) * 2'd2 - 1'b1;
			end
		end
		else
			downCount <= downCount - 1'b1;
	end
	
	assign done_count = downCount == 27'b0 ? 1'b1 : 1'b0;

endmodule

module datapath_pattern(iResetn, iClock, plot1, plot2, clear, oPlot, oX, oY, oColour);
	input iResetn, iClock, plot1, plot2, clear;
	output reg oPlot;
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	 
	reg [7:0] x_coord, x_size;
	reg [6:0] y_coord, y_size;
	reg [2:0] iColour;
	reg plot;
	wire [7:0] box_x;
	wire [6:0] box_y;
	wire [2:0] box_colour;
	 
	dynamicBox D0(iClock, iResetn, x_coord, y_coord, iColour, 8'd24, 7'd24, plot, box_x, box_y, box_colour);
	always@(plot1, plot2, clear) begin
		if (plot1 == 1'b1) begin
			if (clear == 1'b1) 
				iColour <= 3'd7;
			else
				iColour <= 3'd1;
			oPlot <= plot1;
			plot <= plot1;
			x_coord <= 8'd68;
			y_coord <= 7'd84;
			end
		else if (plot2 == 1'b1) begin
			if (clear == 1'b1) 
				iColour <= 3'd7;
			else 
				iColour <= 3'd1;
			oPlot <= plot2;
			plot <= plot2;
			x_coord <= 8'd68;
			y_coord <= 7'd54;
		end
		else begin
			oPlot <= 1'b0;
			plot <= 1'b0;
			iColour <= 3'd0;
		end
	end
	
	always@(posedge iClock) begin
		if (plot1 == 1'b1 || plot2 == 1'b1) begin
			oX <= box_x;
			oY <= box_y;
			oColour <= box_colour;
		end
	end
	 

endmodule 

