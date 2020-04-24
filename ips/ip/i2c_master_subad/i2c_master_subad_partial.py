from .. import base_ip
import os
'''
#an example of io_dic of i2c_master io
'''

#return the class name for query
def get_ip_name():
  return "I2C_MASTER_SUBAD"

class I2C_MASTER_SUBAD(base_ip.base_ip):
  ID = "__I2C_MASTER_SUBAD"
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
    return [ os.path.join(pkgpath,"I2C_MASTER_SUBAD.v"),
			 os.path.join(pkgpath,"I2C_wr_subad.v"),]
  def get_module_caller(self):
    return """
I2C_MASTER_SUBAD        I2C_MASTER_SUBAD_instance(
							.clk(clk),
							.rst_n(subad_i2c_rst),
							.sda(`sda),
							.scl(subad_scl),
							.RD_EN(subad_RD_EN),
							.WR_EN(subad_WR_EN),
							.receive_status(subad_receive_status)
							);
        """

  def get_wire_defines(self):
    return """
wire subad_scl;
wire subad_receive_status;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg subad_RD_EN;
reg subad_WR_EN;
reg subad_i2c_rst;
    """
  def module_rest_codes():
    return """
     subad_i2c_rst <= 1'b0;
	 subad_RD_EN   <= 1'b0;
	 subad_WR_EN   <= 1'b0;
    """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
        subad_i2c_rst <= 1'b1;
        subad_RD_EN   <= 1'b0;
        subad_WR_EN   <= 1'b1;
		"""
    else:
        return """
        subad_i2c_rst <= 1'b1;
        subad_RD_EN   <= 1'b1;
        subad_WR_EN   <= 1'b0;
        """
  def get_rst_case_text(self):
    return """
        subad_i2c_rst <= 1'b0;
        subad_RD_EN   <= 1'b0;
        subad_WR_EN   <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
        subad_i2c_rst <= 1'b0;
        subad_RD_EN   <= 1'b0;
        subad_WR_EN   <= 1'b0;
        """