from .. import base_ip
import os

#return the class name for query
def get_ip_name():
  return "UART7BIT"

class UART7BIT(base_ip.base_ip):
  ID = "__UART7BIT"
  ALT = ["a", "b"]
  def __init__(self, io_hash):
    self.dicts = io_hash
    self.alt = "a"
  def set_alt(self, in_alt):
    if in_alt in self.ALT:
      self.alt = in_alt
  def get_pinmux_setting(self):
    return ''
  def matched_id(self, in_key):
    return in_key == self.ID
  def get_v_file_list(self):
    #return ["uart_rx7to7.v", "uart_top7to7.v", "uart_tx7to7.v", "data_deal.v"]
    pkgpath = os.path.dirname(__file__)
    return [os.path.join(pkgpath,"uart_rx7to7.v"),
          os.path.join(pkgpath,"uart_top7to7.v"),
          os.path.join(pkgpath,"uart_tx7to7.v"),
          os.path.join(pkgpath,"data_deal.v")]
  def get_module_caller(self):
    return """ 
uart_top7to7		uart_top7to7(
						.clk(clk),
						.rst_n(tx_start_f),
						.rs232_rx(rs232_rx7to7),
						.rs232_tx(rs232_tx7to7),
						.data_ok(compara_error),
						.uart_ctl(uart_speed_set)
						); 
    """

  def get_wire_defines(self):
    return """ 
wire compara_error;
wire compare_ok;
wire rs232_tx7to7;
wire rs232_rx7to7; 
    """
  def get_reg_defines(self):
    #additional reg definition
    return """
reg enable_uart7bit;
reg[2:0] uart_speed_set;
reg tx_start_f;
    """
  def module_rest_codes(self):
    return """
      uart_speed_set<=3'd4;
      tx_start_f <= 1'b0;
    """
  def get_cmd_case_text(self):
    if self.alt == self.ALT[0]:
      return """
          uart_speed_set <= 3'd4;
          tx_start_f <= 1'b1;
      """
    else:
      return """
          uart_speed_set <= 3'd0;
          tx_start_f <= 1'b1;
      """
  def get_rst_case_text(self):
    return """
    enable_uart7bit <= 1'b0;
    uart_speed_set<=3'd4;
    tx_start_f <= 1'b0;
    """
  def get_dft_case_text(self):
    return """
    enable_uart7bit <= 1'b0;
    uart_speed_set<=3'd4;
    enable_uart7bit <= 1'b0;
    """