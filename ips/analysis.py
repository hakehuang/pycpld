import yaml, os, re
import pkgutil

#ips that are designed
import ip 
from ip.uart.uart_partial import UART
from ip.enc.enc_partial import ENC
from ip.uart7bit.uart7bit_partial import UART7BIT
from ip.pwm_out.pwm_out_partial import PWM_OUT
from ip.pwm_capture.pwm_capture_partial import PWM_CAPTURE
from ip.i2c_master.i2c_master_partial import I2C_MASTER
from ip.i2c_slave.i2c_slave_partial import I2C_SLAVE
from ip.i2c_slave_for_case.i2c_slave_for_case_partial import I2C_SLAVE_FOR_CASE
from ip.spi_master.spi_master_partial import SPI_MASTER
from ip.uart8bit.uart8bit_partial import UART8BIT
from ip.sw_pulse.sw_pulse_partial import SW_PULSE
form ip.quadpwm.quadpwm_partial import QUADPWM

__PATH__        = os.path.dirname(os.path.abspath(__file__)).replace('\\','/')


#################################################################
#CPLD TYPE, NEW CPLD ADD HERE
#################################################################
#TWR
BOARD_CPLD_IO_PATH = {
    'TWR_CPLD_V1':  __PATH__ + "/cpld_io/twr_cpld_io.yml",
    'FRDM_CPLD_V1': __PATH__ + "/cpld_io/frdm_cpld_io.yml",
    'TWR_CPLD_V2':  __PATH__ + "/cpld_io/twrv2_cpld_io.yml",
    'FRDM_CPLD_V2': __PATH__ + "/cpld_io/frdmv2_cpld_io.yml",
    'EP570_CPLD': __PATH__ + "/cpld_io/ep570_cpld_io.yml"
}

BOARD_CPLD_QSF_TEMPLATE = {
    'TWR_CPLD_V1':  __PATH__ + "/template/twr/top_qsf_template.qsf",
    'FRDM_CPLD_V1': __PATH__ + "/template/frdm/top_qsf_template.qsf",
    'TWR_CPLD_V2':  __PATH__ + "/template/twrv2/top_qsf_template.qsf",
    'FRDM_CPLD_V2': __PATH__ + "/template/frdmv2/top_qsf_template.qsf",
    'EP570_CPLD': __PATH__ + "/template/ep570/top_qsf_template.qsf" 
}

BOARD_CPLD_TCL_TEMPLATE = {
    'TWR_CPLD_V1':  __PATH__ + "/template/twr/top_tcl_template.tcl",
    'FRDM_CPLD_V1': __PATH__ + "/template/frdm/top_tcl_template.tcl",
    'TWR_CPLD_V2':  __PATH__ + "/template/twrv2/top_tcl_template.tcl",
    'FRDM_CPLD_V2': __PATH__ + "/template/frdmv2/top_tcl_template.tcl",
    'EP570_CPLD': __PATH__ + "/template/ep570/top_tcl_template.tcl" 
}


CPLD_IO_TABLE = {}

IP_DICT = {'class': [], 'inst':[]}

#Special CPLD IO,       IO/GCLK: 14,62,64,     IO/DEV: 43,     RESET: 44
#Assign specila_IO as general_IO: add them into Used_io list.
SPECIAL_IO = []

CPLD_QSF_TEMPL_PATH = None
CPLD_TCL_TEMPL_PATH = None



##################################################################
#FILE OPERATIONS SECTION
##################################################################
def file_load_yml(fp):
  try:
    f = open(fp,"r")
  except IOError:
    print ("Error: No such file %s"%fp)
    return None

  c = {}
  try:
    c = yaml.load(f)
  except yaml.parser.ParserError:
    print ("Error: There may be some format errors exist in Yaml File.\n%s"%fp)
    return None

  f.close()
  return c

##################################################################
#CPLD PINS PARSER SECTION
##################################################################
def look_up_table(pin, type):
  global CPLD_IO_TABLE
