from .. import base_ip
import os
'''
#an example of io_dic of button_hold io
'''

#return the class name for query
def get_ip_name():
  return "BUTTON_HOLD"

class BUTTON_HOLD(base_ip.base_ip):
  ID = "__BUTTON_HOLD"
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
    return [ os.path.join(pkgpath,"button_hold.v"),
	         os.path.join(pkgpath,"press_done_tx.v"),]
  def get_module_caller(self):
    return """
button_hold		button_hold_instance(
							.rst(button_rst_n),
							.clk(clk),
							.out_status(out_status),
							.pin_select(Rx_cmd[15:0]),
							.press_done(press_done)
                            );

press_done_tx 	press_done_tx_instance(
							.clk(clk),
							.rst_n(button_hold_rst),
							.tx_start(button_tx_start),
							.press_done(press_done),
							.tx_data(tx_data)
							);
        """

  def get_wire_defines(self):
    return """
wire [25:0] out_status;
wire press_done;
wire button_tx_start;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg  button_rst_n;
reg  button_hold_rst;
    """
  def module_rest_codes():
    return """
     button_rst_n <= 1'b0;
     capture_rst <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
		button_rst_n <= 1'b1;
		capture_rst <= 1'b1;
		button_hold_rst <= 1'b1;
        """
    else:
        return """
	    button_rst_n <= 1'b1;
	    capture_rst <= 1'b1;
	    button_hold_rst <= 1'b1;		
        """
  def get_rst_case_text(self):
    return """
	    button_rst_n <= 1'b0;
	    button_hold_rst <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
	    button_rst_n <= 1'b0;
	    button_hold_rst <= 1'b0;
        """