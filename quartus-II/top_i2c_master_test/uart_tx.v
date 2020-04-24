module my_uart_tx(rst_n, baud_clk, tx_start, tx_data, tx_enable, tx_complete, uart_tx);

input rst_n;
input baud_clk;
input tx_start;
input[7:0] tx_data;
output tx_enable;
output tx_complete;
output uart_tx;


/*************************************************************************************
 * Update tx_enable_reg
 ************************************************************************************/
reg tx_enable_reg;
always @ (negedge tx_start or negedge tx_complete_reg or negedge rst_n)
begin
	if (!rst_n)
	begin
		tx_enable_reg <= 1'b0;
	end
	else if (!tx_complete_reg)
		tx_enable_reg <= 1'b0;
	else if (!tx_start)
		tx_enable_reg <= 1'b1;
end
assign tx_enable = tx_enable_reg;

/*************************************************************************************
 * Update tx_complete_flag
 ************************************************************************************/
reg tx_complete_reg;
always @ (negedge baud_clk or negedge tx_enable_reg or negedge rst_n)
begin
	if (!rst_n)
	begin
		tx_complete_reg <= 1'b1;
	end
	else if (!tx_enable_reg)
		tx_complete_reg <= 1'b1;
	else if (!baud_clk)
	begin
		if (!tx_count)
			tx_complete_reg <= 1'b0;
	end
end
assign tx_complete = tx_complete_reg;

/*************************************************************************************
 * Update tx_count
 ************************************************************************************/
reg[3:0] tx_count;
always @ (posedge baud_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		tx_count <= 4'd0;
	end
	else if (baud_clk)
	begin
		case (tx_count)
			4'd1:	tx_count <= 4'd2;
			4'd2:	tx_count <= 4'd3;
			4'd3:	tx_count <= 4'd4;
			4'd4: tx_count <= 4'd5;
			4'd5: tx_count <= 4'd6;
			4'd6: tx_count <= 4'd7;
			4'd7: tx_count <= 4'd8;
			4'd8:	tx_count <= 4'd9;
			4'd9: tx_count <= 4'd0;
			4'd0: tx_count <= 4'd1;
		endcase
	end
end
/*************************************************************************************
 * Transmit data
 ************************************************************************************/
reg[7:0] tx_data_reg;
reg uart_tx_reg;
always @ (negedge baud_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		uart_tx_reg <= 1'bz;
		tx_data_reg <= 8'dz;
	end
	else if (!baud_clk)
	begin
		case (tx_count)
			4'd1:	begin uart_tx_reg <= 1'b0; tx_data_reg <= tx_data; end
			4'd2:	uart_tx_reg <= tx_data_reg[0];
			4'd3:	uart_tx_reg <= tx_data_reg[1];
			4'd4: uart_tx_reg <= tx_data_reg[2];
			4'd5: uart_tx_reg <= tx_data_reg[3];
			4'd6: uart_tx_reg <= tx_data_reg[4];
			4'd7: uart_tx_reg <= tx_data_reg[5];
			4'd8:	uart_tx_reg <= tx_data_reg[6];
			4'd9: uart_tx_reg <= tx_data_reg[7];
			4'd0: begin uart_tx_reg <= 1'b1;end
			default: uart_tx_reg <= 1'bz;
		endcase
	end
end
assign uart_tx = uart_tx_reg;

endmodule
