//--------------------------------------------------------------------------------
// File Name:     acAvalon.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    23.08.2016 - created
//--------------------------------------------------------------------------------
// avalon MM slave interface
// audio interface control, 16 bits width
//--------------------------------------------------------------------------------
//    adr 0 - w/r :
//        bit 15  : interface is enabled, disabled after reset
//        bit 14  : hardware mute
//        bit 0   : soft reset to default
//    adr 1 - w/r : 
//        bit 3:0 : left channel source data for dac, serial
//        bit 7:4 : right channel source data for dac, serial
//                  0000 - zeros to dac
//                  0001 - external data (from interface)
//                  0010 - adc data (bypass adc to dac)
//                  0011 - saw with custom frequency
//                  0100 - sine with custom frequency
//    adr 2 - w/r : 16 bits, left  channel frequency for saw/sine mode ( relative to Fs )
//    adr 3 - w/r : 16 bits, right channel frequency for saw/sine mode ( relative to Fs )
//--------------------------------------------------------------------------------
module acAvalon             
    ( input  logic            clk,
      input  logic            reset,       // async reset
      
      // avalon MM slave
      input  logic [ 1  : 0 ] avsAdr,
      input  logic            avsWr,
      input  logic [ 15 : 0 ] avsWrData,
      input  logic            avsRd,
      output logic [ 15 : 0 ] avsRdData,
      
      // audio control command
      output logic            cmdModEn,    // 1 - module enabled
      output logic            cmdMute,     // 1 - hardware mute enabled
      output logic [ 3  : 0 ] cmdDacSrcL,  // dac source data, parallel, left
      output logic [ 3  : 0 ] cmdDacSrcR,  // dac source data, parallel, right
                                           // 0000 - 000
                                           // 0001 - 001
                                           // 0010 - 010
                                           // 0100 - 011
                                           // 1000 - 100
      output logic [ 15 : 0 ] cmdFrqL,     // generator frequency, left
      output logic [ 15 : 0 ] cmdFrqR );   // generator frequency, right
   
   // serial 2 parallel converter for cmdDacSrc, comb logic
   logic [ 3 : 0 ] ser2parL, ser2parR;
   // parallel 2 serial converter for avsRdData, comb logic
   logic [ 2 : 0 ] par2serL, par2serR;
      
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         avsRdData    <= 16'b0;
         cmdModEn     <= 1'b0;
         cmdMute      <= 1'b0;
         cmdDacSrcL   <= 4'b0;
         cmdDacSrcR   <= 4'b0;
         cmdFrqL      <= 16'b0;         
         cmdFrqR      <= 16'b0;
      end else begin
         // write
         if ( avsWr ) begin
            case ( avsAdr )
               2'd0 : begin
                  if ( avsWrData[ 0 ] ) begin // soft reset
                     cmdModEn   <= 1'b0;
                     cmdMute    <= 1'b0;
                     cmdDacSrcL <= 4'b0;
                     cmdDacSrcR <= 4'b0;
                     cmdFrqL    <= 16'b0;
                     cmdFrqR    <= 16'b0;
                  end else begin
                     cmdModEn <= avsWrData[ 15 ];                 
                     cmdMute  <= avsWrData[ 14 ];
                  end
               end
               2'd1 : begin
                  cmdDacSrcL <= ser2parL;
                  cmdDacSrcR <= ser2parR;
               end
               2'd2 : begin
                  cmdFrqL <= avsWrData;               
               end
               default : begin
                  cmdFrqR <= avsWrData;               
               end
            endcase
         end // avsWr
         // read
         if ( avsRd ) begin
            case ( avsAdr )
               2'd0    :
                  avsRdData <= { cmdModEn, cmdMute, 14'b0 };
               2'd1    :
                  avsRdData <= { 9'b0, par2serR, 1'b0, par2serL };
               2'd2    :
                  avsRdData <= cmdFrqL;
               default :
                  avsRdData <= cmdFrqR;
            endcase
         end // avsRd
      end      
   
   always_comb begin
      ser2parL = 4'b0000;
      for ( int i = 4; i > 0; i-- )
         if ( avsWrData[ 2 : 0 ] == i )
            ser2parL[ i - 1 ] = 1'b1;
            
      ser2parR = 4'b0000;
      for ( int i = 4; i > 0; i-- )
         if ( avsWrData[ 6 : 4 ] == i )
            ser2parR[ i - 1 ] = 1'b1;
            
      par2serL = 3'b000;
      for ( int i = 4; i > 0; i-- )
         if ( cmdDacSrcL[ i - 1 ] )
            par2serL = ( 3 )'( i );
            
      par2serR = 3'b000;
      for ( int i = 4; i > 0; i-- )
         if ( cmdDacSrcR[ i - 1 ] )
            par2serR = ( 3 )'( i );
   end     

endmodule