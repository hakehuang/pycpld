module spi_ctrl_reduced(
clk,rst_n,sck,mosi,miso,cs_n,spi_tx_en,spi_rx_en,mode_select,receive_status
);

parameter DATA_LENGTH = 64;

input clk,rst_n,miso;
input mode_select;

output sck,mosi,cs_n;
output receive_status;

input spi_tx_en;
input spi_rx_en;

wire spi_over;

wire receive_status;


reg spi_clk;
reg[7:0] clk_count;
reg[7:0] rst_count;
reg rst_flag;
assign cs_n = 1'b0;
/*
	spi baud rate is calculated by clk / 100 / 3
	as we count 3 sck change to be a full period 
*/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		clk_count <= 8'h0;
		spi_clk <= 1'b0;
		end
	else begin 
		if(clk_count < 8'd100)
			clk_count <= clk_count + 1'b1;
		else begin
			clk_count <= 8'h0;
			spi_clk <= ~spi_clk;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		rst_flag <= 1'b0;
		rst_count <= 'h0;
		end
	else begin 
		if(rst_count<8'd20)
			rst_count <= rst_count + 1'b1;
		else 
			rst_flag <= 1'b1;
		end
end

spi_master_reduced #(.DATA_LENGTH(DATA_LENGTH)) spi_master_reduced_instance(
					.clk(spi_clk),
					.rst_n(rst_flag),
					.spi_miso(miso),
					.spi_mosi(mosi),
					.spi_clk(sck),
					.spi_tx_en(spi_tx_en),
					.spi_rx_en(spi_rx_en),
					.mode_select(mode_select),
					.receive_status(receive_status)
);

endmodule 