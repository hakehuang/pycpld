#current supporting IPS
ENC:
an ENC simulation IP which can generate pha/phb/index/home signal

UART:
a UART module can receive and transfer data

UART7Bit:
a UART 7 bit module

#how to mapping IO to IP modules in a cpld module
1. refer to the ips/<ip name>/<ipname>_example.yml
create a file name frdmv2_<your porjcetname>.yml add the example setting to this file.
2. checking the frdmv2_cpld_io.yml in the cpld_io folder, select the pin/function as the PIN: options. The PIN option can either be the function / PIn name defined in the cpld_io.yml file
