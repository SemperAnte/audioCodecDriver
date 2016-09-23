//--------------------------------------------------------------------------------
// File Name:     i2cMaster.sv
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    16.07.2016 - created
//    23.07.2016 - beta version
//--------------------------------------------------------------------------------
// i2c Master with Avalon MM interface
//--------------------------------------------------------------------------------
module i2cMaster             
   #( parameter int CLK_MASTER_FRQ = 50_000_000,   // master clock (input clk) frequency
                int SCLK_I2C_FRQ   = 500_000 )     // desired i2c sclk frequency
    ( input  logic           clk,
      input  logic           reset,   // async reset
      
      // avalon MM slave
      input  logic [ 1 : 0 ] avsAdr,
      input  logic           avsWr,
      input  logic [ 7 : 0 ] avsWrData,
      input  logic           avsRd,
      output logic [ 7 : 0 ] avsRdData,
      // avalon interrupt
      output logic           insIrq,
      
      // i2c lines
      inout  wire            sdat,
      inout  wire            sclk );
      
   logic           tickX4, tickX16;

   logic           sdatOut, sclkOut;
   logic           sdatFlt, sclkFlt;
   
   logic           cmdBegin;  
   logic           cmdClear;  
   logic           cmdBitStart;
   logic           cmdBitWr;
   logic           cmdBitAck; 
   logic           cmdBitStop;
   logic [ 7 : 0 ] cmdByteWr;   
   logic           cmdRdy; 
   logic [ 7 : 0 ] cmdByteRd;
   logic [ 1 : 0 ] cmdErr;    
   logic           cmdBusy;   
   logic           cmdWait;   
   
   // generate reference ticks
   i2cTick 
      #( .CLK_MASTER_FRQ ( CLK_MASTER_FRQ ),
         .SCLK_I2C_FRQ   ( SCLK_I2C_FRQ   ) )
   i2cTickInst
       ( .clk     ( clk     ),
         .reset   ( reset   ),
         .tickX4  ( tickX4  ),
         .tickX16 ( tickX16 ) );
   
   // i2c line sdat / sclk control
   i2cLine i2cLineInst            
       ( .clk     ( clk     ),
         .reset   ( reset   ),
         .tickX16 ( tickX16 ),
         .sdatOut ( sdatOut ),
         .sclkOut ( sclkOut ),
         .sdatFlt ( sdatFlt ),
         .sclkFlt ( sclkFlt ),
         .sdat    ( sdat    ),
         .sclk    ( sclk    ) );
         
   // avalon MM slave interface
   i2cAvalon i2cAvalonInst            
       ( .clk          ( clk          ),
         .reset        ( reset        ),
         .avsAdr       ( avsAdr       ),
         .avsWr        ( avsWr        ),
         .avsWrData    ( avsWrData    ),
         .avsRd        ( avsRd        ),
         .avsRdData    ( avsRdData    ),     
         .insIrq       ( insIrq       ), 
         .cmdBegin     ( cmdBegin     ),
         .cmdClear     ( cmdClear     ),
         .cmdBitStart  ( cmdBitStart  ),
         .cmdBitWr     ( cmdBitWr     ),
         .cmdBitAck    ( cmdBitAck    ),
         .cmdBitStop   ( cmdBitStop   ),
         .cmdByteWr    ( cmdByteWr    ),  
         .cmdRdy       ( cmdRdy       ),
         .cmdByteRd    ( cmdByteRd    ),
         .cmdErr       ( cmdErr       ),
         .cmdBusy      ( cmdBusy      ),
         .cmdWait      ( cmdWait      ) );
   
   // i2c master fsm control   
   i2cControl i2cControlInst            
       ( .clk          ( clk         ),
         .reset        ( reset       ),
         .cmdBegin     ( cmdBegin    ),
         .cmdClear     ( cmdClear    ),
         .cmdBitStart  ( cmdBitStart ),
         .cmdBitWr     ( cmdBitWr    ),
         .cmdBitAck    ( cmdBitAck   ),
         .cmdBitStop   ( cmdBitStop  ),
         .cmdByteWr    ( cmdByteWr   ),  
         .cmdRdy       ( cmdRdy      ),
         .cmdByteRd    ( cmdByteRd   ),
         .cmdErr       ( cmdErr      ),
         .cmdBusy      ( cmdBusy     ),
         .cmdWait      ( cmdWait     ),
         .tickX4       ( tickX4      ),
         .sdatOut      ( sdatOut     ),
         .sclkOut      ( sclkOut     ),
         .sdatFlt      ( sdatFlt     ),
         .sclkFlt      ( sclkFlt     ) );
         
endmodule