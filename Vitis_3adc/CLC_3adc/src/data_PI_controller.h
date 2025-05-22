//******************************************************************
//      VOC: UNSW 2018 - c.a.rojas@ieee.org
//******************************************************************

// Math Constants
// #define MPI		  3.141592653589793 // MPI = M_PI;
// #define M2PI	  6.283185307179586 // M2PI = 2*MPI;
// #define M4PI	 12.566370614359172 // M4PI = 2*M2PI;
// #define M8PI	 25.132741228718345 // M8PI = 2*M4PI;
// #define MPI_23	  2.094395102393195 // MPI_23 = 2*MPI/3;
// #define M_2PI	  0.159154943091895 // M_2PI = 1/(2*MPI);
// #define MPI_12    1.570796326794897 // MPI_12 = MPI/2;
// #define M_23      0.666666666666667 // M_23 = 2/3;
// #define M_12      0.500000000000000 // M_12 = 1/2;
// #define M_13      0.333333333333333 // M_13 = 1/3;
// #define M_19      0.111111111111111 // M_19 = 1/9;
// #define M_14      0.250000000000000 // M_14 = 1/4;
// #define M_32      1.500000000000000 // M_32 = 3/2;
// #define M_S2      1.414213562373095 // M_S2 = sqrt(2);
// #define M_S3      1.732050807568877 // M_S3 = sqrt(3);
// #define M_S6      2.449489742783178 // M_S6 = sqrt(6);
// #define M_S34     0.866025403784439 // M_S34 = sqrt(3/4);
// #define M_S12     0.707106781186547 // M_S13 = sqrt(1/2);
// #define M_S13     0.577350269189626 // M_S13 = sqrt(1/3);
// #define M_S23     0.816496580927726 // M_S23 = sqrt(2/3);
// #define M_S32     1.224744871391589 // M_S32 = sqrt(3/2);


// Function to structure field
// typedef struct {
// 	double fc1;
// 	double fc2;
// 	double fc3;
// 	double fc4;
// } fld;

// Measurements
//double Vfcref = 0.0, Vfc = 0.0, Vout = 0.0, Voutref = 0.0;
//double ILk = 0.0, ILref = 0.0;
//int CCCV = 0.0;

// Actuations
double dV = 0.0, uv = 0.0;
float m = 0.0, ui = 0.0;

// PI Voltage Controller vector
#define sizepi 3			// Size of PVCTRL array
#include "myPVCTRL.h"
// Controller Parameters

/************************ Diseños Aproximados *********************/
/*
// 1W, fs = 1MHz
// Bandwidth 40kHz, shi = 0.707
double Kpv =  0.759123271041260;
double Kiv = -0.693575835299939;
// Bandwidth 40kHz, shi = 0.707
double Kpc =  0.341931087397167;
double Kic = -0.312406625647518;
*/
/*
// 1W, fs = 0.5MHz
// Bandwidth 40kHz, shi = 0.707
double Kpv =  0.759123271041260;
double Kiv = -0.628028399558618;
// Bandwidth 40kHz, shi = 0.707
double Kpc =  0.341931087397167;
double Kic = -0.282882163897869;
*/
/*
// 1W, fs = 0.25MHz
// Bandwidth 40kHz, shi = 0.707
double Kpv =  0.759123271041260;
double Kiv = -0.496933528075975;
// Bandwidth 40kHz, shi = 0.707
double Kpc =  0.341931087397167;
double Kic = -0.223833240398572;
*/

/************************ Diseños Exactos *********************/

/*
// 1W, fs = 1MHz
// Bandwidth 40kHz, shi = 0.707
double Kpv =  0.71301333205763227094;
double Kiv = -0.61077198639530676159;
// Bandwidth 40kHz, shi = 0.707
double Kpc =  0.32786662878744817448;
double Kic = -0.30277094576890699069;
*/
/*
// 1W, fs = 0.5MHz
// Bandwidth 40kHz, shi = 0.707
double Kpv =  0.70858794960574332972;
double Kiv = -0.52865231222823655914;
// Bandwidth 40kHz, shi = 0.707
double Kpc =  0.31258102683228503312;
double Kic = -0.26982729225084242017;
*/
/*
// 1W, fs = 0.25MHz
// Bandwidth 40kHz, shi = 0.707
double Kpv =  0.68232909891251168022;
double Kiv = -0.40117259075255696398;
// Bandwidth 40kHz, shi = 0.707
double Kpc =  0.28057498701656218759;
double Kic = -0.21810193850317323115;
*/

/*
// CONTROLADOR ORIGINAL FUNCIONAL -> Para valores Vout > 2.5V Vout se inestabiliza y se va a VH igual que  con el controlador inicial
double Kpi =  1.3155133150382277364;
double Kii = -0.34231870456857492509;
double Kpv =  0.12080012075649474163*0.1;
double Kiv = -0.031434224478289708457*0.1;
double Kpc =  0.00063060158000519704831;
double Kic = -0.00061391269899450779734;
*/

// Nuevos parámetros 29-07-2024

/*
// 1W, Ts = 6.5us, fsw = 1MHz -> Para valores Vout > 2.5V Vout se inestabiliza y se va a VH igual que  con el controlador inicial
// BWvo = 4kHz, shi = 1
double Kpv =  0.064883915495011203795;
double Kiv = -0.024553347609870754104;
// BWvf = 75Hz, shi = 0.707
double Kpc =  0.00063986358270822811054;
double Kic = -0.00063917325335019776363;
*/

/*
// 1W, Ts = 6.5us, fsw = 1MHz -> Para valores Vout > 2.5V Vout se inestabiliza y se va a VH igual que  con el controlador inicial
// BWvo = 4kHz, shi = 1
double Kpv =  0.064883915495011203795;
double Kiv = -0.024553347609870754104;
// BWvf = 4kHz, shi = 1
double Kpc =  0.037990391292090954388;
double Kic = -0.036805345755513830816;
*/

//#define CTRL_1

#ifdef CTRL_1
// Controlador 1
// Nuevos parámetros 01-08-2024
// 0.15W, Ts = 6.5us (Debug), fsw = 1MHz, Ro = 66.15, Vo=3.15
// BWvo = 1kHz, shi = No hay, es un diseño para obtener polos de primer orden
double Kpv =  0.025312;
double Kiv = -0.011105;
// BWvf = 4kHz, shi = 0.707
double Kpc =  0.099087235;
double Kic = -0.097721975;

#else
// Controlador 2
/* Nuevo controlador para capacitor interno */
// 0.15W, Ts = 6.5us (Debug), fsw = 1MHz, Ro = 66.15, Vo=3.15
// BWvo = 1kHz, shi = No hay, es un diseño para obtener polos de primer orden
double Kpv =  0.025312;
double Kiv = -0.011105;
// BWvf = 1kHz, shi = 0.707, Cf = 7.91nF
double Kpc =  0.00034278496032795589781;
double Kic = -0.00033510460200346020598;
#endif
