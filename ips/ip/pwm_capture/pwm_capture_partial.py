from .. import base_ip
import os
'''
#an example of io_dic of pwm_capture io
'''

#return the class name for query
def get_ip_name():
  return "PWM_CAPTURE"

class PWM_CAPTURE(base_ip.base_ip):
  ID = "__PWM_CAPTURE"
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
    return [ os.path.join(pkgpath,"pwm_capture.v"),
			 os.path.join(pkgpath,"pos_capture.v"),
			 os.path.join(pkgpath,"neg_capture.v"),
			 os.path.join(pkgpath,"captuer_tx.v"),]
  def get_module_caller(self):
    return """ 
pwm_capture		 pwm_capture_instance(
							.pwm_input(pwm_input),
							.clk(clk),
							.rst_n(capture_rst),
							.enable(enable),
						   .tx_start(tx_start),
							.tx_data(tx_data),
							.tx_complete(tx_complete),
							.capture_tx_rst(capture_tx_rst),
							.bps_start_t(bps_start_t)
							);
        """

  def get_wire_defines(self):
    return """ 
wire pwm_input;
wire tx_start;	
wire[7:0] tx_data;
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return """ 
reg enable;
reg capture_rst;
reg capture_tx_rst;
    """
  def module_rest_codes():
    return """
    enable <= 1'b0;
    capture_rst  <= 1'b0;
    capture_tx_rst <= 1'b0;
    """
  def get_cmd_case_text(self):
    return """
	enable <= 1'b1;
    capture_rst <= 1'b1;
    capture_tx_rst <= 1'b1;
	"""
  def get_rst_case_text(self):
    return """
    enable <= 1'b0;
    capture_rst <= 1'b0;
    capture_tx_rst <= 1'b0;
    """
  def get_dft_case_text(self):
    return """
    enable <= 1'b0;
    capture_rst <= 1'b0;
    capture_tx_rst <= 1'b0;
    """





    


