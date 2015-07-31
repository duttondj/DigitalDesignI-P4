// Filename: keypressed.v
// Author: Tom Martin
// Date: 10/24/2013
// Version: 1

// Description: This FSM generates an enable pulse that lasts for one clock period each time the pushbutton is pressed
//              and released.

// Updated on 18 March 2013 by J.S. Thweatt
// Commented to describe state machine structure

module keypressed(clock, reset, enable_in, enable_out);

	input clock;			// The on-board clock, default 50 MHz
	input	reset;			// Reset is active low. Should be connected to pushbutton 0.
	input enable_in;		// Should be connected to pushbutton 1.
	output enable_out;	// The output is high for one FPGA clock cycle each time pushbutton 1 is pressed and released.
	
// Variables for keeping track of the state.
	reg [1:0] key_state, next_key_state;
	reg enable_out;

// Set up parameters for "state" of the pushbutton.
// Since there are three states, we are using 2-bits to represent the state in a so-called "dense" assignment.
	parameter [1:0] KEY_FREE = 2'b00, KEY_PRESSED = 2'b01, KEY_RELEASED = 2'b10;

// The following always block represents sequential logic, and therefore uses non-blocking assignments.

// This always block is sensitized to the clock input and the reset input. You should picture this always block as a 2-bit
// register with an active-low asynchronous clear.

	always @(posedge clock or negedge reset) begin
	
	// If reset = 0, there must have been a negative edge on the reset.
	// Since the effect of the reset occurs in the absence of a clock pulse, the reset is ASYNCHRONOUS.
		if (reset == 1'b0)
			key_state <= KEY_FREE;
		
	// If reset !=0 but this always block is executing, there must have been a positive clock edge.
	// On each positive clock edge, the next state becomes the present state.
		else
			key_state <= next_key_state;
	end

// The following always block represents combinational logic.  It uses blocking assignments.

// This always block is sensitized to changes in the present state and enable input. You should picture this block as 
// a combinational circuit that feeds the register inputs. It determines the next state based on the current state and
// the enable input.

	always @(key_state, enable_in) begin
	
	// To be safe, assign values to the next_key_state and enable_out. That way, if none of the paths in the case
	// statement apply, these variables have known values.
		next_key_state = key_state;
		enable_out = 1'b0;
		
	// Use the present state to determine the next state.
		case (key_state)
		
		// If the key is free (i.e., is unpressed and was not just released):
			KEY_FREE: begin
			
			// If the enable input button is down, make the next state KEY_PRESSED.
				if (enable_in == 1'b0)
					next_key_state = KEY_PRESSED;
			end
		
		// If the key is pressed:
			KEY_PRESSED: begin
			
			// If the enable button is up, make the next state KEY_RELEASED.
				if (enable_in == 1'b1)
					next_key_state = KEY_RELEASED;
			end
			
		// If the key is released (i.e., the button has just gone from being pressed to being released):
			KEY_RELEASED: begin
			
			// Take the output high.
				enable_out = 1'b1;
			
			// Make the next state KEY_FREE. Note that this state transition always happens and is independent of
			// the input
				next_key_state = KEY_FREE;
			end
			
		// If none of the above - something that should never happen - make the next state and output unknown.
			default: begin
				next_key_state = 2'bxx;
				enable_out = 1'bx;
			end
			
		endcase
		
	end
	
endmodule