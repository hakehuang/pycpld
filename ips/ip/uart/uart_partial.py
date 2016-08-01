from .. import base_ip
import os
'''
#this is an build in module

'''

#return the class name for query
def get_ip_name():
  return "UART"

class UART(base_ip.base_ip):
  ID = "__UART"
  count = 0
  def __init__(self, io_hash):
    self.dicts = io_hash
    self.count = 1
  def set_alt(in_alt):
    return ''
  def matched_id(self, in_key):
    return in_key == self.ID
  def get_pinmux_setting(self):
    return ''

  def get_v_file_list(self):
  	#set_global_assignment -name VERILOG_FILE enc.v
    pkgpath = os.path.dirname(__file__)
    return [os.path.join(pkgpath,"speed_select.v"), os.path.join(pkgpath,"uart_rx.v"), os.path.join(pkgpath,"uart_tx.v")]
  def get_module_caller(self):
    return """ 
speed_select    speed_select( .clk(clk),  //baudrate selection
                      .rst_n(rst_n),
                      .rx_enable(bps_start),
                      .tx_enable(bps_start_t),
                      .buad_clk_rx(clk_bps),
                      .buad_clk_tx(clk_bps_t)
                      );

my_uart_rx      my_uart_rx(   .rst_n(rst_n), 
                      .baud_clk(clk_bps), 
                      .uart_rx(rs232_rx), 
                      .rx_data(rx_data),
                      .rx_enable(bps_start), 
                      .rx_complete(rx_complete), 
                      .rx_error(rx_error)
                      );
                      
my_uart_tx      my_uart_tx(   .rst_n(rst_n), 
                      .baud_clk(clk_bps_t), 
                      .tx_start(tx_start), 
                      .tx_data(tx_data), 
                      .tx_enable(bps_start_t), 
                      .tx_complete(tx_complete), 
                      .uart_tx(rs232_tx), 
                      .error(tx_error)
                      );
    """

  def get_wire_defines(self):
    return ""

  def get_reg_defines(self):
  	#additional reg definition
  	return ""
  def get_cmd_case_text(self):
    return ""
  def get_rst_case_text(self):
    return ""
  def get_dft_case_text(self):
    return ""





    


