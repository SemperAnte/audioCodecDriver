//--------------------------------------------------------------------------------
// File Name:     audioCodec.h
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    21.08.2016 - created
//--------------------------------------------------------------------------------
// NIOS example
// initialization audio codec SSM2603 on SoCKit board via I2C
//--------------------------------------------------------------------------------
#include <io.h>
#include <alt_types.h>
#include <stdio.h>
#include <unistd.h>

// fully initialization ssm2603 via I2C
alt_u8 ssm2603I2cInit( alt_u32 baseAdr,      // base module address
                       alt_u8  devAdr,       // device address
                       alt_u8  infoLevel);   // info level ( 0, 1 - additional debug info )

// write data to ssm2603 via I2C
alt_u8 ssm2603I2cWrite( alt_u32 baseAdr,     // base module address
                        alt_u8  devAdr,      // device address
                        alt_u8  regAdr,      // register address
                        alt_u16 regData );   // register data, 9 bits

// read data from ssm2603 via I2C
alt_u8 ssm2603I2cRead( alt_u32  baseAdr,     // base module address
                       alt_u8   devAdr,      // device address
                       alt_u8   regAdr,      // register address
                       alt_u16* regData );   // read data here, 9 bits

// wait for interrupt bit after end of transfer
alt_u8 ssm2603I2cWaitIrq( alt_u32 baseAdr ); // base module address
