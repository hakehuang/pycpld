from .. import base_ip
import os
'''
#an example of io_dic of enc io
{
  ("", 50, "//comments", "pha_out", "enc")
}
'''

#return the class name for query
def get_ip_name():
  return "ENC"

class ENC(base_ip.base_ip):
  ID = "__ENC"
  count = 0
  def __init__(self, io_hash):
    self.dicts = io_hash
    self.count = 1
  def set_alt(self, in_alt):
    return ''
  def matched_id(self, in_key):
    return in_key == self.ID
  def get_pinmux_setting(self):
    return ''

  def get_v_file_list(self):
  	#set_global_assignment -name VERILOG_FILE enc.v
    pkgpath = os.path.dirname(__file__)
    return [ os.path.join(pkgpath,"enc.v")]
  def get_module_caller(self):
    return """ 
enc  enc( .rst_n(rst_n),
          .freq_clk(clk),
          .enable(linkENC),
			    .pha(pha_out), 
			    .phb(phb_out), 
			    .home(home_out), 
			    .index(index_out)
        ); 
            """

  def get_wire_defines(self):
    return """ 
wire pha_out;
wire phb_out;
wire home_out;
wire index_out; 
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return "reg enable_enc;\n"
  def module_rest_codes():
    return "enable_enc <= 1'b0;"
  def get_cmd_case_text(self):
    return "enable_enc <= 1'b1;"
  def get_rst_case_text(self):
    return "enable_enc <= 1'b0;"
  def get_dft_case_text(self):
    return "enable_enc <= 1'b0;"





    


