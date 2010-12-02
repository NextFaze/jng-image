//
//  JNGImagePNG.m
//  jng-image
//
//  Created by Andrew on 2/12/10.
//  Copyright 2010 2moro mobile. All rights reserved.
//

#import "JNGImagePNG.h"

#define PNGImageSignature {0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a}

@implementation JNGImagePNG

@synthesize chunks, colorType;
@synthesize width, height, bitDepth, compressionMethod, filterMethod, interlaceMethod;

- (id)init {
	if(self = [super init]) {
		chunks = [[NSMutableArray alloc] init];
		colorType = JNGImagePNGColorTypeRGB;
		width = height = 0;
		bitDepth = 0;
		compressionMethod = filterMethod = interlaceMethod = 0;
	}
	return self;
}

- (void)dealloc {
	[chunks release];
	[super dealloc];
}

#pragma mark -

- (void)addChunk:(JNGImageChunk *)chunk {
	[chunks addObject:chunk];
}

// return IHDR chunk for this image
- (JNGImageChunk *)ihdr {
	NSMutableData *ihdrData = [NSMutableData data];
	unsigned long widthNet  = NSSwapLong((unsigned long)width);
	unsigned long heightNet = NSSwapLong((unsigned long)height);
	unsigned char hdrdat[5];
	
	snprintf((char *)hdrdat, 5, "%c%c%c%c%c", bitDepth, colorType, compressionMethod, filterMethod, interlaceMethod);
	[ihdrData appendBytes:&widthNet length:4];
	[ihdrData appendBytes:&heightNet length:4];
	[ihdrData appendBytes:hdrdat length:5];
	
	JNGImageChunk *ihdr = [[JNGImageChunk alloc] init];
	ihdr.name = @"IHDR";
	ihdr.data = ihdrData;
	ihdr.crc = [ihdr calculateCrc];

	return [ihdr autorelease];
}

// return png image representation
- (NSData *)data {
	NSMutableData *data = [NSMutableData data];
	NSMutableArray *chunkList = [NSMutableArray arrayWithArray:chunks];
	unsigned char signature[8] = PNGImageSignature;
	
	[data appendBytes:signature length:8];
	
	// prepend header chunk
	[chunkList insertObject:[self ihdr] atIndex:0];
	
	// append chunks
	for(JNGImageChunk *chunk in chunkList) {
		NSData *cdat = [chunk data];
		unsigned long len = NSSwapLong((unsigned long)[cdat length]);
		unsigned long crc = NSSwapLong(chunk.crc);
		
		[data appendBytes:&len length:4];
		[data appendBytes:[chunk.name UTF8String] length:4];
		[data appendData:cdat];
		[data appendBytes:&crc length:4];
	}
	
	return data;
}

@end
