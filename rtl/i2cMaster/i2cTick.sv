//--------------------------------------------------------------------------------
// File Name:     i2cTick.sv
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    16.07.2016 - created
//--------------------------------------------------------------------------------
// generate reference ticks:
//    tickX4 with frequency 4 * SCLK_I2C_FRQ
//    tickX16 with frequency near 16 * SCLK_I2C_FRQ
//--------------------------------------------------------------------------------
module i2cTick
   #( parameter int CLK_MASTER_FRQ,    // master clock (input clk) frequency
                int SCLK_I2C_FRQ )     // desired i2c sclk frequency
    ( input  logic clk,
      input  logic reset,     // async reset
                      
      output logic tickX4,
      output logic tickX16 ); // roughly
   
   // X4
   localparam int X4_N   = CLK_MASTER_FRQ / SCLK_I2C_FRQ / 4.0;
   localparam int X4_MAX = ( X4_N < 12 ) ? 12 : X4_N; // cant be too low
   localparam int X4_WDT = $clog2( X4_MAX );
   
   logic [ X4_WDT - 1 : 0 ] cntX4;   
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         tickX4 <= 1'b0;
         cntX4  <= '0;
      end else
         if ( ~|cntX4 ) begin
            tickX4 <= 1'b1;
            cntX4  <= ( X4_WDT )'( X4_MAX - 1 );
         end else begin
            tickX4 <= 1'b0;
            cntX4  <= cntX4 - 1'd1;
         end
   
   // X16
   localparam int X16_MAX = X4_MAX / 4;
   localparam int X16_WDT = $clog2( X16_MAX );
   
   logic [ X16_WDT - 1 : 0 ] cntX16;
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         tickX16 <= 1'b0;
         cntX16  <= '0;         
      end else
         if ( ~|cntX16 ) begin
            tickX16 <= 1'b1;
            cntX16  <= ( X16_WDT )'( X16_MAX - 1 );
         end else begin
            tickX16 <= 1'b0;
            cntX16  <= cntX16 - 1'd1;
         end   
      
   localparam real SCLK_I2C_FRQ_REAL = CLK_MASTER_FRQ / X4_MAX / 4.0 / 1000.0;
   localparam real TICK_PERIOD_REAL  = 1e6 / SCLK_I2C_FRQ_REAL / 4.0;
   initial begin
      $display( "real I2C sclk frequency  = %f kHz", SCLK_I2C_FRQ_REAL );      
      $display( "real 1/4 I2C sclk period = %f ns", TICK_PERIOD_REAL );
   end   
      
endmodule