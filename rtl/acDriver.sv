//--------------------------------------------------------------------------------
// File Name:     acDriver.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    23.08.2016 - created
//    20.10.2016 - added synchronizer from acClk to mstClk,
//                 added avalon ST interfaces for adc/dac data
//--------------------------------------------------------------------------------
// audio codec SSM2603(SoCKit)/WM8731(DE1-SoC) driver
// audio part + i2c part for configuration
//
// avalon ST source - for adc data
// avalon ST sink   - for dac data
//
// internal generator for testing
//--------------------------------------------------------------------------------
module acDriver
   #( parameter // i2c 
                int    CLK_MASTER_FRQ = 50_000_000,         // clk master frequency
                int    SCLK_I2C_FRQ   = 500_000,            // desired i2c sclk frequency
                // audio part
                string INTERFACE_TYPE = "LEFT-JUSTIFIED",   // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
                int    DATA_WDT       = 24,                 // width of adc/dac data, 16, 20, 24, 32
                int    BCLK_DIVIDER   = 2,                  // relative to mclk, 1, 2, 4, 6, ... or greater even number
                int    LRCK_DIVIDER   = 128 )               // relative to mclk, must be even
    ( // master clock - i2c part + synchronizer                  
      input  logic                          mstClk,
      input  logic                          mstReset,
      // audio part                         
      input  logic                          acClk,      
      input  logic                          acReset,
      
      // audio codec control interface for external chip ( sync with acClk )
      output logic                          audMclk,
      output logic                          audBclk,
      output logic                          audAdcLrck,
      input  logic                          audAdcData,
      output logic                          audDacLrck,
      output logic                          audDacData,      
      output logic                          audMute,
      
      // avalon ST source, adc data ( sync with mstClk )
      output logic                          adcAsoValid, // when changes from '0' to '1' - adc data is set to output bus
      output logic [ 2 * DATA_WDT - 1 : 0 ] adcAsoData,  // upper DATA_WDT bits - left channel  ( signed )   
                                                         // lower DATA_WDT bits - right channel ( signed )
      // avalon ST sink, dac data ( sync with mstClk )
      output logic                          dacAsiRdy,   // when changes from '0' to '1' - dac data is latched to internal register
      input  logic [ 2 * DATA_WDT - 1 : 0 ] dacAsiData,  // upper DATA_WDT bits - left channel  ( signed )                                                                 
                                                         // lower DATA_WDT bits - right channel ( signed )
      // avalon MM slave, audio part ( sync with acClk )
      input  logic               [ 1  : 0 ] acAvsAdr,
      input  logic                          acAvsWr,
      input  logic               [ 15 : 0 ] acAvsWrData,
      input  logic                          acAvsRd,
      output logic               [ 15 : 0 ] acAvsRdData,
                   
      // avalon MM slave, i2c part ( sync with mstClk )
      input  logic                [ 1 : 0 ] i2cAvsAdr,
      input  logic                          i2cAvsWr,
      input  logic                [ 7 : 0 ] i2cAvsWrData,
      input  logic                          i2cAvsRd,
      output logic                [ 7 : 0 ] i2cAvsRdData,
      // avalon interrupt ( sync with mstClk )
      output logic                          i2cInsIrq,
                   
      // i2c lines ( sync with mstClk )             
      inout  wire                           sdat,
      inout  wire                           sclk );  
   
   // sync with acClk
   logic                             acTick;
   logic signed [ DATA_WDT - 1 : 0 ] acAdcDataL; // adc data, left channel
   logic signed [ DATA_WDT - 1 : 0 ] acAdcDataR; // adc data, right channel
   logic signed [ DATA_WDT - 1 : 0 ] acDacDataL; // dac data, left channel
   logic signed [ DATA_WDT - 1 : 0 ] acDacDataR; // dac data, right channel
   
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
        
   // synchronizer, avalon ST converter
   acSync
     #( .SYNC_DEPTH ( 3        ),
        .DATA_WDT   ( DATA_WDT ) )
   acSyncInst
      ( .clk         ( mstClk      ),   
        .reset       ( mstReset    ),
        .adcAsoValid ( adcAsoValid ),
        .adcAsoData  ( adcAsoData  ),
        .dacAsiRdy   ( dacAsiRdy   ),
        .dacAsiData  ( dacAsiData  ), 
        .acTick      ( acTick      ),    
        .acAdcDataL  ( acAdcDataL  ),
        .acAdcDataR  ( acAdcDataR  ),
        .acDacDataL  ( acDacDataL  ),
        .acDacDataR  ( acDacDataR  ) );
        
   // i2c part, from rtllib
   i2cMaster
     #( .CLK_MASTER_FRQ ( CLK_MASTER_FRQ  ),
        .SCLK_I2C_FRQ   ( SCLK_I2C_FRQ    ) )
   i2cMasterInst
      ( .clk         ( mstClk       ),
        .reset       ( mstReset     ),
        .avsAdr      ( i2cAvsAdr    ),
        .avsWr       ( i2cAvsWr     ),
        .avsWrData   ( i2cAvsWrData ),
        .avsRd       ( i2cAvsRd     ),
        .avsRdData   ( i2cAvsRdData ),     
        .insIrq      ( i2cInsIrq    ), 
        .sdat        ( sdat         ),
        .sclk        ( sclk         ) );
        
endmodule