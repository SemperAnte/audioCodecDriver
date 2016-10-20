`timescale 1 ns / 100 ps

module tb_acDriver ();

   localparam realtime T_MST = 8;
   localparam realtime T_AC  = 20;   
   
   localparam string INTERFACE_TYPE = "LEFT-JUSTIFIED";   // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
   localparam int    DATA_WDT       = 32;                 // width of adc/dac data, 16, 20, 24, 32
   localparam int    BCLK_DIVIDER   = 2;                  // relative to mclk, 1, 2, 4, 6, ... or greater even number
   localparam int    LRCK_DIVIDER   = 128;                // relative to mclk, must be even
   
   logic                             mstClk;
   logic                             mstReset;
   // audio part
   logic                             acClk;      
   logic                             acReset;
   // audio codec control interface for external chip
   logic                             audMclk;
   logic                             audBclk;
   logic                             audAdcLrck;
   logic                             audAdcData;
   logic                             audDacLrck;
   logic                             audDacData;      
   logic                             audMute;
   // avalon ST source, adc data ( sync with mstClk 
   logic                             adcAsoValid;   
   logic    [ 2 * DATA_WDT - 1 : 0 ] adcAsoData;   
   // avalon ST sink, dac data ( sync with mstClk )   
   logic                             dacAsiRdy;
   logic    [ 2 * DATA_WDT - 1 : 0 ] dacAsiData;   
   // avalon MM slave, audio part
   logic                  [ 1  : 0 ] avsAdr     = 2'b0;
   logic                             avsWr      = 1'b0;
   logic                  [ 15 : 0 ] avsWrData  = 16'b0;
   logic                             avsRd      = 1'b0;
   logic                  [ 15 : 0 ] avsRdData;

   acDriver
     #( .CLK_MASTER_FRQ ( 50_000_000     ),
        .SCLK_I2C_FRQ   ( 500_000        ),
        .INTERFACE_TYPE ( INTERFACE_TYPE ),
        .DATA_WDT       ( DATA_WDT       ),
        .BCLK_DIVIDER   ( BCLK_DIVIDER   ),
        .LRCK_DIVIDER   ( LRCK_DIVIDER   ) )
   uut
      ( .mstClk       ( mstClk      ),
        .mstReset     ( mstReset    ),
        .acClk        ( acClk       ),
        .acReset      ( acReset     ),
        .audMclk      ( audMclk     ),
        .audBclk      ( audBclk     ),
        .audAdcLrck   ( audAdcLrck  ),
        .audAdcData   ( audAdcData  ),
        .audDacLrck   ( audDacLrck  ),
        .audDacData   ( audDacData  ),
        .audMute      ( audMute     ),
        .adcAsoValid  ( adcAsoValid ),
        .adcAsoData   ( adcAsoData  ),
        .dacAsiRdy    ( dacAsiRdy   ),
        .dacAsiData   ( dacAsiData  ), 
        .acAvsAdr     ( avsAdr      ),
        .acAvsWr      ( avsWr       ),
        .acAvsWrData  ( avsWrData   ),
        .acAvsRd      ( avsRd       ),
        .acAvsRdData  ( avsRdData   ) );  
        
   logic signed [ DATA_WDT - 1 : 0 ] exAdcDataL = '0;
   logic signed [ DATA_WDT - 1 : 0 ] exAdcDataR = '0;
   logic signed [ DATA_WDT - 1 : 0 ] exDacDataL;        
   logic signed [ DATA_WDT - 1 : 0 ] exDacDataR;        

   exInterface
     #( .INTERFACE_TYPE ( INTERFACE_TYPE ),
        .DATA_WDT       ( DATA_WDT       ),
        .BCLK_DIVIDER   ( BCLK_DIVIDER   ),
        .LRCK_DIVIDER   ( LRCK_DIVIDER   ) )
   exInterfaceInst
      ( .clk      ( acClk        ),    
        .reset    ( acReset      ), 
        .audBclk    ( audBclk    ),
        .audAdcLrck ( audAdcLrck ),
        .audAdcData ( audAdcData ),
        .audDacLrck ( audDacLrck ),
        .audDacData ( audDacData ),      
        .exAdcDataL ( exAdcDataL ),
        .exAdcDataR ( exAdcDataR ),
        .exDacDataL ( exDacDataL ),
        .exDacDataR ( exDacDataR ) );
        
   always begin   
      acClk = 1'b1;
      #( T_AC / 2 );
      acClk = 1'b0;
      #( T_AC / 2 );
   end
   
   initial begin      
      acReset = 1'b1;
      # ( 10 * T_AC + T_AC / 2 );
      acReset = 1'b0;
   end
   
   always begin   
      mstClk = 1'b1;
      #( T_MST / 2 );
      mstClk = 1'b0;
      #( T_MST / 2 );
   end
   
   initial begin      
      mstReset = 1'b1;
      # ( 10 * T_MST + T_MST / 2 );
      mstReset = 1'b0;
   end
   
   always @( posedge dacAsiRdy ) begin
      dacAsiData[ 2 * DATA_WDT - 1 : DATA_WDT ] = $urandom();
      dacAsiData[ DATA_WDT - 1 : 0 ] = $urandom();
   end
   
    // avalon write task
   task avmWrite( input logic [ 1  : 0 ] adr,
                  input logic [ 15 : 0 ] wrData );
      avsAdr    = adr;
      avsWr     = 1'b1;      
      avsWrData = wrData;
      # ( T_AC );
      avsAdr    = 2'd0;
      avsWr     = 1'b0;      
      avsWrData = 16'b0;      
   endtask
   
   // avalon read task
   task avmRead( input  logic [ 1  : 0 ] adr,
                 output logic [ 15 : 0 ] rdData );
      avsAdr = adr;
      avsRd  = 1'b1;
      # ( T_AC );
      avsAdr = 2'd0;
      avsRd  = 1'b0;
      rdData    = avsRdData;      
   endtask
   
   initial begin
      logic [ 15 : 0 ] tbWordWr, tbWordRd;
      
      @ ( negedge acReset );
      @ ( negedge acClk );
      # ( 10 * T_AC );
      
      // AVALON INTERFACE TEST
      // soft acReset
      avmWrite( 2'd0, 16'h0001 );
      # ( T_AC );
      // enable + hardawre mute
      tbWordWr = 16'hC000;
      avmWrite( 2'd0, tbWordWr );
      if ( audMute ) // must be 1
         $warning( "tb : wrong audMute bit : %b", audMute ); 
      # ( T_AC );
      avmRead( 2'd0, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      // address 1
      tbWordWr = 16'h0032;
      avmWrite( 2'd1, tbWordWr );
      # ( 3 * T_AC );
      avmRead( 2'd1, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      if ( uut.acCoreInst.cmdDacSrcL != 4'b0010 )
         $warning( "tb : wrong cmdDacSrcL : %b", uut.acCoreInst.cmdDacSrcL );
      if ( uut.acCoreInst.cmdDacSrcR != 4'b0100 )
         $warning( "tb : wrong cmdDacSrcL : %b", uut.acCoreInst.cmdDacSrcR );
      // address 1
      tbWordWr = 16'h0014;
      avmWrite( 2'd1, tbWordWr );
      # ( 2 * T_AC );
      avmRead( 2'd1, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      if ( uut.acCoreInst.cmdDacSrcL != 4'b1000 )
         $warning( "tb : wrong cmdDacSrcL : %b", uut.acCoreInst.cmdDacSrcL );
      if ( uut.acCoreInst.cmdDacSrcR != 4'b0001 )
         $warning( "tb : wrong cmdDacSrcL : %b", uut.acCoreInst.cmdDacSrcR );
      // address 1
      tbWordWr = 16'h0020;
      avmWrite( 2'd1, tbWordWr );
      # ( 1 * T_AC );
      avmRead( 2'd1, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      if ( uut.acCoreInst.cmdDacSrcL != 4'b0000 )
         $warning( "tb : wrong cmdDacSrcL : %b", uut.acCoreInst.cmdDacSrcL );
      if ( uut.acCoreInst.cmdDacSrcR != 4'b0010 )
         $warning( "tb : wrong cmdDacSrcL : %b", uut.acCoreInst.cmdDacSrcR );
      // address 2
      tbWordWr = $urandom();
      avmWrite( 2'd2, tbWordWr );
      # ( 2 * T_AC );
      avmRead( 2'd2, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      if ( uut.acCoreInst.cmdFrqL != tbWordWr )
         $warning( "tb : wrong cmdFrqL : %b", uut.acCoreInst.cmdFrqL );
      // address 3
      tbWordWr = $urandom();
      avmWrite( 2'd3, tbWordWr );
      # ( 1 * T_AC );
      avmRead( 2'd3, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      if ( uut.acCoreInst.cmdFrqR != tbWordWr )
         $warning( "tb : wrong cmdFrqR : %b", uut.acCoreInst.cmdFrqR );
      // address 2
      tbWordWr = $urandom();
      avmWrite( 2'd2, tbWordWr );
      # ( 2 * T_AC );
      avmRead( 2'd2, tbWordRd );
      if ( tbWordRd != tbWordWr )
         $warning( "tb : read / write words arent equal : %b / %b", tbWordRd, tbWordWr );
      if ( uut.acCoreInst.cmdFrqL != tbWordWr )
         $warning( "tb : wrong cmdFrqL : %b", uut.acCoreInst.cmdFrqL );
      # ( 100 * T_AC );
      
      // AUDIO INTERFACE TEST
      avmWrite( 2'd0, 16'h0001 );
      avmWrite( 2'd0, 16'h8000 );
      avmWrite( 2'd1, 16'h0043 ); // L - saw, R - sine
      avmWrite( 2'd2, 16'h3497 );
      avmWrite( 2'd3, 16'h0497 );   
   end   

endmodule