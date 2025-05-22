`timescale 1ns / 1ps

module Shift_Register(
  input wire CLK_SR,
  input wire RST,
  input wire data_in,
  output wire [17:0] data_out
);

  reg [17:0] internal_data [0:17];
  reg [4:0] shift_state;
  integer i;
  
  always @(posedge CLK_SR or posedge RST) begin
    if (RST) begin
      // Reiniciar todas las variables internas a 0 cuando se activa el reset
      for (i = 0; i < 5'd18; i = i + 1) begin
        internal_data[i] <= 0;
      end
      shift_state <= 0;
    end else 
        if (shift_state < 5'd18) begin
          // Almacenar el valor de entrada en la variable interna correspondiente
          internal_data[shift_state] <= data_in;
          // Cambiar al siguiente estado del registro
          shift_state <= shift_state + 1;
        end
end
assign data_out[0] = internal_data[0]; // dt[0]
assign data_out[1] = internal_data[1]; // dt[1]
assign data_out[2] = internal_data[2]; // dt[2]
assign data_out[3] = internal_data[3]; // dt[3] 
assign data_out[4] = internal_data[4]; // dt[4] 
assign data_out[5] = internal_data[5]; // SELECTOR_SIGNAL_GENERATOR_1[0]
assign data_out[6] = internal_data[6]; // SELECTOR_SIGNAL_GENERATOR_1[1]
assign data_out[7] = internal_data[7]; // SELECTOR_SIGNAL_GENERATOR_2[0]
assign data_out[8] = internal_data[8]; // SELECTOR_SIGNAL_GENERATOR_2[1]
assign data_out[9] = internal_data[9]; // OUTPUT_SELECTOR_EXTERNAL[0]
assign data_out[10] = internal_data[10]; // OUTPUT_SELECTOR_EXTERNAL[1]
assign data_out[11] = internal_data[11]; // OUTPUT_SELECTOR_EXTERNAL[2]
assign data_out[12] = internal_data[12]; // OUTPUT_SELECTOR_EXTERNAL[3]
assign data_out[13] = internal_data[13]; // INPUT_SELECTOR
assign data_out[14] = internal_data[14]; // CLK_SELECTOR
assign data_out[15] = internal_data[15]; // PS_SELECTOR
assign data_out[16] = internal_data[16]; // PS3_SELECTOR
assign data_out[17] = internal_data[17]; // ENABLE_OUTPUT
 


endmodule
