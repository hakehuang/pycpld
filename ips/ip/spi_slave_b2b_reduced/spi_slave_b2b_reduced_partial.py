from .. import base_ip
import os
'''
#an example of io_dic of spi_master io
'''

#return the class name for query
def get_ip_name():
  return "SPI_SLAVE_B2B_reduced"

class SPI_SLAVE_B2B_reduced(base_ip.base_ip):
  ID = "__SPI_SLAVE_B2B_reduced"
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
    if self.alt == "a":
      return [ os.path.join(pkgpath,"spi_slave_b2b_act_l_reduced.v")]
    else:
      return [ os.path.join(pkgpath,"spi_slave_b2b_act_h_reduced.v")]
  def get_module_caller(self):
    return """
spi_slave_b2b_reduced		spi_slave_b2b_instance_reduced(
							.clk(clk),
							.sck(ss_rd_sck_b2b),
							.mosi(ss_rd_mosi_b2b),
							.miso(ss_rd_miso_b2b),
							.ssel(ss_rd_ssel_b2b),
							.rst_n(spi_rd_slave_rst_b2b),
							.recived_status(spi_rd_slave_result_b2b)
                            );

        """

  def get_wire_defines(self):
    return """
wire ss_rd_sck_b2b;
wire ss_rd_mosi_b2b;
wire ss_rd_miso_b2b;
wire ss_rd_ssel_b2b;
wire spi_rd_slave_result_b2b;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg spi_rd_slave_rst_b2b;
    """
  def module_rest_codes():
    return """
     spi_rd_slave_rst_b2b <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
      return """
        spi_rd_slave_rst_b2b <= 1'b1;
        """
    else:
      return """
        spi_rd_slave_rst_b2b <= 1'b1;
        """
  def get_rst_case_text(self):
    return """
        spi_rd_slave_rst_b2b <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
        spi_rd_slave_rst_b2b <= 1'b0;
        """