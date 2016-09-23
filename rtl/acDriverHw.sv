//--------------------------------------------------------------------------------
// File Name:     acDriverHw.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    07.09.2016 - created
//--------------------------------------------------------------------------------
// audio codec SSM2603 driver
// audio part + i2c part for configuration
//
// top-level wrapper for qsys automatic signal recognition
//--------------------------------------------------------------------------------
module acDriverHw
   #( parameter string INTERFACE_TYPE = "LEFT-JUSTIFIED",   // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
                int    DATA_WDT       = 24,                 // width of adc/dac data, 16, 20, 24, 32
                int    BCLK_DIVIDER   = 2,                  // relative to mclk, 1, 2, 4, 6, ... or greater even number
                int    LRCK_DIVIDER   = 128,                // relative to mclk, must be even
                // i2c 
                int    CLK_I2C_FRQ    = 50_000_000,         // input clk frequency
                int    SCLK_I2C_FRQ   = 500_000 )           // desired i2c sclk frequency
    ( // audio part
      input logic                              csi_acClk_clk,
      input logic                              rsi_acReset_reset,
      // i2c part
      input logic                              csi_i2cClk_clk,
      input logic                              rsi_i2cReset_reset,
      
      // audio codec control interface for external chip ( sync with acClk )
      output logic                             coe_audMclk,
      output logic                             coe_audBclk,
      output logic                             coe_audAdcLrck,
      input  logic                             coe_audAdcData,
      output logic                             coe_audDacLrck,
      output logic                             coe_audDacData,      
      output logic                             coe_audMute,
      
      // adc/dac audio interface ( sync with acClk )
      output logic                             coe_acTick,
      output logic signed [ DATA_WDT - 1 : 0 ] coe_acAdcDataL, // adc data, left channel
      output logic signed [ DATA_WDT - 1 : 0 ] coe_acAdcDataR, // adc data, right channel
      input  logic signed [ DATA_WDT - 1 : 0 ] coe_acDacDataL, // dac data, left channel
      input  logic signed [ DATA_WDT - 1 : 0 ] coe_acDacDataR, // dac data, right channel

      // avalon MM slave, audio part ( sync with acClk )
      input  logic                  [ 1  : 0 ] avs_acAvs_address,
      input  logic                             avs_acAvs_write,
      input  logic                  [ 15 : 0 ] avs_acAvs_writedata,
      input  logic                             avs_acAvs_read,
      output logic                  [ 15 : 0 ] avs_acAvs_readdata,
                   
      // avalon MM slave, i2c part ( sync with i2cClk )
      input  logic                   [ 1 : 0 ] avs_i2cAvs_address,
      input  logic                             avs_i2cAvs_write,
      input  logic                   [ 7 : 0 ] avs_i2cAvs_writedata,
      input  logic                             avs_i2cAvs_read,
      output logic                   [ 7 : 0 ] avs_i2cAvs_readdata,
      // avalon interrupt ( sync with i2cClk )
      output logic                             ins_i2cIrq_irq,
                   
      // i2c lines ( sync with i2cClk )             
      inout  wire                              coe_sdat,
      inout  wire                              coe_sclk );  
   
   acDriver
     #( .INTERFACE_TYPE ( INTERFACE_TYPE ),
        .DATA_WDT       ( DATA_WDT       ),
        .BCLK_DIVIDER   ( BCLK_DIVIDER   ),
        .LRCK_DIVIDER   ( LRCK_DIVIDER   ),
        .CLK_I2C_FRQ    ( CLK_I2C_FRQ    ),
        .SCLK_I2C_FRQ   ( SCLK_I2C_FRQ   ) )
   acDriverInst
      ( .acClk        ( csi_acClk_clk        ),
        .acReset      ( rsi_acReset_reset    ),
        .i2cClk       ( csi_i2cClk_clk       ),
        .i2cReset     ( rsi_i2cReset_reset   ),
        .audMclk      ( coe_audMclk          ),
        .audBclk      ( coe_audBclk          ),
        .audAdcLrck   ( coe_audAdcLrck       ),
        .audAdcData   ( coe_audAdcData       ),
        .audDacLrck   ( coe_audDacLrck       ),
        .audDacData   ( coe_audDacData       ),
        .audMute      ( coe_audMute          ),
        .acTick       ( coe_acTick           ),
        .acAdcDataL   ( coe_acAdcDataL       ),
        .acAdcDataR   ( coe_acAdcDataR       ),
        .acDacDataL   ( coe_acDacDataL       ),
        .acDacDataR   ( coe_acDacDataR       ),
        .acAvsAdr     ( avs_acAvs_address    ),
        .acAvsWr      ( avs_acAvs_write      ),
        .acAvsWrData  ( avs_acAvs_writedata  ),
        .acAvsRd      ( avs_acAvs_read       ),
        .acAvsRdData  ( avs_acAvs_readdata   ),
        .i2cAvsAdr    ( avs_i2cAvs_address   ),
        .i2cAvsWr     ( avs_i2cAvs_write     ),
        .i2cAvsWrData ( avs_i2cAvs_writedata ),
        .i2cAvsRd     ( avs_i2cAvs_read      ),
        .i2cAvsRdData ( avs_i2cAvs_readdata  ),
        .i2cInsIrq    ( ins_i2cIrq_irq       ),
        .sdat         ( coe_sdat             ),
        .sclk         ( coe_sclk             ) );
        
endmodule