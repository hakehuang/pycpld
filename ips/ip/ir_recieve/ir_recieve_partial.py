from .. import base_ip
import os
'''
#an example of io_dic of ir_recieve io
'''

#return the class name for query
def get_ip_name():
  return "IR_RECIEVE"

class IR_RECIEVE(base_ip.base_ip):
  ID = "__IR_RECIEVE"
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
    return [ os.path.join(pkgpath,"ir_recieve.v"),
			 ]
  def get_module_caller(self):
    return """ 
ir_recieve		 ir_recieve_instance(
							.clk(clk), 
							.rst(ir_rst), 
							.sda(ir_sda), 
							.recieve_status(ir_recieve_status)
							);
        """

  def get_wire_defines(self):
    return """ 
wire ir_sda;	
wire ir_recieve_status;
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return """ 
reg ir_rst;
    """
  def module_rest_codes():
    return """
    ir_rst <= 1'b0;
    """
  def get_cmd_case_text(self):
    return """
	ir_rst <= 1'b1;
	"""
  def get_rst_case_text(self):
    return """
    ir_rst <= 1'b0;
    """
  def get_dft_case_text(self):
    return """
    ir_rst <= 1'b0;
    """





    


