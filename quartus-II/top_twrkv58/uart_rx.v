module my_uart_rx(rst_n, baud_clk, uart_rx, rx_data, rx_enable, rx_complete, rx_error);

input rst_n;
input baud_clk;
input uart_rx;
output[7:0] rx_data;
output rx_enable;
output rx_complete;
output rx_error;

/*************************************************************************************
 * Update the rx_enable_reg
 ************************************************************************************/
reg rx_enable_reg;
always @ (negedge uart_rx or negedge rx_complete_reg or negedge rst_n)
begin
	if (!rst_n) 
	begin
		rx_enable_reg <= 1'b0;
	end
	else if (!rx_complete_reg)
		rx_enable_reg <= 1'b0;
	else if (!uart_rx)
		rx_enable_reg <= 1'b1;
end
assign rx_enable = rx_enable_reg;

/*************************************************************************************
 * Update complete flag and rx_data_reg
 ************************************************************************************/
reg[7:0] rx_data_reg;
reg rx_complete_reg;
always @ (negedge baud_clk or negedge rx_enable_reg or negedge rst_n)
begin
	if (!rst_n)
	begin
		rx_complete_reg <= 1'b1;
		rx_data_reg <= 8'd0;
	end
	else if (!rx_enable_reg)
		rx_complete_reg <= 1'b1;
	else if (!baud_clk)
	begin
		if (!rx_count)
		begin
			rx_data_reg <= rx_data_temp;
			rx_complete_reg <= 1'b0;
		end
	end
end
assign rx_data = rx_data_reg;
assign rx_complete = rx_complete_reg;

/*************************************************************************************
 * Update rx_count
 ************************************************************************************/

reg[3:0] rx_count;
always @ (posedge baud_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		rx_count <= 4'd0;
	end
	else if (baud_clk)
	begin
		case (rx_count)
			4'd1:	rx_count <= 4'd2;
			4'd2:	rx_count <= 4'd3;
			4'd3:	rx_count <= 4'd4;
			4'd4: rx_count <= 4'd5;
			4'd5: rx_count <= 4'd6;
			4'd6: rx_count <= 4'd7;
			4'd7: rx_count <= 4'd8;
			4'd8:	rx_count <= 4'd9;
			4'd9: rx_count <= 4'd0;
			4'd0: rx_count <= 4'd1;
		endcase
	end
end
/*************************************************************************************
 * Copy from uart_rx to rx_data_temp
 * If the data is incorrect, the rx_error_reg will update to 1
 ************************************************************************************/
reg[7:0] rx_data_temp;
reg rx_error_reg;
always @ (negedge baud_clk or negedge rst_n)
begin
	if (!rst_n)
	begin
		rx_error_reg <= 1'b0;
		rx_data_temp <= 8'd0;
	end
	else if (!baud_clk)
	begin
		case (rx_count)
			4'd1:	begin if (uart_rx) rx_error_reg <= 1'b1; rx_data_temp <= 4'd0; end
			4'd2:	rx_data_temp[0] <= uart_rx;
			4'd3:	rx_data_temp[1] <= uart_rx;
			4'd4: rx_data_temp[2] <= uart_rx;
			4'd5: rx_data_temp[3] <= uart_rx;
			4'd6: rx_data_temp[4] <= uart_rx;
			4'd7: rx_data_temp[5] <= uart_rx;
			4'd8:	rx_data_temp[6] <= uart_rx;
			4'd9: rx_data_temp[7] <= uart_rx;
			4'd0: begin if (!uart_rx) rx_error_reg <= 1'b1; end
		endcase
	end
end
assign rx_error = rx_error_reg;
endmodule
