//--------------------------------------------------------------------------------
// File Name:     acDriver.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    23.08.2016 - created
//--------------------------------------------------------------------------------
// audio codec SSM2603(SoCKit)/WM8731(DE1-SoC) driver
// audio part + i2c part for configuration
//
// audio interface ( sync with acClk )
// acTick - '1' for 1 tick of acClk with Fs frequency
// when acTick changes from '0' to '1' - dac data is latched to internal register, adc data is set to output bus
// adc data, dac data - signed format
//
// internal generator for testing
//--------------------------------------------------------------------------------
module acDriver
   #( parameter string INTERFACE_TYPE = "LEFT-JUSTIFIED",   // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
                int    DATA_WDT       = 24,                 // width of adc/dac data, 16, 20, 24, 32
                int    BCLK_DIVIDER   = 2,                  // relative to mclk, 1, 2, 4, 6, ... or greater even number
                int    LRCK_DIVIDER   = 128,                // relative to mclk, must be even
                // i2c 
                int    CLK_I2C_FRQ    = 50_000_000,         // input clk frequency
                int    SCLK_I2C_FRQ   = 500_000 )           // desired i2c sclk frequency
    ( // audio part
      input  logic                             acClk,      
      input  logic                             acReset,
      // i2c part                  
      input  logic                             i2cClk,
      input  logic                             i2cReset,
      
      // audio codec control interface for external chip ( sync with acClk )
      output logic                             audMclk,
      output logic                             audBclk,
      output logic                             audAdcLrck,
      input  logic                             audAdcData,
      output logic                             audDacLrck,
      output logic                             audDacData,      
      output logic                             audMute,
      
      // adc/dac audio interface ( sync with acClk )
      output logic                             acTick,
      output logic signed [ DATA_WDT - 1 : 0 ] acAdcDataL, // adc data, left channel
      output logic signed [ DATA_WDT - 1 : 0 ] acAdcDataR, // adc data, right channel
      input  logic signed [ DATA_WDT - 1 : 0 ] acDacDataL, // dac data, left channel
      input  logic signed [ DATA_WDT - 1 : 0 ] acDacDataR, // dac data, right channel

      // avalon MM slave, audio part ( sync with acClk )
      input  logic                  [ 1  : 0 ] acAvsAdr,
      input  logic                             acAvsWr,
      input  logic                  [ 15 : 0 ] acAvsWrData,
      input  logic                             acAvsRd,
      output logic                  [ 15 : 0 ] acAvsRdData,
                   
      // avalon MM slave, i2c part ( sync with i2cClk )
      input  logic                   [ 1 : 0 ] i2cAvsAdr,
      input  logic                             i2cAvsWr,
      input  logic                   [ 7 : 0 ] i2cAvsWrData,
      input  logic                             i2cAvsRd,
      output logic                   [ 7 : 0 ] i2cAvsRdData,
      // avalon interrupt ( sync with i2cClk )
      output logic                             i2cInsIrq,
                   
      // i2c lines ( sync with i2cClk )             
      inout  wire                              sdat,
      inout  wire                              sclk );  
   
   // audio part
   acCore
     #( .INTERFACE_TYPE ( INTERFACE_TYPE ),
        .DATA_WDT       ( DATA_WDT       ),
        .BCLK_DIVIDER   ( BCLK_DIVIDER   ),
        .LRCK_DIVIDER   ( LRCK_DIVIDER   ) )
   acCoreInst
      ( .clk         ( acClk       ),
        .reset       ( acReset     ),
        .audMclk     ( audMclk     ),
        .audBclk     ( audBclk     ),
        .audAdcLrck  ( audAdcLrck  ),
        .audAdcData  ( audAdcData  ),
        .audDacLrck  ( audDacLrck  ),
        .audDacData  ( audDacData  ),
        .audMute     ( audMute     ),
        .tick        ( acTick      ),
        .adcDataL    ( acAdcDataL  ),
        .adcDataR    ( acAdcDataR  ),
        .dacDataL    ( acDacDataL  ),
        .dacDataR    ( acDacDataR  ),
        .avsAdr      ( acAvsAdr    ),
        .avsWr       ( acAvsWr     ),
        .avsWrData   ( acAvsWrData ),
        .avsRd       ( acAvsRd     ),
        .avsRdData   ( acAvsRdData ) );
        
   // i2c part, from rtllib
   i2cMaster
     #( .CLK_MASTER_FRQ ( CLK_I2C_FRQ     ),
        .SCLK_I2C_FRQ   ( SCLK_I2C_FRQ    ) )
   i2cMasterInst
      ( .clk         ( i2cClk       ),
        .reset       ( i2cReset     ),
        .avsAdr      ( i2cAvsAdr    ),
        .avsWr       ( i2cAvsWr     ),
        .avsWrData   ( i2cAvsWrData ),
        .avsRd       ( i2cAvsRd     ),
        .avsRdData   ( i2cAvsRdData ),     
        .insIrq      ( i2cInsIrq    ), 
        .sdat        ( sdat         ),
        .sclk        ( sclk         ) );
        
endmodule