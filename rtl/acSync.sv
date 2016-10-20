//--------------------------------------------------------------------------------
// File Name:     acSync.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       20.10.2016 - created
//--------------------------------------------------------------------------------
// synchronizer from acCLk to mstClk
// converter to Avalon ST interface
//--------------------------------------------------------------------------------
module acSync
  #( parameter int SYNC_DEPTH,        // number of registers in sync chain ( >= 2 )
               int DATA_WDT )
   ( input  logic                                 clk,
     input  logic                                 reset,        // async reset
     
     // avalon ST source, adc data ( sync with mstClk )
     output logic                                 adcAsoValid,  
     output logic        [ 2 * DATA_WDT - 1 : 0 ] adcAsoData,   // upper DATA_WDT bits - left channel  ( signed )   
                                                                // lower DATA_WDT bits - right channel ( signed )
     // avalon ST sink, dac data ( sync with mstClk )    
     output logic                                 dacAsiRdy,
     input  logic        [ 2 * DATA_WDT - 1 : 0 ] dacAsiData,   // upper DATA_WDT bits - left channel  ( signed )                                                                 
                                                                // lower DATA_WDT bits - right channel ( signed )
     input  logic                                 acTick,        
     input  logic signed     [ DATA_WDT - 1 : 0 ] acAdcDataL,    
     input  logic signed     [ DATA_WDT - 1 : 0 ] acAdcDataR,    
     output logic signed     [ DATA_WDT - 1 : 0 ] acDacDataL,    
     output logic signed     [ DATA_WDT - 1 : 0 ] acDacDataR );                                                              

   // check parameters
   initial begin
      if ( SYNC_DEPTH < 2 ) begin
         $error( "Not correct parameter, SYNC_DEPTH" );
         $stop;
      end
   end
   
   logic [ SYNC_DEPTH : 0 ] syncTick; // SYNC_DEPTH + 1 for edge detection
   
   always_ff @( posedge reset, posedge clk )
   if ( reset ) begin
      adcAsoValid <= 1'b0;
      dacAsiRdy   <= 1'b0;
      acDacDataL  <= '0;
      acDacDataR  <= '0;
      
      syncTick    <= '0;
   end else begin
      syncTick <= { syncTick[ SYNC_DEPTH - 1 : 0 ], acTick };
      if ( ~syncTick[ SYNC_DEPTH ] & syncTick[ SYNC_DEPTH - 1 ] ) begin // detect rising edge
         adcAsoValid <= 1'b1;
         dacAsiRdy   <= 1'b1;
         adcAsoData  <= { acAdcDataL, acAdcDataR };
         acDacDataL  <= dacAsiData[ 2 * DATA_WDT - 1 : DATA_WDT ];
         acDacDataR  <= dacAsiData[ DATA_WDT - 1 : 0 ];
      end else begin
         adcAsoValid <= 1'b0;
         dacAsiRdy   <= 1'b0;
      end
   end
   
endmodule