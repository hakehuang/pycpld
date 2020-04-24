`timescale	1ns/1ps

module test_spi_master;

reg clk; 
reg spi_tx_rd_en_256;
reg spi_rx_rd_en_256;
reg spi_rd_rst_256;
reg mode_rd_select_256;

wire sm_rd_sck_256;
wire sm_rd_mosi_256;
wire sm_rd_miso_256;
wire sm_rd_cs_n_256;
wire spi_receive_rd_status_256;


spi_ctrl_reduced #(.DATA_LENGTH(256)) spi_ctrl_reduced_instance_256(
              .clk(clk),
              .rst_n(spi_rd_rst_256),
              .sck(sm_rd_sck_256),
              .mosi(sm_rd_mosi_256),
              .miso(sm_rd_miso_256),
              .cs_n(sm_rd_cs_n_256),
              .spi_tx_en(spi_tx_rd_en_256),
              .spi_rx_en(spi_rx_rd_en_256),
              .mode_select(mode_rd_select_256),
              .receive_status(spi_receive_rd_status_256)
                            );
									 
  initial 
    begin
     spi_rd_rst_256 = 1'b0;
     spi_tx_rd_en_256 = 1'b1;
     spi_rx_rd_en_256 = 1'b1;
     mode_rd_select_256 = 1'b0;
		 clk = 0;
	   #10 spi_rd_rst_256 = 1;
	   #100000000
	   $stop;
	 end

always begin
	 //50M HZ about 20ns one cycle
    #10 clk = ! clk;
end
endmodule
									 
									 


