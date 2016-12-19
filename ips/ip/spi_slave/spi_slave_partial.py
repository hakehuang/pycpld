from .. import base_ip
import os
'''
#an example of io_dic of spi_master io
'''

#return the class name for query
def get_ip_name():
  return "SPI_SLAVE"

class SPI_SLAVE(base_ip.base_ip):
  ID = "__SPI_SLAVE"
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
    return [ os.path.join(pkgpath,"spi_slave.v"),]
  def get_module_caller(self):
    return """
spi_slave		spi_slave_instance(
							.clk(clk),
							.sck(ss_sck),
							.mosi(ss_mosi),
							.miso(ss_miso),
							.ssel(ss_ssel),
							.rst_n(spi_slave_rst),
							.recived_status(spi_slave_result)
                            );

        """

  def get_wire_defines(self):
    return """
wire ss_sck;
wire ss_mosi;
wire ss_miso;
wire ss_ssel;
wire spi_slave_result;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg spi_slave_rst;
    """
  def module_rest_codes():
    return """
     spi_slave_rst <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
        spi_slave_rst <= 1'b1;
        """
  def get_rst_case_text(self):
    return """
        spi_slave_rst <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
        spi_slave_rst <= 1'b0;
        """