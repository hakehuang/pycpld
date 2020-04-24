`timescale 1ns / 1ps
//**********************************************************************
// File: spi_master.v
// Module:spi_master
// by Robin zhang 
//**********************************************************************
module spi_master_reduced(

clk,rst_n,

spi_miso,spi_mosi,spi_clk,

spi_tx_en,spi_rx_en,mode_select,receive_status

);

parameter DATA_LENGTH = 64;

input clk;

input rst_n;

input spi_miso;

output spi_mosi;

output spi_clk;

input spi_tx_en;

output receive_status;

input spi_rx_en;

input mode_select;

reg[8:0] data_count;

reg[7:0] recv_detect;

reg[7:0] spi_tx_db;

reg[4:0] cnt8;

reg spi_clkr;

reg spi_mosir;

reg spi_mosir1;

reg receive_status;

reg[7:0] spi_rx_dbr;

reg[7:0] spi_rx_dbr1;

wire[7:0] spi_rx_db;

wire[4:0] mode_reg;

wire[4:0] start_reg;
/***********************************************************************
*detect spi mode
***********************************************************************/
assign mode_reg = mode_select ? 5'd18 : 5'd17;

assign start_reg = mode_select ? 5'd1 : 5'd0;

/***********************************************************************
*control the spi timimg
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		cnt8 <= 5'd0;
		data_count <= 9'h0;
		spi_tx_db  <= 8'h0;
		recv_detect <= 8'h0;
		end
	else if((spi_tx_en || spi_rx_en) && ((data_count < DATA_LENGTH) )) begin
		if(cnt8 < mode_reg)
			cnt8 <= cnt8+1'b1;
		else begin
			if(spi_tx_en && spi_rx_en) begin
				cnt8 <= 5'd0;
				data_count <= data_count + 1'b1;
				spi_tx_db <= spi_tx_db + 1'b1;
				recv_detect <= (spi_rx_db == data_count) ? (recv_detect+1'b1) : recv_detect;
				end
			else begin
				if(spi_tx_en) begin
					cnt8 <= 5'd0;
					data_count <= data_count + 1'b1;
					spi_tx_db <= spi_tx_db + 1'b1;
				end
				else begin
					cnt8 <= 5'd0;
					data_count <= data_count + 1'b1;
					recv_detect <= (spi_rx_db == data_count) ? (recv_detect+1'b1) : recv_detect;
				end
			end
		end
	end
	else begin 
	 cnt8 <= 5'd0;
	 data_count <= data_count;
	end
end

/***********************************************************************
*generate spi clk
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		spi_clkr <= mode_select ? 1'b1 : 1'b0;
	else if(cnt8 > start_reg && cnt8 < mode_reg)
				spi_clkr <= ~spi_clkr;
			else
				spi_clkr <= spi_clkr;
end

assign spi_clk = spi_clkr;

/***********************************************************************
*spi master output data
***********************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_mosir <= 1'b1;
	else if(spi_tx_en) begin
				case(cnt8[4:1])
				   4'd0: spi_mosir <= spi_tx_db[7];
					
					4'd1: spi_mosir <= spi_tx_db[6];

					4'd2: spi_mosir <= spi_tx_db[5];

					4'd3: spi_mosir <= spi_tx_db[4];

					4'd4: spi_mosir <= spi_tx_db[3];

					4'd5: spi_mosir <= spi_tx_db[2];

					4'd6: spi_mosir <= spi_tx_db[1];

					4'd7: spi_mosir <= spi_tx_db[0];

					default: spi_mosir <= 1'b1;
				endcase
			end
	else 
		spi_mosir <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) 
		spi_mosir1 <= 1'b1;
	else if(spi_tx_en) begin
				case(cnt8[4:1])
				   4'd1: spi_mosir1 <= spi_tx_db[7];
					
					4'd2: spi_mosir1 <= spi_tx_db[6];

					4'd3: spi_mosir1 <= spi_tx_db[5];

					4'd4: spi_mosir1 <= spi_tx_db[4];

					4'd5: spi_mosir1 <= spi_tx_db[3];

					4'd6: spi_mosir1 <= spi_tx_db[2];

					4'd7: spi_mosir1 <= spi_tx_db[1];

					4'd8: spi_mosir1 <= spi_tx_db[0];

					default: spi_mosir1 <= 1'b1;
				endcase
			end
	else 
		spi_mosir1 <= 1'b1;
end

assign spi_mosi = mode_select ? spi_mosir1 : spi_mosir;


endmodule