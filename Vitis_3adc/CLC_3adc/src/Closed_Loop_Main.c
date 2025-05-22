// LAZO CERRADO 7 bits triangular

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xsysmon.h"
#include "xscugic.h"
#include "Xil_exception.h"
#include "sleep.h"
#include "xuartps.h"
#include "xclk_wiz.h"

#include "data_Main.h"
#include "data_PI_controller.h"

/* ------------------- defines ------------------- */

#define CLK1MHZ
//#define CLK250KHZ
//#define CLK2MHZ

//#define INTERLEAVED	// NO OLVIDAR CONECTAR EL JUMPER EN LA TEST BOARD

//#define DESACOPLE
//#define ESCALON
//#define UI_MED

/* ----------------------------------------------- */

XSysMon SysMonInst;
XScuGic InterruptController;

// Voltajes de referencia
volatile double Voutref = 1.8; // Vout Ref
volatile double Vfcref = 1.65; // V flying capacitor
unsigned int D1, D2;
float data14_Vout;
float data_Vfc, data7_Vfc_p, data15_Vfc_n;

#if defined (DESACOPLE) || defined (ESCALON)
// Contador global para triangular/escalon
unsigned long int COUNTER = 0;
#endif

// Variables del Clock Wizard
#ifdef CLK1MHZ
u64 FREQ_ClkWiz_MHz = 256; // SETEAR FRECUENCIA - Recordar que la PWM opera a FREQ_ClkWiz_MHz/256 approx
#elif defined CLK250KHZ
u64 FREQ_ClkWiz_MHz = 64;
#elif defined CLK2MHZ
u64 FREQ_ClkWiz_MHz = 512;
#endif
XClk_Wiz ClkWiz_Dynamic;
XClk_Wiz_Config *CfgPtr_Dynamic;

// Registros segun el uso del Modulador en la FPGA
int *reg0_interleaved; // Variable de 1 bit - rango: [0,1]
int *reg1_dt; // Variable de 5 bits - rango: [0,31]
int *reg2_d1; // Variable de 7 bits - rango: [0,127]
int *reg3_d2; // Variable de 7 bits - rango: [0,127]
int *reg4_dataValid; // Variable de 1 bit - rango: [0,1]
int *reg5_Test; // Variable de 2 bit - rango: [0,3] -> saca esta se�al por JB[1:0]

/* Funciones para desacople/escalon */
#ifdef DESACOPLE
float generar_tri(float volt, float max, float min, float paso, int FREQ);
#endif

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

	/************************* Interrupciones XADC *************************/
	XSysMon_Config *ConfigPtr;
	XSysMon *SysMonInstPtr = &SysMonInst;

	ConfigPtr = XSysMon_LookupConfig(SYSMON_DEVICE_ID);
	if (ConfigPtr == NULL) {
		xil_printf("No config found\n");
		return XST_FAILURE;
	}

	XSysMon_CfgInitialize(SysMonInstPtr, ConfigPtr, ConfigPtr->BaseAddress);

	Status = SetupInterruptSystem(&InterruptController, &SysMonInst, INTR_ID);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_SAFE);
	XSysMon_SetSequencerMode(SysMonInstPtr, XSM_SEQ_MODE_CONTINPASS);
	XSysMon_SetAlarmEnables(SysMonInstPtr, 0x0);
	XSysMon_SetCalibEnables(SysMonInstPtr, XSM_CFR1_CAL_VALID_MASK);
	XSysMon_GetStatus(SysMonInstPtr); /* Clear the old status */

	XSysMon_IntrEnable(SysMonInstPtr, XSM_IPIXR_EOC_MASK);
	XSysMon_IntrGlobalEnable(SysMonInstPtr);

	/*********************** Registros de comunicacion de PS a PL ***********************/

	reg0_interleaved = (int *)AXI_Modulator_BASEADDR;
	reg1_dt = (int *)(AXI_Modulator_BASEADDR + 4);
	reg2_d1 = (int *)(AXI_Modulator_BASEADDR + 8);
	reg3_d2 = (int *)(AXI_Modulator_BASEADDR + 12);
	reg4_dataValid = (int *)(AXI_Modulator_BASEADDR + 16);
	reg5_Test = (int *)(AXI_Modulator_BASEADDR + 20);

	/***********************************************************************************************/
	/*************************** Valores de Inicializacion *****************************************/
#ifdef INTERLEAVED
	*reg0_interleaved= 1; // 0=single core ; 1=interleaved
#else
	*reg0_interleaved= 0;
#endif
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

	printf("Closed Loop Control initialized!\n");

	/*************************** LAZO CERRADO *****************************************/
	/*
	 * print("Toque cualquier tecla para iniciar el lazo de control (hasta entonces el sistema esta en lazo abierto con los valores por default)\n\r");
	while(!(XUartPs_IsReceiveData(XPAR_PS7_UART_1_BASEADDR)));
	XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET);
	print("Comenzara en 3 segundos\n\r");
	sleep(3);
	*/
	char input;
#ifdef DESACOPLE
	int DIRECTION = 0;
	int DIRECTION2 = 0;
#endif
#ifdef ESCALON
	int estado = 0;
