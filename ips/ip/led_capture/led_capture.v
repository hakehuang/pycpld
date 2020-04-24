`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: pwm capture deal
Note:
****************************************************************************/
module led_capture(
led_input,clk,rst_n,tx_start,tx_data
);

input led_input;
input clk;
input rst_n;
output tx_start;
output[7:0] tx_data;

reg ready;
reg[31:0] counter;
reg[31:0] pos_counter;
reg[31:0] nextpos_counter;
reg[31:0] periodcounter;
reg pos_counter_flag;
reg nextpos_counter_flag;
wire pos_btn;


/*******************************************************************************
*counter
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
  if(!rst_n) begin
   counter <= 'h0;
   end
  else begin
	counter <= (counter < 32'hFFFFFFFF) ? (counter + 1'b1) : 'h0 ;
   end
end


/*******************************************************************************
*Instance
*********************************************************************************/
pos_capture pos_capture_instance(
					.led_input(led_input),
					.clk(clk),
					.rst_n(rst_n),
					.pos_btn(pos_btn)
);

captuer_tx      captuer_tx_instance( 
							.clk(clk),
							.rst_n(rst_n),
							.tx_start(tx_start),
							.capture_ready(ready),
							.periodcounter(periodcounter),
							.tx_data(tx_data),
							.counter(counter),
							.led_input(led_input)
							);

/*******************************************************************************
*Capture pos counter value
*********************************************************************************/

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		pos_counter <= 'h0;
		pos_counter_flag <= 'h0;
	end
	else if(pos_btn && (pos_counter_flag != 1'b1))begin
		pos_counter <= counter;
		pos_counter_flag <= 1'b1;
	end
end

/*******************************************************************************
*Capture next pos counter value
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		nextpos_counter <= 'h0;
		nextpos_counter_flag <= 'h0;
	end
	else if(pos_btn && pos_counter_flag && (nextpos_counter_flag != 1'b1))begin
		nextpos_counter <= counter;
		nextpos_counter_flag <= 1'b1;
	end
end

/*******************************************************************************
*Calculate the period
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		periodcounter <= 'h0;
		ready <= 'h0;
	end
	else if(pos_counter_flag && nextpos_counter_flag)begin
		periodcounter <= nextpos_counter - pos_counter;
		ready <= 'h1;
	end
end

endmodule 