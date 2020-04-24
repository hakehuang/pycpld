from .. import base_ip
import os
'''
#an example of io_dic of button_isp io
'''

#return the class name for query
def get_ip_name():
  return "BUTTON_ISP"

class BUTTON_ISP(base_ip.base_ip):
  ID = "__BUTTON_ISP"
  ALT = ["a", "b", "c"]
  def __init__(self, io_hash):
    self.dicts = io_hash
    self.alt = "a"
  def set_alt(self, in_alt):
   if in_alt in self.ALT:
      self.alt = in_alt
  def matched_id(self, in_key):
    return in_key == self.ID
  def get_pinmux_setting(self):
    return ''

  def get_v_file_list(self):
    #set_global_assignment -name VERILOG_FILE enc.v
    pkgpath = os.path.dirname(__file__)
    return [ os.path.join(pkgpath,"button_isp.v"),]
  def get_module_caller(self):
    return """
button_isp		button_isp_instance(
							.rst(buttom_rst_i),
							.clk(clk),
							.outpin_isp(button_out_isp),
							.outpin_rst(button_out_reset)
                            );
        """

  def get_wire_defines(self):
    return """
wire button_out_isp;
wire button_out_reset;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg  buttom_rst_i;
    """
  def module_rest_codes():
    return """
     buttom_rst_i <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
		buttom_rst_i <= 1'b1;
        """
    else:
        return """
	    buttom_rst_i <= 1'b1;
        """
  def get_rst_case_text(self):
    return """
	    buttom_rst_i <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
	    buttom_rst_i <= 1'b0;
        """