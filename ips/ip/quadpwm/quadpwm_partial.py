from .. import base_ip
import os
'''
#an example of io_dic of quadpwm io
{
  ("", 50, "//comments", "pha_out", "quadpwm")
}
'''

#return the class name for query
def get_ip_name():
  return "QUADPWM"

class QUADPWM(base_ip.base_ip):
  ID = "__QUADPWM"
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
    return [ os.path.join(pkgpath,"quadpwm.v")]
  def get_module_caller(self):
    return """ 
quadpwm  quadpwm( .rst_n(rst_n),
          .freq_clk(clk),
          .enable(enable_quad),
			    .mode(quadmode),
          .pwm0(pwm0),
          .pwm1(pwm1),
          .pwm2(pwm2),
          .pwm3(pwm3)
        ); 
            """

  def get_wire_defines(self):
    return """ 
  wire pwm0;
  wire pwm1;
  wire pwm2;
  wire pwm3; 
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return """
    reg enable_quad;
    reg[31:0] quadmode;
    """
  def module_rest_codes():
    return """
    enable_quad <= 1'b0;
    quadmode <= 32'b0;
    """
  def get_cmd_case_text(self):
    return "enable_quad <= 1'b1;"
  def get_rst_case_text(self):
    return """
    enable_quad <= 1'b0;
    quadmode <= 32'b0
    """
  def get_dft_case_text(self):
    return """
    enable_quad <= 1'b0;
    quadmode <= 32'b0;
    """





    


