module pwm_module (input wire clk,
						 input wire [7:0] pwm_duty_in,
						 output reg pwm_out);
	integer pwm_duty, counter;
	
	initial
		begin
			counter = 0;
		end

	always @ (posedge clk)
		begin
			if (counter <= pwm_duty)
				pwm_out <= 1;
			else
				pwm_out <= 0;
				
		counter = counter + 1;
		if (counter == 255)
			counter <= 0;
			pwm_duty <= pwm_duty_in;
		end
		
endmodule