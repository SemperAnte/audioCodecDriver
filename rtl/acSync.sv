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
   ( input  logic                             clk,
     input  logic                             reset,        // async reset
     
      // avalon ST source, adc data ( sync with mstClk ), left / right channels
     output logic                             adcLAsoValid, // when changes from '0' to '1' - adc data is set to output bus
     output logic signed [ DATA_WDT - 1 : 0 ] adcLAsoData,    
     output logic                             adcRAsoValid,
     output logic signed [ DATA_WDT - 1 : 0 ] adcRAsoData,      
     
     // avalon ST sink, dac data ( sync with mstClk ), left / right channels
     output logic                             dacLAsiRdy,   // when changes from '0' to '1' - dac data is latched to internal register
     input  logic signed [ DATA_WDT - 1 : 0 ] dacLAsiData,
     output logic                             dacRAsiRdy,  
     input  logic signed [ DATA_WDT - 1 : 0 ] dacRAsiData, 
      
     input  logic                             acTick,        
     input  logic signed [ DATA_WDT - 1 : 0 ] acAdcDataL,    
     input  logic signed [ DATA_WDT - 1 : 0 ] acAdcDataR,    
     output logic signed [ DATA_WDT - 1 : 0 ] acDacDataL,    
     output logic signed [ DATA_WDT - 1 : 0 ] acDacDataR );                                                              

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
      adcLAsoValid <= 1'b0;
      adcLAsoData  <= '0;
      adcRAsoValid <= 1'b0;
      adcRAsoData  <= '0;
      dacLAsiRdy   <= 1'b0;
      dacRAsiRdy   <= 1'b0;
      
      acDacDataL  <= '0;
      acDacDataR  <= '0;
      
      syncTick    <= '0;
   end else begin
      syncTick <= { syncTick[ SYNC_DEPTH - 1 : 0 ], acTick };
      if ( ~syncTick[ SYNC_DEPTH ] & syncTick[ SYNC_DEPTH - 1 ] ) begin // detect rising edge
         adcLAsoValid <= 1'b1;
         adcRAsoValid <= 1'b1;
         dacLAsiRdy   <= 1'b1;
         dacRAsiRdy   <= 1'b1;
         
         adcLAsoData <= acAdcDataL;
         adcRAsoData <= acAdcDataR;         

         acDacDataL  <= dacLAsiData;
         acDacDataR  <= dacRAsiData;
      end else begin
         adcLAsoValid <= 1'b0;
         adcRAsoValid <= 1'b0;
         dacLAsiRdy   <= 1'b0;
         dacRAsiRdy   <= 1'b0;
      end
   end
   
endmodule