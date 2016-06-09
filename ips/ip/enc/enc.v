module enc(rst_n, freq_clk, enable, pha, phb, home, index, led);

input rst_n;
input freq_clk;
input enable;
output pha;
output phb;
output home;
output index;
output led;


reg pha_reg;
reg phb_reg;
reg home_reg;
reg index_reg;
reg[7:0] pha_count;

//debug led
reg led;

// generate 100 Hz from 50 MHz
reg [31:0] count_reg;
reg out_100hz;

always @(posedge freq_clk or negedge rst_n) begin
    if (!rst_n) begin
        count_reg <= 0;
        out_100hz <= 0;
        count_reg <= 0;
        out_100hz <= 0;
	
    end 
	 else if (enable) 
	 begin
        if (count_reg < 249999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_100hz <= ~out_100hz;
        end
    end
end

/*
  we will be generating waveform like below
        _   _
  pha  | |_| |_
          _   _  
  phb  __| |_| |_
                                 _
  home <every 12 clock of pha> _| |_
                                  _
  index <every 12 clock of pha> _| |_
*/

/* process the  pha_count*/
always @ (posedge out_100hz or negedge rst_n)
begin
	if (!rst_n)
	begin
		pha_count <= 8'd12;
		led <= 1'b0; 
	end
	else if (out_100hz)
	begin
	   led <= ~led; 
		case (pha_count)
			8'd1:	pha_count <= 8'd2;
			8'd2:	pha_count <= 8'd3;
			8'd3:	pha_count <= 8'd4;
			8'd4: pha_count <= 8'd5;
			8'd5: pha_count <= 8'd6;
			8'd6: pha_count <= 8'd7;
			8'd7: pha_count <= 8'd8;
			8'd8:	pha_count <= 8'd9;
			8'd9: pha_count <= 8'd10;
			8'd10: pha_count <= 8'd11;
			8'd11: pha_count <= 8'd12;
			8'd12: pha_count <= 8'd0;
			8'd0: pha_count <=  8'd1;
		endcase
	end
end


/*process the pha signal*/
always @ (posedge out_100hz or negedge rst_n)
begin
	if (!rst_n)
	begin
		pha_reg <= 1'b1;
	end
	else if (out_100hz)
	begin
		case (pha_reg)
			1'd1:	
			begin
			pha_reg <=  1'd0;
			phb_reg <= 1'd1;
			end
			1'd0: 
			begin
			pha_reg <=  1'd1;
			phb_reg <=  1'd0;
			end
		endcase
	end
end
assign pha = pha_reg;
assign phb = phb_reg;

/*process the home signal*/
always @ (posedge out_100hz or negedge rst_n)
begin
	if (!rst_n)
	begin
		home_reg <= 1'b0;
	end
	else if (out_100hz)
	begin
		case (pha_count)
			8'd12:	home_reg <=  1'd1;
			default: home_reg <=  1'd0;
		endcase
	end
end
assign home = home_reg;

/*process the index signal*/
always @ (posedge out_100hz or negedge rst_n)
begin
	if (!rst_n)
	begin
		index_reg <= 1'b0;
	end
	else if (out_100hz)
	begin
		case (pha_count)
			8'd12:	index_reg <=  1'd1;
			default: index_reg <=  1'd0;
		endcase
	end
end
assign index = index_reg;

endmodule