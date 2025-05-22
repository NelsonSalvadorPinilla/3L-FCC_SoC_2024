#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/3LFCC_3adc_platform/export/3LFCC_3adc_platform/3LFCC_3adc_platform.xpfm
SYS_CONFIG = 3LFCC_3adc_platform
DOMAINS = standalone_domain
BIF_PATH = D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/CLC_3adc_system/Debug/system.bif

BITSTREAM_PATH = D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/CLC_3adc/_ide/bitstream/Design_Closed_Loop_3adc.bit
SD_FILES = --elf D:/Programs/Proyecto_3LFCC_Zybo/Vitis_3adc/CLC_3adc/Debug/CLC_3adc.elf,ps7_cortexa9_0

#
# primary build targets
#

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 56957 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean

all: package


