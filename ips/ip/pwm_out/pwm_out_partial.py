from .. import base_ip
import os
'''
#an example of io_dic of pwm_out io
'''

#return the class name for query
def get_ip_name():
  return "PWM_OUT"

class PWM_OUT(base_ip.base_ip):
  ID = "__PWM_OUT"
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
    return [ os.path.join(pkgpath,"pwm_out.v")]
  def get_module_caller(self):
    return """ 
pwm_out pwm_out(.rst_n(rst_n),
          .clk(clk),
          .enable(enable_pwm_out),
          .pha(pha), 
          .phb(phb), 
          .pwmfre(pwmfreq), 
          .dutyratio(dutyratio)
        );
        """

  def get_wire_defines(self):
    return """ 
wire pha;
wire phb;
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return """ 
reg enable_pwm_out;
reg[0:31] pwmfreq;
reg[0:31] dutyratio;
    """
  def module_rest_codes():
    return """
    enable_pwm_out <= 1'b0;
    pwmfreq   <= 32'd500000;
    dutyratio <= 32'd250000;
    """
  def get_cmd_case_text(self):
    return "enable_pwm_out <= 1'b1;"
  def get_rst_case_text(self):
    return """
    enable_pwm_out <= 1'b0;
    pwmfreq   <= 32'd500000;
    dutyratio <= 32'd250000;
    """
  def get_dft_case_text(self):
    return """
    enable_pwm_out <= 1'b0;
    pwmfreq   <= 32'd500000;
    dutyratio <= 32'd250000;
    """





    


