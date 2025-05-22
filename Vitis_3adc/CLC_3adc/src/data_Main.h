#ifndef DATA_MAIN_H
#define DATA_MAIN_H

#define SYSMON_DEVICE_ID 	XPAR_SYSMON_0_DEVICE_ID
#define INTR_ID				XPAR_FABRIC_XADC_WIZARD_IP2INTC_IRPT_INTR
#define INTC_DEVICE_ID		XPAR_SCUGIC_SINGLE_DEVICE_ID

#define Offset_Aux7         0x25C // Offset Address del Address Editor en Vivado
#define Offset_Aux14        0x278 // Offset Address del Address Editor en Vivado
#define Offset_Aux15 		0x27C
#define FactorConversionRaw2Volt 0.0000152588
#define FACTOR_CONVERSION (FactorConversionRaw2Volt * 4.0)
#define MAX_DUTY_CYCLE 127

// Estas direcciones vienen dadas desde el Address Editor en Vivado, y aca se pueden verificar en el archivo xparameters.h
#define XADC_BASEADDR XPAR_XADC_WIZARD_BASEADDR
#define AXI_Modulator_BASEADDR XPAR_PS_TO_REGS_0_S00_AXI_BASEADDR

#define XCLK_WIZARD_DEVICE_ID XPAR_CLK_WIZ_0_DEVICE_ID
#define XCLK_US_WIZ_RECONFIG_OFFSET 0x0000025C

static int SetupInterruptSystem(XScuGic *IntcInstancePtr, XSysMon *XAdcPtr, u16 IntrId);
void XAdcInterruptHandler(void *CallBackRef);

#endif
