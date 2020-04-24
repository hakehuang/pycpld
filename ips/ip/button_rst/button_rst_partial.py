from .. import base_ip
import os
'''
#an example of io_dic of spi_master io
'''

#return the class name for query
def get_ip_name():
  return "BUTTON_RST"

class BUTTON_RST(base_ip.base_ip):
  ID = "__BUTTON_RST"
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
    return [ os.path.join(pkgpath,"button_rst.v"),]
  def get_module_caller(self):
    return """
button_rst		button_rst_instance(
							.rst(buttom_rst_r),
							.clk(clk),
							.pull_done(button_pull_done),
							.out_status(button_out_status)
                            );

        """

  def get_wire_defines(self):
    return """
wire button_out_status;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg  button_pull_done;
reg  buttom_rst_r;
    """
  def module_rest_codes():
    return """
     button_pull_done <= 1'b0;
     buttom_rst_r <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
        button_pull_done <= 1'b0;
		buttom_rst_r <= 1'b1;
        """
    else:
        return """
        button_pull_done <= 1'b1;
	    buttom_rst_r <= 1'b1;
        """
  def get_rst_case_text(self):
    return """
        button_pull_done <= 1'b0;
	    buttom_rst_r <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
        button_pull_done <= 1'b0;
	    buttom_rst_r <= 1'b0;
        """