#endif

	while (1) {

		if(XUartPs_IsReceiveData(XPAR_PS7_UART_1_BASEADDR)) {
			input = XUartPs_ReadReg(XPAR_PS7_UART_1_BASEADDR, XUARTPS_FIFO_OFFSET);
			switch (input){ // Cambiar dinamicamente Vout ref

				case '0': Voutref = 0.0;
				break;

				case '1': Voutref = 1.2;
				break;

				case '2': Voutref = 1.8;
				break;

				case '3': Voutref = 2.4;
				break;

				case '4': Voutref = 3.3;
				break;

				case '+': Voutref += 0.3;
						  if(Voutref>=3.3){Voutref = 3.3;}
				break;

				case '-': Voutref -= 0.3;
						  if(Voutref<=0.0){Voutref = 0.0;}
				break;

				case '*': Voutref += 0;

				default: Voutref = 1.8;
				break;
			}
			printf("Valor de referencia:  %f\r\n", Voutref);
#ifndef UI_MED
			printf("Ciclo de trabajo D1 %d y D2 %d\r\n", D1, D2);
#endif
			printf("Voltaje Vout %f y Vfc %f\r\n\r\n", data14_Vout, data_Vfc);
		}

#ifdef UI_MED
		printf("Valor de referencia:  %f\r\n", Voutref);
		printf("VALOR DE UI:  %f\r\n\r\n", ui);
#endif

#ifdef DESACOPLE
		/* Probar triangulares (desacople) */

		/* Vfc variable */ /* volt , max, min, paso, freq */
		Vfcref = generar_tri(Vfcref, 2.5, 1.2, 0.3, 1000);

		/* Vout variable */  /* volt , max, min, paso, freq */
		Voutref = generar_tri(Voutref, 2.7, 0.6, 0.3, 10000);
#endif

#ifdef ESCALON
		/* Probar escalon vout */
		if (!(COUNTER%1000) && estado == 0){
			Voutref = 1.2;
			estado = 1;
			COUNTER = 0;
		}
		else if (!(COUNTER%1000) && estado == 1){
			Voutref = 2.4;
			estado = 2;
			COUNTER = 0;
		}
		else if (!(COUNTER%1000) && estado == 2){
			Voutref = 1.2;
			estado = 0;
			COUNTER = 0;
		}
//		else if (!(COUNTER%1000) && estado == 3){
//			Voutref = 0.6;
//			estado = 0;
//			COUNTER = 0;
//		}
#endif
#if defined DESACOPLE || defined ESCALON
		COUNTER++;
#endif

	}

	return 0;
}

#ifdef DESACOPLE
float generar_tri(float volt, float max, float min, float paso, int FREQ)
{
	static int DIRECTION = 0;

	if (!(COUNTER%FREQ) && DIRECTION){
		volt += paso;
	    if(volt>=max){volt= max; DIRECTION = 0;}
	}
	if (!(COUNTER%FREQ) && !DIRECTION){
		volt -= paso;
		if(volt<=min){volt = min; DIRECTION = 1;}
	}

	return volt;
}
#endif


static int SetupInterruptSystem(XScuGic *IntcInstancePtr, XSysMon *XAdcPtr, u16 IntrId)
{
	XScuGic_Config *IntcConfig;
	int Status;

	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcInstancePtr, IntcConfig, IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XScuGic_Connect(IntcInstancePtr, IntrId, (Xil_InterruptHandler)XAdcInterruptHandler, (void *)XAdcPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XScuGic_Enable(IntcInstancePtr, IntrId);

	Xil_ExceptionInit();
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, IntcInstancePtr);
	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

void XAdcInterruptHandler(void *CallBackRef)
{
	*reg5_Test = 1;

	// Leer los datos desde los puertos AD14 y AD7 en la Zybo
	data14_Vout = (float)Xil_In32(XADC_BASEADDR + Offset_Aux14) * FACTOR_CONVERSION;
	data7_Vfc_p = (float)Xil_In32(XADC_BASEADDR + Offset_Aux7) * FACTOR_CONVERSION;
	data15_Vfc_n = (float)Xil_In32(XADC_BASEADDR + Offset_Aux15) * FACTOR_CONVERSION;
	data_Vfc = data7_Vfc_p - data15_Vfc_n + 0.14; // Este offset se puede modificar dependiendo del Vout del punto de operacion 0.12 para Vout < 1V y 0.15 para Vout>2V

	// Algoritmo de control
	float ui = piv_fun(Voutref, data14_Vout, 0.0, 0.0, 1.0, Kpv, Kiv, 1);
	float uv = piv_fun(Vfcref, data_Vfc, 0.0, -0.3, 0.3, Kpc, Kic, 2);

	// Calcular D1 y D2
	D1 = (unsigned int)((ui + uv) * MAX_DUTY_CYCLE);
	D2 = (unsigned int)((ui - uv) * MAX_DUTY_CYCLE);

	// Saturar D1 y D2
	*reg2_d1 = (D1 <= MAX_DUTY_CYCLE) ? D1 : MAX_DUTY_CYCLE;
	*reg3_d2 = (D2 <= MAX_DUTY_CYCLE) ? D2 : MAX_DUTY_CYCLE;

	// Actualizar registro de validez de datos
	*reg4_dataValid = 1;
	*reg4_dataValid = 0;

	// Limpiar interrupciones del SysMon
	XSysMon_IntrClear(&SysMonInst, XSM_IPIXR_EOC_MASK);

	*reg5_Test = 0;

}