#look up pins in cpld_io.yml
  for i in CPLD_IO_TABLE:
    if   (CPLD_IO_TABLE[i]["PINS"] == pin and (CPLD_IO_TABLE[i]["TYPE"] == type or CPLD_IO_TABLE[i]["TYPE"] == 'NONE'))or(CPLD_IO_TABLE[i]["FUNC"] == pin):
      return i

  if pin is None:
    print ("Error: Empty Tag: \'%s\'"%type)
  else:
    if type == "T": type = "Target"
    else          : type = "Assistant"
    print ("Error: Specific \'%s : %s\' not connected with the CPLD!\n")%(type,pin)

  return None

#For FRDM-Series
def remap_pin(pin):
  if ("CPLD_IO" in pin): return pin
  character = pin[0]
  digit     = int(pin[1:])
  digit     = str(2 + 2*(digit-1))
  pin       = character + digit
  return pin


# the valid direction are A2T T2A T2T
def parser_pin_in_out(connection, switch):
  d = connection["DIRECTION"]
  in_type  = d[0]
  out_type = d[2]

  if in_type == "T":
    try:
      p_in = connection["T_PIN"]
    except KeyError:
      p_in = connection["T_PIN_1"]
  elif in_type == "A":
    p_in = connection["A_PIN"]
  elif in_type == "W":
    p_in = connection["WIRE"]

  if out_type == "T":
    try:
      p_out = connection["T_PIN"]
    except KeyError:
      p_out = connection["T_PIN_2"]
  elif out_type == "A":
    p_out = connection["A_PIN"]
  elif out_type == "W":
    p_out = connection["WIRE"]

  if switch is True and "WIRE" not in connection:
    p_in  = remap_pin(p_in)
    p_out = remap_pin(p_out)


  if (in_type != "W"): CPinIN = look_up_table(p_in, in_type)
  else: CPinIN = p_in

  if (out_type != "W"): CPinOUT = look_up_table(p_out, out_type)
  else: CPinOUT = p_out

  comments = "// %s <- %s"%(p_out, p_in)

  return CPinIN, CPinOUT, comments


#look up io in cpld_io dic
#return:  [(CpldIOIn0,CpldIoOut0,Comments),....]    type[list]
#switch: single row need to remap, this value set True
def look_up(module, switch):
  mname = module["CMD"]

  confuncs = module.keys()
  confuncs.remove("CMD")
  confuncs.sort()

  look_result = []

  for conname in confuncs:
    connection = module[conname]
    CPinIN, CPinOUT, comments = parser_pin_in_out(connection, switch)

    if CPinIN is not None and CPinOUT is not None:
      look_result.append((CPinIN,CPinOUT,comments))
    else:
      return None

  return look_result

import sys, inspect
def print_classes():
    for name, obj in inspect.getmembers(sys.modules[__name__]):
      #print name
      if inspect.isclass(obj):
        print(obj)

#parse IP pins
# do not use the assistant used pins
# only target pins are used
def parser_pin_ip(connection, conname):
  d = connection["DIRECTION"]
  PIN_OUT = None
  PIN_IN = None
  if d.upper() == "OUT":
    p_out = connection["PIN"]
    print p_out
    PIN_OUT = look_up_table(p_out, 'T')
    if PIN_OUT is None:
      PIN_OUT = look_up_table(p_out, 'NONE')
    print PIN_OUT
  elif d.upper() == "INOUT":
    p_io = connection["PIN"]
    print p_io
    PIN_OUT = look_up_table(p_io, 'T')
    if PIN_OUT is None:
      PIN_OUT = look_up_table(p_io, 'NONE')
    PIN_IN = PIN_OUT
  else:
    p_in = connection["PIN"]
    PIN_IN = look_up_table(p_in, 'T')
    if PIN_IN is None:
      PIN_IN = look_up_table(p_in, 'NONE')

  comments = "// %s %s %s"%(connection["DIRECTION"], connection["PIN"], conname)

  ip_wire_name = conname

  return PIN_IN, PIN_OUT, comments, ip_wire_name

