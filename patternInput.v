module patternInput(iResetn, iClock, start, level, oX, oY, oColour, oPlot, key0, key1, key2, key3, lost, done);

	parameter X_SCREEN_PIXELS	= 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire 	    iClock, key0, key1, key2, key3;
	input wire [3:0] level;
	input wire iResetn, start;
   output wire [7:0] oX;        
   output wire [6:0] oY;

   output wire [2:0] oColour;    
   output wire 	     oPlot, done, lost;    
	
	wire plot1, clear, plot2;
	wire [7:0] x_coord;
	wire [6:0] y_coord;
	
	control_input ci(iResetn, iClock, start, level, key0, key1, key2, key3, oX, oY, x_coord, y_coord, lost, done, plot1, plot2, clear);
	datapath_input di(iResetn, iClock, oPlot, plot1, plot2, clear, oX, oY, oColour, x_coord, y_coord);

endmodule 

module control_input(iResetn, iClock, start, level, key0, key1, key2, key3, oX, oY, x_coord, y_coord, lost, done, plot1, plot2, clear);
	input iResetn, iClock, start, key0, key1, key2, key3;
	input [3:0] level;
	input [7:0] oX, x_coord;
	input [6:0] oY, y_coord;
	output reg lost, done, plot1, clear, plot2;


    reg [3:0] current_state, next_state;
	 reg [4:0] squares;

    localparam  S_IDLE = 4'd0,
					 S_BOX1 = 4'd1,
					 S_DISPLAY1 = 4'd2,
					 S_LOST = 4'd3,
					 S_DONE = 4'd4,
					 S_CLEAR = 4'd5,
					 S_WAIT = 4'd6,
					 S_WAIT2 = 4'd7,
					 S_BOX2 = 4'd8,
					 S_DISPLAY2 = 4'd9,
					 S_WAIT3 = 4'd10,
					 S_CLEAR2 = 4'd11,
					 S_WAIT4 = 4'd12;
	
   
    always@(*)
    begin: state_table
            case (current_state)
                S_IDLE: next_state = start == 1'b1 ? S_BOX1 : S_IDLE;
					 S_BOX1: begin
							if (key1 == 1'b0)
								next_state = S_DISPLAY1;
							else if (key0 == 1'b0 || key2 == 1'b0 || key3 == 1'b0)
								next_state = S_LOST;
							else
								next_state = S_BOX1;
						end
					 S_DISPLAY1: next_state = key1 == 1'b1 ? S_WAIT : S_DISPLAY1;
					 S_WAIT: next_state = (oX - x_coord == 8'd0) && (oY - y_coord == 7'd0) ? S_CLEAR : S_WAIT;
					 S_LOST: next_state = S_DONE;
					 S_CLEAR: next_state = (oX - x_coord == 8'd23) && (oY - y_coord == 7'd23) ? S_WAIT2 : S_CLEAR;
					 S_WAIT2:  
						if ((oX - x_coord == 8'd20) && (oY - y_coord == 7'd20)) begin
							if (squares == level) 
								next_state = S_DONE;
							else
								next_state = S_BOX2;
						end
						else 
							next_state = S_WAIT2;
					 S_BOX2: begin
							if (key2 == 1'b0)
								next_state = S_DISPLAY2;
							else if (key0 == 1'b0 || key1 == 1'b0 || key3 == 1'b0)
								next_state = S_LOST;
							else
								next_state = S_BOX2;
						end
					S_DISPLAY2: next_state = key2 == 1'b1 ? S_WAIT3 : S_DISPLAY2;
					S_WAIT3: next_state = (oX - x_coord == 8'd0) && (oY - y_coord == 7'd0) ? S_CLEAR2 : S_WAIT3; 
					S_CLEAR2: next_state = (oX - x_coord == 8'd23) && (oY - y_coord == 7'd23) ? S_WAIT4 : S_CLEAR2;
					S_WAIT4: 
						if ((oX - x_coord == 8'd20) && (oY - y_coord == 7'd20)) begin
							if (squares == level) 
								next_state = S_DONE;
							else
								next_state = S_DONE;
						end
						else 
							next_state = S_WAIT4;
					 S_DONE: next_state = S_IDLE;
				
            default:     next_state = S_IDLE;
        endcase
    end

 
    always @(*)
    begin: enable_signals
   
		  lost = 1'b0;
		  plot1 = 1'b0;
		  clear = 1'b0;
		  done = 1'b0;
		  plot2 = 1'b0;

        case (current_state)
            S_IDLE: begin
					squares = 4'd0;
					end
				S_BOX1: begin
					squares = 4'd1;
					end
				S_DISPLAY1: begin
					plot1 = 1'b1;
					squares = 4'd1;
					end
				S_WAIT: begin
					plot1 = 1'b1;
					squares = 4'd1;
					end
				S_WAIT2: begin
					plot1 = 1'b1;
					clear = 1'b1;
					squares = 4'd1;
					end
				S_LOST: begin
					lost = 1'b1;
					squares = 4'd0;
					end
				S_CLEAR: begin
					plot1 = 1'b1;
					clear = 1'b1;
					squares = 4'd1;
					end
				S_DONE: begin
					done = 1'b1;
					squares = 4'd0;
					end
				S_BOX2: begin
					squares = 4'd2;
					end
				S_DISPLAY2: begin
					plot2 = 1'b1;
					squares = 4'd2;
					end
				S_WAIT3: begin
					plot2 = 1'b1;
					squares = 4'd2;
					end
				S_CLEAR2: begin
					plot2 = 1'b1;
					clear = 1'b1;
					squares = 4'd2;
					end
				S_WAIT4: begin
					plot2 = 1'b1;
					clear = 1'b1;
					squares = 4'd2;
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

module datapath_input(iResetn, iClock, oPlot, plot1, plot2, clear, oX, oY, oColour, x_coord, y_coord);
	input iResetn, iClock, plot1, clear, plot2;
	output reg oPlot;
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	 
	output reg [7:0] x_coord;
	output reg [6:0] y_coord;
	reg [2:0] iColour;
	reg plot;
	wire [7:0] box_x;
	wire [6:0] box_y;
	wire [2:0] box_colour;
	reg [7:0] x_b;
	reg [6:0] y_b;
	 
	dynamicBox D0(iClock, iResetn, x_coord, y_coord, iColour, 8'd24, 7'd24, plot, box_x, box_y, box_colour);
	always@(plot1, clear, plot2) begin
		if (plot1 == 1'b1) begin
			if (clear == 1'b1) 
				iColour = 3'd7;
			else
				iColour = 3'd5;
			oPlot = plot1;
			plot = plot1;
			x_coord = 8'd68;
			y_coord = 7'd84;
		end
		else if (plot2 == 1'b1) begin
			if (clear == 1'b1) 
				iColour = 3'd7;
			else
				iColour = 3'd5;
			oPlot = plot2;
			plot = plot2;
			x_coord = 8'd68;
			y_coord = 7'd54;
		end
		else begin
			oPlot <= 1'b0;
			plot <= 1'b0;
			iColour <= 3'd0;
		end
	end
	
	always@(posedge iClock) begin
		if (plot1 == 1'b1 || clear == 1'b1 || plot2 == 1'b1) begin
			oX <= box_x;
			oY <= box_y;
			oColour <= box_colour;
		end
	end
	 

endmodule 





