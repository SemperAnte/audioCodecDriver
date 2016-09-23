//--------------------------------------------------------------------------------
// File Name:     acGenerator.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    25.08.2016 - created
//--------------------------------------------------------------------------------
// audio generator
//
// cmdDacSrc :
// 0000 - 0
// 0001 - dac data to gen ( audio interface   )
// 0010 - adc data to gen ( bypass adc to dac )
// 0100 - saw wave
// 1000 - sine wave ( based on cordic algorithm )
//--------------------------------------------------------------------------------
module acGenerator
   #( parameter int DATA_WDT )
    ( input  logic                             clk, 
      input  logic                             reset,
      
      // avalon commands
      input  logic                             cmdModEn,    // 1 - module enabled
      input  logic                  [ 3  : 0 ] cmdDacSrcL,  // dac source data, parallel, left
      input  logic                  [ 3  : 0 ] cmdDacSrcR,  // dac source data, parallel, right
      input  logic                  [ 15 : 0 ] cmdFrqL,     // generator frequency, left
      input  logic                  [ 15 : 0 ] cmdFrqR,     // generator frequency, right
                                                     
      input  logic                             tick,
      
      input  logic signed [ DATA_WDT - 1 : 0 ] adcDataL,
      input  logic signed [ DATA_WDT - 1 : 0 ] adcDataR,
      input  logic signed [ DATA_WDT - 1 : 0 ] dacDataL,
      input  logic signed [ DATA_WDT - 1 : 0 ] dacDataR,
      
      output logic signed [ DATA_WDT - 1 : 0 ] genDataL,
      output logic signed [ DATA_WDT - 1 : 0 ] genDataR );
   
   // check previous state of cmdDacSrc, clear acc if changed
   logic                  [ 3  : 0 ] srcLPrev, srcRPrev;
   // accumulator
   logic                  [ 15 : 0 ] accL, accR;    
   // cordic control
   logic                             crdSt;  
   logic                  [ 16 : 0 ] crdPhi;             // 17 bits    
   logic                             crdRdy;    
   logic signed           [ 16 : 0 ] crdSin;             // 17 bits
   logic signed           [ 15 : 0 ] crdSinSaturate;     // comb, saturate 0100.. value to 0011..
   
   logic signed [ DATA_WDT - 1 : 0 ] sinDataL, sinDataR; // reg,  sine wave
   logic signed [ DATA_WDT - 1 : 0 ] sawDataL, sawDataR; // comb, saw wave
   
   // fsm
   enum int unsigned { ST0, ST1, ST2, ST3, ST4, ST5, ST6 } state;
   
   
   assign genDataL = ~cmdModEn       ? '0       : // disabled
                     cmdDacSrcL[ 3 ] ? sinDataL :
                     cmdDacSrcL[ 2 ] ? sawDataL :
                     cmdDacSrcL[ 1 ] ? adcDataL :
                     cmdDacSrcL[ 0 ] ? dacDataL :
                                       '0;
                                       
   assign genDataR = ~cmdModEn       ? '0       : // disabled
                     cmdDacSrcR[ 3 ] ? sinDataR :
                     cmdDacSrcR[ 2 ] ? sawDataR :
                     cmdDacSrcR[ 1 ] ? adcDataR :
                     cmdDacSrcR[ 0 ] ? dacDataR :
                                       '0;   

   // acc control
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         srcLPrev <= '0;
         srcRPrev <= '0;
         accL     <= '0;
         accR     <= '0;
      end else begin
         if ( cmdModEn ) begin
            if ( tick ) begin
               // left
               srcLPrev <= cmdDacSrcL;
               if ( srcLPrev == cmdDacSrcL )
                  accL <= accL + cmdFrqL;
               else              // mode was changed, clear acc
                  accL <= '0;
               // right
               srcRPrev <= cmdDacSrcR;
               if ( srcRPrev == cmdDacSrcR )
                  accR <= accR - cmdFrqR;         
               else
                  accR <= '0;
            end
         end else begin
            accL <= '0;
            accR <= '0;
         end
      end
      
   assign sawDataL = { accL, { ( DATA_WDT - 16 ) { 1'b0 } } };
   assign sawDataR = { accR, { ( DATA_WDT - 16 ) { 1'b0 } } };
   
   // fsm for sine wave, cordic algorithm control
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         crdSt    <= 1'b0;
         crdPhi   <= '0;
         sinDataL <= '0;
         sinDataR <= '0;
         state    <= ST0;
      end else begin
         if ( ~cmdModEn ) begin // disabled
            crdSt    <= 1'b0;
            crdPhi   <= '0;
            sinDataL <= '0;
            sinDataR <= '0;
            state    <= ST0;
         end else begin               
            case ( state )
               ST0 : begin // wait for acc increment
                  if ( tick )
                     if ( cmdDacSrcL[ 3 ] ) // left or left + right
                        state <= ST1;
                     else if ( cmdDacSrcR[ 3 ] ) // only right
                        state <= ST4;
                     else
                        state <= ST0;
               end
               ST1 : begin // start cordic
                  crdSt  <= 1'b1;
                  crdPhi <= { accL, 1'b0 };
                  state  <= ST2;
               end 
               ST2 : begin // wait for rdy 1'b0
                  crdSt <= 1'b0;
                  state <= ST3;
               end
               ST3 : begin
                  if ( crdRdy ) begin
                     sinDataL <= { crdSinSaturate, { ( DATA_WDT - 16 ) { 1'b0 } } };
                     if ( cmdDacSrcR[ 3 ] )
                        state <= ST4;
                     else
                        state <= ST0;
                  end
               end
               ST4 : begin
                  crdSt  <= 1'b1;
                  crdPhi <= { accR, 1'b0 };
                  state  <= ST5;
               end
               ST5 : begin
                  crdSt <= 1'b0;
                  state <= ST6;
               end
               ST6 : begin
                  if ( crdRdy ) begin
                     sinDataR <= { crdSinSaturate, { ( DATA_WDT - 16 ) { 1'b0 } } };
                     state    <= ST0;
                  end
               end
            endcase
         end
      end
   
   // when 0100.. saturate to 0011..
   assign crdSinSaturate = ( ~crdSin[ 16 ] & crdSin[ 15 ] ) ? { 1'b0, { 15{ 1'b1 } } } : 
                                                              crdSin[ 15 : 0 ];
  
   // simple sine generator
   cordicCosSin
     #( .CORDIC_TYPE ( "SERIAL" ),
        .N           ( 8        ),
        .PHI_WDT     ( 16 + 1   ) ) // 1 bit more
   cordicCosSinInst
      ( .clk   ( clk    ),
        .reset ( reset  ),
        .sclr  ( 1'b0   ),
        .en    ( 1'b1   ),
        .st    ( crdSt  ),
        .phi   ( crdPhi ),
        .rdy   ( crdRdy ),
        .sin   ( crdSin ) );
      
endmodule