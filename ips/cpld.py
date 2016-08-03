import yaml, os, re,sys

import analysis

#Bus Name Definition
BUS_NAME = ["BusA", "BusB", "BusC", "BusD", "BusE", "BusF", "BusG", "BusH", "BusI", "BusJ", "BusK", "BusL"]

#Special CPLD IO,       IO/GCLK: 14,62,64,     IO/DEV: 43,     RESET: 44
#Assign specila_IO as general_IO: add them into Used_io list.
SPECIAL_IO = []

#BUS LIST
BUS_LIST = []

##################################################################
#CODE SYNTAX DEFINITON SECTION
##################################################################
#Quartus TCL Assignment Syntax
Quartus_TCL_ASSIGNMENT_TEXT = "set_location_assignment PIN_%s -to %s\n"

#Verilog: name reg example(linkSPI)
LINK_NAME = "link%s"

#Verilog: reg **;
REG_TEXT = "reg %s;\n"

#Verilog inout Syntax
INOUT_TEXT = "inout [%d:%d] %s;\n"

#Verilog: assign Bus[1] =  %s? Bus[0] : 1'bz;
ASSIGN_TEXT = "assign %s =  %s ? %s : 1'bz;"

#Verilog module definiton Syntax
MODULE_TEXT = "module top(clk,rst_n,rs232_rx,rs232_tx, %s led);\n"

#Verilog: reg assignment Syntax
TO_REG_TEXT = "%s <= 1'b%d;\n"

#Verilog: led
TO_LED_TEXT = "\t\t\t  led <= 1'b1;\n"

#Verilog: code block
TO_WIRE_TEXT = "wire %s;\n"

TO_REG_INIT_TEXT = "reg %s;\n"

TO_ASSIGN_TEXT = "assign %s =  %s ? %s : 1'bz;\n"

TO_ALIAS_TEXT = '`define %s %s\n'

IP_TEXT = "%s\n"

TO_CMD_CASE_TEXT = '''
      {%s,%s, %s}: //{C,M,D}
      begin
        %s
        led <= 1'b1;
      end
      '''

TO_RST_REG_TEXT = "%s // linkFCP <= 1'b0;\n"

TO_DFT_REG_TEXT = "%s // linkFCP <= 1'b0;\n"


##################################################################
#CODE GENERATE SECTION
##################################################################
def get_ip_inst(ipname, cmd_key):
  cinst = None
  if ipname in analysis.IP_DICT['class']:
    for inst in analysis.IP_DICT['inst']:
      if inst.__class__.__name__ == ipname:
        if hasattr(inst, 'ALT_CMD'):
          if inst.ALT_CMD == cmd_key:
            cinst = inst
            break
        else:
          cinst = inst
          break
  return cinst


def ip_caller(io_dic):
  IP_TEXT = ''
  for cmd in io_dic:
    cinst = None
    LINKCMD = LINK_NAME%cmd
    for settings in io_dic[cmd]:
      if len(settings) == 5:
        #this has a IP settings
        cinst = get_ip_inst(settings[4], cmd)
        break
        # if settings[4] in analysis.IP_DICT['class']:
        #   for inst in analysis.IP_DICT['inst']:
        #     if inst.__class__.__name__ == settings[4]:
        #       cinst = inst
    #ensure we find the inst
    if cinst is not None:
      if cinst.get_module_caller() not in IP_TEXT:
        IP_TEXT += cinst.get_module_caller()
  return IP_TEXT



def get_busname_by_id(bus_scope_list, bid):
  bus_count = len(bus_scope_list)
  Bus = []
  #Generate bus definition code
  for n in xrange(bus_count):
    bus = bus_scope_list[n]
    Bus.append([bus[1], bus[0], BUS_NAME[n]])

  for sub_bus in Bus:
    if bid >= sub_bus[1] and bid <= sub_bus[0]:
      print "%s assign bus %s"%(bid ,sub_bus[2])
      return sub_bus[2]