#look up io in cpld_io dic for internal IPs
#return:  [(CpldIOIn0,CpldIoOut0,Comments),....]    type[list]
#switch: single row need to remap, this value set True
def look_up_ip(module, switch):
  global IP_DICT
  mname = module["CMD"]
  print "module name: " + mname
  confuncs = module.keys()
  confuncs.remove("CMD")

  #search the IP package and find the matching IPs
  pkgpath = os.path.dirname(ip.__file__)
  cips = [name for _, name, _ in pkgutil.iter_modules([pkgpath])]
  ip_name = None
  for cip in cips:
    print "checking " + cip
    #print_classes()
    #func = getattr(ip, cip + '.get_ip_name')
    sub_module = getattr(ip, cip)
    func = getattr(sub_module, 'get_ip_name')
    sub_module_class = getattr(sub_module, func())
    sub_module_class_instance = sub_module_class("")
    if sub_module_class_instance.matched_id(module['IP']) is True:
      print "ID matched for " + module['IP']
      ip_name = sub_module_class_instance.__class__.__name__
      if sub_module_class_instance.__class__.__name__ not in IP_DICT['class']:
        IP_DICT['inst'].append(sub_module_class_instance)
        IP_DICT['class'].append(sub_module_class_instance.__class__.__name__)
        if "ALT" in module:
          print "*****************************"
          print "set inst alt %s"%(module["ALT"])
          sub_module_class_instance.set_alt(module["ALT"])
          sub_module_class_instance.ALT_CMD = mname
      elif "ALT" in module:
        print "*****************************"
        print "set inst alt %s"%(module["ALT"])
        IP_DICT['inst'].append(sub_module_class_instance)
        IP_DICT['class'].append(sub_module_class_instance.__class__.__name__)
        sub_module_class_instance.set_alt(module["ALT"])
        sub_module_class_instance.ALT_CMD = mname
      break

  if ip_name is None:
    print "No matching IP found for " + module['IP']
    return None
  confuncs.remove("IP")
  if "ALT" in confuncs:
    confuncs.remove("ALT")
  confuncs.sort()

  look_result = []

  if mname == "BIM":
    look_result.append(('','',"//build in %s"%module['IP'], 'BIM', ip_name))
    return look_result

  for conname in confuncs:
    connection = module[conname]
    CPinIN, CPinOUT, comments, ip_ping_wire = parser_pin_ip(connection, conname)

    if CPinIN is not None or CPinOUT is not None:
      look_result.append((CPinIN,CPinOUT,comments, ip_ping_wire, ip_name))
    else:
      return None

  return look_result  

 

def map_io(modules):
  '''
  <cmd>: [(ioin0,inout0,comments),...(ioin,ioout,comments), <module_name>]

  Struct io_dic:
  {
    <moudle_cmd_0>: [(ioin0,inout0,comments),...(ioin,ioout,comments), module_name],
    <moudle_cmd_1>: [(ioin0,inout0,comments),...(ioin,ioout,comments), module_name],
    <moudle_cmd_2>: [(ioin0,inout0,comments),...(ioin,ioout,comments), module_name],
    ...
  }

  '''
  SingF  = 0
  switch = False

  try:
    SingF = modules["SINGLE"]
    del modules["SINGLE"]
  except KeyError:
    pass

  if SingF == 1: switch = True

  io_dic = {}

  #look up io in cpld for each module
  for module_name in modules:
    module = modules[module_name]
    CMD = module["CMD"]

    if ( "IP" in module):
      io_dic[CMD] = look_up_ip(module, switch)
      if io_dic[CMD] is None:
        print ("Error: Pin error, Please check your yml file at module: \'%s\'."%module_name)
        return None
      io_dic[CMD].append(module_name)
    else:
      io_dic[CMD] = look_up(module, switch)
      if io_dic[CMD] is None:
        print ("Error: Pin error, Please check your yml file at module: \'%s\'."%module_name)
        return None
      io_dic[CMD].append(module_name)
  build_in_module = {'IP': '__UART', 'CMD': 'BIM'}
  io_dic['UART'] = look_up_ip(build_in_module, switch)
  return io_dic


#cpld ip analyze: divide bus
def cpld_io_analyze(io_dic):
  #initial Used_io list
  Used_io = SPECIAL_IO
  for cmd in io_dic:
    tem = io_dic[cmd][0:-1]
    for i in tem:
      if i[0] not in Used_io:
        Used_io.append(i[0])
      if i[1] not in Used_io:
        Used_io.append(i[1])
  #sort list
  Used_io = filter(None, Used_io)
  Used_io.sort()

  print "Used IO-Pins: ",Used_io

  MAX   = 0
  MIN   = Used_io[0]
  scope = []

  #Divide Bus Scope
  for i in xrange(1,len(Used_io)):
    if Used_io[i] - Used_io[i-1] > 7:
      MAX = Used_io[i-1]
      scope.append((MIN,MAX))
      MIN = Used_io[i]
  MAX = Used_io[-1]
  scope.append((MIN,MAX))

  num_bus = len(scope)

  SUM = 0
  for n in xrange(num_bus):
    bus = scope[n]
    SUM += bus[1] - bus[0] + 1
    if SUM > 76:
      print "Auto-Bus Definition Error:",scope
      return None,None,None

  return scope, Used_io

