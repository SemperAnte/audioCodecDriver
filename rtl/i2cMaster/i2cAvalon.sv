//--------------------------------------------------------------------------------
// File Name:     i2cAvalon.sv
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    16.07.2016 - created
//--------------------------------------------------------------------------------
// avalon MM slave interface
//--------------------------------------------------------------------------------
//    adr 0 - w/r :
//        bit 7   : module is enabled, disabled after reset
//        bit 6   : interrupt is enabled (insIrq), disabled after reset
//        bit 0   : soft reset to default
//    adr 1 - w/r : 
//        bit 0   : interrupt bit, 0 - clear interrupt
//    adr 2 - w   : transmitted byte
//    adr 2 - r   : last received byte
//    adr 3 - w   : start transfer, clear interrupt
//        bit 7   : 0 - no start bit      1 - (rep) start bit
//        bit 6   : 0 - read byte         1 - write byte 
//        bit 5   : 0 - no ack by master  1 - ack by master
//        bit 4   : 0 - no stop bit       1 - stop bit
//    adr 3 - r   : read status
//        bit 7   : transfer in progress (busy bit)
//        bit 6   : transfer in waiting  (no stop bit in last packet)
//        bit 1:0 : 00 - no errors occurred, transfer is successful
//                  01 - no ack from slave
//                  10 - time limit exceeded
//--------------------------------------------------------------------------------
module i2cAvalon             
    ( input  logic           clk,
      input  logic           reset,       // async reset
      
      // avalon MM slave
      input  logic [ 1 : 0 ] avsAdr,
      input  logic           avsWr,
      input  logic [ 7 : 0 ] avsWrData,
      input  logic           avsRd,
      output logic [ 7 : 0 ] avsRdData,
      // avalon interrupt
      output logic           insIrq,
      
      // i2c control command
      output logic           cmdBegin,    // forced start transfer
      output logic           cmdClear,    // forced clear transfer      
      output logic           cmdBitStart, // 0 - no start bit      1 - (rep) start bit
      output logic           cmdBitWr,    // 0 - read byte         1 - write byte 
      output logic           cmdBitAck,   // 0 - no ack by master  1 - ack by master
      output logic           cmdBitStop,  // 0 - no stop bit       1 - stop bit
      output logic [ 7 : 0 ] cmdByteWr,   // write data
      
      input  logic           cmdRdy,      // finish transfer
      input  logic [ 7 : 0 ] cmdByteRd,   // read data
      input  logic [ 1 : 0 ] cmdErr,      // error transfer
      input  logic           cmdBusy,     // transfer in progress
      input  logic           cmdWait );   // transfer in waiting
      
   logic rmapModEn;
   logic rmapIrqEn;
   logic rmapIrqBit;
      
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin    
         avsRdData  <= 8'b0;
         cmdBegin   <= 1'b0;
         cmdClear   <= 1'b0;  
         cmdByteWr  <= 8'b0;         
         rmapModEn  <= 1'b0;
         rmapIrqEn  <= 1'b0; 
         rmapIrqBit <= 1'b0;
      end else begin   
         // default
         cmdBegin <= 1'b0;
         cmdClear <= 1'b0;  
         // set interrupt bit
         if ( cmdRdy )
            rmapIrqBit <= 1'b1;
         // write
         if ( avsWr ) begin
            case ( avsAdr )
               2'd0 : begin
                  if ( avsWrData[ 0 ] ) begin // soft reset
                     cmdClear   <= 1'b1; // forced stop
                     cmdByteWr  <= 8'b0;
                     rmapModEn  <= 1'b0;
                     rmapIrqEn  <= 1'b0;
                     rmapIrqBit <= 1'b0;
                  end else begin
                     rmapModEn <= avsWrData[ 7 ];
                     if ( ~avsWrData[ 7 ] ) begin
                        cmdClear   <= 1'b1; // forced stop
                        rmapIrqBit <= 1'b0;
                     end
                     rmapIrqEn <= avsWrData[ 6 ];
                  end 
               end
               2'd1 : begin
                  rmapIrqBit <= avsWrData[ 0 ];
               end
               2'd2 : begin
                  cmdByteWr <= avsWrData;
               end
               default : begin // 2'd3 + additional always block
                  if ( rmapModEn ) begin
                     cmdBegin <= 1'b1;  
                  end
                  rmapIrqBit <= 1'b0;
               end
            endcase
         end // avsWr
         // read
         if ( avsRd ) begin
            case ( avsAdr )
               2'd0 : begin
                  avsRdData <= { rmapModEn, rmapIrqEn, 6'b0 };
               end
               2'd1 : begin
                  avsRdData <= { 7'b0, rmapIrqBit };
               end
               2'd2 : begin
                  avsRdData <= cmdByteRd;
               end
               default : begin // 2'd3
                  avsRdData <= { cmdBusy, cmdWait, 4'b0, cmdErr };
               end
            endcase
         end // avsRd
      end
   
   always_ff @( posedge clk ) // dont need reset
      if ( avsWr && avsAdr == 2'd3 ) begin
         cmdBitStart <= avsWrData[ 7 ];
         cmdBitWr    <= avsWrData[ 6 ];
         cmdBitAck   <= avsWrData[ 5 ];
         cmdBitStop  <= avsWrData[ 4 ];
      end
   
   assign insIrq = ( rmapModEn & rmapIrqEn ) ? rmapIrqBit : 1'b0;
      
endmodule