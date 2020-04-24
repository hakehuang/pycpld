from .. import base_ip
import os
'''
#an example of io_dic of qdec io
{
  ("", 50, "//comments", "pha_out", "qdec")
}
'''

#return the class name for query
def get_ip_name():
  return "QDEC"

class QDEC(base_ip.base_ip):
  ID = "__QDEC"
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
  	#set_global_assignment -name VERILOG_FILE qdec.v
    pkgpath = os.path.dirname(__file__)
    return [ os.path.join(pkgpath,"qdec.v")]
  def get_module_caller(self):
    return """ 
qdec  qdec( .rst_n(rst_n),
          .freq_clk(clk),
          .enable(enable_qdec),
			    .pha(phaseA_out), 
			    .phb(phaseB_out), 
			    .index(qdec_out)
        ); 
            """

  def get_wire_defines(self):
    return """ 
wire phaseA_out;
wire phaseB_out;
wire qdec_out; 
          """

  def get_reg_defines(self):
  	#additional reg definition
  	return "reg enable_qdec;\n"
  def module_rest_codes():
    return "enable_qdec <= 1'b0;"
  def get_cmd_case_text(self):
    return "enable_qdec <= 1'b1;"
  def get_rst_case_text(self):
    return "enable_qdec <= 1'b0;"
  def get_dft_case_text(self):
    return "enable_qdec <= 1'b0;"





    


