from .. import base_ip
import os
'''
#an example of io_dic of spi_master io
'''

#return the class name for query
def get_ip_name():
  return "SPI_MASTER"

class SPI_MASTER(base_ip.base_ip):
  ID = "__SPI_MASTER"
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
    return [ os.path.join(pkgpath,"spi_ctrl.v"),
			 os.path.join(pkgpath,"spi_master.v"),]
  def get_module_caller(self):
    return """
spi_ctrl        spi_ctrl_instance(
							.clk(clk),
							.rst_n(spi_rst),
							.sck(sck),
							.mosi(mosi),
							.miso(miso),
							.cs_n(cs_n),
							.spi_tx_en(spi_tx_en),
							.spi_rx_en(spi_rx_en),
							.mode_select(mode_select),
							.receive_status(spi_receive_status)
							);
        """

  def get_wire_defines(self):
    return """
wire sck;
wire mosi;
wire miso;
wire cs_n;
wire spi_receive_status;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg spi_tx_en;
reg spi_rx_en;
reg spi_rst;
reg mode_select;
    """
  def module_rest_codes():
    return """
     spi_rst <= 1'b0;
     spi_tx_en <= 1'b0;
     spi_rx_en <= 1'b0;
     mode_select <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
	  return """
        spi_rst <= 1'b1;
        spi_tx_en <= 1'b1;
        spi_rx_en <= 1'b1;
        mode_select <= 1'b0;
        """
    else:
        return """
        spi_rst <= 1'b1;
        spi_tx_en <= 1'b1;
        spi_rx_en <= 1'b1;
        mode_select <= 1'b1;
        """
  def get_rst_case_text(self):
    return """
        spi_rst <= 1'b0;
        spi_tx_en <= 1'b0;
        spi_rx_en <= 1'b0;
        mode_select <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
        spi_rst <= 1'b0;
        spi_tx_en <= 1'b0;
        spi_rx_en <= 1'b0;
        mode_select <= 1'b0;
        """