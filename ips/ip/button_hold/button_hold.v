`timescale 1ns / 1ps
//**********************************************************************
// File: button_hold.v
// Module:button_hold
// by Robin zhang 
//**********************************************************************
module button_hold(
 rst,clk,out_status,pin_select,press_done
);

input rst;
input clk;
input [15:0]  pin_select;

output [25:0] out_status;
output press_done;
reg [25:0] out_status;
reg [31:0] counter;
reg pull_done;
reg press_done;

always @(posedge clk or negedge rst)begin
	if(!rst)
		counter <= 'h0;
	else
		counter <= ((counter < 32'hFFFFFFFF) && pin_select != 'h0) ? (counter + 1'b1) : 'h0;
end

always@(posedge clk or negedge rst)begin
	if(!rst)
		out_status <= 26'h3ffffff;
	else begin
		case(pin_select[7:0])
			8'h41 : out_status[0] <= pull_done;
			8'h42 : out_status[1] <= pull_done;
			8'h43 : out_status[2] <= pull_done;
			8'h44 : out_status[3] <= pull_done;
			8'h45 : out_status[4] <= pull_done;
			8'h46 : out_status[5] <= pull_done;
			8'h47 : out_status[6] <= pull_done;
			8'h48 : out_status[7] <= pull_done;
			8'h49 : out_status[8] <= pull_done;
			8'h4a : out_status[9] <= pull_done;
			8'h4b : out_status[10] <= pull_done;
			8'h4c : out_status[11] <= pull_done;
			8'h4d : out_status[12] <= pull_done;
			8'h4e : out_status[13] <= pull_done;
			8'h4f : out_status[14] <= pull_done;
			8'h50 : out_status[15] <= pull_done;
			8'h51 : out_status[16] <= pull_done;
			8'h52 : out_status[17] <= pull_done;
			8'h53 : out_status[18] <= pull_done;
			8'h54 : out_status[19] <= pull_done;
			8'h55 : out_status[20] <= pull_done;
			8'h56 : out_status[21] <= pull_done;
			8'h57 : out_status[22] <= pull_done;
			8'h58 : out_status[23] <= pull_done;
			8'h59 : out_status[24] <= pull_done;
			8'h5a : out_status[25] <= pull_done;
			default : out_status <= 26'h3ffffff;
		endcase
	end
end

always @(posedge clk or negedge rst)begin
	if(!rst)
		pull_done <= 1'bz;
	else begin
		pull_done <= ((pin_select[15:8] == 8'h53) && (counter < 'd3500000)) ? 1'b0 
						: ((pin_select[15:8] == 8'h4c) && (counter < 'd100000000)) ? 1'b0
						: ((pin_select[15:8] == 8'h56) && (counter < 'd500000000)) ? 1'b0 
						: (pin_select[15:8] == 8'h44) ? 1'b0 
						: (pin_select[15:8] == 8'h48) ? 1'b1 : 1'bz;
	end
end

always @(posedge clk or negedge rst)begin
	if(!rst)
		press_done <= 1'b0;
	else
		press_done <= ((pin_select[15:8] == 8'h53) && (counter > 'd3500000)) ? 1'b1 
						: ((pin_select[15:8] == 8'h4c) && (counter > 'd100000000)) ? 1'b1
						: ((pin_select[15:8] == 8'h56) && (counter > 'd500000000)) ? 1'b1 
						: (pin_select[15:8] == 8'h44) ? 1'b1 
						: (pin_select[15:8] == 8'h48) ? 1'b1 : 1'b0;
end
endmodule 