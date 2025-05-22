# 
# Usage: To re-create this platform project launch xsct with below options.
# xsct D:\Projects_Embedded\Closed_Loop\Vitis_3adc\3LFCC_3adc_platform\platform.tcl
# 
# OR launch xsct and run below command.
# source D:\Projects_Embedded\Closed_Loop\Vitis_3adc\3LFCC_3adc_platform\platform.tcl
# 
# To create the platform in a different location, modify the -out option of "platform create" command.
# -out option specifies the output directory of the platform project.

platform create -name {3LFCC_3adc_platform}\
-hw {D:\Projects_Embedded\Closed_Loop\Vivado\Design_Closed_Loop_3adc.xsa}\
-proc {ps7_cortexa9_0} -os {standalone} -out {D:/Projects_Embedded/Closed_Loop/Vitis_3adc}

platform write
platform generate -domains 
platform active {3LFCC_3adc_platform}
platform generate
platform active {3LFCC_3adc_platform}
platform generate -domains 
platform clean
platform generate
platform clean
platform generate
