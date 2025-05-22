`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: POWERLAB, DEPARTAMENTO DE ELECTRONICA, UTFSM
// Engineer: GONZALO CARRASCO REYES
// 
// Create Date:    17:31:06 04/17/2007 
// Design Name: 
// Module Name:    reloj_principal 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: El m�dulo cuenta con una entrada del reloj principal de la tarjeta
//					(clk_in) y 4 buses (div_clkX) para ingresar el valor de divisi�n
//					deseado para obtener un reloj de salida de menor frecuencia por las
//					respectivas salidas (clkX).
//
// Dependencies: 
//						clk_in	- Se�al de reloj
//						div_clk0	- Divisor 0
//						div_clk1	- Divisor 1
//						div_clk2	- Divisor 2
//						div_clk3	- Divisor 3
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Clk_Divider(clk_in, div_clk0, clk0, rst);

	input clk_in;							//Entrada del reloj principal
	input [15:0] div_clk0;				//Bus del divisor para salida clk0
	output reg clk0;						//Salida del reloj clk0
	
	input rst;
	//----------------------------------------------------------------------------
	//Variables internas //AQUI SE INICIALIZO EN CERO PARA SIMULAR
	reg [15:0] cont0;//=0;						//Contador de divisi�n del reloj clk0
	///////////////////////////////////////////////////////////////////////////////
	
	//Operaci�n de los contadores
	always @(posedge clk_in) begin
		if (rst)begin //ESTO ES LO NUEVO //hace underflow? siempre al parecer
			cont0=0;
		end 
		cont0 = cont0 + 1;
		if (cont0 == div_clk0)	//La cuenta es hasta el valor del divisor
			cont0 = 0;
	end
	
	//Generador sincr�nico para CLKx 
	always @(posedge clk_in) begin
		if ( cont0 < {1'b0,div_clk0[15:1]} )
			clk0 = 1;
		else
			clk0 = 0;
	end
	
	///////////////////////////////////////////////////////////////////////////////
endmodule
