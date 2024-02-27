module movingFace(iResetn, iClock, enable, oX, oY, oColour, oPlot, won, lose);
   parameter X_SCREEN_PIXELS	= 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire 	    iClock, won, lose;
	input wire iResetn, enable;
   output wire [7:0] oX;         
   output wire [6:0] oY;

   output wire [2:0] oColour;    
   output wire oPlot;      
	
	wire [7:0] x_coord;
	wire [6:0] y_coord;
	wire doneFrames, plot, startCount, y_count, clear, inc;
	
	control_mf C(iClock, iResetn, enable, doneFrames, oX, oY, x_coord, y_coord, oPlot, plot, startCount, y_count, clear, inc);
	datapath_mf D(iClock, iResetn, plot, oPlot, startCount, clear, inc, y_count, x_coord, y_coord, oX, oY, oColour, doneFrames, won, lose);

endmodule

module control_mf(iClock, iResetn, enable, doneFrames, oX, oY, x_coord, y_coord, oPlot, plot, startCount, y_count, clear, inc);
    input iClock, enable,doneFrames;
    input iResetn;
	 input [7:0] oX, x_coord;
	 input [6:0] oY, y_coord;
	 
    output reg oPlot, plot, startCount, y_count, clear, inc;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    reg [2:0] current_state, next_state;

    localparam  S_IDLE = 3'd0,
					 S_DRAW = 3'd1,
					 S_FINISHBOX = 3'd2,
					 S_WAIT = 3'd3,
					 S_CLEAR = 3'd4,
					 S_INC = 3'd5;
	
   
    always@(*)
    begin: state_table
            case (current_state)
                S_IDLE: next_state = enable == 1'b1 ? S_DRAW : S_IDLE;
					 S_DRAW: next_state = doneFrames == 1'b1 ? S_FINISHBOX : S_DRAW;
					 S_FINISHBOX: next_state = (oX - x_coord == 8'd0) &&  (oY - y_coord == 7'd0) ? S_CLEAR : S_FINISHBOX;
					 S_CLEAR: next_state = (oX - x_coord == 8'd14) &&  (oY - y_coord == 7'd14) ? S_WAIT : S_CLEAR;
					 S_WAIT: next_state = (oX - x_coord == 8'd4) && (oY - y_coord == 7'd4) ? S_INC : S_WAIT;
					 S_INC: next_state = S_IDLE;
				
            default:     next_state = S_IDLE;
        endcase
    end 

  
    always @(*)
    begin: enable_signals
    
		  oPlot = 1'b0;
		  plot = 1'b0;
		  startCount = 1'b1;
		  y_count = 1'b0;
		  clear = 1'b0;
		  inc = 1'b0;

        case (current_state)
            S_IDLE: begin
                oPlot = 1'b0;
                end
				S_DRAW: begin
					 oPlot = 1'b1;
					 plot = 1'b1;
					 startCount = 1'b0;
					 y_count = 1'b1;
					end
				S_FINISHBOX: begin
					oPlot = 1'b1;
					 plot = 1'b1;
					end
				S_CLEAR: begin
					oPlot = 1'b1;
					clear = 1'b1;
				end
				S_WAIT: begin
					oPlot = 1'b1;
					clear = 1'b1;
				end
				S_INC: begin
					inc = 1'b1;
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

module frameCounter(iClock, iResetn, startCount, doneCount, doneFrames);
	input iClock, iResetn, startCount, doneCount;
	output wire doneFrames;
	
	reg [26:0] framesLeft;
	
	always@(posedge iClock) begin
		if (startCount == 1'b1) 
			framesLeft <= 26'd50000000;
		else
			framesLeft = framesLeft - 1'b1;
	end

	assign doneFrames = framesLeft == 1'b0 ? 1'b1 : 1'b0;
	
endmodule

module delayCounter(iClock, iResetn, startCount, doneCount);

	input iClock, iResetn, startCount;
	output wire doneCount;
	
	wire [25:0] clock_freq;
	assign clock_freq = 26'd50000000;
	reg [26:0] downCount;
	
	always@(posedge iClock) begin
		if (startCount == 1'b1 || downCount == 27'b0) begin
			downCount <= clock_freq;
		end
		else
			downCount <= downCount - 1'b1;
	end
	
	assign done_count = downCount == 27'b0 ? 1'b1 : 1'b0;

endmodule  

module y_coordinate(iClock, iResetn, inc, y_coord);
	input iClock, iResetn, inc;
	output reg [6:0] y_coord;
	reg direction;
	
	always@(posedge iClock) begin
		if(iResetn == 1'b0) begin
			y_coord <= 7'd80;
			direction <= 1'b0;
		end
		else if(iResetn == 1'b1) begin
			if (y_coord == 7'd100)
				direction <= 1'b1;
			if (y_coord == 7'd68)
				direction <= 1'b0;
			if (inc == 1'b1) begin
				if(direction == 1'b0) 
					y_coord <= y_coord + 1'b1;
				else if (direction == 1'b1)
					y_coord <= y_coord - 1'b1;
			end
		end
	end

endmodule

module datapath_mf(iClock, iResetn, plot, oPlot, startCount, clear, inc, y_count, x_coord, y_coord, oX, oY, oColour, doneFrames, won, lose);
    input iClock, iResetn, plot, y_count, startCount, clear, inc, won, lose;
	 input oPlot;
	 
	 output wire [6:0] y_coord;
	 output reg [7:0] x_coord;

    output reg [7:0] oX;
	 output reg [6:0] oY;
	 output reg [2:0] oColour;
	 output doneFrames;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	 
	reg  [2:0] colour;
	wire doneCount;
	wire [6:0] Ycoord;
	assign y_coord = Ycoord;
	wire [7:0] df_x, db_x;
	wire [6:0] df_y, db_y;
	wire [2:0] df_colour, db_colour;
	reg face;
	
	frameCounter fc(iClock, iResetn, startCount, doneCount, doneFrames);
	delayCounter dc(iClock, iResetn, startCount, doneCount);
	y_coordinate y0(iClock, iResetn, inc, Ycoord);
	displayFaces df0(iClock, iResetn, x_coord, Ycoord, face, plot, df_x, df_y, df_colour);
	dynamicBox u0(iClock, iResetn, x_coord, Ycoord, 3'd0, 8'd15, 7'd15, clear, db_x, db_y, db_colour);
	always@(oPlot, plot, clear) begin
		if(oPlot == 1'b1) begin
			if (plot == 1'b1) begin
					x_coord <= 8'd72;
			end
			else if (clear == 1'b1)
				colour = 3'd0;
		end
		else
			colour = 3'd0;
	end
	
	always@(posedge iClock) begin
		if(oPlot == 1'b1) begin
			if (plot == 1'b1) begin
				oX <= df_x;
				oY <= df_y;
				oColour <= df_colour;
			end
			else begin
				oX <= db_x;
				oY <= db_y;
				oColour <= db_colour;
			end
		if (won == 1'b1) 
			face <= 1'b0;
		if (lose == 1'b1) 
			face <= 1'b1;
		end
	end
	 

endmodule
