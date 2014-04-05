//
//  ROM.m
//  MupenLaunch
//
//  Created by Stephen Tierney on 13/04/12.
//  Copyright (c) 2012 Stephen Tierney. All rights reserved.
//
//	This program is free software; you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation; either version 2 of the License, or
//	(at your option) any later version.
//	                                                                      
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//	
//	You should have received a copy of the GNU General Public License
//	along with this program; if not, write to the
//	Free Software Foundation, Inc.,
//	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
//

#import "ROM.h"
#include <stdio.h>
#include <stdlib.h>
#import <Cocoa/Cocoa.h>
#import <CommonCrypto/CommonDigest.h>
#import "md5.h"

@implementation ROM

@synthesize filePath;
@synthesize cic;
@synthesize name;
@synthesize gameCode;
@synthesize CRC1;
@synthesize CRC2;
@synthesize calculatedCRC1;
@synthesize calculatedCRC2;
@synthesize MD5;

/* Supported rom image types. */
enum
{
    Z64IMAGE,
    V64IMAGE,
    N64IMAGE
};


#define ROL(i, b) (((i) << (b)) | ((i) >> (32 - (b))))
#define BYTES2LONG(b) ( (b)[0] << 24 | \
(b)[1] << 16 | \
(b)[2] <<  8 | \
(b)[3] )

#define N64_HEADER_SIZE  0x40
#define N64_BC_SIZE      (0x1000 - N64_HEADER_SIZE)

#define N64_CRC1		0x10
#define N64_CRC2		0x14

#define N64_NAME		0x20
#define N64_CODE		0x3B

#define CHECKSUM_START   0x00001000
#define CHECKSUM_LENGTH  0x00100000
#define CHECKSUM_CIC6102 0xF8CA4DDC
#define CHECKSUM_CIC6103 0xA3886759
#define CHECKSUM_CIC6105 0xDF26F436
#define CHECKSUM_CIC6106 0x1FEA617A

#define Write32(Buffer, Offset, Value)\
Buffer[Offset] = (Value & 0xFF000000) >> 24;\
Buffer[Offset + 1] = (Value & 0x00FF0000) >> 16;\
Buffer[Offset + 2] = (Value & 0x0000FF00) >> 8;\
Buffer[Offset + 3] = (Value & 0x000000FF);\

unsigned int crc_table[256];

void gen_table() {
	unsigned int crc, poly;
	int	i, j;
	
	poly = 0xEDB88320;
	for (i = 0; i < 256; i++) {
		crc = i;
		for (j = 8; j > 0; j--) {
			if (crc & 1) crc = (crc >> 1) ^ poly;
			else crc >>= 1;
		}
		crc_table[i] = crc;
	}
}

unsigned int crc32(unsigned char *data, int len) {
	unsigned int crc = ~0;
	int i;
	
	for (i = 0; i < len; i++) {
		crc = (crc >> 8) ^ crc_table[(crc ^ data[i]) & 0xFF];
	}
	
	return ~crc;
}


int N64GetCIC(unsigned char *data) {
	switch (crc32(&data[N64_HEADER_SIZE], N64_BC_SIZE)) {
		case 0x6170A4A1: return 6101;
		case 0x90BB6CB5: return 6102;
		case 0x0B050EE0: return 6103;
		case 0x98BC2C86: return 6105;
		case 0xACC8580A: return 6106;
	}
	
	return 6105;
}

/* Tests if a file is a valid N64 rom by checking the first 4 bytes. */
static int is_valid_rom(const unsigned char *buffer)
{
    /* Test if rom is a native .z64 image with header 0x80371240. [ABCD] */
    if((buffer[0]==0x80)&&(buffer[1]==0x37)&&(buffer[2]==0x12)&&(buffer[3]==0x40))
        return 1;
    /* Test if rom is a byteswapped .v64 image with header 0x37804012. [BADC] */
    else if((buffer[0]==0x37)&&(buffer[1]==0x80)&&(buffer[2]==0x40)&&(buffer[3]==0x12))
        return 1;
    /* Test if rom is a wordswapped .n64 image with header  0x40123780. [DCBA] */
    else if((buffer[0]==0x40)&&(buffer[1]==0x12)&&(buffer[2]==0x37)&&(buffer[3]==0x80))
        return 1;
    else
        return 0;
}


