module squaresGrid(iResetn, iClock, enable, oX, oY, oColour, oPlot, done);
   parameter X_SCREEN_PIXELS	= 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire 	    iClock;
	input wire iResetn, enable;
   output wire [7:0] oX;         
   output wire [6:0] oY;

   output wire [2:0] oColour;   
   output wire oPlot, done;      
	
	wire [7:0] x_coord;
	wire [6:0] y_coord;
	wire plot1, plot2, plot3, plot4;
	
   control_sq #(X_SCREEN_PIXELS, Y_SCREEN_PIXELS) u5(iClock, iResetn, enable, oX, oY, x_coord, y_coord, oPlot, plot1, plot2, plot3, plot4, done);
	
	datapath_sq #(X_SCREEN_PIXELS, Y_SCREEN_PIXELS) u6(iClock, iResetn, plot1, plot2, plot3, plot4, oPlot, x_coord, y_coord, oX, oY, oColour);

endmodule 

module control_sq(iClock, iResetn, enable, oX, oY, x_coord, y_coord, oPlot, plot1, plot2, plot3, plot4, done);
    input iClock, enable;
    input iResetn;
	 input [7:0] oX, x_coord;
	 input [6:0] oY, y_coord;
	 
    output reg oPlot, done;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    reg [2:0] current_state, next_state;

    localparam  S_IDLE = 3'd0,
					 S_BOX1 = 3'd1,
					 S_BOX2 = 3'd2,
					 S_BOX3 = 3'd3,
					 S_BOX4 = 3'd4,
					 S_DONE = 3'd5;
	
    always@(*)
    begin: state_table
            case (current_state)
                S_IDLE: next_state = enable == 1'b1 ? S_BOX1 : S_IDLE;
					 S_BOX1: next_state = (oX - x_coord == 8'd23) && (oY - y_coord == 7'd23) ? S_BOX2: S_BOX1;
					 S_BOX2: next_state = (oX - x_coord == 8'd23) && (oY - y_coord == 7'd23) ? S_BOX3 : S_BOX2;
					 S_BOX3: next_state = (oX - x_coord == 8'd23) && (oY - y_coord == 7'd23) ? S_BOX4 : S_BOX3;
					 S_BOX4: next_state = (oX - x_coord == 8'd23) && (oY - y_coord == 7'd23) ? S_DONE : S_BOX4;
					 S_DONE: next_state = S_IDLE;
					
            default:     next_state = S_IDLE;
        endcase
    end 
	
	output reg plot1, plot2, plot3, plot4;


    always @(*)
    begin: enable_signals
       
		  oPlot = 1'b0;
		  plot1 = 1'b0;
		  plot2 = 1'b0;
		  plot3 = 1'b0;
		  plot4 = 1'b0;
		  done = 1'b0;

        case (current_state)
            S_IDLE: begin
                oPlot = 1'b0;
                end
				S_BOX1: begin
					oPlot = 1'b1;
					plot1 = 1'b1;
					end
				S_BOX2: begin
					oPlot = 1'b1;
					plot2 = 1'b1;
					end
				S_BOX3: begin
					oPlot = 1'b1;
					plot3 = 1'b1;
					end
				S_BOX4: begin
					oPlot = 1'b1;
					plot4 = 1'b1;
					end
				S_DONE: begin
					done = 1'b1;
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

module datapath_sq(iClock, iResetn, plot1, plot2, plot3, plot4, oPlot, x_coord, y_coord, oX, oY, oColour);
    input iClock, iResetn, plot1, plot2, plot3, plot4;
	 input oPlot;
	 
	 output reg [6:0] y_coord;
	 output reg [7:0] x_coord;

    output [7:0] oX;
	 output [6:0] oY;
	 output [2:0] oColour;
	 
	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	 
	reg  [2:0] colour;
	 
	 dynamicBox u0(iClock, iResetn, x_coord, y_coord, colour, 8'd24, 7'd24, oPlot, oX, oY, oColour);
	always@(oPlot, plot1, plot2, plot3, plot4) begin
		if(oPlot == 1'b1) begin
			if (plot1 == 1'b1) begin
					x_coord <= 8'd38;
					y_coord <= 7'd69;
					colour = 3'd7;
			end
				else if (plot2 == 1'b1) begin
					x_coord <= 8'd68;
					y_coord <= 7'd54;
					colour = 3'd7;
				end
				else if (plot3 == 1'b1) begin
					x_coord <= 8'd68;
					y_coord <= 7'd84;
					colour = 3'd7;
				end
				else if (plot4 == 1'b1) begin
					x_coord <= 8'd98;
					y_coord <= 7'd69;
					colour = 3'd7;
				end
			end
		else
			colour = 3'd0;
	end
	 

endmodule
