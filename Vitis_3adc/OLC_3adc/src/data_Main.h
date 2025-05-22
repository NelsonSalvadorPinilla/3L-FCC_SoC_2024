#ifndef DATA_MAIN_H
#define DATA_MAIN_H

#define Offset_Aux7         0x25C // Offset Address del Address Editor en Vivado
#define Offset_Aux14        0x278 // Offset Address del Address Editor en Vivado
#define Offset_Aux15 		0x27C

#define FactorConversionRaw2Volt 0.0000152588
#define FACTOR_CONVERSION (FactorConversionRaw2Volt * 4.0)

// Estas direcciones vienen dadas desde el Address Editor en Vivado, y aca se pueden verificar en el archivo xparameters.h
#define XADC_BASEADDR XPAR_XADC_WIZARD_BASEADDR
#define AXI_Modulator_BASEADDR XPAR_PS_TO_REGS_0_S00_AXI_BASEADDR

#define XCLK_WIZARD_DEVICE_ID XPAR_CLK_WIZ_0_DEVICE_ID
#define XCLK_US_WIZ_RECONFIG_OFFSET 0x0000025C


#endif
