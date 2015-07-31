// Filename:    sevensegmentdecoder_assign.v
// Author:      Danny Dutton
// Date:        03/03/15
// Version:     1
// Description: Decode 4-bit input and drive a seven segment using assignment

module sevensegdecoder_always(digit, drivers);
    input [3:0] digit;
    output [6:0] drivers;	// Take a to be the MSB of the vector.
    reg [6:0] drivers;

    always @(digit) begin
    	if(digit == 4'h0)
		begin
			drivers = 7'b0000001;
		end
		else if(digit == 4'h1)
		begin
			drivers = 7'b1001111;
		end
		else if(digit == 4'h2)
		begin
			drivers = 7'b0010010;
		end
		else if(digit == 4'h3)
		begin
			drivers = 7'b0000110;
		end
		else if(digit == 4'h4)
		begin
			drivers = 7'b1001100;
		end
		else if(digit == 4'h5)
		begin
			drivers = 7'b0100100;
		end
		else if(digit == 4'h6)
		begin
			drivers = 7'b0100000;
		end
		else if(digit == 4'h7)
		begin
			drivers = 7'b0001101;
		end
		else if(digit == 4'h8)
		begin
			drivers = 7'b0000000;
		end
		else if(digit == 4'h9)
		begin
			drivers = 7'b0000100;
		end
		else if(digit == 4'hA)
		begin
			drivers = 7'b0001000;
		end
		else if(digit == 4'hB)
		begin
			drivers = 7'b1100000;
		end
		else if(digit == 4'hC)
		begin
			drivers = 7'b0110001;
		end
		else if(digit == 4'hD)
		begin
			drivers = 7'b1000010;
		end
		else if(digit == 4'hE)
		begin
			drivers = 7'b0110000;
		end
		else if(digit == 4'hF)
		begin
			drivers = 7'b0111000;
		end
    end

endmodule