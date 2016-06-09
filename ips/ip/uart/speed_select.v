module speed_select(clk, rst_n, rx_enable, tx_enable, buad_clk_rx, buad_clk_tx);

input clk;	// 50MHz
input rst_n;	//low reset
input rx_enable;	//start clk when get data
input tx_enable;
output buad_clk_rx;	// buad_clk_rx high for transfer sample point
output buad_clk_tx;	// buad_clk_rx high for transfer sample point

parameter 	bps9600 		= 5208,	//baud is 9600bps
			 	bps19200 	= 2603,	//baud is 19200bps
				bps38400 	= 1301,	//baud is 38400bps
				bps57600 	= 867,	//baud is 57600bps
				bps115200	= 434,	//baud is 115200bps
				bps256000	= 195;	//baud is 115200bps

parameter 	bps9600_2 	= 2604,
				bps19200_2	= 1301,
				bps38400_2	= 650,
				bps57600_2	= 433,
				bps115200_2 = 217,  
				bps256000_2 = 97; 

reg[12:0] bps_para;	//max divider
reg[12:0] bps_para_2;	// half of the divider 

//----------------------------------------------------------
reg[2:0] uart_ctrl;	// uart baud selection register
//----------------------------------------------------------

always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
	begin 
		uart_ctrl <= 3'd4;	//default baudrate is 115200
	end
	else
	begin
		case (uart_ctrl)	//baud rate
			3'd0:	begin
					bps_para <= bps9600;
					bps_para_2 <= bps9600_2;
					end
			3'd1:	begin
					bps_para <= bps19200;
					bps_para_2 <= bps19200_2;
					end
			3'd2:	begin
					bps_para <= bps38400;
					bps_para_2 <= bps38400_2;
					end
			3'd3:	begin
					bps_para <= bps57600;
					bps_para_2 <= bps57600_2;
					end
			3'd4:	begin
					bps_para <= bps115200;
					bps_para_2 <= bps115200_2;
					end
			3'd5:	begin
					bps_para <= bps256000;
					bps_para_2 <= bps256000_2;
					end
			default:uart_ctrl <= 3'd0;
		endcase
	end
end

reg[12:0] cnt_rx;			// counter
reg buad_clk_rx_reg;			//baud rate clk register

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		cnt_rx <= 13'd0;
	else if (cnt_rx < bps_para && rx_enable)
		cnt_rx <= cnt_rx + 13'd1;	//start count
	else
		cnt_rx <= 13'd0;
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		buad_clk_rx_reg <= 1'b0;
	else if (cnt_rx < bps_para_2 && rx_enable && cnt_rx > 13'd10)
		buad_clk_rx_reg <= 1'b1;	// buad_clk_rx_reg high enable the sampling data
	else
		buad_clk_rx_reg <= 1'b0;
end

assign buad_clk_rx = buad_clk_rx_reg;

reg[12:0] cnt_tx;			// counter
reg buad_clk_tx_reg;			//baud rate clk register

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		cnt_tx <= 13'd0;
	else if (cnt_tx < bps_para && tx_enable)
		cnt_tx <= cnt_tx + 13'd1;	//start count
	else
		cnt_tx <= 13'd0;
end

always @ (posedge clk or negedge rst_n)
begin
	if (!rst_n)
		buad_clk_tx_reg <= 1'b0;
	else if (cnt_tx < bps_para_2 && tx_enable && cnt_tx > 13'd10)
		buad_clk_tx_reg <= 1'b1;	// buad_clk_tx_reg high enable the sampling data
	else
		buad_clk_tx_reg <= 1'b0;
end

assign buad_clk_tx = buad_clk_tx_reg;

endmodule
