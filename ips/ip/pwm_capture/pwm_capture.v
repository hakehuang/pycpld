`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: pwm capture deal
Note:
****************************************************************************/
module pwm_capture(
pwm_input,clk,rst_n,enable,tx_start,tx_data,tx_complete,capture_tx_rst,bps_start_t
);

input pwm_input;
input clk;
input rst_n;
input enable;
input tx_complete;
input capture_tx_rst;
input bps_start_t;
output tx_start;
output[7:0] tx_data;

reg ready;
reg[31:0] counter;
reg[31:0] pos_counter;
reg[31:0] neg_counter;
reg[31:0] nextpos_counter;
reg[31:0] periodcounter;
reg[31:0] dutycyclecounter;
reg pos_counter_flag;
reg neg_counter_flag;
reg nextpos_counter_flag;
wire pos_btn;
wire neg_btn;
wire tx_end;


/*******************************************************************************
*counter
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
  if(!rst_n) begin
   counter <= 'h0;
   end
  else if(enable) begin
	counter <= (counter < 32'hFFFFFFFF) ? (counter + 1'b1) : 'h0 ;
   end
end


/*******************************************************************************
*Instance
*********************************************************************************/
neg_capture neg_capture_instance(
					.pwm_input(pwm_input),
					.clk(clk),
					.rst_n(rst_n),
					.enable(enable),
					.neg_btn(neg_btn)
);


pos_capture pos_capture_instance(
					.pwm_input(pwm_input),
					.clk(clk),
					.rst_n(rst_n),
					.enable(enable),
					.pos_btn(pos_btn)
);

captuer_tx      captuer_tx_instance( 
							.clk(clk),
							.rst_n(rst_n),
							.tx_start(tx_start),
							.capture_ready(ready),
							.periodcounter(periodcounter),
							.dutycyclecounter(dutycyclecounter),
							.tx_data(tx_data),
							.tx_complete(tx_complete),
							.capture_tx_rst(capture_tx_rst),
							.tx_end(tx_end),
							.bps_start_t(bps_start_t)
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
*Capture neg counter value
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		neg_counter <= 'h0;
		neg_counter_flag <= 'h0;
	end
	else if(neg_btn && pos_counter_flag && (neg_counter_flag != 1'b1))begin
		neg_counter <= counter;
		neg_counter_flag <= 1'b1;
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
	else if(pos_btn && pos_counter_flag && neg_counter_flag && (nextpos_counter_flag != 1'b1))begin
		nextpos_counter <= counter;
		nextpos_counter_flag <= 1'b1;
	end
end

/*******************************************************************************
*Calculate the dutycycle
*********************************************************************************/
always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		dutycyclecounter <= 'h0;
	end
	else if(neg_counter_flag && pos_counter_flag)begin
		dutycyclecounter <= neg_counter - pos_counter;
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
	else if(neg_counter_flag && pos_counter_flag && nextpos_counter_flag)begin
		periodcounter <= nextpos_counter - pos_counter;
		ready <=(tx_end) ? 'h0:'h1;
	end
end

endmodule 