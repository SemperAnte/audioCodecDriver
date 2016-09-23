//--------------------------------------------------------------------------------
// File Name:     i2cControl.sv
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    16.07.2016 - created
//--------------------------------------------------------------------------------
// i2c master fsm control
//--------------------------------------------------------------------------------
module i2cControl             
    ( input  logic           clk,
      input  logic           reset,       // async reset
      
      // i2c control command
      input  logic           cmdBegin,    // forced start transfer
      input  logic           cmdClear,    // forced clear transfer     
      input  logic           cmdBitStart, // 0 - no start bit      1 - (rep) start bit
      input  logic           cmdBitWr,    // 0 - read byte         1 - write byte 
      input  logic           cmdBitAck,   // 0 - no ack by master  1 - ack by master
      input  logic           cmdBitStop,  // 0 - no stop bit       1 - stop bit
      input  logic [ 7 : 0 ] cmdByteWr,   // write data
      
      output logic           cmdRdy,      // finish transfer
      output logic [ 7 : 0 ] cmdByteRd,   // read data
      output logic [ 1 : 0 ] cmdErr,      // error transfer
      output logic           cmdBusy,     // transfer in progress
      output logic           cmdWait,     // transfer in waiting
      
      // reference tick
      input  logic          tickX4,
      
      // i2c outputs control
      output logic          sdatOut,
      output logic          sclkOut,      
      // i2c filtered inputs, comb logic
      input  logic          sdatFlt,
      input  logic          sclkFlt ); 
      
   logic sdatEn, sclkEn;
   assign sdatOut = sdatEn;
   assign sclkOut = sclkEn;
   
   // check equality of specified and real values sdat / sclk
   logic sdatChk, sclkChk; // 1 - if needed check
   logic eql;              // check equality
   
   always_ff @( posedge clk )
      eql <= ( ~sdatChk | ( sdatFlt == sdatEn  ) ) & ( ~sclkChk | ( sclkFlt == sclkEn  ) ); 
      
   // watch timer, error through WATCH_MAX ticks of tickX4, when i2c lines is in deadlock
   localparam int WATCH_MAX = 10 * 4 * 10; // 10 bits * 4 ticks * 10 ( tens time longer delay)
   localparam int WATCH_WDT = $clog2( WATCH_MAX );
   logic                       watchAlarm; // 1 when time limit exceeded
   logic [ WATCH_WDT - 1 : 0 ] watchCnt;   // watch timer counter

   logic           bitWait;           // = cmdWait, transfer in waiting
   logic           bitBusy;           // = cmdBusy, transfer in progress
   logic [ 3 : 0 ] bitCnt;            // count bit's number ( 0 - 8 ), 8 bits + ack
   logic [ 8 : 0 ] shiftWr, shiftRd ; // write / read shift registers, 8 bits + ack
   
   // sdat, sclk fsm control
   enum int unsigned { IDLE,
                       START_A, START_B, START_C, START_D, START_E,
                       DATA_A,  DATA_B,  DATA_C,  DATA_D,
                       STOP_A,  STOP_B,  STOP_C,  STOP_D,  STOP_E } state;
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         sdatEn  <= 1'b1;
         sclkEn  <= 1'b1;
         sdatChk <= 1'b0;
         sclkChk <= 1'b0;
         state   <= IDLE;
      end else begin
         if ( cmdClear ) begin
            sdatEn  <= 1'b1;
            sclkEn  <= 1'b1;
            sdatChk <= 1'b0;
            sclkChk <= 1'b0;
            state   <= IDLE;
         end else if ( cmdBegin ) begin
            sdatChk <= 1'b0;
            sclkChk <= 1'b0;
            if ( cmdBitStart & bitWait )
               state <= START_A; // rep start
            else if ( cmdBitStart & ~bitWait )
               state <= START_B; // start
            else
               state <= DATA_A;  // write/read byte without start
         end else if ( watchAlarm ) begin // watch timer, lower priority than cmdBegin
            sdatEn  <= 1'b1;
            sclkEn  <= 1'b1;
            sdatChk <= 1'b0;
            sclkChk <= 1'b0;
            state   <= IDLE;
         end else if ( tickX4 & eql ) begin
            case ( state )
               IDLE : begin
                  sdatEn  <= sdatEn;
                  sclkEn  <= sclkEn;
                  sdatChk <= 1'b0;
                  sclkChk <= 1'b0;
                  state   <= IDLE;
               end
               START_A : begin
                  sdatEn  <= 1'b1;
                  sclkEn  <= 1'b0;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= START_B;
               end
               START_B : begin
                  sdatEn  <= 1'b1;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= START_C;
               end
               START_C : begin
                  sdatEn  <= 1'b0;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= START_D;
               end
               START_D : begin
                  sdatEn  <= 1'b0;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= START_E;
               end
               START_E : begin
                  sdatEn  <= 1'b0;
                  sclkEn  <= 1'b0;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= DATA_A;
               end
               DATA_A : begin
                  sdatEn  <= shiftWr[ 8 ];
                  sclkEn  <= 1'b0;
                  if ( bitCnt == 4'd8 ) // current bit - ack
                     sdatChk <= cmdBitAck;
                  else
                     sdatChk <= cmdBitWr;
                  sclkChk <= 1'b1;
                  state   <= DATA_B;
               end
               DATA_B : begin
                  sdatEn  <= shiftWr[ 8 ];
                  sclkEn  <= 1'b1;
                  if ( bitCnt == 4'd8 )
                     sdatChk <= cmdBitAck;
                  else
                     sdatChk <= cmdBitWr;
                  sclkChk <= 1'b1;
                  state   <= DATA_C;
               end
               DATA_C : begin
                  sdatEn  <= shiftWr[ 8 ];
                  sclkEn  <= 1'b1;
                  if ( bitCnt == 4'd8 )
                     sdatChk <= cmdBitAck;
                  else
                     sdatChk <= cmdBitWr;
                  sclkChk <= 1'b1;
                  state   <= DATA_D;
               end
               DATA_D : begin
                  sdatEn  <= shiftWr[ 8 ];
                  sclkEn  <= 1'b0;
                  sdatChk <= 1'b0;
                  if ( bitCnt == 4'd8 )
                     if ( cmdBitStop ) begin
                        sclkChk <= 1'b1;
                        state   <= STOP_A;
                     end else begin
                        sclkChk <= 1'b0;
                        state   <= IDLE;
                     end
                  else begin
                     sclkChk <= 1'b1;
                     state   <= DATA_A;
                  end
               end
               STOP_A : begin
                  sdatEn  <= 1'b0;
                  sclkEn  <= 1'b0;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= STOP_B;                  
               end
               STOP_B : begin
                  sdatEn  <= 1'b0;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= STOP_C;   
               end
               STOP_C : begin
                  sdatEn  <= 1'b0;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= STOP_D;   
               end
               STOP_D : begin
                  sdatEn  <= 1'b1;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b1;
                  sclkChk <= 1'b1;
                  state   <= STOP_E;   
               end
               STOP_E : begin
                  sdatEn  <= 1'b1;
                  sclkEn  <= 1'b1;
                  sdatChk <= 1'b0;
                  sclkChk <= 1'b0;
                  state   <= IDLE;   
               end
            endcase
         end            
      end
   
   // watch timer   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         watchAlarm <= 1'b0;
         watchCnt   <= '0;
      end else begin
         watchAlarm <= 1'b0;  // default
         if ( cmdClear | cmdBegin | ~bitBusy )
            watchCnt <= ( WATCH_WDT )'( WATCH_MAX - 1 ); // set counter
         else if ( bitBusy & tickX4 ) //begin
            if ( ~|watchCnt ) begin
               watchCnt   <= ( WATCH_WDT )'( WATCH_MAX - 1 ); 
               watchAlarm <= 1'b1;
            end else
               watchCnt   <= watchCnt - 1'd1;                   
      end
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         cmdRdy    <= 1'b0;
         cmdByteRd <= 8'b0;
         cmdErr    <= 2'b00;
         bitBusy   <= 1'b0;
         bitWait   <= 1'b0;
      end else begin
         cmdRdy <= 1'b0;   // default
         if ( cmdClear ) begin // clear transfer - high priority
            cmdRdy    <= 1'b0;
            cmdByteRd <= 8'b0;
            cmdErr    <= 2'b00;
            bitBusy   <= 1'b0;
            bitWait   <= 1'b0;
         end else if ( cmdBegin ) begin // start transfer - busy bit
            bitBusy <= 1'b1;
         end else if ( watchAlarm ) begin // time limit exceeded
            cmdRdy    <= 1'b1;
            cmdByteRd <= 8'b0;
            cmdErr    <= 2'b10; // error
            bitBusy   <= 1'b0;
            bitWait   <= 1'b1;
         end else if ( tickX4 & eql ) begin
            if ( state == DATA_D && bitCnt == 4'd8 && ~cmdBitStop ) begin // end transfer without stop bit (waiting)
               cmdRdy <= 1'b1;
               if ( ~cmdBitWr ) // if read operation
                  cmdByteRd <= shiftRd[ 8 : 1 ];
               else
                  cmdByteRd <= 8'b0;
               if ( cmdBitWr )
                  cmdErr <= { 1'b0, shiftRd[ 0 ] };  
               else
                  cmdErr <= 2'b00;
               bitBusy <= 1'b0;
               bitWait <= 1'b1; // no stop bit, transfer in waiting
            end
            if ( state == STOP_E ) begin // end transfer with stop bit
               cmdRdy <= 1'b1;
               if ( ~cmdBitWr )
                  cmdByteRd <= shiftRd[ 8 : 1 ];
               else
                  cmdByteRd <= 8'b0;
               if ( cmdBitWr )
                  cmdErr <= { 1'b0, shiftRd[ 0 ] };  
               else
                  cmdErr <= 2'b00;
               bitBusy <= 1'b0;
               bitWait <= 1'b0;
            end
         end
      end
   
   // shift register control, bit counter
   always_ff @( posedge clk )
      if ( cmdBegin ) begin // start transfer
         bitCnt <= 4'b0;
         if ( cmdBitWr )
            shiftWr <= { cmdByteWr, ~cmdBitAck };
         else // if read - fill all by '1
            shiftWr <= { 8'hff, ~cmdBitAck };
      end else if ( tickX4 & eql ) begin 
         if ( state == DATA_C ) begin // middle of positive half-period sclk
            shiftRd <= { shiftRd[ 7 : 0 ], sdatFlt };
         end
         if ( state == DATA_D ) begin // falling edge of sclk
            shiftWr <= { shiftWr[ 7 : 0 ], 1'b0 };
            bitCnt  <= bitCnt + 4'd1;
         end
      end
   
   assign cmdBusy = bitBusy;
   assign cmdWait = bitWait;  
      
endmodule