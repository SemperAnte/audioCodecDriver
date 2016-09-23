//--------------------------------------------------------------------------------
// File Name:     main.c
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    21.08.2016 - created
//--------------------------------------------------------------------------------
// NIOS example
// initialization audio codec SSM2603 on SoCKit board via I2C
//--------------------------------------------------------------------------------
#include <system.h>
#include <sys/alt_timestamp.h>
#include "audioCodec.h"

#include <io.h>

int main()
{
   alt_u32 time0, time1;

   alt_timestamp_start();
   time0 = alt_timestamp();

   ssm2603I2cInit( ACDRIVER_I2CAVS_BASE, 0x1A, 1 ); // device adr - 0001_1010

   //ssm2603AudioConfig

   time1 = alt_timestamp();
   printf( "ticks spent = %u\n", ( unsigned int ) ( time1 - time0 ) );

   IOWR_16DIRECT( ACDRIVER_ACAVS_BASE, 0, 0x8000 );
   IOWR_16DIRECT( ACDRIVER_ACAVS_BASE, 2, 0x0043 );
   IOWR_16DIRECT( ACDRIVER_ACAVS_BASE, 4, ( alt_u16 ) ( 1000.0 / 96000.0 * 65536.0 ) );
   IOWR_16DIRECT( ACDRIVER_ACAVS_BASE, 6, ( alt_u16 ) ( 2500.0 / 96000.0 * 65536.0 ) );

   alt_u16 a = IORD_16DIRECT( ACDRIVER_ACAVS_BASE, 2 );
   printf( "%x\n", a );
   a = IORD_16DIRECT( ACDRIVER_ACAVS_BASE, 4 );
   printf( "%u\n", a );
   a = IORD_16DIRECT( ACDRIVER_ACAVS_BASE, 6 );
   printf( "%u\n", a );
   return 0;
}
