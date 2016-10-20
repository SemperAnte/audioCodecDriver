//--------------------------------------------------------------------------------
// File Name:     acDriverDE1SoC.sv
// Project:       sockit
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    17.10.2016 - 0.1, verified with hardware
//--------------------------------------------------------------------------------
// DE1-SoC board wrapper
// audio codec WM8731 driver
//--------------------------------------------------------------------------------
module acDriverDE1SoC
    ( input  logic CLOCK_50,
                   
      output logic AUD_XCK,
      output logic AUD_BCLK,
      output logic AUD_ADCLRCK,
      input  logic AUD_ADCDAT,
      output logic AUD_DACLRCK,
      output logic AUD_DACDAT,      
                   
      inout  wire  FPGA_I2C_SDAT,
      inout  logic FPGA_I2C_SCLK );
      
   acDriverQsys acDriver
     ( .clk_clk                 ( CLOCK_50      ),
       .reset_reset_n           ( 1'b1          ),
       .codeccontrol_audMclk    ( AUD_XCK       ),
       .codeccontrol_audBclk    ( AUD_BCLK      ),
       .codeccontrol_audAdcLrck ( AUD_ADCLRCK   ),
       .codeccontrol_audAdcData ( AUD_ADCDAT    ),
       .codeccontrol_audDacLrck ( AUD_DACLRCK   ),       
       .codeccontrol_audDacData ( AUD_DACDAT    ),       
       // no hardware mute on DE1-SoC
       //.codeccontrol_audMute    ( AUD_MUTE     ),
       .i2cinterface_sdat       ( FPGA_I2C_SDAT ),
       .i2cinterface_sclk       ( FPGA_I2C_SCLK ) );
       
endmodule       