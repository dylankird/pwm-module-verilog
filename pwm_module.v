module pwm_module (input wire pwm_clk, chip_select, mosi, sclk, parallel_enable,
						 input wire [7:0] pwm_duty_in,
						 output reg pwm_out);
			// I/O:
			// chip_select - active low, acts as chip select for the SPI bus. Enables SPI communication when low.
			// mosi - Master Out Slave In data pin for SPI bus
			// sclk - clock pin for SPI bus
			// parallel_enable - when high, the duty cycle is determined by the pwm_duty_in parallel bus.
			//							when low, the duty cycle is determined by the SPI bus.
			// pwm_duty_in - the 8 bit bus that allows the PWM duty cycle to be directly set 
			// pwm_out - the output pin that generates the PWM signal with the duty cycle dictated by 
			//				 either the SPI bus or the parallel bus.
			// pwm_clk - the clock signal that is used to generate the PWM signal. The PWM frequency will be 1/254th
			//				 the frequency of the pwm_clk input clock frequency
						 
	reg [7:0] pwm_duty_out, pwm_duty, pwm_counter, spi_in;
	
			// pwm_duty_out - the register that holds the pwm duty cycle that the pwm_out pin is currently outputting
			// pwm_duty - the intermediate register that holds the duty cycle to be outputted on the next PWM period
			// pwm_counter - the counter that counts PWM clock pulses in order to generate the proper duty cycle
			// spi_in - the register that holds the SPI bits as they are being recieved

	reg [2:0] spi_counter;	// spi_counter counts the 8 bits (from 0 to 7) being recieved over SPI
	
	
	always @ (posedge sclk, posedge chip_select)
		begin
			if (chip_select)			// When chip_select goes high, SPI communication is over
				spi_counter <= 0;		// spi_counter is reset to 0 for the next transferred byte
			else												// If chip_select is low, that means we posedge clock has been triggered
				begin											// therefore, we are shifting in the next bit over SPI.
					spi_in[spi_counter] <= mosi;		// The current SPI bit is obtained from the MOSI pin and stored in the spi_in reg
					spi_counter <= spi_counter + 1;	// Add 1 to spi_counter so that the next bit is shifted in next time
				end
		end	
		
	always @ *
		begin
			if(parallel_enable)				// If parallel_enable is high, the pwm duty cycle is determined by the pwm_duty_in parallel input
				pwm_duty <= pwm_duty_in;	// Save the duty cycle input to the intermediate pwm_duty register
			else								// If parallel_enable is low, the pwm duty cycle is determined by the SPI input
				if(chip_select)			// If chip_select is high, then the SPI transfer is over and the spi_in byte is ready to be used
					pwm_duty <= spi_in;	// Save the byte recieved over SPI to the intermediate pwm_duty register
		end

	always @ (posedge pwm_clk)					// Triggered every pwm_clk pulse
		begin
			if (pwm_counter < pwm_duty_out)	// This if/else statement makes sure that 
				pwm_out <= 1;						// pwm_out is high for pwm_duty_out number of cycles
			else										// out of 255 total cycles
				pwm_out <= 0;
				
		if (pwm_counter == 0)					// When pwm_counter is 0, a cycle has been completed and the updated pwm duty cycle
			pwm_duty_out <= pwm_duty;			// from the intermedate pwm_duty register can be loaded into the pwm_duty_out register
														// which controls how many cycles pwm_out is high for.
		pwm_counter <= pwm_counter + 1;		// pwm_counter is incremented here since we have completed a cycle
		
		if(pwm_counter == 254) 	// This causes the counter to reset before 255. This is important because otherwise we would
			pwm_counter <= 0;		// see a pulse to low even if the duty cycle is set to 255.
		end
		
endmodule