//******************************************************************
//      PVCTRL: UNSW 2018 - c.a.rojas@ieee.org
//******************************************************************

#ifndef pi_fun_H
#define pi_fun_H

// Y(z)    KN0bz + KN1b
// ---  = ---------------    by using ZOH
// X(z)    z - 1

extern double piv_fun(double Vrk, double Vk, double ffk, double Vmin, double Vmax, double Kpid, double Kiid, unsigned int cindex)
{
    // PI parameters
    static double Kp[sizepi];
    static double Ki[sizepi];
    static double KUi[sizepi];
    static double KXi[sizepi];

 	// PI variables
    static double xVrk[sizepi];
    static double xVk[sizepi];
    static double xffk[sizepi];
    static double xVmax[sizepi];
    static double xVmin[sizepi];
    static double xXik[2][sizepi];
    static double xUik[2][sizepi];
    static double xVmk[sizepi];

    // PI variables initialization
	xVrk[cindex] = Vrk;
	xVk[cindex]	= Vk;
	xffk[cindex] = ffk;
	xVmax[cindex] = Vmax;
	xVmin[cindex] = Vmin;
	Kp[cindex] = Kpid;
	Ki[cindex] = Kiid;

	KUi[cindex] = -(Kp[cindex] + Ki[cindex])/(Kp[cindex]*Kpid);
	KXi[cindex] = -Ki[cindex]/Kp[cindex];

	// Feedforward limitation
    xffk[cindex] = ( xffk[cindex] > xVmax[cindex] ) ? xVmax[cindex] : ( xffk[cindex] < -xVmax[cindex] ) ? -xVmax[cindex] : xffk[cindex];

    // PI implementation
	xXik[1][cindex] = xXik[0][cindex];
	xUik[1][cindex] = xUik[0][cindex];
	xXik[0][cindex] = KUi[cindex]*xUik[1][cindex] + KXi[cindex]*xXik[1][cindex];
    xUik[0][cindex] = Kp[cindex]*(xVrk[cindex] - xVk[cindex] - xXik[0][cindex]);

	// Actuation limitation
    //xUik[0][cindex] = ( xUik[0][cindex] > (xVmax[cindex] - xffk[cindex]) ) ? (xVmax[cindex] - xffk[cindex]) : ( xUik[0][cindex] < 0.0 ) ? (-xVmax[cindex] + xffk[cindex]) : xUik[0][cindex];
    xUik[0][cindex] = ( xUik[0][cindex] > (xVmax[cindex] - xffk[cindex]) ) ? (xVmax[cindex] - xffk[cindex]) : ( xUik[0][cindex] < (xVmin[cindex] - xffk[cindex]) ) ? (xVmin[cindex] - xffk[cindex]) : xUik[0][cindex];

    // Feedforward application
    xVmk[cindex] = xUik[0][cindex] + xffk[cindex];


    return xVmk[cindex];

}
#endif


