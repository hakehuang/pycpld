from .. import base_ip
import os
'''
#an example of io_dic of i2c_slave_for_case io
'''

#return the class name for query
def get_ip_name():
  return "I2C_SLAVE_FOR_CASE_TWO_AD"

class I2C_SLAVE_FOR_CASE_TWO_AD(base_ip.base_ip):
  ID = "__I2C_SLAVE_FOR_CASE_TWO_AD"
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
    return [ os.path.join(pkgpath,"i2c_slave.v"),
			 os.path.join(pkgpath,"i2c_slave_op.v"),]
  def get_module_caller(self):
    return """
i2c_slave      i2c_slave_instance(
							.reset_n(i2c_rst_slv),
							.sda(`sda),
							.scl(scl_slv),
							.clock(clk),
							.saddress_sel(saddress_sel)
							);
    """

  def get_wire_defines(self):
    return """
wire scl_slv;
    """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg i2c_rst_slv;
reg saddress_sel;
    """
  def module_rest_codes():
    return """
     i2c_rst_slv <= 1'b0;
     saddress_sel <= 1'b0;
    """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:  
      return """
        i2c_rst_slv <= 1'b1;
        saddress_sel <= 1'b0;
        """
    else:  
      return """
        i2c_rst_slv <= 1'b1;
        saddress_sel <= 1'b1;
        """
  def get_rst_case_text(self):
    return """
        i2c_rst_slv <= 1'b0;
        saddress_sel <= 1'b0;		
    """
  def get_dft_case_text(self):
    return """
        i2c_rst_slv <= 1'b0;
        saddress_sel <= 1'b0;		
    """