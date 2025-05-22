# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\Programs\Proyecto_3LFCC_Zybo\Vitis_3adc\CLC_3adc_system\_ide\scripts\systemdebugger_clc_3adc_system_standalone.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\Programs\Proyecto_3LFCC_Zybo\Vitis_3adc\CLC_3adc_system\_ide\scripts\systemdebugger_clc_3adc_system_standalone.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zybo 210279778067A" && level==0 && jtag_device_ctx=="jsn-Zybo-210279778067A-13722093-0"}
fpga -file D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/CLC_3adc/_ide/bitstream/Design_Closed_Loop_3adc.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/3LFCC_3adc_platform/export/3LFCC_3adc_platform/hw/Design_Closed_Loop_3adc.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/CLC_3adc/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/CLC_3adc/Debug/CLC_3adc.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
