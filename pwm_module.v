module pwm_module (input wire ext_clk,
						 output reg pwm_out);
	reg int_clk;
	
	always
		#1 int_clk = ~int_clk;
		
endmodule