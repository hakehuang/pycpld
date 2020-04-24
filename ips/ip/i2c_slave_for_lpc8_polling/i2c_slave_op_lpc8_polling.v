`timescale	1ns/1ps
//**********************************************************************
// File: i2c_slave_op_lpc8_polling.v
// Module:i2c_slave_op_lpc8_polling
// by Robin zhang 
//**********************************************************************
module	i2c_slave_op_lpc8_polling(
		reset_n,
		clock,
		sda_out,
		sda_in,
		scl,
		sda_en,    
		ip_select
		);
		
input		clock;   
input		reset_n;
input		sda_in;
input		scl;
input    ip_select;

output 		sda_en;
reg		   sda_en;
output 		sda_out;

reg 		reset_n1;
reg 		reset_n2;
reg 		scl_regi0; 
reg 		scl_regi;
reg 		sda_regi0;
reg 		sda_regi;
reg		start_bus_reg;
reg		stop_bus_reg; 
reg   [7:0]  receive_count; 
reg   [7:0]  send_count; 
reg	[7:0] 	data_reg0;  
reg	[7:0]	data_reg1; 
 
reg	[6:0]	addr_in_reg;
reg	[3:0]	main_state; 
reg	[2:0]	addr_in_state;
reg	[3:0]	data_in_state;
reg	[3:0]	data_out_state;

reg		sda_out1;		// ACK
reg 		sda_out2;		// data_to_master
 
reg		write_read;
reg	[1:0]	ack_state; 
 
reg		flag;
 
reg[7:0]      send_flag;
reg[7:0] data_in_reg;
reg[7:0] data_out_reg;
reg[7:0] receive_status;
assign sda_out = flag ? sda_out2 : sda_out1;

// ----------------------------------------------------------------
// reset_n, scl, sda_in -> two stages registered 
always@(posedge clock)
begin
	reset_n1 <= reset_n;
	reset_n2 <= reset_n1; 
end
  
always@(posedge clock or negedge reset_n2)
begin
      if(!reset_n2)
	begin
             scl_regi  <= 1'b0;
             sda_regi  <= 1'b0;
             scl_regi0 <= 1'b0;
             sda_regi0 <= 1'b0;
	end
      else
	begin
             scl_regi0 <= scl_regi;
             scl_regi  <= scl;
             sda_regi0 <= sda_regi;
             sda_regi  <= sda_in;
	end
end

// ----------------------------------------------------------------
// to test start condition: scl=1, sda_in=100

always@(posedge clock or negedge reset_n2)
 begin
  if(!reset_n2)begin
     start_bus_reg <= 1'b0;
	  send_flag <= 'h0;
	  end
  else
     begin
       if({sda_regi0,sda_regi,sda_in}==3'b100 && {scl_regi0,scl_regi,scl}==3'b111)begin
					send_flag <= send_flag + 1'b1;
					start_bus_reg <= 1'b1;
			end
       else begin
            start_bus_reg <= 1'b0;
				send_flag <= send_flag;
				end
     end
 end
 
// ----------------------------------------------------------------
// to test stop condition: scl=1, sda_in=011

always@(posedge clock or negedge reset_n2)
 begin
  if(!reset_n2)
     stop_bus_reg <= 1'b0;
  else
     begin
       if({sda_regi0,sda_regi,sda_in}==3'b011 && {scl_regi0,scl_regi,scl}==3'b111)
            stop_bus_reg <= 1'b1;
       else
            stop_bus_reg <= 1'b0;
     end
 end
 
//----------------- addr in statemachine -------------------------------
 
parameter addr_in6   		= 3'h0;			// chip_id
parameter addr_in5   		= 3'h1;
parameter addr_in4   		= 3'h2;
parameter addr_in3   		= 3'h3;
parameter addr_in2   		= 3'h4;
parameter addr_in1   		= 3'h5;
parameter addr_in0   		= 3'h6;
parameter addr_end   		= 3'h7;
       
//----------------- data in statemachine -------------------------------

parameter   data_in7   		= 4'h0;
parameter   data_in6   		= 4'h1;
parameter   data_in5   		= 4'h2;
parameter   data_in4   		= 4'h3;
parameter   data_in3   		= 4'h4;
parameter   data_in2   		= 4'h5;
parameter   data_in1   		= 4'h6;
parameter   data_in0   		= 4'h7;
parameter   data_end   		= 4'h8;

//----------------- data out statemachine -------------------------------
 parameter   data_out7   		= 4'h0;
 parameter   data_out6   		= 4'h1;
 parameter   data_out5   		= 4'h2;
 parameter   data_out4   		= 4'h3;
 parameter   data_out3   		= 4'h4;
 parameter   data_out2   		= 4'h5;
 parameter   data_out1   		= 4'h6;
 parameter   data_out0   		= 4'h7;
 parameter   data_out_end  = 4'h8; 

//----------------- main statemachine ------------------------------
parameter idle                       =4'h0;
parameter addr_read                  =4'h1;
parameter write_read_flag            =4'h2;
parameter addr_ack                   =4'h3;
parameter data_write	                =4'h4;
parameter data_in_ack                =4'h5;			 	 
parameter data_read                  =4'h6;
parameter data_out_ack               =4'h7;
parameter if_rep_start               =4'h8; 

//------------------------------------------------------------------	
//main state machine
reg send_flag_rst;
always @(posedge clock or negedge reset_n2)begin
	if(!reset_n2)
	begin
		main_state <= idle;
		write_read <= 1'b0;
		receive_count <= 8'h0;
		send_count <= 8'h0;
		data_out_reg <= 8'h0;
		send_flag_rst <= 1'b0;
	end
	else if(ip_select == 1'b1 && send_flag == 8'd3 && send_flag_rst == 1'b0)begin
		main_state	<= addr_read;
		send_flag_rst <= 1'b1;
	end
	else if(ip_select == 1'b0 && send_flag == 8'd4 && send_flag_rst == 1'b0)begin
		main_state	<= addr_read;
		send_flag_rst <= 1'b1;
	end	
	else
	begin
		case (main_state)	
		idle:
		begin
					    
			if(start_bus_reg)	// receive start from SDA
			begin
				main_state	<= addr_read;							 
			end
			else					 
			begin
				main_state	<= idle;						     
			end									     					  
		end
						
		addr_read:	// read chip_id from the master
		begin				    
			if(addr_in_state==addr_end)
				main_state	 <= write_read_flag;
			else					        
				main_state	 <= addr_read;
		end	
				
		write_read_flag:	// read R/W flag following chip_id 			         
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				write_read <= sda_in;   	                                                      
				main_state <= addr_ack;
			end	
			else
				main_state <= write_read_flag;			 
		end
		addr_ack:	// send addr_ack to master
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)	
			begin
				if(sda_out1)	
					main_state <= idle;
				else
				begin
					if(write_read)	 // '1': read			            
						main_state <= data_read;				       
					else		// '0': write
						main_state <= data_write;
				end
			end
			else
				main_state <= addr_ack;	
		end				
		data_write:	// read data from master			
		begin						 
 			if(data_in_state == data_end)			
				main_state <= data_in_ack;
			else
				main_state <= data_write;						    					      
		end
						
		data_in_ack:	// write data_in_ack to master		 
		begin	
			if({scl_regi0,scl_regi,scl}==3'b011)					
				main_state <= if_rep_start;
			else                  
				main_state <= data_in_ack;			
		end	
								 
		data_read:	// write data to master
		begin
		   data_out_reg <= send_count;
			if(data_out_state==data_out_end && {scl_regi0,scl_regi,scl}==3'b100)		              
			begin
				main_state <= data_out_ack;		             
			end                   
			else                  
			begin                 
				main_state <= data_read;			              
			end			            	           
		end
			
		data_out_ack:	// write data_out_ack to master
		begin			             
			if({scl_regi0,scl_regi,scl}==3'b011)
				main_state <= if_rep_start;
			else                  
				main_state <= data_out_ack;
		end
			 
		if_rep_start:	// read restart from master
		begin
			if(stop_bus_reg)
				main_state <= idle;
			else if((receive_count < 8'd33) && (write_read == 1'b0)) 
			      begin
						main_state <= data_write;
						receive_count <= receive_count + 1'b1;
					end
			else if((send_count < 8'd31) && (write_read == 1'b1) && (receive_status == 8'd34))
			      begin	            
						main_state <= data_read;	
						send_count <= send_count + 1'b1;
					end
			else
				main_state <= if_rep_start;
		end   
		                        
		default:	main_state <= idle;
		endcase 						 
	end 
end
//------------------------------------------------------------------			
// send chip_id_ack to master           
always @(posedge clock or negedge reset_n2) //addr ack output
begin
	if(!reset_n2)
	begin 
		ack_state <= 2'b00;
		sda_en    <= 1'b0;
		flag      <= 1'b0;
		sda_out1  <= 1'b0; 
	end
	else
	begin
		case(ack_state)
		2'b00:
		begin
			if(main_state==addr_ack && {scl_regi0,scl_regi,scl}==3'b100)    //to ack chip address           
			begin 
				if(addr_in_reg==7'b1111110)   
					sda_out1 <= 1'b0;
				else
					sda_out1 <= 1'b1; 
					 
            flag      <= 1'b0;                               
				sda_en    <= 1'b1;
				ack_state <= 2'b11;
			end
			else if(main_state==data_in_ack && {scl_regi0,scl_regi,scl}==3'b100)
			begin
				sda_out1  <= 1'b0;   
				flag      <= 1'b0;    
				sda_en    <= 1'b1;
				ack_state <= 2'b01;
			end
			else if(main_state==data_read && {scl_regi0,scl_regi,scl}==3'b100)
			begin
				flag      <= 1'b1;
				sda_en    <= 1'b1;
				ack_state <= 2'b10;	
			end
			else
				sda_en<=1'b0;
			end
		2'b01:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin
				sda_en    <= 1'b0;
				ack_state <= 2'b00;
			end
			else
				ack_state <= 2'b01; 
		end
		2'b10:
		begin
			if(main_state==data_read)
				ack_state <= 2'b10;
			else
			begin 
				ack_state <= 2'b00;
				sda_en    <= 1'b0;  
				flag      <= 1'b0;
			end
		end
		
		2'b11:
		begin
			if(main_state==data_read && {scl_regi0,scl_regi,scl}==3'b100)
			begin
				flag      <= 1'b1;
				sda_en    <= 1'b1;
				ack_state <= 2'b10;
			end
			else if(main_state!=data_read && {scl_regi0,scl_regi,scl}==3'b100)
			begin 
				ack_state <= 2'b00;
				sda_en    <= 1'b0;  
			end
			else
				ack_state <= 2'b11;
		end  
		default:	ack_state <= 2'b00;         
		endcase				 
	end
 end

//------------------------------------------------------------------	
//to read Chip_id from master

always @(posedge clock or negedge reset_n2)begin//to write chip address
	if(!reset_n2)
	begin 
		addr_in_state <= addr_in6;
		addr_in_reg   <= 7'b0000000;
	end
	else if(main_state==addr_read)
	begin
		case(addr_in_state)	
		addr_in6:
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_in5;
				addr_in_reg[6] <= sda_in;
			end
			else
				addr_in_state  <= addr_in6;
		end
			        
		addr_in5:					 
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_in4;
				addr_in_reg[5] <= sda_in;
			end
			else
				addr_in_state  <= addr_in5;
		end				
		addr_in4:
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_in3;
				addr_in_reg[4] <= sda_in;
			end
			else
				addr_in_state  <= addr_in4;
		end				
		addr_in3:
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_in2;
				addr_in_reg[3] <= sda_in;
			end
			else
				addr_in_state  <= addr_in3;
		end			
		addr_in2:
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_in1;
				addr_in_reg[2] <= sda_in;
			end
			else
				addr_in_state  <= addr_in2;
		end				
		addr_in1:
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_in0;
				addr_in_reg[1] <= sda_in;
			end
			else
				addr_in_state  <= addr_in1;
		end				
		addr_in0:
		begin
			if({scl_regi0,scl_regi,scl}==3'b011)
			begin
				addr_in_state  <= addr_end;
				addr_in_reg[0] <= sda_in;
			end
			else
				addr_in_state <= addr_in0;		    
		end
		addr_end:	addr_in_state <= addr_in6;
		default:	addr_in_state <= addr_in6;
		endcase
	end
	else
		addr_in_state  <= addr_in6;  
end
//------------------------------------------------------------------	
//to read data from master
always @(posedge clock or negedge reset_n2)begin
	if(!reset_n2)
	begin
		data_in_state <= data_in7;

		data_in_reg <= 8'h0;
	end
	else
	begin
		if(main_state==data_write)
			case(data_in_state)	
			data_in7:
			begin	 
				if({scl_regi0,scl_regi,scl}==3'b011)          
				begin	
					data_in_reg[7] <= sda_in; 				    
					data_in_state <= data_in6;                             
				end
				else
					data_in_state <= data_in7; 
			end	
			data_in6:
			begin	
				if({scl_regi0,scl_regi,scl}==3'b011)
				begin					     
					data_in_reg[6] <= sda_in; 
					data_in_state <= data_in5;
				end
				else
					data_in_state <= data_in6; 
			end
			data_in5:
			begin	
				if({scl_regi0,scl_regi,scl}==3'b011)
				begin					     
					data_in_state <= data_in4;
					data_in_reg[5] <= sda_in;
				end
				else
					data_in_state <= data_in5;     			
			end	
						
			data_in4:
			begin	
				if({scl_regi0,scl_regi,scl}==3'b011)  	
				begin				    
					data_in_state <= data_in3;
					data_in_reg[4] <= sda_in;	
				end	
				else
					data_in_state <= data_in4;    	
			end
					
			data_in3: 
			begin	
				if({scl_regi0,scl_regi,scl}==3'b011)  
				begin					    
					data_in_state <= data_in2;
					data_in_reg[3] <= sda_in;
				end	
				else
					data_in_state <= data_in3;  	
			end
					
			data_in2:			 
			begin		
				if({scl_regi0,scl_regi,scl}==3'b011)  
				begin				  
					data_in_reg[2] <= sda_in;			
					data_in_state <= data_in1;
				end
				else
					data_in_state <= data_in2; 
			end
								
			data_in1:
			begin
				if({scl_regi0,scl_regi,scl}==3'b011)   
				begin
					data_in_state <= data_in0;
					data_in_reg[1] <= sda_in;
				end	
				else
					data_in_state <= data_in1;   		
			end
							
			data_in0:
			begin
				if({scl_regi0,scl_regi,scl}==3'b011) 
				begin
					data_in_state <= data_end;
					data_in_reg[0] <= sda_in;
				end	
				else
					data_in_state <= data_in0;   						    
			end 
					     
			data_end:
			begin
				data_in_state <= data_in7;
			end
			default: data_in_state <= data_in7;
			endcase
		else
			data_in_state <= data_in7;     
	end
end
//---------------------to read data in task--------------------------------
always@(posedge clock or negedge reset_n2)begin //data read
	if(!reset_n2)
	begin
		data_out_state <= data_out7;
		sda_out2       <= 1'b0;   
	end
	else
	begin   
		case(data_out_state)
		data_out7:
		begin			                    
			if(main_state==data_read&&{scl_regi0,scl_regi,scl}==3'b100)
			begin		                          
				sda_out2 <= data_out_reg[7];
				data_out_state   <= data_out6;					                         
			end                         
			else                        
			begin                       
				data_out_state   <= data_out7; 
			end  
		end 
		data_out6:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin
				data_out_state   <= data_out5;                            
				sda_out2 <= data_out_reg[6];           
			end                         
			else                        
				data_out_state   <= data_out6;		
		end
		data_out5:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin
				data_out_state   <= data_out4;		                          
				sda_out2 <= data_out_reg[5];		 
			end                         
			else                        
				data_out_state   <= data_out5; 
		end
		data_out4:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin
				data_out_state   <= data_out3;			                          
				sda_out2 <= data_out_reg[4];            
			end	                    
			else                        
				data_out_state   <= data_out4; 		
		end
		data_out3:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin
				data_out_state   <= data_out2;		                          
				sda_out2 <= data_out_reg[3];            
			end	                    
			else                        
				data_out_state   <= data_out3; 		
		end
		data_out2:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100) 
			begin
				data_out_state   <= data_out1;			                          
				sda_out2 <= data_out_reg[2];				           
			end                         
			else                        
				data_out_state   <= data_out2; 			
		end
		data_out1:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin
				data_out_state   <= data_out0;		                          
				sda_out2 <= data_out_reg[1];
			end	
			else
				data_out_state   <=data_out1; 	
		end
		data_out0:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
			begin  
				data_out_state   <= data_out_end;
				sda_out2 <= data_out_reg[0];
			end
			else
				data_out_state   <= data_out0;		
		end
		data_out_end:
		begin
			if({scl_regi0,scl_regi,scl}==3'b100)
				data_out_state <= data_out7;
			else                      
				data_out_state <= data_out_end; 
		end                               
			                          
		default:	data_out_state <= data_out7;
		endcase	     
	end
 end
 
/********************************************************************************************
*judge received datas  
********************************************************************************************/
 always @(posedge clock or negedge reset_n2)begin
   if(!reset_n2)
		receive_status <= 1'b0;
   else begin
	 if(data_in_state == data_end)begin
			if(receive_count == 0)
				receive_status <= (data_in_reg == 8'h1) ? (receive_status+1'b1) : receive_status;
			else if(receive_count == 1)
				receive_status <= (data_in_reg == 8'b00100000) ? (receive_status+1'b1) : receive_status;
			else
				receive_status <= (data_in_reg == (receive_count - 2))? (receive_status+1'b1) : receive_status;
		end
	 else 
			receive_status <= receive_status;
	end
 end
endmodule

