module pwm_module (input wire pwm_clk, chip_select, mosi, sclk, parallel_enable,
						 input wire [7:0] pwm_duty_in,
						 output reg pwm_out);
						 
	reg [7:0] pwm_duty_out, pwm_duty, pwm_counter, spi_in;
	reg [2:0] spi_counter;
	reg spi_begin;	
	
	always @ (posedge sclk)
		begin
			if (chip_select)
				spi_counter <= 0;
			else
				spi_in[spi_counter] <= mosi;
				spi_counter <= spi_counter + 1;
		end	
		
	always @ (spi_begin, pwm_duty_in, parallel_enable)
		begin
			if(parallel_enable)
				pwm_duty <= pwm_duty_in;
			else
				if(chip_select)
					pwm_duty <= spi_in;
		end

	always @ (posedge pwm_clk)
		begin
			if (pwm_counter < pwm_duty_out)
				pwm_out <= 1;
			else
				pwm_out <= 0;
				
		if (pwm_counter == 0)
			pwm_duty_out <= pwm_duty;
			
		pwm_counter <= pwm_counter + 1;
		
		if(pwm_counter == 254) //Necessary so that 255 makes it constantly high
			pwm_counter <= 0;
		end
		
endmodule