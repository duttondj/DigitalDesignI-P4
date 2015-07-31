//==================================================================================================
//  Filename      : vendingmachine.v
//  Created On    : 2015-05-05 08:17:43
//  Last Modified : 2015-05-07 19:37:31
//  Author        : Danny Dutton
//  Class         : ECE3544
//  Project       : Project 4
//  Description   : Vending machine state machine. The FSM increments the count of the change 
//                  inside the vending machine until reaching 65c. Then a product will dispense and
//                  change given, starting from dimes to nickels, if needed.
//
//==================================================================================================

module vendingmachine(clock, enable, reset, coin, mode, quarter_counter, dime_counter, nickel_counter, dimenickelLEDon, dimeLEDon, nickelLEDon, vendLEDon);
	input clock;			// Clock used for timing the LEDs
	input enable;			// KEY[1] in the top module, serves as a user controlled clock pulse
	input reset;			// KEY[0] in top module, resets values
	input[1:0] coin;		// SW[1:0] sets which coin is to be inserted on enable high
	input mode;				// SW[2] sets if vending machine should be in normal mode (1) or maintenance mode (0).
							// It sets if we wish to increment "count" or not.
	output reg [7:0] quarter_counter, dime_counter, nickel_counter;	            // Total numbers of each coin in the machine to be used as change
	output reg dimeLEDon, nickelLEDon, vendLEDon;							// Controls when LEDs should light up for returning coins or vending item
	output dimenickelLEDon;

	reg [7:0] count;         		// Total in cents of change inserted when trying to make a purchase
	reg [27:0] LEDcounter;					// Counter for how long an LED is on
	reg nickelLED, nickelLED2, nickelLED3, nickelLED4, dimeLED, dimeLED2, vendLED, LEDon;	// Current state of an LED;
	reg countreset;
	reg nickelinc, dimeinc, quarterinc;		// Flags for incrementing
	reg dispense;
	reg venddec, nickeldec, nickeldec2, nickeldec3, nickeldec4, dimedec, dimedec2;	// Flags for decrementing nickels and dimes
	

	// Nickel counter
	always @(posedge clock or negedge reset) begin
		if(!reset)
			nickel_counter <= 8'd0;
		else if(nickelinc)
			nickel_counter <= nickel_counter + 8'd1;
		else if(nickeldec)
			nickel_counter <= nickel_counter - 8'd1;
		else if(nickeldec2)
			nickel_counter <= nickel_counter - 8'd2;
		else if(nickeldec3)
			nickel_counter <= nickel_counter - 8'd3;
		else if(nickeldec4)
			nickel_counter <= nickel_counter - 8'd4;
		else
			nickel_counter <= nickel_counter;
	end

	// Dime counter
	always @(posedge clock or negedge reset) begin
		if(!reset)			dime_counter <= 8'd0;
		else if(dimeinc)
			dime_counter <= dime_counter + 8'd1;
		else if(dimedec)
			dime_counter <= dime_counter - 8'd1;
		else if(dimedec2)
			dime_counter <= dime_counter - 8'd2;
		else
			dime_counter <= dime_counter;
	end

	// Quarter counter
	always @(posedge clock or negedge reset) begin
		if(!reset)
			quarter_counter <= 8'd0;
		else if(quarterinc)
			quarter_counter <= quarter_counter + 8'd1;
		else
			quarter_counter <= quarter_counter;
	end

	// Change counter
	always @(posedge clock or negedge reset) begin
		if(!reset)
			count <= 8'd0;
		else if(countreset)
			count <= 8'd0;
		else if(nickelinc && mode)
			count <= count + 8'd5;
		else if(dimeinc && mode)
			count <= count + 8'd10;
		else if(quarterinc && mode)
			count <= count + 8'd25;
		else if(venddec) begin
			if(dimedec && nickeldec)
				count <= count - 8'd75;
			else if(dimedec && nickeldec2)
				count <= count - 8'd80;
			else if(nickeldec)
				count <= count - 8'd65;
			else if(nickeldec2)
				count <= count - 8'd70;
			else if(dimedec)
				count <= count - 8'd70;
			else if(nickeldec3)
				count <= count - 8'd75;
			else if(dimedec2)
				count <= count - 8'd80;
			else if(nickeldec4)
				count <= count - 8'd80;
			else begin
				count <= count - 8'd60;
			end
		end
		else
			count <= count;
	end

	// Deposit
	always @(posedge clock) begin
		// Coin inserted, increment counters
		if(enable) begin
			case(coin)
				// Nickel
				2'b01: begin
					nickelinc <= 1'b1;
				end
				// Dime
				2'b10: begin
					dimeinc <= 1'b1;
				end
				// Quarter
				2'b11: begin
					quarterinc <= 1'b1;
				end
				// SW[1:0] = 2'b00 or something else so dont do anything
				default: begin
					nickelinc <= 1'b0;
					dimeinc <= 1'b0;
					quarterinc <= 1'b0;
				end
			endcase
		end
		// No coins inserted
		else begin
			nickelinc <= 1'b0;
			dimeinc <= 1'b0;
			quarterinc <= 1'b0;
		end

		if(count > 60) begin
			dispense <= 1;
		end
		else begin
			dispense <= 0;
		end
	end

	// Dispense when count >= 60. Set venddec and dime/nickel/2/3dec if we need to
	always @(dispense) begin
		// Need to vend product
		if(count == 60) begin
			venddec <= 1'b1;
			dimedec <= 1'b0;
			dimedec2 <= 1'b0;
			nickeldec <= 1'b0;
			nickeldec2 <= 1'b0;
			nickeldec3 <= 1'b0;
			nickeldec4 <= 1'b0;
			dispense <= 0;
		end
		// Do we need to return coins as well?
		else if(count > 60) begin
			venddec <= 1'b1;
			dispense <= 0;
			// Need to only return a nickel if we have any
			if((count == 65) && (nickel_counter > 0))
				nickeldec <= 1'b1;
			// Need to return 10
			if(count == 70) begin
				// Return a dime if we have any
				if(dime_counter > 0)
					dimedec <= 1'b1;
				// Return 2 nickels instead
				else if(nickel_counter > 1)
					nickeldec2 <= 1'b1;
				// Return 1 nickel since thats all we have
				else if(nickel_counter == 1)
					nickeldec <= 1'b1;
			end
			// Need to return 15
			if(count == 75) begin
				// Return a dime if we have one
				if(dime_counter > 0) begin
					dimedec <= 1'b1;
					// Return a nickel too if we have one
					if(nickel_counter > 0)
						nickeldec <= 1'b1;
				end
				// No dimes so give back 3 nickels
				else if(nickel_counter > 2)
					nickeldec3 <= 1'b1;
				// Not enough nickels so give 2
				else if(nickel_counter > 1)
					nickeldec2 <= 1'b1;
				// Not enough nickels so give 1
				else if(nickel_counter == 1)
					nickeldec <= 1'b1;
			end
			// Need to return 20
			if(count == 80) begin
				// Return 2 dimes if we have some
				if(dime_counter > 1)
					dimedec2 <= 1'b1;
				// Not enough dimes so give back 1 dime and and 2 nickels
				else if(dime_counter > 0) begin
					dimedec <= 1'b1;
					// Give 2 nickels if we have enough
					if(nickel_counter > 1)
						nickeldec2 <= 1'b1;
					// Give one nickel if we dont have enough
					else if(nickel_counter > 0)
						nickeldec <= 1'b1;
				end
				// Not enough dimes so give 4 nickels
				else if(nickel_counter > 1)
					nickeldec4 <= 1'b1;
				// Not enough nickels so give 3
				else if(nickel_counter > 1)
					nickeldec2 <= 1'b1;
				// Not enough nickels so give 1
				else if(nickel_counter == 1)
					nickeldec <= 1'b1;
			end
		end
		else begin
			dimedec <= 1'b0;
			dimedec2 <= 1'b0;
			nickeldec <= 1'b0;
			nickeldec2 <= 1'b0;
			nickeldec3 <= 1'b0;
			nickeldec4 <= 1'b0;
			venddec <= 1'b0;
		end
	end

	// LEDs 
	always @(posedge clock) begin
		// Select correct LED sequences for dispensing product and coins
		if(nickeldec || nickeldec2 || nickeldec3 || nickeldec4 || dimedec || dimedec2 || venddec) begin
			if(nickeldec || nickeldec2 || nickeldec3 || nickeldec4) begin
				if(nickeldec)
					nickelLED <= 1;
				else if(nickeldec2)
					nickelLED2 <= 1;
				else if(nickeldec3)
					nickelLED3 <= 1;
				else if(nickeldec4)
					nickelLED4 <= 1;
			end
			
			if(dimedec)
				dimeLED <= 1;
			
			if(dimedec2)
				dimeLED2 <= 1;
			
			if(venddec)
				vendLED <= 1;

			// Need to reset the count since we might have extra leftover if we didnt have enough change to give back.
			// This needs to be done here since we cant reset the count to zero while we are subtracting from it.
			countreset <= 1;
		end
		// // Otherwise, if LED lock is on, keep current state of LEDs
		// // If the lock is on, keep the LEDs on that should be
		else if(LEDon) begin
			nickelLED <= nickelLED;
			nickelLED2 <= nickelLED2;
			nickelLED3 <= nickelLED3;
			nickelLED4 <= nickelLED4;
			dimeLED <= dimeLED;
			vendLED <= vendLED;
			LEDcounter <= LEDcounter + 28'd1;
		end
		else begin
			nickelLED <= 0;
			nickelLED2 <= 0;
			nickelLED3 <= 0;
			nickelLED4 <= 0;
			dimeLED <= 0;
			dimeLED2 <= 0;
			vendLED <= 0;
			LEDcounter = 28'd0;
			countreset <= 0;
		end
	end

	// LED output machine
	always @(nickelLED or nickelLED2 or nickelLED3 or nickelLED4 or dimeLED or dimeLED2 or vendLED or LEDcounter or LEDon) begin
		// Turn on the lock so we can keep this always block running until we dont need it anymore
		LEDon = 1;
		// Need to dispense product and a dime
		if(dimeLED2) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 150000000) begin
					dimeLEDon = 0;
					LEDon = 0;
				end
			end
		end
		// Need to dispense product, dime, then 2 nickels
		else if(dimeLED && nickelLED2) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 100000000) begin
					dimeLEDon = 0;
					nickelLEDon = 1;
					if(LEDcounter >= 200000000) begin
						nickelLEDon = 0;
						LEDon = 0;
					end
				end
			end
		end
		// Need to dispense product, dime, then nickel
		else if(dimeLED && nickelLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 100000000) begin
					dimeLEDon = 0;
					nickelLEDon = 1;
					if(LEDcounter >= 150000000) begin
						nickelLEDon = 0;
						LEDon = 0;
					end
				end
			end
		end
		// Need to dispense product and a dime
		else if(dimeLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				dimeLEDon = 1;
				if(LEDcounter >= 100000000) begin
					dimeLEDon = 0;
					LEDon = 0;
				end
			end
		end
		// Need to dispense product and 4 nickels
		else if(nickelLED4) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter >= 250000000) begin
					nickelLEDon = 0;
					LEDon = 0;
				end
			end
		end
		// Need to dispense product and 3 nickels
		else if(nickelLED3) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter >= 200000000) begin
					nickelLEDon = 0;
					LEDon = 0;
				end
			end
		end
		// Need to dispense product and 2 nickels
		else if(nickelLED2) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter == 150000000) begin
					nickelLEDon	= 0;
					LEDon = 0;
				end
			end
		end
		// Need to dispense product and a nickel
		else if(nickelLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				nickelLEDon = 1;
				if(LEDcounter >= 100000000) begin
					nickelLEDon = 0;
					LEDon = 0;
				end
			end
		end
		// Need to dispense product only
		else if(vendLED) begin
			vendLEDon = 1;
			if(LEDcounter >= 50000000) begin
				vendLEDon = 0;
				LEDon = 0;
			end
		end
		else begin
			nickelLEDon = 0;
			dimeLEDon = 0;
			vendLEDon = 0;
			LEDon = 0;
		end
	end

	// Continuous assignment for the dime/nickel count LED
	assign dimenickelLEDon = (dime_counter == 0) && (nickel_counter == 0);
endmodule