# pycpld
CPLD program integrated by python script.

#purpose
this project is to use the python script to integrate different CPLD IP into target board system. Currently the Altera MAX-II EP570P is supported with Quartus-15.1 version. and the Arduio compatible CPLD board is added in reference design. 

#future work
anyone can add his project template in quartus-ii folder, so that maore CPLD chips can be supported.
anyone can add new IP into the ip list, and ask for help <hakehuang@gmail.com> to integration, such as his IP can be easy integarted by anyone.


#requirement
1. install python 2.7
2. install alter Quartus lite

#install
1. pip install -r requirements.txt



#build steps
1. create a CPLD configure file in yaml format, please refer to twrkv58f220m_SDK_2_0_enc.yml or twrkv46f150m_SDK_2_0_enc.yml
2. run below
python ./Auto_Generate.py twrkv58f220m_SDK_2_0_enc.yml
3. all files are generated in the output folder

#use the build result
1. copy the quartus-II/top folder and rename it to your project e.g. top_myproject
2. copy all files from the output folder into top_myproject
3. open your top_myproject/top.qpf
4. build the project

