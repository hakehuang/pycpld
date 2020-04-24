`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/30/2018 04:58:00 PM
// Design Name: 
// Module Name: spi_master_retb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module CLOCK(
 output bit clk
);
always #(100ps) begin
    clk = ~clk;
end
endmodule


module spi_master_retb();
 class work_status_checkout;
    bit rst_n;
    rand bit spi_tx_en;
    rand bit spi_rx_en;
    rand bit miso;
    rand bit mode_select;
    
    function new();
        rst_n = 1'b1;
    endfunction : new
    
    function void next();
        //this.randomize();
        mode_select = 1'b1;
        miso = 1'b1;
    endfunction : next
    
    function void clear();
        rst_n = 1'b0;
    endfunction : clear
 endclass : work_status_checkout
 
 bit clk,rst_n,spi_tx_en,spi_rx_en,mode_select,miso;
 bit sck,mosi,cs_n;
 bit [7:0] recieve_date;
 work_status_checkout wsc;
 
 CLOCK CLOCK1(clk);
 
 spi_ctrl_reduced spi_ctrl_reduced_instance(
 .clk(clk),.rst_n(rst_n),.sck(sck),.mosi(mosi),.miso(miso),.cs_n(cs_n),.spi_tx_en(spi_tx_en),.spi_rx_en(spi_rx_en),.mode_select(mode_select)
 );
 
 task recieve_mosi();
    @(posedge clk);
    for(int i = 0;i<64;i++) begin
            for(int j = 0;j<8;j++)begin
            @(posedge sck);
            recieve_date = {recieve_date[6:0],mosi};
            end
            $display("recieved the %d date is %d\n",i, recieve_date);
    end
 endtask : recieve_mosi
 
 task work();
    @(posedge clk);
    wsc.next();
    rst_n = wsc.rst_n;
    miso = wsc.miso;
    spi_tx_en = 1;
    spi_rx_en = 1;
    mode_select = wsc.mode_select;
    @(posedge clk);
    @(posedge clk);
    $display("miso = %b\nspi_tx_en = %b\nspi_rx_en = %b\nmode_select = %d\n",miso,spi_tx_en,spi_rx_en,mode_select);
    recieve_mosi();
 endtask : work
 
 task clear();
    wsc.clear();
    rst_n = wsc.rst_n;
 endtask : clear
 
 initial begin
    wsc = new();
    repeat(20)
    work();
    clear();
 end
endmodule
