//--------------------------------------------------------------------------------
// File Name:     acInterface.sv
// Project:       audioCodec
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    30.06.2016 - beta, tested with modelsim
//    05.09.2016 - 0.7, add INTERFACE_TYPE parameter
//--------------------------------------------------------------------------------
// audio interface
// see SSM2603 datasheet, page 15
//
// acTick - '1' for 1 tick of acClk with Fs frequency
// when acTick changes from '0' to '1' - dac data is latched to internal register, adc data is set to output bus
// adc data, dac data - signed format
//--------------------------------------------------------------------------------
module acInterface
   #( parameter string INTERFACE_TYPE,   // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
                int    DATA_WDT,         // width of adc/dac data, 16, 20, 24, 32
                int    BCLK_DIVIDER,     // relative to mclk, 1, 2, 4, 6, ... or greater even number
                int    LRCK_DIVIDER )    // relative to mclk, must be even
    ( input  logic                             clk, 
      input  logic                             reset,
      
      // adc/dac audio interface to external chip                                 
      output logic                             audMclk,
      output logic                             audBclk,
      output logic                             audAdcLrck,
      input  logic                             audAdcData,
      output logic                             audDacLrck,
      output logic                             audDacData,
      
      input  logic                             cmdModEn,
      
      output logic                             tick,
      output logic signed [ DATA_WDT - 1 : 0 ] adcDataL,
      output logic signed [ DATA_WDT - 1 : 0 ] adcDataR, 
      input  logic signed [ DATA_WDT - 1 : 0 ] genDataL,   // dac
      input  logic signed [ DATA_WDT - 1 : 0 ] genDataR ); // dac
    
   // check parameters
   initial begin
      if ( BCLK_DIVIDER <= 0 || ( BCLK_DIVIDER != 1 && ( BCLK_DIVIDER % 2 ) != 0 ) ) begin // 1, 2, 4, 6, ... or greater even number         
         $error( "Not correct parameter, BCLK_DIVIDER" );
         $stop;
      end
      if ( ( LRCK_DIVIDER % 2 ) != 0 ) begin // must be even         
         $error( "Not correct parameter, LRCK_DIVIDER" );
         $stop;
      end
      if ( INTERFACE_TYPE == "I2S" ) begin
         if ( DATA_WDT * BCLK_DIVIDER * 2 + 2 > LRCK_DIVIDER ) begin // additional offset
            $error( "Not correct parameters, DATA_WDT * BCLK_DIVIDER * 2 + 2 > LRCK_DIVIDER" );
            $stop;
         end 
      end else begin
         if ( DATA_WDT * BCLK_DIVIDER * 2 > LRCK_DIVIDER ) begin
            $error( "Not correct parameters, DATA_WDT * BCLK_DIVIDER * 2 > LRCK_DIVIDER" );
            $stop;
         end
      end
   end
   
   // audMclk
   assign audMclk = ( cmdModEn & ~reset ) ? clk : 1'b0;
   
   // audBclk
   logic bclk;
   logic bclkFalling; // reference comb logic, falling edge of bclk
   generate
      if ( BCLK_DIVIDER == 1 ) begin // divider = 1
      
         assign bclk        = ( cmdModEn & ~reset ) ? ~clk : 1'b0; // inverse audMclk
         assign bclkFalling = ( cmdModEn & ~reset ) ? 1'b1 : 1'b0;
         
      end else begin // divider > 1
      
         logic [ $clog2( BCLK_DIVIDER ) - 1 : 0 ] cntBclk;
      
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin
               bclk    <= 1'b0;
               cntBclk <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( cntBclk == BCLK_DIVIDER - 1 ) 
                     cntBclk <= '0;                     
                  else
                     cntBclk <= cntBclk + 1'd1;
                  
                  if ( cntBclk == 0 )
                     bclk <= 1'b1;
                  if ( cntBclk == BCLK_DIVIDER / 2 )
                     bclk <= 1'b0;
               end else begin
                  bclk    <= 1'b0;
                  cntBclk <= '0;
               end
            end
         assign bclkFalling = ( cntBclk == BCLK_DIVIDER / 2 ) ? 1'b1 : 1'b0;
         
      end
   endgenerate
   assign audBclk = bclk;
   
   // audLrck
   logic           lrck;
   logic [ $clog2( LRCK_DIVIDER / BCLK_DIVIDER ) - 1 : 0 ] cntLrck;   
   localparam logic LEFT_CHANNEL_LVL = ( INTERFACE_TYPE == "I2S" ) ? 1'b0 : 1'b1;   // invert for I2S
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         lrck    <= 1'b0;
         cntLrck <= '0;
      end else begin         
         if ( cmdModEn ) begin
            if ( bclkFalling ) begin
               if ( cntLrck == LRCK_DIVIDER / BCLK_DIVIDER - 1 )
                  cntLrck <= '0;
               else
                  cntLrck <= cntLrck + 1'd1;
                  
               if ( cntLrck == 0 ) // left channel
                  lrck <= LEFT_CHANNEL_LVL;
               if ( cntLrck == LRCK_DIVIDER / BCLK_DIVIDER / 2 ) // right channel
                  lrck <= ~LEFT_CHANNEL_LVL;
            end
         end else begin
            lrck    <= 1'b0;
            cntLrck <= '0;
         end
      end
   assign audDacLrck = lrck;
   assign audAdcLrck = lrck;
   
   // tick
   always_ff @( posedge clk, posedge reset )
      if ( reset )
         tick <= 1'b0;
      else
         if ( cmdModEn )
            if ( bclkFalling && cntLrck == 0 )
               tick <= 1'b1;
            else
               tick <= 1'b0;            
         else
            tick <= 1'b0;      
   
   // dacData
   logic [ DATA_WDT - 1 : 0 ] dacShiftL;
   logic [ DATA_WDT - 1 : 0 ] dacShiftR;
   
   generate
      if ( INTERFACE_TYPE == "LEFT-JUSTIFIED" || ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" && LRCK_DIVIDER / BCLK_DIVIDER / 2 == DATA_WDT ) ) // same behaviour
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin
               audDacData <= 1'b0;
               dacShiftL  <= '0;
               dacShiftR  <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( bclkFalling ) begin
                     if ( cntLrck == 0 ) begin
                        audDacData <= genDataL[ DATA_WDT - 1 ];   // first bit
                        dacShiftL  <= { genDataL[ DATA_WDT - 2 : 0 ], 1'b0 };
                        dacShiftR  <= genDataR;
                     end               
        
                     if ( cntLrck >= 1 && cntLrck <= DATA_WDT - 1 ) begin
                        audDacData                    <= dacShiftL[ DATA_WDT - 1 ];
                        dacShiftL[ DATA_WDT - 1 : 0 ] <= { dacShiftL[ DATA_WDT - 2 : 0 ], 1'b0 };
                     end
                     
                     if ( cntLrck == DATA_WDT )
                        audDacData <= 1'b0;
                        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER / 2 && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT - 1 ) begin
                        audDacData                    <= dacShiftR[ DATA_WDT - 1 ];
                        dacShiftR[ DATA_WDT - 1 : 0 ] <= { dacShiftR[ DATA_WDT - 2 : 0 ], 1'b0 };
                     end   
                     
                     if ( cntLrck == LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT ) // dont need truncate max value to zero
                        audDacData <= 1'b0;
                        
                  end
               end else begin
                  audDacData <= 1'b0;
                  dacShiftL  <= '0;
                  dacShiftR  <= '0;            
               end
            end
      else if ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" )
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin
               audDacData <= 1'b0;
               dacShiftL  <= '0;
               dacShiftR  <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( bclkFalling ) begin
                     if ( cntLrck == 0 ) begin
                        audDacData <= 1'b0;
                        dacShiftL  <= genDataL;
                        dacShiftR  <= genDataR;
                     end               
        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER / 2 - 1 ) begin
                        audDacData                    <= dacShiftL[ DATA_WDT - 1 ];
                        dacShiftL[ DATA_WDT - 1 : 0 ] <= { dacShiftL[ DATA_WDT - 2 : 0 ], 1'b0 };
                     end
                     
                     if ( cntLrck == LRCK_DIVIDER / BCLK_DIVIDER / 2 )
                        audDacData <= 1'b0;
                        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER - DATA_WDT && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER - 1 ) begin
                        audDacData                    <= dacShiftR[ DATA_WDT - 1 ];
                        dacShiftR[ DATA_WDT - 1 : 0 ] <= { dacShiftR[ DATA_WDT - 2 : 0 ], 1'b0 };
                     end   
                        
                  end
               end else begin
                  audDacData <= 1'b0;
                  dacShiftL  <= '0;
                  dacShiftR  <= '0;            
               end
            end
      else if ( INTERFACE_TYPE == "I2S" )
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin
               audDacData <= 1'b0;
               dacShiftL  <= '0;
               dacShiftR  <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( bclkFalling ) begin
                     if ( cntLrck == 0 ) begin
                        audDacData <= 1'b0;
                        dacShiftL  <= genDataL;
                        dacShiftR  <= genDataR;
                     end               
        
                     if ( cntLrck >= 1 && cntLrck <= DATA_WDT ) begin
                        audDacData                    <= dacShiftL[ DATA_WDT - 1 ];
                        dacShiftL[ DATA_WDT - 1 : 0 ] <= { dacShiftL[ DATA_WDT - 2 : 0 ], 1'b0 };
                     end
                     
                     if ( cntLrck == DATA_WDT + 1 )
                        audDacData <= 1'b0;
                        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER / 2 + 1 && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT ) begin
                        audDacData                    <= dacShiftR[ DATA_WDT - 1 ];
                        dacShiftR[ DATA_WDT - 1 : 0 ] <= { dacShiftR[ DATA_WDT - 2 : 0 ], 1'b0 };
                     end   
                     
                     if ( cntLrck == LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT + 1 ) // dont need truncate max value to zero
                        audDacData <= 1'b0;
                        
                  end
               end else begin
                  audDacData <= 1'b0;
                  dacShiftL  <= '0;
                  dacShiftR  <= '0;            
               end
            end
      else
         initial
            $error( "Not correct parameter, INTERFACE_TYPE" );
   endgenerate
   
   // adcData
   localparam logic [ $clog2( LRCK_DIVIDER / BCLK_DIVIDER ) - 1 : 0 ] LIMITER = // case when need truncate max value to zero
      ( $clog2( LRCK_DIVIDER / BCLK_DIVIDER ) )'( LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT );
   
   logic [ DATA_WDT - 1 : 0 ] adcShiftL;
   logic [ DATA_WDT - 2 : 0 ] adcShiftR;
   
   generate
      if ( INTERFACE_TYPE == "LEFT-JUSTIFIED" || ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" && LRCK_DIVIDER / BCLK_DIVIDER / 2 == DATA_WDT ) )
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin         
               adcDataL  <= '0;
               adcDataR  <= '0;
               adcShiftL <= '0;
               adcShiftR <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( bclkFalling ) begin
                     if ( cntLrck >= 1 && cntLrck <= DATA_WDT )               
                        adcShiftL[ DATA_WDT - 1 : 0 ] <= { adcShiftL[ DATA_WDT - 2 : 0 ], audAdcData };
                        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER / 2 + 1 && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT - 1 )
                        adcShiftR[ DATA_WDT - 2 : 0 ] <= { adcShiftR[ DATA_WDT - 3 : 0 ], audAdcData };
                        
                     if ( cntLrck == LIMITER ) begin
                        adcDataL <= adcShiftL;
                        adcDataR <= { adcShiftR, audAdcData };
                     end
                  end
               end else begin
                  adcDataL  <= '0;
                  adcDataR  <= '0;
                  adcShiftL <= '0;
                  adcShiftR <= '0;
               end
            end
      else if ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" )
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin         
               adcDataL  <= '0;
               adcDataR  <= '0;
               adcShiftL <= '0;
               adcShiftR <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( bclkFalling ) begin
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT + 1 && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER / 2 )               
                        adcShiftL[ DATA_WDT - 1 : 0 ] <= { adcShiftL[ DATA_WDT - 2 : 0 ], audAdcData };
                        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER - DATA_WDT + 1 && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER - 1 )
                        adcShiftR[ DATA_WDT - 2 : 0 ] <= { adcShiftR[ DATA_WDT - 3 : 0 ], audAdcData };
                        
                     if ( cntLrck == 0 ) begin
                        adcDataL <= adcShiftL;
                        adcDataR <= { adcShiftR, audAdcData };
                     end
                  end
               end else begin
                  adcDataL  <= '0;
                  adcDataR  <= '0;
                  adcShiftL <= '0;
                  adcShiftR <= '0;
               end
            end
      else if ( INTERFACE_TYPE == "I2S" )
         always_ff @( posedge clk, posedge reset )
            if ( reset ) begin         
               adcDataL  <= '0;
               adcDataR  <= '0;
               adcShiftL <= '0;
               adcShiftR <= '0;
            end else begin
               if ( cmdModEn ) begin
                  if ( bclkFalling ) begin
                     if ( cntLrck >= 2 && cntLrck <= DATA_WDT + 1 )               
                        adcShiftL[ DATA_WDT - 1 : 0 ] <= { adcShiftL[ DATA_WDT - 2 : 0 ], audAdcData };
                        
                     if ( cntLrck >= LRCK_DIVIDER / BCLK_DIVIDER / 2 + 2 && cntLrck <= LRCK_DIVIDER / BCLK_DIVIDER / 2 + DATA_WDT )
                        adcShiftR[ DATA_WDT - 2 : 0 ] <= { adcShiftR[ DATA_WDT - 3 : 0 ], audAdcData };
                        
                     if ( cntLrck == LIMITER + 1 ) begin
                        adcDataL <= adcShiftL;
                        adcDataR <= { adcShiftR, audAdcData };
                     end
                  end
               end else begin // ~cmdModEn
                  adcDataL  <= '0;
                  adcDataR  <= '0;
                  adcShiftL <= '0;
                  adcShiftR <= '0;
               end
            end
      else
         initial
            $error( "Not correct parameter, INTERFACE_TYPE" );
   endgenerate
      
endmodule   