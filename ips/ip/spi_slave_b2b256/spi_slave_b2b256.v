`timescale 1ns / 1ps

/*******************************************************************************
* Engineer: Robin zhang

* Create Date: 2016.09.10

* Module Name: spi_slave_b2b

* this module will get 64 bytes and then return the count 64 at next clks
*******************************************************************************/
module spi_slave_b2b256(
clk,sck,mosi,miso,ssel,rst_n,recived_status,spi_sel
);

input clk;
input rst_n;
input sck,mosi,ssel;
input spi_sel;
output miso;
output recived_status;

reg recived_status;
reg[2:0] sckr;
reg[2:0] sselr;
reg[1:0] mosir;
reg[2:0] bitcnt;
reg[7:0] bytecnt;
reg byte_received;  // high when a byte has been received
reg [7:0] byte_data_received;
reg[7:0] received_memory;
reg [7:0] byte_data_sent;
reg [7:0] cnt;
reg [7:0] first_byte;

wire ssel_active;
wire sck_risingedge;
wire sck_fallingedge;
wire ssel_startmessage;
wire ssel_endmessage;
wire mosi_data;
/*******************************************************************************
*detect the rising edge and falling edge of sck
*******************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sckr <= 3'h0;
	else
		sckr <= {sckr[1:0],sck};
end

assign sck_risingedge = (sckr[2:1] == 2'b01) ? 1'b1 : 1'b0;
assign sck_fallingedge = (sckr[2:1] == 2'b10) ? 1'b1 : 1'b0;

/*******************************************************************************
*detect starts at falling edge and stops at rising edge of ssel
*******************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		sselr <= 3'h0;
	else
		sselr <= {sselr[1:0],ssel};
end

assign  ssel_active = (~sselr[1]) ? 1'b1 : 1'b0;  // SSEL is active low
assign  ssel_startmessage = (sselr[2:1]==2'b10) ? 1'b1 : 1'b0;  // message starts at falling edge
assign  ssel_endmessage = (sselr[2:1]==2'b01) ? 1'b1 : 1'b0;  // message stops at rising edge

/*******************************************************************************
*read from mosi
*******************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		mosir <= 2'h0;
	else
		mosir <={mosir[0],mosi};
end

assign mosi_data = mosir[1];

/*******************************************************************************
*SPI slave reveive in 8-bits format
*******************************************************************************/
always @(posedge clk or negedge rst_n)begin
  if(!rst_n)begin
	bitcnt <= 3'b000;
	byte_data_received <= 8'h0;
  end
  else begin
   if(~ssel_active)
     bitcnt <= 3'b000;
   else begin
      if(sck_risingedge)begin
        bitcnt <= bitcnt + 3'b001;
        byte_data_received <= {byte_data_received[6:0], mosi_data};
      end
		else begin
		  bitcnt <= bitcnt;
        byte_data_received <= byte_data_received;
		end
	  end
  end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		byte_received <= 1'b0;
	else
		byte_received <= ssel_active && sck_risingedge && (bitcnt==3'b111);
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)begin
		bytecnt <= 8'h0;
		received_memory <= 8'h0;
	end
   else begin 
	 if(byte_received) begin
		  bytecnt <= bytecnt + 1'b1;
		  if(spi_sel)
            received_memory <= (byte_data_received == bytecnt) ? (received_memory + 1'b1) : received_memory;
		  else begin
		  if((bytecnt == 'h0 && byte_data_received == 'h2) || first_byte == 8'h2)
				received_memory <= (byte_data_received == bytecnt + 'h2) ? (received_memory + 1'b1) : received_memory;
			else
				received_memory <= (byte_data_received == bytecnt + 'h1) ? (received_memory + 1'b1) : received_memory;
			end
	 end
	 else begin
		  bytecnt <= bytecnt;
	     received_memory <= received_memory;
	 end
	end
end
always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		first_byte <= 'h0;
	else if(bytecnt == 'h0 && byte_data_received == 'h2)
		first_byte <= byte_data_received;
	else
		first_byte <= first_byte;
end
/*******************************************************************************
*SPI  slave send date 
*******************************************************************************/
always @(posedge clk or negedge rst_n) begin
	 if(!rst_n)
	  cnt<= 8'h1;
	 else begin
	  if((first_byte == 8'h2) && (!recived_status))
				cnt<= 8'h2;
     else if(byte_received && recived_status) 
				cnt<=cnt+8'h1;  // count the messages
	  else
				cnt<=cnt;
    end
end

reg [7:0] byte_data_sent_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
		byte_data_sent <= 8'hff;
		byte_data_sent_reg <= 8'hff;
		end
	 else begin
		byte_data_sent <= spi_sel ? 8'hff : 8'h0;
      if(ssel_active && sck_fallingedge) begin
          if(bitcnt==3'b000)begin
               byte_data_sent <= spi_sel ? byte_data_sent_reg - 1'b1 : cnt;  // after that, we send 0s
					byte_data_sent_reg <= byte_data_sent_reg - 1'b1;
					end
           else
               byte_data_sent <= {byte_data_sent[6:0], 1'b0};
		end
		else
			byte_data_sent <= byte_data_sent;
	end
end

assign miso = byte_data_sent[7];  // send MSB first

always @(posedge clk or negedge rst_n) begin
	 if(!rst_n)
	  recived_status <= 1'b0;
	 else begin
	  if(spi_sel)
            recived_status <= (received_memory == 8'd256) ? 1'b1 : 1'b0;
        else
            recived_status <= (received_memory == 8'd64) ? 1'b1 : 1'b0;
	  end
end

endmodule