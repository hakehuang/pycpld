module sw_pulse(clk,rst_n,sw_en,sw_out);

input clk;
input rst_n;
input sw_en;
output sw_out;

reg sw_signal;

reg [19:0]count;
always @ (posedge clk or negedge rst_n) 
begin
	if(!rst_n)
		begin 
			count <= 20'b0;	
			sw_signal <= 1'b1;
		end
	else if(!sw_en)	
		begin
			count <= 20'b0;	
			sw_signal <= 1'b1;
		end
	else if(sw_en)
		begin
		   if( !count[19])
				begin
					count <= count + 1'b1;	
					sw_signal <= 1'b0;
				end
			else
				begin
					count <= count;	
					sw_signal <= 1'b1;
				end
		end
	else	
		begin 
			count <= 20'b0;	
			sw_signal <= 1'b1;
		end
end


assign sw_out = sw_signal;

endmodule