##################################################################
#AUTO-GENERATE-API
##################################################################
def analysis_context(boardyml):
  global CPLD_IO_TABLE
  global BOARD_CPLD_IO_PATH
  global CPLD_QSF_TEMPL_PATH
  global CPLD_TCL_TEMPL_PATH

  file_name = os.path.basename(boardyml)
  dir_name  = os.path.dirname(boardyml)
  ##########################################################################
  #Choose cpld. According cpld versio and type, load cpld io and template path
  ##########################################################################
  #TYPE: TWR CPLD
  if  re.search("twr", file_name):
    #TWR CPLD V2
    if re.search("v2", dir_name):
      cpld_io_path  = BOARD_CPLD_IO_PATH['TWR_CPLD_V2']
      CPLD_QSF_TEMPL_PATH = BOARD_CPLD_QSF_TEMPLATE['TWR_CPLD_V2']
      CPLD_TCL_TEMPL_PATH = BOARD_CPLD_TCL_TEMPLATE['TWR_CPLD_V2']
    #TWR CPLD V1
    else:
      cpld_io_path  = BOARD_CPLD_IO_PATH['TWR_CPLD_V1']
      CPLD_QSF_TEMPL_PATH = BOARD_CPLD_QSF_TEMPLATE['TWR_CPLD_V1']
      CPLD_TCL_TEMPL_PATH = BOARD_CPLD_TCL_TEMPLATE['TWR_CPLD_V1']

  #TYPE: FRDM CPLD
  elif re.search("frdm", file_name):
    #FRDM CPLD V2
    if re.search("v2", dir_name):
      cpld_io_path  = BOARD_CPLD_IO_PATH['FRDM_CPLD_V2']
      CPLD_QSF_TEMPL_PATH = BOARD_CPLD_QSF_TEMPLATE['FRDM_CPLD_V2']
      CPLD_TCL_TEMPL_PATH = BOARD_CPLD_TCL_TEMPLATE['FRDM_CPLD_V2']


    #FRDM CPLD V1
    else:
      cpld_io_path  = BOARD_CPLD_IO_PATH['FRDM_CPLD_V1']
      CPLD_QSF_TEMPL_PATH = BOARD_CPLD_QSF_TEMPLATE['FRDM_CPLD_V1']
      CPLD_TCL_TEMPL_PATH = BOARD_CPLD_TCL_TEMPLATE['FRDM_CPLD_V1']

  #TYPE: CPLD EP570
  elif re.search("ep570", dir_name):
    cpld_io_path  = BOARD_CPLD_IO_PATH['EP570_CPLD']
    CPLD_QSF_TEMPL_PATH = BOARD_CPLD_QSF_TEMPLATE['EP570_CPLD']
    CPLD_TCL_TEMPL_PATH = BOARD_CPLD_TCL_TEMPLATE['EP570_CPLD']


  else:
    print "Error: Unknown CPLD Version!"
    return

  #load yml files
  modules = file_load_yml( boardyml )
  CPLD_IO_TABLE = file_load_yml( cpld_io_path )

  if modules is None or CPLD_IO_TABLE is None:
    print ("Error: Load file error.")
    return None

  #map cpld pins with boards(target & assitant), return a dic
  io_dic = map_io(modules)
  print io_dic
  if io_dic is None:
    return None, None


  bus_scope, Used_io = cpld_io_analyze(io_dic)
  
  if Used_io is None:
    print ("Error: Bus Definition!")
    return None, None

  #Generate  my_uart_top.v
  #---------------------------------------------
  #---------------------------------------------
  return io_dic, bus_scope
  #generate_top_v_file(internal_io_dic, external_io_dic, bus_scope)
    
  
