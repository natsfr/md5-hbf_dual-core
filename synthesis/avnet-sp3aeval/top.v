`define CLOCK_FREQUENCY 46000000

module top(input rewind_usart, output reset_led, input clock, input reset, output led, output led2, output led3, input UART_TXD, output UART_RXD);

reg reset_sync;
reg rewind_usart_sync;

wire sys_clk;
wire sys_clk_dcm;

wire clk_fb;
wire clk_fb_buf;

always @(posedge sys_clk)
begin
	reset_sync <= reset;
	rewind_usart_sync <= rewind_usart;
end

generator #(.clock_freq(`CLOCK_FREQUENCY) ) g1 (sys_clk, reset_sync, led, led3, UART_RXD, rewind_usart_sync);

DCM_SP #(
//	.CLKDV_DIVIDE(2),
	.CLKFX_DIVIDE(8),
	.CLKFX_MULTIPLY(23),
	.CLKIN_DIVIDE_BY_2("FALSE"),
	.CLKIN_PERIOD(62.5),
	.CLKOUT_PHASE_SHIFT("NONE"),
	.CLK_FEEDBACK("1X"),
	.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
	.DFS_FREQUENCY_MODE("LOW"),
	.DLL_FREQUENCY_MODE("LOW"),
	.DUTY_CYCLE_CORRECTION("TRUE"),
	.PHASE_SHIFT(0),
	.STARTUP_WAIT("TRUE"),
        .FACTORY_JF(16'hC080)
) clkgen (
	.CLK0(clk_fb),
	.CLK90(),
	.CLK180(),
	.CLK270(),
	.CLK2X(),
	.CLK2X180(),
	.CLKDV(),
	.CLKFX(sys_clk_dcm),
	.CLKFX180(),
	.LOCKED(),
	.CLKFB(clk_fb_buf),
	.CLKIN(clock),
	.RST(1'b0),
	.PSEN(1'b0)
);

BUFG b1(
	.I(sys_clk_dcm),
	.O(sys_clk)
);

BUFG b_fb(
	.I(clk_fb),
	.O(clk_fb_buf)
);

assign led2 = UART_TXD;
assign reset_led = reset_sync;

endmodule
