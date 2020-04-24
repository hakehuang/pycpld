from .. import base_ip
import os
'''
#an example of io_dic of led_capture io
'''

#return the class name for query
def get_ip_name():
  return "LED_CAPTURE"

class LED_CAPTURE(base_ip.base_ip):
  ID = "__LED_CAPTURE"
  count = 0
  def __init__(self, io_hash):
    self.dicts = io_hash
    self.count = 1
  def set_alt(self, in_alt):
    return ''
  def matched_id(self, in_key):
    return in_key == self.ID
  def get_pinmux_setting(self):
    return ''

  def get_v_file_list(self):
  	#set_global_assignment -name VERILOG_FILE enc.v
    pkgpath = os.path.dirname(__file__)
    return [ os.path.join(pkgpath,"led_capture.v"),
			 os.path.join(pkgpath,"pos_capture.v"),
			 os.path.join(pkgpath,"captuer_tx.v"),]
  def get_module_caller(self):
    return """ 
led_capture		 led_capture_instance(
							.led_input(led_input),
							.clk(clk),
							.rst_n(led_capture_rst),
							.tx_start(led_tx_start),
							.tx_data(tx_data)
							);
        """

  def get_wire_defines(self):
    return """ 
wire led_input;
wire led_tx_start;
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return """ 
reg led_capture_rst; 
    """
  def module_rest_codes():
    return """
    capture_rst  <= 1'b0;
    led_capture_rst <= 1'b0;
    """
  def get_cmd_case_text(self):
    return """
    capture_rst <= 1'b1;
    led_capture_rst <= 1'b1;	
	"""
  def get_rst_case_text(self):
    return """
    led_capture_rst <= 1'b0;
    """
  def get_dft_case_text(self):
    return """
    led_capture_rst <= 1'b0;
    """





    


