from .. import base_ip
import os
'''
#an example of io_dic of i2c_slave_for_case io
'''

#return the class name for query
def get_ip_name():
  return "I2C_SLAVE_SUBAD"

class I2C_SLAVE_SUBAD(base_ip.base_ip):
  ID = "__I2C_SLAVE_SUBAD"
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
    return [ os.path.join(pkgpath,"i2c_slave_subad.v"),
			 os.path.join(pkgpath,"i2c_slave_op_subad.v"),]
  def get_module_caller(self):
    return """
i2c_slave_subad      i2c_slave_subad_instance(
							.reset_n(subad_i2c_rst_slv),
							.sda(`sda),
							.scl(subad_scl_slv),
							.clock(clk)
							);
    """

  def get_wire_defines(self):
    return """
wire subad_scl_slv;
    """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg subad_i2c_rst_slv;
    """
  def module_rest_codes():
    return """
     subad_i2c_rst_slv <= 1'b0;
	 linkICS <= 1'b0;
    """
  def get_cmd_case_text(self):
    return """
        subad_i2c_rst_slv <= 1'b1;
    """
  def get_rst_case_text(self):
    return """
        subad_i2c_rst_slv <= 1'b0;
    """
  def get_dft_case_text(self):
    return """
        subad_i2c_rst_slv <= 1'b0;
    """