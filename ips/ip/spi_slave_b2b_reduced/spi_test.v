`timescale	1ns/1ps

module test_spi;

reg clk;  
reg spi_rd_slave_rst_b2b;
reg ss_rd_sck_b2b;
reg ss_rd_mosi_b2b;
wire ss_rd_miso_b2b;
reg ss_rd_ssel_b2b;
wire recived_status;



integer i;

spi_slave_b2b_reduced		spi_slave_b2b_instance_reduced(
							.clk(clk),
							.sck(ss_rd_sck_b2b),
							.mosi(ss_rd_mosi_b2b),
							.miso(ss_rd_miso_b2b),
							.ssel(ss_rd_ssel_b2b),
							.rst_n(spi_rd_slave_rst_b2b),
							.recived_status(recived_status)
                            );
									 
  initial 
    begin
		spi_rd_slave_rst_b2b = 0;
		clk = 0;
		ss_rd_mosi_b2b = 0;
		ss_rd_ssel_b2b = 1;
		ss_rd_sck_b2b = 0;
		#10 spi_rd_slave_rst_b2b = 1;
		//chip select active low
		#10 ss_rd_ssel_b2b = 1'b0;
		
	   for (i=0; i< 32; i=i+1) begin
			//bit 0
		   #25 ss_rd_mosi_b2b = 1'b1;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
			//bit 1
		   #25 ss_rd_mosi_b2b = 1'b0;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
		   //bit 2
			#25 ss_rd_mosi_b2b = 1'b1;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
			//bit 3
			#25 ss_rd_mosi_b2b = 1'b0;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
			//bit 4
			#25 ss_rd_mosi_b2b = 1'b1;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
			//bit 5
			#25 ss_rd_mosi_b2b = 1'b0;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
			// bit 6
			#25 ss_rd_mosi_b2b = 1'b1;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;
			//bit 7
			#25 ss_rd_mosi_b2b = 1'b0;
			#25 ss_rd_sck_b2b = 1'b1;
			#50 ss_rd_sck_b2b = 1'b0;	
		end
	 
	 
	   $stop;
	 end

always begin
	 //50M HZ about 20ns one cycle
    #10 clk = ! clk;
end
endmodule
									 
									 


