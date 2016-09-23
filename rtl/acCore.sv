//--------------------------------------------------------------------------------
// File Name:     acCore.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    23.08.2016 - created
//--------------------------------------------------------------------------------
// audio codec SSM2603 driver
// audio part
//--------------------------------------------------------------------------------
module acCore
   #( parameter string INTERFACE_TYPE,   // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
                int    DATA_WDT,         // width of adc/dac data, 16, 20, 24, 32
                int    BCLK_DIVIDER,     // relative to mclk, 1, 2, 4, 6, ... or greater even number
                int    LRCK_DIVIDER )    // relative to mclk, must be even
    ( // audio part
      input  logic                             clk,      
      input  logic                             reset,

      // audio codec control interface
      output logic                             audMclk,
      output logic                             audBclk,
      output logic                             audAdcLrck,
      input  logic                             audAdcData,
      output logic                             audDacLrck,
      output logic                             audDacData,      
      output logic                             audMute,
      
      // adc/dac audio interface
      output logic                             tick,
      output logic signed [ DATA_WDT - 1 : 0 ] adcDataL, // adc data, left channel
      output logic signed [ DATA_WDT - 1 : 0 ] adcDataR, // adc data, right channel
      input  logic signed [ DATA_WDT - 1 : 0 ] dacDataL, // dac data, left channel
      input  logic signed [ DATA_WDT - 1 : 0 ] dacDataR, // dac data, right channel

      // avalon MM slave
      input  logic                  [ 1  : 0 ] avsAdr,
      input  logic                             avsWr,
      input  logic                  [ 15 : 0 ] avsWrData,
      input  logic                             avsRd,
      output logic                  [ 15 : 0 ] avsRdData );
      
   // avalon commands
   logic            cmdModEn;    // 1 - module enabled
   logic            cmdMute;     // 1 - hardware mute enabled
   logic [ 3  : 0 ] cmdDacSrcL;  // dac source data, parallel, left
   logic [ 3  : 0 ] cmdDacSrcR;  // dac source data, parallel, right
   logic [ 15 : 0 ] cmdFrqL;     // generator frequency, left
   logic [ 15 : 0 ] cmdFrqR;     // generator frequency, right
      
   assign audMute = ~cmdMute; // hardware mute - active low
   
   logic signed [ DATA_WDT - 1 : 0 ] genDataL;
   logic signed [ DATA_WDT - 1 : 0 ] genDataR;
   
   // audio codec control interface 
   acInterface
     #( .INTERFACE_TYPE ( INTERFACE_TYPE ),
        .DATA_WDT       ( DATA_WDT       ),
        .BCLK_DIVIDER   ( BCLK_DIVIDER   ),
        .LRCK_DIVIDER   ( LRCK_DIVIDER   ) )     
   acInterfaceInst
      ( .clk        ( clk        ),
        .reset      ( reset      ),
        .audMclk    ( audMclk    ),
        .audBclk    ( audBclk    ),
        .audAdcLrck ( audAdcLrck ),
        .audAdcData ( audAdcData ),
        .audDacLrck ( audDacLrck ),
        .audDacData ( audDacData ),     
        .cmdModEn   ( cmdModEn   ),
        .tick       ( tick       ),
        .adcDataL   ( adcDataL   ),
        .adcDataR   ( adcDataR   ),
        .genDataL   ( genDataL   ),
        .genDataR   ( genDataR   ) );
   
   // test signals audio generator
   acGenerator
     #( .DATA_WDT   ( DATA_WDT ) )
   acGeneratorInst
      ( .clk        ( clk        ),
        .reset      ( reset      ),   
        .cmdModEn   ( cmdModEn   ),
        .cmdDacSrcL ( cmdDacSrcL ),
        .cmdDacSrcR ( cmdDacSrcR ),
        .cmdFrqL    ( cmdFrqL    ),
        .cmdFrqR    ( cmdFrqR    ),               
        .tick       ( tick       ),  
        .adcDataL   ( adcDataL   ),
        .adcDataR   ( adcDataR   ), 
        .dacDataL   ( dacDataL   ),
        .dacDataR   ( dacDataR   ),     
        .genDataL   ( genDataL   ),
        .genDataR   ( genDataR   ) );
                                 
   // avalon MM slave interface
   acAvalon acAvalonInst
      ( .clk        ( clk        ),
        .reset      ( reset      ),
        .avsAdr     ( avsAdr     ),
        .avsWr      ( avsWr      ),
        .avsWrData  ( avsWrData  ),
        .avsRd      ( avsRd      ),
        .avsRdData  ( avsRdData  ),
        .cmdModEn   ( cmdModEn   ),
        .cmdMute    ( cmdMute    ),
        .cmdDacSrcL ( cmdDacSrcL ),
        .cmdDacSrcR ( cmdDacSrcR ),
        .cmdFrqL    ( cmdFrqL    ),
        .cmdFrqR    ( cmdFrqR    ) );    
        
endmodule