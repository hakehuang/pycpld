`timescale 1ns/1ps
/***************************************************************************
Name:
Date: 7/18/2016
Founction: I2C top module
Note:
****************************************************************************/
module I2C_MASTER(clk,rst_n,sda,scl,RD_EN,WR_EN,receive_status

);

input clk;
input rst_n;
input RD_EN;
input WR_EN;
reg WR,RD;


output scl;
output receive_status;

inout sda;

reg scl_clk;
reg receive_status;
reg[7:0] clk_div;
reg[7:0] send_count;
wire[7:0] data;

reg[7:0] data_reg;

wire ack;

reg[7:0] send_memory[31:0];
reg[7:0] receive_memory[31:0];

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		scl_clk <= 1'b0;
		clk_div <= 'h0;
		send_memory[0] <= 8'd0;
		send_memory[1] <= 8'd1;
		send_memory[2] <= 8'd2;
		send_memory[3] <= 8'd3;
		send_memory[4] <= 8'd4;
		send_memory[5] <= 8'd5;
		send_memory[6] <= 8'd6;
		send_memory[7] <= 8'd7;
		send_memory[8] <= 8'd8;
		send_memory[9] <= 8'd9;
		send_memory[10] <= 8'd10;
		send_memory[11] <= 8'd11;
		send_memory[12] <= 8'd12;
		send_memory[13] <= 8'd13;
		send_memory[14] <= 8'd14;
		send_memory[15] <= 8'd15;
		send_memory[16] <= 8'd16;
		send_memory[17] <= 8'd17;
		send_memory[18] <= 8'd18;
		send_memory[19] <= 8'd19;
		send_memory[20] <= 8'd20;
		send_memory[21] <= 8'd21;
		send_memory[22] <= 8'd22;
		send_memory[23] <= 8'd23;
		send_memory[24] <= 8'd24;
		send_memory[25] <= 8'd25;
		send_memory[26] <= 8'd26;
		send_memory[27] <= 8'd27;
		send_memory[28] <= 8'd28;
		send_memory[29] <= 8'd29;
		send_memory[30] <= 8'd30;
		send_memory[31] <= 8'd31;
		end
	else begin 
	   if(clk_div > 'd100)begin
				scl_clk <= ~scl_clk;
				clk_div <= 'h0;
				end
	   else
		clk_div <= clk_div + 1'b1;
		end
	
end

always @(posedge ack or negedge rst_n)begin
	if(!rst_n)begin
		send_count <= 'h0;
	end
	else begin
		if((send_count < 10'd32) && (ack))begin
			send_count <= send_count + 1'b1;
			receive_memory[send_count] <= RD_EN ? data : 8'h0;
			end	
		else begin
			send_count <= send_count;
			end
		end	
end

always @(posedge clk or negedge rst_n)begin
   if(!rst_n)
	receive_status <= 1'b0;
	else 		
	receive_status <=(receive_memory[31]== 31) ? 1'b1 : 1'b0;
end

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)begin	
		WR         <= 1'b0;
		RD         <= 1'b0;
		data_reg   <= 'h0;
	end
	else begin
	   if(send_count == 8'd32)begin
			WR         <= 1'b0;
			RD         <= 1'b0;
			end
		else begin
		if(RD_EN)
			RD         <= 1'b1;
		else if(WR_EN)begin
			WR         <= 1'b1;
			data_reg       <= send_memory[send_count];
			end
		end
	end
		
end

assign data = WR_EN ? data_reg :  8'hz;

I2C_wr I2C_wr_instance(
					.sda(sda),
					.scl(scl),
					.ack(ack),
					.rst_n(rst_n),
					.clk(scl_clk),
					.WR(WR),
					.RD(RD),
					.data(data)
);

endmodule 