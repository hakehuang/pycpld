from .. import base_ip
import os
'''
#this is an build in module

'''

#return the class name for query
def get_ip_name():
  return "SW_PULSE"

class SW_PULSE(base_ip.base_ip):
  ID = "__SW_PULSE"
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
  	#set_global_assignment -name VERILOG_FILE sw_pulse.v
    pkgpath = os.path.dirname(__file__)
    return [os.path.join(pkgpath,"sw_pulse.v")]
  def get_module_caller(self):
    return """ 
sw_pulse        sw_pulse( .clk(clk),  
							  .rst_n(rst_n),
							  .sw_en(linkSWP),
							  .sw_out(sw_out)
							  );
    """

  def get_wire_defines(self):
    return """ 
wire sw_out;
          """
  def get_reg_defines(self):
  	#additional reg definition
  	return ""
  def get_cmd_case_text(self):
    return ""
  def get_rst_case_text(self):
    return ""
  def get_dft_case_text(self):
    return ""





    


