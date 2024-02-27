module dynamicBox(iClock, iResetn, x_coord, y_coord, iColour, x_size, y_size, plot, oX, oY, oColour);
	input iClock, iResetn;
	input [7:0] x_coord;
	input [6:0] y_coord;
	input [2:0] iColour;
	input [7:0] x_size;
	input [6:0] y_size;
	input plot;
	
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;

	 parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	 
	 reg [6:0] y_count;
	 reg [7:0] x_count;

	always@(posedge iClock) begin
        if(iResetn == 1'b0 || plot == 1'b0) begin
				y_count <= 7'b0;
				x_count <= 8'b0;
				oColour <= 3'd0;
        end
		else if (plot == 1'b1) begin
			if (x_count == x_size) 
					x_count <= 8'd0;
			else
				begin
					oX <= x_coord + x_count;
					x_count <= x_count + 1'b1;
				end
								

			if (y_count == y_size) 
				y_count <= 7'd0;
				else if (x_count == 8'd0)
					begin
						oY <= y_coord + y_count;
						y_count <= y_count + 1'b1;
					end
								
				oColour <= iColour;
			end
	end
							
endmodule





