module generator(input clk, input reset, output led, output tx_led, output tx, input rewind_usart);


parameter clock_freq = 16000000;
reg	[10:0] a = 11'b0;
reg	we = 0;
wire	[7:0] do;
reg	[7:0] di = 8'b0;
reg	[47:0] j = 48'b0;
reg	[3:0] state = 4'b0;

bram bram1 (clk, we, a, di, do);

reg	[0:127] m_in = 128'd0;
reg	[0:127] m_in_2 = 128'd0;
reg	[0:127] m_in_buff = 128'd0;
reg	[0:7]	m_in_w = 8'd0;
reg	[0:7]	m_in_w_2 = 8'd0;
reg	m_in_valid = 0;
reg	m_in_valid_2 = 0;

wire	[0:127] m_out;
wire	[0:127] m_out_2;

wire	m_out_val, m_out_val_1, m_out_val_2;
wire	md5_ready, md5_ready_1, md5_ready_2;

reg	led_reg = 0;

reg	[7:0] bytetosend;
wire	sent;
reg	send;

reg	[7:0] tmp_val_1;
reg	[7:0] tmp2;

pancham md5(
	.clk(clk),
	.reset(reset),
	.msg_in(m_in),
	.msg_in_width(m_in_w),
	.msg_in_valid(m_in_valid),
	.msg_output(m_out),
	.msg_out_valid(m_out_val_1),
	.ready(md5_ready_1)
	);

pancham md5_2(
	.clk(clk),
	.reset(reset),
	.msg_in(m_in_2),
	.msg_in_width(m_in_w_2),
	.msg_in_valid(m_in_valid_2),
	.msg_output(m_out_2),
	.msg_out_valid(m_out_val_2),
	.ready(md5_ready_2)
	);
	
usart #(.fsm_clk_freq(clock_freq) ) usart1 (clk, reset, tx_led, bytetosend, send, sent, tx); 


assign led = led_reg;

initial begin
	state = 0;
`ifdef SIMULATION
	$dumpfile("top.vcd");
	$dumpvars(0, top);
`endif
end

parameter s1 = 4'd0;
parameter s2 = 4'd1;
parameter s3 = 4'd2;
parameter s4 = 4'd3;
parameter s5 = 4'd4;
parameter s6 = 4'd5;
parameter s7 = 4'd6;
parameter s8 = 4'd7;
parameter s9 = 4'd8;
parameter s10 = 4'd9;
parameter s11 = 4'd10;
parameter found = 4'd11;

always @(posedge clk or posedge reset)
begin
	if (reset)
		begin
			state <= s1;
			led_reg <= 0;
			a <= 11'b0;
			j <= 48'b0;
			m_in_valid <= 0;
			m_in_w <= 8'd64;
			m_in_buff <= 128'd0;
			
			m_in_valid_2 <= 0;
			m_in_w_2 <= 8'd64;
		end
	else
		begin
			case (state)
			s1:	begin
					a <= { 5'b0, j[11:6] };
					state <= s2;
					m_in_valid <= 0;
					m_in_valid_2 <= 0;
				end
			s2:	begin
					m_in_buff[64:71] <= do;
					a <= { 5'b0, j[17:12] };
					state <= s3;
				end
			s3:	begin
					m_in_buff[72:79] <= do;
					a <= { 5'b0, j[23:18] };
					state <= s4;
				end
			s4:	begin
					m_in_buff[80:87] <= do;
					a <= { 5'b0, j[29:24] };
					state <= s5;
				end
			s5:	begin
					m_in_buff[88:95] <= do;
					a <= { 5'b0, j[35:30] };
					state <= s6; 
				end
			s6:	begin
					m_in_buff[96:103] <= do;
					a <= { 5'b0, j[41:36] };
					state <= s7;
				end
			s7:	begin
					m_in_buff[104:111] <= do;
					a <= { 5'b0, j[47:42] };
					state <= s8;
				end
			s8:	begin
					m_in_buff[112:119] <= do;
					state <= s9;
				end
			s9:	begin
					m_in_buff[120:127] <= do;
					j <= j + 1;
					if (m_out_val_2)
						begin
`ifdef SIMULATION
							$display("CORE2 - md5(%s) = %h", m_in_2, m_out_2);
							if (m_out_2 == 128'h694eb0dbf2862a890290ad783f954bf3)
`else
							if (m_out_2 == 128'he5021844a2e797612077406d699e5934)
`endif
								begin
									state <= found;
									led_reg <= 1;
`ifdef SIMULATION
									$display("CORE2 - MD5 HASH FOUND");
`endif
									tmp_val_1 <= m_in_2[120:127];
									m_in <= m_in_2;
								end
							else
								begin
									state <= s10;
								end
						end
                                                else
                                                begin
                                                      state <= s10;
                                                end



				end
			s10:	begin
					if (m_out_val_1)
						begin
`ifdef SIMULATION
							$display("CORE1 - md5(%s) = %h", m_in, m_out);
							if (m_out == 128'h694eb0dbf2862a890290ad783f954bf3)
`else
							if (m_out == 128'he5021844a2e797612077406d699e5934)
`endif
								begin
									state <= found;
									led_reg <= 1;
`ifdef SIMULATION
									$display("CORE1 - MD5 HASH FOUND");
`endif
									tmp_val_1 <= m_in[120:127];
								end
							else
								begin
									state <= s10;
								end
						end
					else if(md5_ready_1)
						begin
							m_in_w <= 8'd64;
							m_in_valid <= 1;
							m_in <= m_in_buff;
							state <= s1;
							a <= { 5'b0, j[5:0] };
						end
					else if(md5_ready_2)
						begin
							m_in_w_2 <= 8'd64;
							m_in_valid_2 <= 1;
							m_in_2 <= m_in_buff;
							state <= s1;
							a <= { 5'b0, j[5:0] };
						end
					else
						begin
							state <= s10;
						end
				end
			found:	begin
					state <= found;
				end
			endcase
		end
end

wire 	result_displayed;
reg	[3:0] show_result_count = 4'b0;
assign result_displayed = (rewind_usart ? 4'd0 : show_result_count == 4'd8);
reg	[0:127] cleartext;

	always @(posedge clk)
	begin
		if (reset)
			send <= 1'b0;
		else
		begin
			if (state == found)
			begin
				if (~result_displayed & sent & ~send)
				begin
					if (show_result_count == 4'd0)
					begin
						tmp2 <= tmp_val_1;
						cleartext <= { 56'b0, tmp_val_1, m_in[64:119] }; 
						bytetosend <= tmp_val_1;
					end
					else
					begin
						cleartext <= { 56'b0, tmp2, cleartext[64:119] };
						bytetosend <= tmp2;
					end
					send <= 1'b1;
					show_result_count <= show_result_count + 1;
`ifdef SIMULATION
`ifdef MAXDEBUG
					$display("tmp = %h, m_in = %h, bytetosend = %h, send = %b", tmp_val_1, m_in[64:127], bytetosend, send);
					$display("tmp2 = %h, cleartext = %h, bytetosend = %h, send = %b", tmp_val_1, cleartext[64:127], bytetosend, send);
`endif
`endif
				end 	
				if (send)
				begin
					tmp2 <= cleartext[120:127];
					send <= 1'b0;
				end
			end
		end
	end

endmodule
