from .. import base_ip
import os
'''
#spi master without continus CS
'''

#return the class name for query
def get_ip_name():
  return "SPI_MASTER_KL"

class SPI_MASTER_KL(base_ip.base_ip):
  ID = "__SPI_MASTER_KL"
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
    return [ os.path.join(pkgpath,"spi_ctrl_kl.v"),
			 os.path.join(pkgpath,"spi_master_kl.v"),]
  def get_module_caller(self):
    return """
spi_ctrl_kl      spi_ctrl_kl_instance(
							.clk(clk),
							.rst_n(spi_rst_kl),
							.sck(sm_sck_kl),
							.mosi(sm_mosi_kl),
							.miso(sm_miso_kl),
							.cs_n(sm_cs_n_kl),
							.spi_tx_en(spi_tx_en_kl),
							.spi_rx_en(spi_rx_en_kl),
							.mode_select(mode_select_kl),
							.receive_status(spi_receive_status_kl)
							);
        """

  def get_wire_defines(self):
    return """
wire sm_sck_kl;
wire sm_mosi_kl;
wire sm_miso_kl;
wire sm_cs_n_kl;
wire spi_receive_status_kl;
          """

  def get_reg_defines(self):
    #additional reg definition
    return """
reg spi_tx_en_kl;
reg spi_rx_en_kl;
reg spi_rst_kl;
reg mode_select_kl;
    """
  def module_rest_codes():
    return """
     spi_rst_kl <= 1'b0;
     spi_tx_en_kl <= 1'b0;
     spi_rx_en_kl <= 1'b0;
     mode_select_kl <= 1'b0;
     """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
    #active high, raising edge, msb first
	  return """
        spi_rst_kl <= 1'b1;
        spi_tx_en_kl <= 1'b1;
        spi_rx_en_kl <= 1'b1;
        mode_select_kl <= 1'b0;
        """
    else:
    #active low, raising edge, msb first
        return """
        spi_rst_kl <= 1'b1;
        spi_tx_en_kl <= 1'b1;
        spi_rx_en_kl <= 1'b1;
        mode_select_kl <= 1'b0;
        """
  def get_rst_case_text(self):
    return """
        spi_rst_kl <= 1'b0;
        spi_tx_en_kl <= 1'b0;
        spi_rx_en_kl <= 1'b0;
        mode_select_kl <= 1'b0;
        """
  def get_dft_case_text(self):
    return """
        spi_rst_kl <= 1'b0;
        spi_tx_en_kl <= 1'b0;
        spi_rx_en_kl <= 1'b0;
        mode_select_kl <= 1'b0;
        """