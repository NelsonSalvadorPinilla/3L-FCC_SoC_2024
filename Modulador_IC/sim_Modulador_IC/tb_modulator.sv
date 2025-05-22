`timescale 1 ns/10 ps

module tb_modulator();

  // Senales del testbench
    logic CLK_PLL;        // Reloj de entrada proveniente del PLL
    logic CLK_EXT;        // Rloj de entrada que proviene de un PIN
    logic RST;            // senal de reset 
    
    logic [5:0] d1;       // Senal 1 que viene del controlador
    logic [5:0] d2;       // Senal 2 que viene del controlador

    logic PMOS1_PS1;      // Senal de control del transistor NMOS 1 del PS1
    logic PMOS2_PS1;      // Senal de control del transistor PMOS 1 del PS1
    logic NMOS1_PS1;      // Senal de control del transistor NMOS 2 del PS1
    logic NMOS2_PS1;      // Senal de control del transistor PMOS 2 del PS1
    
    logic PMOS1_PS2;      // Senal de control del transistor NMOS 1 del PS2
    logic PMOS2_PS2;      // Senal de control del transistor PMOS 1 del PS2
    logic NMOS1_PS2;      // Senal de control del transistor NMOS 2 del PS2
    logic NMOS2_PS2;      // Senal de control del transistor PMOS 2 del PS2
    
    logic SIGNAL_OUTPUT;
    
    logic CLK_SR;
    logic Data_SR;
    
    logic PMOS_PS3;
    logic NMOS_PS3;
    
    logic ENABLE_OUTPUT;

  // Instancia el DUT
  Modulator dut (
    .ENABLE_OUTPUT(ENABLE_OUTPUT),
    .CLK_PLL(CLK_PLL),
    .CLK_EXT(CLK_EXT),
    .RST(RST),
    .d1(d1),
    .d2(d2),
    .PMOS1_PS1(PMOS1_PS1),
    .NMOS2_PS1(NMOS2_PS1),
    .PMOS2_PS1(PMOS2_PS1),
    .NMOS1_PS1(NMOS1_PS1),
    
    .PMOS1_PS2(PMOS1_PS2),
    .NMOS2_PS2(NMOS2_PS2),
    .PMOS2_PS2(PMOS2_PS2),
    .NMOS1_PS2(NMOS1_PS2),
    
    .SIGNAL_OUTPUT(SIGNAL_OUTPUT),
    .CLK_SR(CLK_SR),
    .Data_SR(Data_SR),
    .PMOS_PS3(PMOS_PS3),
    .NMOS_PS3(NMOS_PS3)
  );

  // Testbench
  always #1 CLK_PLL= ~CLK_PLL;
  always #10 CLK_EXT= ~CLK_EXT;
  initial begin
    CLK_PLL= 0;
    CLK_EXT= 0;
    RST= 0;
    d1= 6'h0;
    d2= 6'h0;
    
    CLK_SR= 0;
    #10;
    
    RST= 1;

    #10;
    
    RST= 0;
    
    #10;
    
    /////////// Seteo de valores en Shift Register /////////////////
    
    Data_SR= 1; // dt[0]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // dt[1]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // dt[2]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // dt[3]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // dt[4]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5Data_SR= 1; // SELECTOR_SIGNAL_GENERATOR_1[0]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // SELECTOR_SIGNAL_GENERATOR_1[1]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // SELECTOR_SIGNAL_GENERATOR_2[0]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // SELECTOR_SIGNAL_GENERATOR_2[1]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // OUTPUT_SELECTOR_EXTERNAL[0]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // OUTPUT_SELECTOR_EXTERNAL[1]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // OUTPUT_SELECTOR_EXTERNAL[2]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // OUTPUT_SELECTOR_EXTERNAL[3]
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // INPUT_SELECTOR
    #5 CLK_SR= 1;
    #5 CLK_SR= 0;
    
    #5 Data_SR= 1; // CLK_SELECTOR
    #5 CLK_SR= 1;
    #5 CLK_SR= 0; 
    
    #5 Data_SR= 1; // PS_SELECTOR
    #5 CLK_SR= 1;
    #5 CLK_SR= 0; 
    
    #5 Data_SR= 0; // PS3_SELECTOR
    #5 CLK_SR= 1;
    #5 CLK_SR= 0; 
    
    /////////// Asignación de valores en las entradas /////////////////
    #100;
    d1= 6'h1c;
    d2= 6'h1c;
    
    #5 ENABLE_OUTPUT= 1; // ENABLE_OUTPUT  
    
   /*
    #10000;
    d1= 6'h2e;
    d2= 6'h2e;
    */
    
    
    #1000;
    d1[0]= 0; // NMOS2_EXT_IN
    d1[1]= 0; // PMOS2_EXT_IN
    d1[2]= 1; // NMOS1_EXT_IN
    d1[3]= 1; // PMOS1_EXT_IN
    d1[4]= 1; // PMOS_PS3
    d1[5]= 0; // NMOS_PS3
    
    d2[0]= 1; 
    d2[1]= 1;
    d2[2]= 1; 
    d2[3]= 1; 
    d2[4]= 1; 
    d2[5]= 1; 
    
    
    $display("Simulacion finalizada");
    //$finish; // Finaliza la simulacion
  end

endmodule