NSString* getMD5FromFile(NSString *pathToFile) {
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	
    NSData *inputData = [[NSData alloc] initWithContentsOfFile:pathToFile];
    CC_MD5([inputData bytes], (uint)[inputData length], outputData);
	
    NSMutableString *hash = [[NSMutableString alloc] init];
	
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", outputData[i]];
    }
	
    return hash;
}

NSString* getMD5FromData(unsigned char *data, uint size) {
    unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	
    CC_MD5(data, size, outputData);
	
    NSMutableString *hash = [[NSMutableString alloc] init];
	
    for (NSUInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", outputData[i]];
    }
	
    return hash;
}

+(ROM*)romFromURL:(NSURL*) URL
{
	ROM *r = [[ROM alloc] init];
    r.filePath = URL;
    
    FILE *fPtr = fopen([[URL path] UTF8String], "rb");
    fseek(fPtr, 0L, SEEK_END);
    long romlength = ftell(fPtr);
    fseek(fPtr, 0L, SEEK_SET);
    
    unsigned char *ROM_buffer = (unsigned char *) malloc(romlength);
    fread(ROM_buffer, 1, romlength, fPtr);
   
    unsigned char imagetype;
    swap_rom(ROM_buffer, &imagetype, (int)romlength);
    
//    BOOL valid = is_valid_rom(ROM_buffer);
    
    r.MD5 = getMD5FromData(ROM_buffer, romlength);

    unsigned char *headerBuffer;
    headerBuffer = (unsigned char*)malloc((CHECKSUM_START + CHECKSUM_LENGTH));
    fseek(fPtr, 0L, SEEK_SET);
    fread(headerBuffer, 1, (CHECKSUM_START + CHECKSUM_LENGTH), fPtr);
    long header_size = ftell(fPtr);
    swap_rom(headerBuffer, &imagetype, (int)header_size);
    
	r.cic = [NSNumber numberWithInt: N64GetCIC(headerBuffer)];

	r.name = [NSString stringWithFormat:@"%s", &headerBuffer[N64_NAME]];

	r.gameCode = [NSString stringWithFormat:@"%s", &headerBuffer[N64_CODE]];

	r.CRC1 = [NSNumber numberWithUnsignedInt:BYTES2LONG(&headerBuffer[N64_CRC1])];
	r.CRC2 = [NSNumber numberWithUnsignedInt:BYTES2LONG(&headerBuffer[N64_CRC2])];

    fclose(fPtr);
    
	return r;
}

/* If rom is a .v64 or .n64 image, byteswap or wordswap loadlength amount of
 * rom data to native .z64 before forwarding. Makes sure that data extraction
 * and MD5ing routines always deal with a .z64 image.
 */
static void swap_rom(unsigned char* localrom, unsigned char* imagetype, int loadlength)
{
    unsigned char temp;
    int i;
    
    /* Btyeswap if .v64 image. */
    if(localrom[0]==0x37)
    {
        *imagetype = V64IMAGE;
        for (i = 0; i < loadlength; i+=2)
        {
            temp=localrom[i];
            localrom[i]=localrom[i+1];
            localrom[i+1]=temp;
        }
    }
    /* Wordswap if .n64 image. */
    else if(localrom[0]==0x40)
    {
        *imagetype = N64IMAGE;
        for (i = 0; i < loadlength; i+=4)
        {
            temp=localrom[i];
            localrom[i]=localrom[i+3];
            localrom[i+3]=temp;
            temp=localrom[i+1];
            localrom[i+1]=localrom[i+2];
            localrom[i+2]=temp;
        }
    }
    else
        *imagetype = Z64IMAGE;
}

- (BOOL)isValid
{
	// Check that fields are not null
	if (self.filePath == NULL
		|| self.cic == NULL
		|| self.name == NULL
		|| self.gameCode == NULL
		|| self.CRC1 == NULL
		|| self.CRC2 == NULL
		|| self.MD5 == NULL)
		return NO;
	
	return YES;
}

@end
