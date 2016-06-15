import yaml, os, sys

__PATH__       	= os.path.dirname(os.path.abspath(__file__)).replace('\\','/')
board_prefix = {'1':'twr', '2': 'frdm', '3':'twrv2', '4': 'frdmv2'}

def create_new_yml(board, output_prefix):
	fp = file(__PATH__ + "/../ips/template/template_board.yml")
	lines = []
	for line in fp: 
	    lines.append(line)
	fp.close()

	s = ''.join(lines)
	if output_prefix:
		filepath = __PATH__ + "/" + output_prefix +"/"+ board+".yml"
	else:
		filepath = __PATH__ + "/"+ board+".yml"

	fp = file(filepath, "w")
	fp.write(s)
	fp.close()
	print filepath
	print ("Create Sucessfully!")

print """ Please select the CPLD board Type:
      1: TWR_CPLD
      2: FRDM_CPLD
      3: TWRV2_CPLD 201512 version
      4: FRDMV2_CPLD 201512 version
"""
print "CPLD board type: "
sys.stdout.flush()
cpld_type = raw_input()
print ""
print "please enter Board name:"
sys.stdout.flush()
board = raw_input()
create_new_yml(board, board_prefix[cpld_type])
sys.stdout.flush()
os.system("Pause")