def assign(io_dic,bus_scope_list):
  global BUS_LIST
  isolated_inout_pins = []
  # INIT_REG_TEXT block
  ASSIGN_TEXT = ''
  for cmd in io_dic:
    cinst = None
    LINKCMD = LINK_NAME%cmd
    isbuildin = False
    for settings in io_dic[cmd]:
      isbuildin = False
      if len(settings) == 5:
        #this has a IP settings
        if settings[3] == "BIM":
          print "a build in moudle does not need special settings"
          isbuildin = True
        else:
          cinst = get_ip_inst(settings[4] ,cmd)
        # if settings[4] in analysis.IP_DICT['class']:
        #   for inst in analysis.IP_DICT['inst']:
        #     if inst.__class__.__name__ == settings[4]:
        #       cinst = inst
      if isbuildin == True:
        continue
      #ensure we find the inst
      if cinst is not None and len(settings) == 5 and settings.__class__.__name__ == "tuple":
        if settings[0] is None:
          #output pin
          busname_1 = get_busname_by_id(bus_scope_list, settings[1])
          bus_assign_1 = "%s[%s]"%(busname_1, settings[1])
          ASSIGN_TEXT +=  TO_ASSIGN_TEXT%(bus_assign_1, LINKCMD, settings[3])
          BUS_LIST.append([bus_assign_1,settings[1]])
        elif settings[1] is None:
          #inut pin
          busname_0 = get_busname_by_id(bus_scope_list, settings[0])
          bus_assign_0 = "%s[%s]"%(busname_0, settings[0])
          ASSIGN_TEXT +=  TO_ASSIGN_TEXT%(settings[3], LINKCMD, bus_assign_0)
          BUS_LIST.append([bus_assign_0,settings[0]])
        else:
          #inout pins
          busname = get_busname_by_id(bus_scope_list, settings[0])
          bus_assign = "%s[%s]"%(busname, settings[1])
          if (bus_assign not in isolated_inout_pins):
            ASSIGN_TEXT += TO_ALIAS_TEXT%(settings[3], bus_assign)
            isolated_inout_pins.append(bus_assign)
      elif len(settings) == 3 and settings.__class__.__name__ == "tuple":
        #normal pin settings
        busname_0 = get_busname_by_id(bus_scope_list, settings[0])
        busname_1 = get_busname_by_id(bus_scope_list, settings[1])
        bus_assign_0 = "%s[%s]"%(busname_0, settings[0])
        bus_assign_1 = "%s[%s]"%(busname_1, settings[1])

        ASSIGN_TEXT += TO_ASSIGN_TEXT%(bus_assign_1, LINKCMD, bus_assign_0)
        BUS_LIST.append([bus_assign_0,settings[0]])
        BUS_LIST.append([bus_assign_1,settings[1]])
      else: #not a pin setting
        pass
  #check the inout constrains
  #in cpld the inout pins that used by ips can not be used as in/out agains
  for cmd in io_dic:
    cinst = None
    LINKCMD = LINK_NAME%cmd
    isbuildin = False
    for settings in io_dic[cmd]:
      isbuildin = False
      if len(settings) == 5:
        #this has a IP settings
        if settings[3] == "BIM":
          print "a build in moudle does not need special settings"
          isbuildin = True
        else:
          cinst = get_ip_inst(settings[4], cmd)
          break
        # if settings[4] in analysis.IP_DICT['class']:
        #   for inst in analysis.IP_DICT['inst']:
        #     if inst.__class__.__name__ == settings[4]:
        #       if hasattr(inst, 'alt'):
        #         if inst.alt == cmd:
        #           cinst = inst
        #       else:
        #         cinst = inst
      if isbuildin == True:
        continue
      if cinst is not None and len(settings) == 5 and settings.__class__.__name__ == "tuple":
        if settings[0] is None:
          #output pin
          busname_1 = get_busname_by_id(bus_scope_list, settings[1])
          bus_assign_1 = "%s[%s]"%(busname_1, settings[1])
          if (bus_assign_1 in isolated_inout_pins):
            print "Error %s is used in inout and can not be used otherwise!"%(bus_assign_1)
            sys.exit()
        elif settings[1] is None:
          #inut pin
          busname_0 = get_busname_by_id(bus_scope_list, settings[0])
          bus_assign_0 = "%s[%s]"%(busname_0, settings[0])
          if (bus_assign_0 in isolated_inout_pins):
            print "Error %s is used in inout and can not be used otherwise!"%(bus_assign_1)
            sys.exit()          
        else:
          pass
      elif len(settings) == 3 and settings.__class__.__name__ == "tuple":
        #normal pin settings
        busname_0 = get_busname_by_id(bus_scope_list, settings[0])
        busname_1 = get_busname_by_id(bus_scope_list, settings[1])
        bus_assign_0 = "%s[%s]"%(busname_0, settings[0])
        bus_assign_1 = "%s[%s]"%(busname_1, settings[1])
        if (bus_assign_0 in isolated_inout_pins or bus_assign_1 in isolated_inout_pins):
          print "Error %s is used in inout and can not be used otherwise!"%(bus_assign_1)
          sys.exit()  
      else: #not a pin setting
        pass

  return ASSIGN_TEXT

