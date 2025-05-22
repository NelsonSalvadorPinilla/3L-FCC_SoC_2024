// LAZO ABIERTO 7 bits

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "Xil_exception.h"
#include "sleep.h"
#include "xuartps.h"
#include "xclk_wiz.h"

#include "data_Main.h"

// Variables del Clock Wizard
u64 FREQ_ClkWiz_MHz = 256; // SETEAR FRECUENCIA - Recordar que la PWM opera a FREQ_ClkWiz_MHz/256 approx
XClk_Wiz ClkWiz_Dynamic;
XClk_Wiz_Config *CfgPtr_Dynamic;

// Registros segun el uso del Modulador en la FPGA
int *reg0_interleaved; // Variable de 1 bit - rango: [0,1]
int *reg1_dt; // Variable de 5 bits - rango: [0,31]
int *reg2_d1; // Variable de 7 bits - rango: [0,127]
int *reg3_d2; // Variable de 7 bits - rango: [0,127]
int *reg4_dataValid; // Variable de 1 bit - rango: [0,1]
int *reg5_Test; // Variable de 2 bit - rango: [0,3] -> saca esta señal por JB[1:0]

int main()
{

	init_platform();
	int Status;

	/***************************** UART *****************************/
	XUartPs uart_ps;
	XUartPs_Config *Config = XUartPs_LookupConfig(XPAR_PS7_UART_1_DEVICE_ID);
	XUartPs_CfgInitialize(&uart_ps, Config, Config->BaseAddress);

	/***************************** Clock Wizard *******************************************/

	CfgPtr_Dynamic = XClk_Wiz_LookupConfig(XCLK_WIZARD_DEVICE_ID);
	XClk_Wiz_CfgInitialize(&ClkWiz_Dynamic, CfgPtr_Dynamic, CfgPtr_Dynamic->BaseAddr);

	XClk_Wiz_WriteReg(CfgPtr_Dynamic->BaseAddr,
							  XCLK_WIZ_REG25_OFFSET, 0);

	XClk_Wiz_SetRate(&ClkWiz_Dynamic, FREQ_ClkWiz_MHz); // AQUI SE CAMBIA LA FRECUENCIA EN MHZ

	XClk_Wiz_WriteReg(CfgPtr_Dynamic->BaseAddr,
					   XCLK_US_WIZ_RECONFIG_OFFSET,
					  (XCLK_WIZ_RECONFIG_LOAD |
					  XCLK_WIZ_RECONFIG_SADDR));
	Status = XClk_Wiz_WaitForLock(&ClkWiz_Dynamic);

	if (Status != XST_SUCCESS) {
		xil_printf("WaitForLock Failed\r\n");
		return XST_FAILURE;
	}

	/*********************** Registros de comunicacion de PS a PL ***********************/

	reg0_interleaved = (int *)AXI_Modulator_BASEADDR;
	reg1_dt = (int *)(AXI_Modulator_BASEADDR + 4);
	reg2_d1 = (int *)(AXI_Modulator_BASEADDR + 8);
	reg3_d2 = (int *)(AXI_Modulator_BASEADDR + 12);
	reg4_dataValid = (int *)(AXI_Modulator_BASEADDR + 16);
	reg5_Test = (int *)(AXI_Modulator_BASEADDR + 20);

	/***********************************************************************************************/
	/*************************** Valores de Inicializacion *****************************************/
	*reg0_interleaved= 0; // 0=single core ; 1=interleaved
	*reg1_dt= 4; // periodos de FREQ_ClkWiz_MHz que se usaran como tiempo muerto
	*reg2_d1= 70; // reg2_d1/127% es el duty cycle
	*reg3_d2= 70; // reg3_d2/127% es el duty cycle
	*reg4_dataValid= 0;
	usleep(1000);
	*reg4_dataValid= 1;
	usleep(1000);
	*reg4_dataValid= 0;
	/**********************************************************************************************/
	/**********************************************************************************************/

	printf("Open Loop Control initialized! 3\n");
	char input;

	/*************************** LAZO ABIERTO *****************************************/

	int DC;
	DC = *reg2_d1;

	while (1) {


		if(XUartPs_IsReceiveData(XPAR_PS7_UART_1_BASEADDR)){
			input = XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET);
			switch (input){ // Cambiar dinamicamente Duty Cycle

			case '+':
				DC += 12;
				if (DC >= 127) {
					DC = 127;
					*reg2_d1 = 127;
					*reg3_d2 = 127;
				}
				else{
					*reg2_d1 = DC;
					*reg3_d2 = DC;
				}
			break;

			case '-':
				DC -= 12;
				if (DC <= 0) {
					DC = 0;
					*reg2_d1 = 0;
					*reg3_d2 = 0;
				}
				else{
					*reg2_d1 = DC;
					*reg3_d2 = DC;
				}
			break;

			case '2':
				DC = 70;
				*reg2_d1 = DC;
				*reg3_d2 = DC;
			break;

			default: printf("Caracter invalido, use + o - para modificar el ciclo de trabajo\r\n");
			break;
			}
			printf("Ciclo de trabajo: %f\r\n", ((float)DC/127.0*100.0));
			*reg4_dataValid= 1;
			*reg4_dataValid= 0;
		}
	}

	return 0;
}

