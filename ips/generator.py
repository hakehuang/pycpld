
import sys
import os
import sys
import shutil

## import modules and helper functions
import tenjin
from tenjin.escaped import is_escaped, as_escaped, to_escaped
#tenjin.set_template_encoding('cp932')   # template encoding
from tenjin.helpers import *
from . import analysis
from . import cpld

from shutil import copyfile

__PATH__      = os.path.dirname(os.path.abspath(__file__)).replace('\\','/')
__PATH_DIR__  = os.path.dirname(__PATH__)
#output
VERILOG_OUTPUT_PATH = __PATH_DIR__ + "/output"

#template file
VERILOG_TEMPLATE_PATH = __PATH_DIR__ + "/ips/template/top_template.v"

#io_dic
IO_DIC = None

## create engine object
engine = tenjin.Engine(path=['template'])

VERILOG_FILE_TEXT = "set_global_assignment -name VERILOG_FILE %s\n"
PIN_ASSIGNMENT_TEXT = "set_location_assignment PIN_%s -to %s\n"

def save_template_to_file(outpath, output_file_name, template):
  try:
    shutil.rmtree(outpath)
  except OSError, e:
    print ("Error: %s - %s." % (e.filename,e.strerror))

  if not os.path.exists(outpath):
    os.makedirs(outpath)
  #create the verilog integration output file according to the template
  output_name = output_file_name + ".v"
  fileout_path = os.path.join(outpath, output_name)
  print fileout_path
  fp = open(fileout_path, 'w')
  fp.write(template)
  fp.close()
  #copy the ip verilog files
  for inst in analysis.IP_DICT['inst']:
    files = inst.get_v_file_list()
    for i in files:
      print "copy file " + os.path.basename(i)
      copyfile(i, os.path.join(outpath,os.path.basename(i)))

  #update the qsf file
  qsf_context = {'ENTRY':'',
  'VERILOG_FILES':'', 
  'SET_PINS_TEXT':''}

  qsf_context['ENTRY'] = output_file_name

  v_file_list = []
  for inst in analysis.IP_DICT['inst']:
    v_file_list += inst.get_v_file_list()

  VERILOG_FILES = ""
  for file in v_file_list:
    VERILOG_FILES += VERILOG_FILE_TEXT%(os.path.basename(file))
  qsf_context['VERILOG_FILES'] = VERILOG_FILES
  SET_PINS_TEXT = ""
  for bus_pair in cpld.BUS_LIST:
    SET_PINS_TEXT += PIN_ASSIGNMENT_TEXT%(bus_pair[1],  bus_pair[0])
  qsf_context['SET_PINS_TEXT'] = SET_PINS_TEXT

  qsf = engine.render(analysis.CPLD_QSF_TEMPL_PATH, qsf_context)
  tcl = engine.render(analysis.CPLD_TCL_TEMPL_PATH, qsf_context)
  output_name = output_file_name + ".qsf"
  fileout_path = os.path.join(outpath, output_name)
  print fileout_path
  fp = open(fileout_path, 'w')
  fp.write(qsf)
  fp.close()
  output_name = output_file_name + ".tcl"
  fileout_path = os.path.join(outpath, output_name)
  print fileout_path
  fp = open(fileout_path, 'w')
  fp.write(tcl)
  fp.close()


#analyze the boardyml and update the context for tempale
def analysis_yml(boardyml, context):
  io_dic, bus_scope = analysis.analysis_context(boardyml)
  print io_dic
  print bus_scope
  if io_dic is None:
    return None
  IO_DIC = io_dic
  INIT_REG_TEXT, CMD_CASE_TEXT, RST_REG_TEXT, DFT_REG_TEXT = cpld.Code_verilog_reg(io_dic)  
  context['INIT_REG_TEXT'] = as_escaped(INIT_REG_TEXT)
  context['CMD_CASE_TEXT'] = as_escaped(CMD_CASE_TEXT)
  context['RST_REG_TEXT'] = as_escaped(RST_REG_TEXT)
  context['DFT_REG_TEXT'] = as_escaped(DFT_REG_TEXT)
  MODULE_TEXT = cpld.Module_header(bus_scope)
  context['MODULE_TEXT'] = as_escaped(MODULE_TEXT)
  INOUT_TEXT = cpld.inout(bus_scope)
  context['INOUT_TEXT'] = as_escaped(INOUT_TEXT)
  WIRE_TEXT = cpld.wire(io_dic)
  context['WIRE_TEXT'] = as_escaped(WIRE_TEXT)
  REG_TEXT = cpld.reg(io_dic)
  context['REG_TEXT'] = as_escaped(REG_TEXT)
  ASSIGN_TEXT = cpld.assign(io_dic, bus_scope)
  context['ASSIGN_TEXT'] = ASSIGN_TEXT
  IP_TEXT = cpld.ip_caller(io_dic)
  context['IP_TEXT'] = IP_TEXT
  return True


def generate(boardyml):
  ## context data
  context = {
    'MODULE_TEXT': 'module top(clk,rst_n,rs232_rx,rs232_tx, %s, led);',
    'INOUT_TEXT': '',
    'WIRE_TEXT': '',
    'REG_TEXT': '',
    'ASSIGN_TEXT': '',
    'IP_TEXT': '',
    'INIT_REG_TEXT': '',
    'CMD_CASE_TEXT': '',
    'RST_REG_TEXT': '',
    'DFT_REG_TEXT': ''
  }

  ret = analysis_yml(boardyml, context)
 
  if ret is None:
    return None
  ## render template with context data
  print "rend data*******************"
  topv = engine.render(VERILOG_TEMPLATE_PATH, context)

  save_template_to_file(VERILOG_OUTPUT_PATH, 'top', topv)
  print VERILOG_OUTPUT_PATH




