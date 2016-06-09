# pycpld
CPLD program integrated by python script

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

