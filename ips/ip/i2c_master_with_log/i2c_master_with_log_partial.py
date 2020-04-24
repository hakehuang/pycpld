from .. import base_ip
import os
'''
#an example of io_dic of i2c_master io
'''

#return the class name for query
def get_ip_name():
  return "I2C_MASTER_WITH_LOG"

class I2C_MASTER_WITH_LOG(base_ip.base_ip):
  ID = "__I2C_MASTER_WITH_LOG"
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
    return [ os.path.join(pkgpath,"I2C_MASTER.v"),
			 os.path.join(pkgpath,"I2C_wr.v"),
			 os.path.join(pkgpath,"check_pin.v"),]
  def get_module_caller(self):
    return """
I2C_MASTER        I2C_MASTER_instance(
							.clk(clk),
							.rst_n(i2c_rst),
							.sda(`sda),
							.scl(scl),
							.RD_EN(RD_EN),
							.WR_EN(WR_EN),
							.receive_status(receive_status),
							.tx_start(tx_start),
							.tx_data(tx_data),
							.tx_complete(tx_complete),
							.bps_start_t(bps_start_t),
							.capture_rst(capture_rst)
							);
        """

  def get_wire_defines(self):
    return """
wire scl;
wire receive_status;
wire [7:0] tx_data;
wire tx_start;
wire rs232_tx;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg RD_EN;
reg WR_EN;
reg i2c_rst;
reg capture_rst;
    """
  def module_rest_codes():
    return """
     i2c_rst <= 1'b0;
	 linkICW <= 1'b0;
	 RD_EN   <= 1'b0;
	 WR_EN   <= 1'b0;
     capture_rst <= 1'b0;	 
    """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
        i2c_rst <= 1'b1;
        RD_EN   <= 1'b0;
        WR_EN   <= 1'b1;
        capture_rst <= 1'b1;		
		"""
    else:
        return """
        i2c_rst <= 1'b1;
        RD_EN   <= 1'b1;
        WR_EN   <= 1'b0;
        capture_rst <= 1'b1;		
        """
  def get_rst_case_text(self):
    return """
        i2c_rst <= 1'b0;
        RD_EN   <= 1'b0;
        WR_EN   <= 1'b0;
        capture_rst <= 1'b0;		
        """
  def get_dft_case_text(self):
    return """
        i2c_rst <= 1'b0;
        RD_EN   <= 1'b0;
        WR_EN   <= 1'b0;
        capture_rst <= 1'b0;		
        """