module ir_recieve(
clk, rst, sda, recieve_status,recieved_data
);
input clk;
input rst;
input sda;
output recieve_status;
output [10:0] recieved_data;

reg[1:0] sda_reg;
wire falling_edge;
wire rising_edge;
reg[10:0] recieved_data;
reg[7:0] cyc_cnt;
reg[7:0] start_cnt;
reg recieve_status;
reg [31:0] time_cnt;
reg [2:0] start_bits;
reg data_start;

always @(posedge clk or negedge rst)begin
	if(!rst)begin
		start_bits <= 'h0;
		start_cnt <= 'h0;
		end
	else begin
		if(falling_edge && start_cnt < 'd3)begin
			start_bits[start_cnt]<= 1'b1;
			start_cnt <= start_cnt + 1'b1;
		end
		else begin
			start_bits <= start_bits;
			start_cnt <= start_cnt;
		end
	end
end

always @(posedge clk or negedge rst)begin
	if(!rst)begin
		time_cnt <= 'h0;
		cyc_cnt <= 'h0;
		data_start <= 'h0;
	end
	else begin
		if(start_bits == 3'b111 && data_start == 0 && time_cnt < 'd44500)
			time_cnt <= time_cnt + 1'b1;
		else if(start_bits == 3'b111 && data_start == 0 && time_cnt == 'd44500)begin
			time_cnt <= 'h0;
			data_start <= 'h1;
		end
		else begin
		if(start_bits == 3'b111 && time_cnt < 'd89000 && cyc_cnt < 'd11 && data_start == 1)begin
			time_cnt <= time_cnt + 1'b1;
			end
		else if(start_bits == 3'b111 && time_cnt == 'd89000 && cyc_cnt < 'd11 && data_start == 1)begin
			time_cnt <= 'h0;
			cyc_cnt <= cyc_cnt + 1'b1;
			end
		 else begin
			time_cnt <= time_cnt;
			cyc_cnt <= cyc_cnt;
			data_start <= data_start;
		 end
		 end
	end
end

always @(posedge clk or negedge rst)begin
	if(!rst)
		sda_reg <= 2'b11;
	else begin
		sda_reg[0] <= sda;
		sda_reg[1] <= sda_reg[0];
	end
end

assign falling_edge = (sda_reg[1:0] == 2'b10) ? 1'b1 : 1'b0;
assign rising_edge = (sda_reg[1:0] == 2'b01) ? 1'b1 : 1'b0;

always @(posedge clk or negedge rst)begin
	if(!rst)begin
		recieved_data <= 'h0;
	end
	else begin
		if(falling_edge && time_cnt > 'd30000 && time_cnt < 'd60000 && cyc_cnt < 'd11)begin
			recieved_data[cyc_cnt] <= 1'b1;
		end
		else if(rising_edge && time_cnt > 'd30000 && time_cnt < 'd60000 && cyc_cnt < 'd11)begin
			recieved_data[cyc_cnt] <= 1'b0;
		end
		else begin
			recieved_data <= recieved_data;
		end
	end
end

always @(posedge clk or negedge rst)begin
	if(!rst)
		recieve_status <= 1'b0;
	else
		recieve_status <= ( recieved_data == 11'b00011110101) ? 1'b1 : 1'b0;
		//recieve_status <= ( cyc_cnt == 11) ? 1'b1 : 1'b0;
		//recieve_status <= ( recieved_data == 22'b1010101010101010101010) ? 1'b1 : 1'b0;
end 
endmodule 