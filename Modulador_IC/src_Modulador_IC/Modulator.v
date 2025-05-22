`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Modulator
// Module Name: Modulator
// Project Name: Modulacion PS-PWM para 3L-FCC
// Date: 25/10/2023
//////////////////////////////////////////////////////////////////////////////////


module Modulator(
    input ENABLE_OUTPUT,

    input CLK_PLL,        // Reloj de entrada proveniente del PLL
    input CLK_EXT,        // Rloj de entrada que proviene de un PIN
 
    input CLK_SR,         // Reloj que controla la captura de datos del SR
    input Data_SR,        // Datos a guardar segun la configuracion deseada
    
    input RST,            // senal de reset 
    
    input [5:0] d1,       // Senal 1 que viene del controlador
    input [5:0] d2,       // Senal 2 que viene del controlador

    output wire PMOS1_PS1,      // Senal de control del transistor PMOS 1 del PS1
    output wire NMOS2_PS1,      // Senal de control del transistor NMOS 2 del PS1
    output wire PMOS2_PS1,      // Senal de control del transistor PMOS 2 del PS1
    output wire NMOS1_PS1,      // Senal de control del transistor NMOS 1 del PS1
    
    output wire PMOS1_PS2,      // Senal de control del transistor PMOS 1 del PS2
    output wire NMOS2_PS2,      // Senal de control del transistor NMOS 2 del PS2
    output wire PMOS2_PS2,      // Senal de control del transistor PMOS 2 del PS2
    output wire NMOS1_PS2,      // Senal de control del transistor NMOS 1 del PS2
    
    output wire PMOS_PS3,      // Senal de control del transistor PMOS del PS3
    output wire NMOS_PS3,      // Senal de control del transistor NMOS del PS3

    output reg SIGNAL_OUTPUT   // Senal de medicion, puede ser el CLK o cualquier senal PMOS/NMOS
);

/* Clock divider innecesario
Clk_Divider Clk_Divider_Inst(
    .clk_in(clk_in),
    .div_clk0(16'd1), 
    .clk0(clk),
    .rst(RST)
);*/


/**************** ETAPA DE SHIFT REGISTER ****************/
wire CLK_SELECTOR;
wire INPUT_SELECTOR;
wire [4:0] dt;
wire [1:0] SELECTOR_SIGNAL_GENERATOR_1; // escoge el desfase que tendra la triangular 1
wire [1:0] SELECTOR_SIGNAL_GENERATOR_2; // escoge el desfase que tendra la triangular 2
wire [3:0]OUTPUT_SELECTOR_EXTERNAL;
wire PS_SELECTOR;
wire PS3_SELECTOR;

Shift_Register Shift_Register_Inst(
    CLK_SR,
    RST,
    Data_SR,
    {PS3_SELECTOR, PS_SELECTOR, CLK_SELECTOR, INPUT_SELECTOR, OUTPUT_SELECTOR_EXTERNAL[3], OUTPUT_SELECTOR_EXTERNAL[2], OUTPUT_SELECTOR_EXTERNAL[1], OUTPUT_SELECTOR_EXTERNAL[0],SELECTOR_SIGNAL_GENERATOR_2[1],SELECTOR_SIGNAL_GENERATOR_2[0],SELECTOR_SIGNAL_GENERATOR_1[1],SELECTOR_SIGNAL_GENERATOR_1[0], dt[4], dt[3], dt[2], dt[1], dt[0]}
);

// El orden para meter los datos es (de primero a ultimo): 
// dt[0]
// dt[1]
// dt[2]
// dt[3]
// dt[4]
// SELECTOR_SIGNAL_GENERATOR_1[0]
// SELECTOR_SIGNAL_GENERATOR_1[1]
// SELECTOR_SIGNAL_GENERATOR_2[0]
// SELECTOR_SIGNAL_GENERATOR_2[1]
// OUTPUT_SELECTOR_EXTERNAL[0]
// OUTPUT_SELECTOR_EXTERNAL[1]
// OUTPUT_SELECTOR_EXTERNAL[2]
// OUTPUT_SELECTOR_EXTERNAL[3]
// INPUT_SELECTOR
// CLK_SELECTOR
// PS_SELECTOR
// PS3_SELECTOR

/**************** ETAPA DE MUX INPUT ****************/

// INPUT_SELECTOR d1(0) u offchip (1)
wire d1_0;
wire d1_1;
wire d1_2;
wire d1_3;

wire NMOS2_EXT_IN;
wire PMOS2_EXT_IN;
wire NMOS1_EXT_IN;
wire PMOS1_EXT_IN;

// Si INPUT_SELECTOR es 0 -> d1[0:3] se utiliza para la comparacion con la triangular, si es 1 ->  pasan directo al PS1 o PS2 segun corresponda
assign d1_0         = INPUT_SELECTOR ? 0 : d1[0];
assign NMOS2_EXT_IN = INPUT_SELECTOR ? d1[0] : 0;

assign d1_1         = INPUT_SELECTOR ? 0 : d1[1];
assign PMOS2_EXT_IN = INPUT_SELECTOR ? d1[1] : 0;

assign d1_2         = INPUT_SELECTOR ? 0 : d1[2];
assign NMOS1_EXT_IN = INPUT_SELECTOR ? d1[2] : 0;

assign d1_3         = INPUT_SELECTOR ? 0 : d1[3];
assign PMOS1_EXT_IN = INPUT_SELECTOR ? d1[3] : 0;

// PS3_SELECTOR
wire d1_4;
wire d1_5;

wire INPUT_PMOS_PS3;
wire INPUT_NMOS_PS3;

// Si PS3_SELECTOR es 0 -> d1[4] y d1[5] se usan para comparacion con la triangular, si es 1 -> pasan directo al PS3
assign d1_4           = PS3_SELECTOR ? 0 : d1[4];
assign INPUT_PMOS_PS3 = PS3_SELECTOR ? d1[4] : 1;

assign d1_5           = PS3_SELECTOR ? 0 : d1[5];
assign INPUT_NMOS_PS3 = PS3_SELECTOR ? d1[5] : 0;

/**************** ETAPA DE CONEXION PS3 ****************/

wire Not_PMOS_PS3;
wire Not_NMOS_PS3;

assign Not_PMOS_PS3 = ~INPUT_PMOS_PS3;
assign Not_NMOS_PS3 = ~INPUT_NMOS_PS3;

assign PMOS_PS3 = ~Not_PMOS_PS3;
assign NMOS_PS3 = ~Not_NMOS_PS3;

/**************** ETAPA DE MUX CLK ****************/

wire clk;

// Si CLK_SELECTOR es 0 -> se usa clk del PLL, si es 1 -> se usa el clk del pin externo
assign clk = CLK_SELECTOR ? CLK_EXT : CLK_PLL;


/**************** ETAPA DE TRIANGULARES ****************/

// Fases de la triangular 1
wire [5:0] triangular_1_0;
Signal_Generator_0phase Signal_Generator_1_0phase_inst(
    clk,
    RST,
    triangular_1_0
);

wire [5:0] triangular_1_90;
Signal_Generator_90phase Signal_Generator_1_90phase_inst(
    clk,
    RST,
    triangular_1_90
);

wire [5:0] triangular_1_180;
Signal_Generator_180phase Signal_Generator_1_180phase_inst(
    clk,
    RST,
    triangular_1_180
);

wire [5:0] triangular_1_270;
Signal_Generator_270phase Signal_Generator_1_270phase_inst(
    clk,
    RST,
    triangular_1_270
);

// Fases de la triangular 2
wire [5:0] triangular_2_0;
Signal_Generator_0phase Signal_Generator_2_0phase_inst(
    clk,
    RST,
    triangular_2_0
);

wire [5:0] triangular_2_90;
Signal_Generator_90phase Signal_Generator_2_90phase_inst(
    clk,
    RST,
    triangular_2_90
);

wire [5:0] triangular_2_180;
Signal_Generator_180phase Signal_Generator_2_180phase_inst(
    clk,
    RST,
    triangular_2_180
);

wire [5:0] triangular_2_270;
Signal_Generator_270phase Signal_Generator_2_270phase_inst(
    clk,
    RST,
    triangular_2_270
);

/**************** ETAPA DE MUX Triangulares ****************/

// Triangular 1
reg [5:0] triangular_1;
always @(*) begin

    // SELECTOR_SIGNAL_GENERATOR_2 selecciona la fase de la triangular_1
    case(SELECTOR_SIGNAL_GENERATOR_1)           
           2'd0  : triangular_1 = triangular_1_0;
           2'd1  : triangular_1 = triangular_1_90;
           2'd2  : triangular_1 = triangular_1_180;
           2'd3  : triangular_1 = triangular_1_270;
           default : triangular_1 = 0;
       endcase

end

// Triangular 2
reg [5:0] triangular_2;
always @(*) begin

    // SELECTOR_SIGNAL_GENERATOR_2 selecciona la fase de la triangular_2
    case(SELECTOR_SIGNAL_GENERATOR_2)           
           2'd0  : triangular_2 = triangular_2_0;
           2'd1  : triangular_2 = triangular_2_90;
           2'd2  : triangular_2 = triangular_2_180;
           2'd3  : triangular_2 = triangular_2_270;
           default : triangular_2 = 0;
       endcase

end

/**************** ETAPA DE COMPARACION ****************/

wire Output_Comparison_1;
Comparator Comparator_Inst_1(
    {d1_5, d1_4, d1_3, d1_2, d1_1, d1_0},
    triangular_1,
    Output_Comparison_1
);

wire Output_Comparison_2;
Comparator Comparator_Inst_2(
    d2,
    triangular_2,
    Output_Comparison_2
);

/**************** ETAPA DE DEAD-TIME GENERATOR ****************/

wire pmos1_int; 
Dead_Time_Generator Dead_Time_Generator_inst_1(
    clk,
    dt,
    Output_Comparison_1,
    pmos1_int
);

wire Not_Output_Comparison_1;
wire nmos2_int;
assign Not_Output_Comparison_1 = ~Output_Comparison_1;
Dead_Time_Generator Dead_Time_Generator_inst_2(
    clk,
    dt,
    Not_Output_Comparison_1,
    nmos2_int
);

wire pmos2_int;
Dead_Time_Generator Dead_Time_Generator_inst_3(
    clk,
    dt,
    Output_Comparison_2,
    pmos2_int
);

wire Not_Output_Comparison_2;
wire nmos1_int;
assign Not_Output_Comparison_2 = ~Output_Comparison_2;
Dead_Time_Generator Dead_Time_Generator_inst_4(
    clk,
    dt,
    Not_Output_Comparison_2,
    nmos1_int
);

/**************** ETAPA DE MUX OUTPUT INTERNA ****************/

wire PMOS1_prev, NMOS2_prev, PMOS2_prev, NMOS1_prev;

// Si OUTPUT_SELECTOR_INTERNAL es 0 -> salidas vienen del modulador , si es 1 -> vienen offchip
assign PMOS1_prev = INPUT_SELECTOR ? PMOS1_EXT_IN : ~pmos1_int; // TIENE EL NEGADOR POR EL PMOS
assign NMOS2_prev = INPUT_SELECTOR ? NMOS2_EXT_IN : nmos2_int;
assign PMOS2_prev = INPUT_SELECTOR ? PMOS2_EXT_IN : ~pmos2_int; // TIENE EL NEGADOR POR EL PMOS
assign NMOS1_prev = INPUT_SELECTOR ? NMOS1_EXT_IN : nmos1_int;

/**************** ETAPA DE MUX OUTPUT EXTERNA ****************/


always @(*) begin

    // OUTPUT_SELECTOR_EXTERNAL selecciona que salida se podra medir externamente
    case(OUTPUT_SELECTOR_EXTERNAL)         
      
           4'd0  : SIGNAL_OUTPUT = PMOS1_PS1;
           4'd1  : SIGNAL_OUTPUT = NMOS2_PS1;
           4'd2  : SIGNAL_OUTPUT = PMOS2_PS1;
           4'd3  : SIGNAL_OUTPUT = NMOS1_PS1;
           
           4'd4  : SIGNAL_OUTPUT = PMOS1_PS2;
           4'd5  : SIGNAL_OUTPUT = NMOS2_PS2;
           4'd6  : SIGNAL_OUTPUT = PMOS2_PS2;
           4'd7  : SIGNAL_OUTPUT = NMOS1_PS2;
           
           4'd8  : SIGNAL_OUTPUT = PMOS_PS3;
           4'd9   : SIGNAL_OUTPUT = NMOS_PS3;
           
           4'd10  : SIGNAL_OUTPUT = clk;
           
           default : SIGNAL_OUTPUT = 0;
       endcase

end

/**************** ETAPA SELECTOR PS ****************/

wire PMOS1_PS1_prev, NMOS2_PS1_prev, PMOS2_PS1_prev, NMOS1_PS1_prev;
wire PMOS1_PS1_prev_prev, NMOS2_PS1_prev_prev, PMOS2_PS1_prev_prev, NMOS1_PS1_prev_prev;
wire PMOS1_PS1_prev_neg, NMOS2_PS1_prev_neg, PMOS2_PS1_prev_neg, NMOS1_PS1_prev_neg;
// si PS_SELECTOR es 0 -> PS1 , si es 1 -> PS2

assign PMOS1_PS1_prev_prev = PS_SELECTOR ? PMOS1_prev : 1; 
assign NMOS2_PS1_prev_prev = PS_SELECTOR ? NMOS2_prev : 0;
assign PMOS2_PS1_prev_prev = PS_SELECTOR ? PMOS2_prev : 1;
assign NMOS1_PS1_prev_prev = PS_SELECTOR ? NMOS1_prev : 0;

wire PMOS1_PS2_prev, NMOS2_PS2_prev, PMOS2_PS2_prev, NMOS1_PS2_prev;
wire PMOS1_PS2_prev_prev, NMOS2_PS2_prev_prev, PMOS2_PS2_prev_prev, NMOS1_PS2_prev_prev;
wire PMOS1_PS2_prev_neg, NMOS2_PS2_prev_neg, PMOS2_PS2_prev_neg, NMOS1_PS2_prev_neg;

assign PMOS1_PS2_prev_prev = PS_SELECTOR ? 1 : PMOS1_prev; 
assign NMOS2_PS2_prev_prev = PS_SELECTOR ? 0 : NMOS2_prev;
assign PMOS2_PS2_prev_prev = PS_SELECTOR ? 1 : PMOS2_prev;
assign NMOS1_PS2_prev_prev = PS_SELECTOR ? 0 : NMOS1_prev;

// buffers

assign PMOS1_PS1_prev_neg = ~PMOS1_PS1_prev_prev; 
assign NMOS2_PS1_prev_neg = ~NMOS2_PS1_prev_prev;
assign PMOS2_PS1_prev_neg = ~PMOS2_PS1_prev_prev;
assign NMOS1_PS1_prev_neg = ~NMOS1_PS1_prev_prev;

assign PMOS1_PS1_prev = ~PMOS1_PS1_prev_neg; 
assign NMOS2_PS1_prev = ~NMOS2_PS1_prev_neg;
assign PMOS2_PS1_prev = ~PMOS2_PS1_prev_neg;
assign NMOS1_PS1_prev = ~NMOS1_PS1_prev_neg;

assign PMOS1_PS2_prev_neg = ~PMOS1_PS2_prev_prev;
assign NMOS2_PS2_prev_neg = ~NMOS2_PS2_prev_prev;
assign PMOS2_PS2_prev_neg = ~PMOS2_PS2_prev_prev;
assign NMOS1_PS2_prev_neg = ~NMOS1_PS2_prev_prev;

assign PMOS1_PS2_prev = ~PMOS1_PS2_prev_neg;
assign NMOS2_PS2_prev = ~NMOS2_PS2_prev_neg;
assign PMOS2_PS2_prev = ~PMOS2_PS2_prev_neg;
assign NMOS1_PS2_prev = ~NMOS1_PS2_prev_neg;


/**************** ETAPA ENABLE OUTPUTs ****************/

wire ENABLE_OUTPUT_FINAL;

// Si PS3_SELECTOR es 1, entonces deshabilita las salidas de PS1 o PS2
assign ENABLE_OUTPUT_FINAL= PS3_SELECTOR ? 0 : ENABLE_OUTPUT; 

// Si ENABLE_OUTPUT_FINAL es 0 -> los 4 transistores cmos estan en corte, si es 1 -> las salidas de los 4 cmos viene dada segun su logica previa, 
assign PMOS1_PS1 = ENABLE_OUTPUT_FINAL ? PMOS1_PS1_prev : 1; 
assign NMOS2_PS1 = ENABLE_OUTPUT_FINAL ? NMOS2_PS1_prev : 0;
assign PMOS2_PS1 = ENABLE_OUTPUT_FINAL ? PMOS2_PS1_prev : 1;
assign NMOS1_PS1 = ENABLE_OUTPUT_FINAL ? NMOS1_PS1_prev : 0;

assign PMOS1_PS2 = ENABLE_OUTPUT_FINAL ? PMOS1_PS2_prev : 1; 
assign NMOS2_PS2 = ENABLE_OUTPUT_FINAL ? NMOS2_PS2_prev : 0;
assign PMOS2_PS2 = ENABLE_OUTPUT_FINAL ? PMOS2_PS2_prev : 1;
assign NMOS1_PS2 = ENABLE_OUTPUT_FINAL ? NMOS1_PS2_prev : 0;

endmodule