def reg(io_dic):
  REG_TEXT = ""
  for cmd in io_dic:
    cinst = None
    LINKCMD = LINK_NAME%cmd
    REG_TEXT += TO_REG_INIT_TEXT%LINKCMD
    for settings in io_dic[cmd]:
      if len(settings) == 5:
        #this has a IP settings
        cinst = get_ip_inst(settings[4], cmd)
        break
        # if settings[4] in analysis.IP_DICT['class']:
        #   for inst in analysis.IP_DICT['inst']:
        #     if inst.__class__.__name__ == settings[4]:
        #       if hasattr(inst, 'alt'):
        #         if inst.alt == cmd:
        #       else
        #         cinst = inst
    #ensure we find the inst
    if cinst is not None:
      if cinst.get_reg_defines() not in REG_TEXT:
        REG_TEXT += cinst.get_reg_defines()
  return REG_TEXT  

def wire(io_dic):
  WIRE_TEXT = ""
  for cmd in io_dic:
    cinst = None
    LINKCMD = LINK_NAME%cmd
    for settings in io_dic[cmd]:
      if len(settings) == 5:
        #this has a IP settings
        cinst = get_ip_inst(settings[4], cmd)
        break
        # if settings[4] in analysis.IP_DICT['class']:
        #   for inst in analysis.IP_DICT['inst']:
        #     if inst.__class__.__name__ == settings[4]:
        #       cinst = inst
    #ensure we find the inst
    if cinst is not None:
      if cinst.get_wire_defines() not in WIRE_TEXT:
        WIRE_TEXT += cinst.get_wire_defines()
  return WIRE_TEXT

def verilog_inout(max,min,busname):
  CodeText = INOUT_TEXT%(max,min,busname)
  return CodeText

def inout(bus_scope_list):
  BusText = ""
  bus_count = len(bus_scope_list)
  #Generate bus definition code
  for n in xrange(bus_count):
    bus = bus_scope_list[n]
    BusText += verilog_inout(bus[1], bus[0], BUS_NAME[n])

  return BusText


def Module_header(bus_scope_lsit):
  FunctionVariableText = ''
  bus_count = len(bus_scope_lsit)
  for i in BUS_NAME[:bus_count]:
    FunctionVariableText += i+","
  FunctionTitle = MODULE_TEXT%FunctionVariableText
  return FunctionTitle


# ${INIT_REG_TEXT}
# ${CMD_CASE_TEXT}
# ${RST_REG_TEXT}
# ${DFT_REG_TEXT}
def Code_verilog_reg(io_dic):
  # INIT_REG_TEXT block
  INIT_REG_TEXT = ''
  CMD_CASE_TEXT = ''
  RST_REG_TEXT = ''
  DFT_REG_TEXT = ''
  for cmd in io_dic:
    cinst = None
    isbuildin = False
    LINKCMD = LINK_NAME%cmd
    for settings in io_dic[cmd]:
      isbuildin = False
      if len(settings) == 5 and settings.__class__.__name__ == "tuple":
        if settings[3] == "BIM":
          print "a build in moudle does not need special settings"
          isbuildin = True
          continue
        #this has a IP settings
        cinst = get_ip_inst(settings[4], cmd)
        break
        # if settings[4] in analysis.IP_DICT['class']:
        #   for inst in analysis.IP_DICT['inst']:
        #     if inst.__class__.__name__ == settings[4]:
        #       cinst = inst
    if isbuildin == True:
      continue
    #ensure we find the inst
    if cinst is not None:
      INIT_REG_TEXT += "\t\t\t" + TO_REG_TEXT%(LINKCMD, 0)
      case_string = TO_REG_TEXT%(LINKCMD, 1) + "\t\t\t "+ cinst.get_cmd_case_text() + "\n";
      CMD_CASE_TEXT += TO_CMD_CASE_TEXT%(cmd[0], cmd[1], cmd[2], case_string)
      if cinst.get_rst_case_text() not in RST_REG_TEXT:
        RST_REG_TEXT += "\t\t\t" + cinst.get_rst_case_text() + "\n"
        DFT_REG_TEXT += "\t\t\t" + cinst.get_dft_case_text() + "\n"
    else: #normal pin settings
      INIT_REG_TEXT += "\t\t\t" + TO_REG_TEXT%(LINKCMD, 0)
      CMD_CASE_TEXT += "\t\t\t" + TO_CMD_CASE_TEXT%(cmd[0], cmd[1], cmd[2], TO_REG_TEXT%(LINKCMD, 1))
    RST_REG_TEXT += "\t\t\t" + TO_REG_TEXT%(LINKCMD, 0)
    DFT_REG_TEXT += "\t\t\t" + TO_REG_TEXT%(LINKCMD, 0)
  return INIT_REG_TEXT, CMD_CASE_TEXT, RST_REG_TEXT, DFT_REG_TEXT


