//--------------------------------------------------------------------------------
// File Name:     acDriverSoCKit.sv
// Project:       sockit
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    30.06.2016 - 0.1, verified with hardware
//--------------------------------------------------------------------------------
// SoCkit board wrapper
// audio codec SSM2603 driver
//--------------------------------------------------------------------------------
module acDriverSoCKit
    ( input  logic OSC_50_B8A,
                   
      output logic AUD_XCK,
      output logic AUD_BCLK,
      output logic AUD_ADCLRCK,
      input  logic AUD_ADCDAT,
      output logic AUD_DACLRCK,
      output logic AUD_DACDAT,      
                   
      output logic AUD_MUTE,      // DAC output mute, active low
                   
      inout  wire  AUD_I2C_SDAT,  
      inout  logic AUD_I2C_SCLK ); 
      
   acDriverQsys acDriver
     ( .clk_clk                 ( OSC_50_B8A   ),
       .reset_reset_n           ( 1'b1         ),
       .codeccontrol_audMclk    ( AUD_XCK      ),
       .codeccontrol_audBclk    ( AUD_BCLK     ),
       .codeccontrol_audAdcLrck ( AUD_ADCLRCK  ),
       .codeccontrol_audAdcData ( AUD_ADCDAT   ),
       .codeccontrol_audDacLrck ( AUD_DACLRCK  ),       
       .codeccontrol_audDacData ( AUD_DACDAT   ),       
       .codeccontrol_audMute    ( AUD_MUTE     ),
       .i2cinterface_sdat       ( AUD_I2C_SDAT ),
       .i2cinterface_sclk       ( AUD_I2C_SCLK ) );
       
endmodule       