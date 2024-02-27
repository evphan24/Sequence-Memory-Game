module displayFaces(iClock, iResetn, x_coord, y_coord, face, plot, oX, oY, oColour);
	input iClock, iResetn, face;
	input [7:0] x_coord;
	input [6:0] y_coord;
	input plot;
	
	output reg [7:0] oX;
	output reg [6:0] oY;
	output reg [2:0] oColour;
	 
	 reg [6:0] y_count;
	 reg [7:0] x_count;
	 reg [7:0] address;
	 wire data1, data2;
	 
	 smileyFace smf(address, iClock, data1);
	 sadFace sdf(address, iClock, data2);

	always@(posedge iClock) begin
        if(iResetn == 1'b0 || plot == 1'b0) begin
				y_count <= 7'b0;
				x_count <= 8'b0;
				oColour <= 3'd0;
				address <= 1'b1;
        end
		else if (plot == 1'b1) begin
			if (x_count == 4'd15) 
					x_count <= 8'd0;
			else
				begin
					oX <= x_coord + x_count;
					x_count <= x_count + 1'b1;
					
					if (address < 8'd224) 
						address <= address + 1'b1;
					else if (address == 8'd224)
						address <= 8'b0;
				end
								

			if (y_count == 4'd15) 
				y_count <= 7'd0;
				else if (x_count == 8'd0)
					begin
						oY <= y_coord + y_count;
						y_count <= y_count + 1'b1;
					end
				
			if (face == 1'b0) begin
				if (data1 == 1'b0)
					oColour <= 3'b0;
				else if (data1 == 1'b1)
					oColour <= 3'd6;
			end
			if (face == 1'b1) begin
				if (data2 == 1'b0)
					oColour <= 3'b0;
				else if (data2 == 1'b1)
					oColour <= 3'd3;
			end
					
					
			end
	end
							
endmodule