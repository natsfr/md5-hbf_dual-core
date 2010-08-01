`define CLOCK_FREQUENCY 50000000

module top(input rewind_usart, output reset_led, input clock, input reset, output led, output led2, output led3, input UART_TXD, output UART_RXD);

reg reset_sync = 1'b1;
reg rewind_usart_sync;

wire sys_clk_dcm;
wire sys_clk;

wire clk_fb_buf;
wire clk0_buf;

wire not_led, not_led3;

/* CHIPSCOPE PART ! */

//wire [35:0] ILA_Ctrl_bus;
//wire [31:0] data_ila;

//assign data_ila = {23'b0, clock, sys_clk, not_led, led, not_led3, led3, led2, reset_led, rewind_usart_sync};

//icon_module i_icon(.CONTROL0(ILA_Ctrl_bus)) /* synthesis syn_noprune=1 */;
//ila_module i_ila(.CONTROL(ILA_Ctrl_bus), .CLK(sys_clk), .TRIG0({7'b0, reset_sync}), .DATA(data_ila)) /* synthesis syn_noprune=1 */;

/* END OF CHIPSCOPE PART */

/*wire locked_status;
reg global_reset = 1'b1;

reg locked_reg = 1'b0; // Based flip flop metastable filter.
reg locked_reg_2 = 1'b0;

reg startup_reset = 1'b1;
reg [27:0] startup_rst_counter = 27'b0;*/

DCM #(
	.CLKDV_DIVIDE(2),
	.CLKFX_DIVIDE(4),
	.CLKFX_MULTIPLY(2),
	.CLKIN_DIVIDE_BY_2("FALSE"),
	.CLKIN_PERIOD(10.0),
	.CLKOUT_PHASE_SHIFT("NONE"),
	.CLK_FEEDBACK("1X"),
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
	.DFS_FREQUENCY_MODE("LOW"),
	.DLL_FREQUENCY_MODE("LOW"),
	.DUTY_CYCLE_CORRECTION("TRUE"),
	.PHASE_SHIFT(0),
	.STARTUP_WAIT("FALSE")
) clkgen (
	.CLK0(clk0_buf),
	.CLK90(),
	.CLK180(),
	.CLK270(),
	.CLK2X(),
	.CLK2X180(),
	.CLKDV(),
	.CLKFX(sys_clk_dcm),
	.CLKFX180(),
	.LOCKED(/*locked_status*/),
	.CLKFB(clk_fb_buf),
	.CLKIN(clock),
	.RST(/*global_reset*/1'b0),
	.PSEN(1'b0)
);

BUFG b1(
	.I(sys_clk_dcm),
	.O(sys_clk)
);

BUFG b_fb(
	.I(clk0_buf),
	.O(clk_fb_buf)
);

// DCM Watchdog
//	Thanks to MatthiasM 
/*always @(posedge clock)
begin
	reset_sync <= ~reset;
	rewind_usart_sync <= ~rewind_usart;
	locked_reg <= locked_status;
	locked_reg_2 <= locked_reg;
	global_reset <= reset_sync | startup_reset;
	if(startup_rst_counter[10])
	begin
		if (locked_reg_2) begin
			startup_reset <= 0;
		end else begin
			startup_rst_counter <= 16'b0;
			startup_reset <= 1'b1;
		end
	end else begin
		startup_rst_counter <= startup_rst_counter + 1;
		startup_reset <= 1'b1;
	end
end*/

always @(posedge sys_clk)
begin
	reset_sync <= ~reset;
	rewind_usart_sync <= ~rewind_usart;
end

generator #(.clock_freq(`CLOCK_FREQUENCY)) g1 (sys_clk, reset_sync, not_led, not_led3, UART_RXD, rewind_usart_sync);

assign reset_led = ~reset_sync; //~global_reset;
assign led2 = ~rewind_usart_sync;
assign led = ~not_led;
assign led3 = ~not_led3;

/*assign led2 = locked_reg_2;
assign reset_led = global_reset;*/

endmodule
