`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/11/2016
Founction: Send out capture value
Note:
****************************************************************************/
module captuer_tx( 
clk,rst_n,tx_start,capture_ready,periodcounter,dutycyclecounter,tx_data,tx_complete,capture_tx_rst,tx_end,bps_start_t
);

input clk;
input rst_n;
input capture_ready;
input tx_complete;
input bps_start_t;
input capture_tx_rst;
input[31:0] periodcounter;
input[31:0] dutycyclecounter;

output tx_start;
output tx_end;
output [7:0] tx_data;

reg tx_start;
reg[15:0] tx_counter;
reg[3:0] tx_count;
reg[7:0] tx_data;
reg tx_end;

always @ (posedge clk or negedge rst_n) begin

	if (!rst_n)begin
		tx_start <= 1'b1;
        tx_data <= 'hzz;
	end
	else if(capture_ready && (tx_counter >'d600))begin
	   case(tx_count)
			4'b0000:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= periodcounter[7:0];
			end
			4'b0001:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= periodcounter[15:8];
			end
			4'b0010:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= periodcounter[23:16];
			end
			4'b0011:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= periodcounter[31:24];
			end
			4'b0100:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= dutycyclecounter[7:0];
			end
			4'b0101:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= dutycyclecounter[15:8];
			end
			4'b0110:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= dutycyclecounter[23:16];
			end
			4'b0111:begin
				tx_start <= tx_start ? 1'b0:1'b1;
				tx_data <= dutycyclecounter[31:24];
			end
			default:begin
				tx_start <= 1'b1;
				tx_data <= 'hzz;
			end
		endcase
	end

end 

always @ (posedge tx_complete or negedge capture_tx_rst) begin

	if (!capture_tx_rst)begin
		tx_count <= 'h0;
		tx_end <= 'h0;
	end
	else if(tx_complete && (tx_count<7)&&capture_ready)begin
		tx_count <= tx_count + 1'b1;
	end
	else begin
		tx_end <= 'h1;
		end
end

always @ (posedge clk or negedge rst_n) begin

	if (!rst_n)begin
		tx_counter <= 'h0;
	end
	else if(!bps_start_t)begin
		tx_counter <= tx_counter + 1'b1;
	end
	else begin
		tx_counter <= 'h0;
		end
end

endmodule 