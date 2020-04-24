from .. import base_ip
import os
'''
#an example of io_dic of spi_master io
'''

#return the class name for query
def get_ip_name():
  return "SPI_MASTER_reduced"

class SPI_MASTER_reduced(base_ip.base_ip):
  ID = "__SPI_MASTER_reduced"
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
    return [ os.path.join(pkgpath,"spi_ctrl_reduced.v"),
			 os.path.join(pkgpath,"spi_master_reduced.v"),]
  def get_module_caller(self):
    if self.alt == self.ALT[0] :
      return """
spi_ctrl_reduced      spi_ctrl_reduced_instance(
							.clk(clk),
							.rst_n(spi_rd_rst),
							.sck(sm_rd_sck),
							.mosi(sm_rd_mosi),
							.miso(sm_rd_miso),
							.cs_n(sm_rd_cs_n),
							.spi_tx_en(spi_tx_rd_en),
							.spi_rx_en(spi_rx_rd_en),
							.mode_select(mode_rd_select),
							.receive_status(spi_receive_rd_status)
							);
        """
    elif self.alt == self.ALT[1] :
      return """
spi_ctrl_reduced #(.DATA_LENGTH(256)) spi_ctrl_reduced_instance_256(
              .clk(clk),
              .rst_n(spi_rd_rst_256),
              .sck(sm_rd_sck_256),
              .mosi(sm_rd_mosi_256),
              .miso(sm_rd_miso_256),
              .cs_n(sm_rd_cs_n_256),
              .spi_tx_en(spi_tx_rd_en_256),
              .spi_rx_en(spi_rx_rd_en_256),
              .mode_select(mode_rd_select_256),
              .receive_status(spi_receive_rd_status_256)
              );
        """

  def get_wire_defines(self):
    if self.alt == self.ALT[0] :
      return """
wire sm_rd_sck;
wire sm_rd_mosi;
wire sm_rd_miso;
wire sm_rd_cs_n;
wire spi_receive_rd_status;
          """
    elif self.alt == self.ALT[1] :
      return """
wire sm_rd_sck_256;
wire sm_rd_mosi_256;
wire sm_rd_miso_256;
wire sm_rd_cs_n_256;
wire spi_receive_rd_status_256;
          """
  def get_reg_defines(self):
    #additional reg definition
    if self.alt == self.ALT[0] :
      return """
reg spi_tx_rd_en;
reg spi_rx_rd_en;
reg spi_rd_rst;
reg mode_rd_select;
    """
    elif self.alt == self.ALT[1] :
      return """
reg spi_tx_rd_en_256;
reg spi_rx_rd_en_256;
reg spi_rd_rst_256;
reg mode_rd_select_256;
    """

  def module_rest_codes():
    if self.alt == self.ALT[0] :
      return """
     spi_rd_rst <= 1'b0;
     spi_tx_rd_en <= 1'b0;
     spi_rx_rd_en <= 1'b0;
     mode_rd_select <= 1'b0;
     """
    elif self.alt == self.ALT[1] :
      return """
     spi_rd_rst_256 <= 1'b0;
     spi_tx_rd_en_256 <= 1'b0;
     spi_rx_rd_en_256 <= 1'b0;
     mode_rd_select_256 <= 1'b0;
     """

  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
    #active high, raising edge, msb first
	    return """
        spi_rd_rst <= 1'b1;
        spi_tx_rd_en <= 1'b1;
        spi_rx_rd_en <= 1'b1;
        mode_rd_select <= 1'b0;
        """
    elif self.alt == self.ALT[1] :
      return """
        spi_rd_rst_256 <= 1'b1;
        spi_tx_rd_en_256 <= 1'b1;
        spi_rx_rd_en_256 <= 1'b1;
        mode_rd_select_256 <= 1'b0;
        """      
    else:
    #active low, raising edge, msb first
      return """
        spi_rd_rst <= 1'b1;
        spi_tx_rd_en <= 1'b1;
        spi_rx_rd_en <= 1'b1;
        mode_rd_select <= 1'b1;
        """

  def get_rst_case_text(self):
    if self.alt == self.ALT[0]:
      return """
        spi_rd_rst <= 1'b0;
        spi_tx_rd_en <= 1'b0;
        spi_rx_rd_en <= 1'b0;
        mode_rd_select <= 1'b0;
        """
    elif self.alt == self.ALT[1] :
      return """
        spi_rd_rst_256 <= 1'b0;
        spi_tx_rd_en_256 <= 1'b0;
        spi_rx_rd_en_256 <= 1'b0;
        mode_rd_select_256 <= 1'b0;
        """

  def get_dft_case_text(self):
    if self.alt == self.ALT[0]:
      return """
        spi_rd_rst <= 1'b0;
        spi_tx_rd_en <= 1'b0;
        spi_rx_rd_en <= 1'b0;
        mode_rd_select <= 1'b0;
        """
    elif self.alt == self.ALT[1] :
      return """
        spi_rd_rst_256 <= 1'b0;
        spi_tx_rd_en_256 <= 1'b0;
        spi_rx_rd_en_256 <= 1'b0;
        mode_rd_select_256 <= 1'b0;
        """      